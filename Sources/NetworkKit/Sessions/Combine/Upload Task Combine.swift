//
//  Upload Task Combine.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 06/11/20.
//

#if canImport(Combine)
import Combine

import Foundation
import PublisherKit

extension URLSession {
    
    /// Returns a publisher that wraps a URL session data task for a given URL.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter url: The URL for which to create a data task.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a data task for the URL.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func uploadTaskCOPublisher(for request: URLRequest, name: String = "", from data: Data?, session: NetworkSession) -> UploadTaskCOPublisher {
        return UploadTaskCOPublisher(name: name, request: request, from: data, session: session)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a data task for the URL request.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func uploadTaskCOPublisher(for request: URLRequest, name: String = "", from file: URL, session: NetworkSession) -> UploadTaskCOPublisher {
        UploadTaskCOPublisher(name: name, request: request, from: file, session: session)
    }
}

extension URLSession {
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public struct UploadTaskCOPublisher: Combine.Publisher {
        
        public typealias Output = (data: Data, response: URLResponse, metrics: URLSessionTaskMetrics?)
        
        public typealias Failure = Error
        
        public let request: URLRequest
        
        public let data: Data?
        
        private let fileUrl: URL?
        
        public let session: NetworkSession
        
        public let name: String
        
        var progressHandler: ((Progress) -> Void)?
        var isWaitingForConnectivity: (() -> Void)?
        var isStarting: (() -> Void)?
        
        public init(name: String = "", request: URLRequest, from data: Data?, session: NetworkSession) {
            self.name = name
            self.request = request
            self.session = session
            self.data = data
            fileUrl = nil
        }
        
        public init(name: String = "", request: URLRequest, from file: URL, session: NetworkSession) {
            self.name = name
            self.request = request
            self.session = session
            data = nil
            fileUrl = file
        }
        
        public func receive<S: Combine.Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            subscriber.receive(subscription: Inner(downstream: subscriber, parent: self))
        }
        
        mutating public func waitForConnectivity(_ isWaitingForConnectivity: @escaping () -> Void) {
            self.isWaitingForConnectivity = isWaitingForConnectivity
        }
        
        mutating public func progress(_ progressHandler: @escaping (Progress) -> Void) {
            self.progressHandler = progressHandler
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension URLSession.UploadTaskCOPublisher {
    
    // MARK: DATA TASK SINK
    private final class Inner<Downstream: Combine.Subscriber>: Combine.Subscription, CustomStringConvertible, CustomPlaygroundDisplayConvertible, CustomReflectable where Output == Downstream.Input, Failure == Downstream.Failure {
        
        private var task: URLSessionDataTask?
        
        private let lock = Lock()
        private var downstream: Downstream?
        private var demand: Combine.Subscribers.Demand = .none
        
        private var parent: URLSession.UploadTaskCOPublisher?
        
        private var cancellable: Combine.AnyCancellable?
        
        init(downstream: Downstream, parent: URLSession.UploadTaskCOPublisher) {
            self.downstream = downstream
            self.parent = parent
        }
        
        func request(_ demand: Combine.Subscribers.Demand) {
            lock.lock()
            guard let parent = parent, task == nil else { lock.unlock(); return }
            
            var task: URLSessionDataTask!
            
            if let url = parent.fileUrl {
                task = parent.session.session.uploadTask(with: parent.request, fromFile: url) { [weak self] in
                    self?.handleResponse(data: $0, response: $1, error: $2, taskIdentifier: task.taskIdentifier)
                }
            } else {
                task = parent.session.session.uploadTask(with: parent.request, from: parent.data) { [weak self] in
                    self?.handleResponse(data: $0, response: $1, error: $2, taskIdentifier: task.taskIdentifier)
                }
            }
            
            self.task = task
            
            self.demand += demand
            
            if let isWaitingForConnectivity = parent.isWaitingForConnectivity {
                cancellable = parent.session.delegate.taskWaitingForConnectivity
                    .receive(on: DispatchQueue.global(qos: .utility))
                    .filter { (taskIdentifiers) in
                        Swift.print(taskIdentifiers, task.taskIdentifier)
                        return taskIdentifiers.contains(task.taskIdentifier)
                    }
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { (_) in
                        isWaitingForConnectivity()
                        parent.session.delegate.taskWaitingForConnectivity.value.remove(task.taskIdentifier)
                    })
            }
            
            lock.unlock()
            
            DispatchQueue.main.async {
                parent.progressHandler?(task.progress)
                parent.isStarting?()
            }
            
            Logger.default.logAPIRequest(request: parent.request, name: parent.name)
            
            task.resume()
        }
        
        private func handleResponse(data: Data?, response: URLResponse?, error: Error?, taskIdentifier: Int) {
            lock.lock()
            guard demand > .none, let downstream = downstream else { lock.unlock(); return }
            let session = parent?.session
            terminate()
            lock.unlock()
            
            let metrics = session?.delegate.taskMetrics.value[taskIdentifier]
            session?.delegate.taskMetrics.value[taskIdentifier] = nil
            
            if let error = error as NSError? {
                var userInfo = error.userInfo
                userInfo[NKTaskMetrics] = metrics
                userInfo[NKTaskResponse] = response
                userInfo[NKTaskData] = data
                let finalError = NSError(domain: error.domain, code: error.code, userInfo: userInfo)
                downstream.receive(completion: .failure(finalError))
            } else if let response = response, let data = data {
                _ = downstream.receive((data, response, metrics))
                downstream.receive(completion: .finished)
            } else {
                
                let finalError = URLError(.unknown, userInfo: [
                    NKTaskMetrics: metrics as Any,
                    NKTaskResponse: response as Any,
                    NKTaskData: data as Any
                ])
                
                downstream.receive(completion: .failure(finalError))
            }
        }
        
        func cancel() {
            lock.lock()
            guard downstream != nil else { lock.unlock(); return }
            let task = self.task
            terminate()
            lock.unlock()
            
            task?.cancel()
        }
        
        private func terminate() {
            downstream = nil
            demand = .none
            parent = nil
            task = nil
            cancellable?.cancel()
            cancellable = nil
        }
        
        var description: String {
            "DataTaskPublisher"
        }
        
        var playgroundDescription: Any {
            description
        }
        
        var customMirror: Mirror {
            let children: [Mirror.Child] = [
                ("task", task as Any),
                ("downstream", downstream as Any),
                ("parent", parent as Any),
                ("demand", demand)
            ]
            
            return Mirror(self, children: children)
        }
    }
}

#endif
