//
//  NetworkSession.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 26/10/20.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class NetworkSession: NKConfiguration {
    
    public static let shared = NetworkSession()
    
    let delegate = NetworkSessionDelegate()
    
    init() {
        super.init(configuration: NKConfiguration.defaultConfiguration, deleagte: delegate, delegateQueue: nil)
    }
    
    typealias NKAnyNetworkTaskOutput = (metrics: URLSessionTaskMetrics, data: Data, response: URLResponse)
    typealias NKAnyNetworkTask = AnyPublisher<NKAnyNetworkTaskOutput, Error>
    
    // MARK: DATA TASK
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    @inlinable open func dataTaskCombine(_ request: @autoclosure () -> NKRequest) -> NKDataTaskCombine {
        dataTaskCombine(request)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func dataTaskCombine(_ requestBlock: () -> NKRequest) -> NKDataTaskCombine {
        let nkRequest = requestBlock()
        guard let request = nkRequest.getRequest() else {
            preconditionFailure("Invalid Request Created for connection: \(nkRequest.connection)")
        }
        
        return URLSession.dataTaskCOPublisher(for: request, name: nkRequest.apiName, session: self)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func dataTaskCombine(_ request: URLRequest, name: String) -> NKDataTaskCombine {
        URLSession.dataTaskCOPublisher(for: request, name: name, session: self)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func uploadTaskCombine(_ request: URLRequest, name: String, fileURL: URL) -> NKUploadTaskCombine {
        URLSession.uploadTaskCOPublisher(for: request, name: name, from: fileURL, session: self)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func uploadTaskCombine(_ request: URLRequest, name: String, data: Data?) -> NKUploadTaskCombine {
        URLSession.uploadTaskCOPublisher(for: request, name: name, from: data, session: self)
    }
}

@available(iOS 13.0, *)
class NetworkSessionDelegate: NSObject, URLSessionTaskDelegate {
    
    var taskMetrics: Combine.CurrentValueSubject<[Int: URLSessionTaskMetrics], Never> = .init([:])
    var taskWaitingForConnectivity: Combine.CurrentValueSubject<Set<Int>, Never> = .init(.init())
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        taskMetrics.value[task.taskIdentifier] = metrics
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        taskWaitingForConnectivity.value.insert(task.taskIdentifier)
    }
}
