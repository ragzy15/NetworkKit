//
//  WebSocket Task Combine.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 19/03/21.
//

#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, *)
extension NetworkSession {
    
    public func webSocketTask(request: URLRequest, name: String) -> WebSocketTask {
        WebSocketTask(request: request, name: name, session: self)
    }
}

@available(macOS 10.15, iOS 13.0, *)
public final class WebSocketTask {
    
    public let session: NetworkSession
    
    public let request: URLRequest
    public let name: String
    
    private let task: URLSessionWebSocketTask
    
    public var progress: Progress {
        task.progress
    }
    
    public var onOpen: ((_ `protocol`: String?) -> Void)?
    public var onClose: ((_ closeCode: URLSessionWebSocketTask.CloseCode, _ reason: Data?) -> Void)?
    public var isWaitingForConnectivity: (() -> Void)?
    
    private var cancellableBag = Set<Combine.AnyCancellable>()
    
    public init(request: URLRequest, name: String, session: NetworkSession) {
        self.request = request
        self.name = name
        self.session = session
        task = session.session.webSocketTask(with: request)
        setNotificationCenterObservers()
    }
    
    private func setNotificationCenterObservers() {
        NotificationCenter.default.publisher(for: Notification.Name("taskIsWaitingForConnectivity"))
            .compactMap { $0.userInfo }
            .filter { [weak self] (userInfo) in
                (userInfo["taskIdentifier"] as! Int) == self?.task.taskIdentifier
            }
            .sink { [weak self] (userInfo) in
                self?.isWaitingForConnectivity?()
            }
            .store(in: &cancellableBag)
        
        NotificationCenter.default.publisher(for: Notification.Name("webSocketDidOpen"))
            .compactMap { $0.userInfo }
            .filter { [weak self] (userInfo) in
                (userInfo["taskIdentifier"] as! Int) == self?.task.taskIdentifier
            }
            .sink { [weak self] (userInfo) in
                self?.onOpen?(userInfo["protocol"] as? String)
            }
            .store(in: &cancellableBag)
        
        NotificationCenter.default.publisher(for: Notification.Name("webSocketDidClose"))
            .compactMap { $0.userInfo }
            .filter { [weak self] (userInfo) in
                (userInfo["taskIdentifier"] as! Int) == self?.task.taskIdentifier
            }
            .sink { [weak self] (userInfo) in
                self?.onClose?(userInfo["closeCode"] as! URLSessionWebSocketTask.CloseCode, userInfo["reason"] as? Data)
            }
            .store(in: &cancellableBag)
    }
    
    public func connect() {
        task.resume()
    }
    
    public func sendPing(pongReceiveHandler: @escaping (NSError?) -> Void) {
        task.sendPing { (error) in
            pongReceiveHandler(error as NSError?)
        }
    }
    
    public func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (NSError?) -> Void) {
        task.send(message) { (error) in
            completionHandler(error as NSError?)
        }
    }
    
    public func onReceive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, NSError>) -> Void) {
        task.receive { [weak self] (result) in
            switch result {
            case .success(let message):
                completionHandler(.success(message))
                self?.onReceive(completionHandler: completionHandler)
                
            case .failure(let error):
                completionHandler(.failure(error as NSError))
            }
        }
    }
    
    public func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        task.cancel(with: closeCode, reason: reason)
    }
    
    public func suspend() {
        task.suspend()
    }
    
    public func resume() {
        task.resume()
    }
}

#endif
