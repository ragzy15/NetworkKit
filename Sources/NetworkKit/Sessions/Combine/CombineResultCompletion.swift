//
//  CombineResultCompletion.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 14/02/21.
//

#if canImport(Combine)
import Combine

// MARK: COMPLETION
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Combine.Publisher {
    
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter block: The closure to execute on completion.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func completion(_ block: @escaping (Result<Output, Failure>) -> Void) -> Combine.AnyCancellable {
        let subscriber = Combine.Subscribers.ResultCompletion(receiveCompletion: block)
        subscribe(subscriber)
        return Combine.AnyCancellable(subscriber)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Combine.Subscribers {
    
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    final class ResultCompletion<Input, Failure: Error>: Combine.Subscriber, Combine.Cancellable {
        
        /// The closure to execute on completion.
        final public let receiveCompletion: (Result<Input, Failure>) -> Void
        
        private var receivedValue: Input? = nil
        
        private var subscription: Combine.Subscription?
        
        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveCompletion: The closure to execute on completion.
        ///   - receiveValue: The closure to execute on receipt of a value.
        public init(receiveCompletion: @escaping ((Result<Input, Failure>) -> Void)) {
            self.receiveCompletion = receiveCompletion
        }
        
        final public func receive(subscription: Combine.Subscription) {
            guard self.subscription == nil else { return }
            self.subscription = subscription
            subscription.request(.unlimited)
        }
        
        final public func receive(_ value: Input) -> Combine.Subscribers.Demand  {
            guard subscription != nil else { return .none }
            receivedValue = value
            return .none
        }
        
        final public func receive(completion: Combine.Subscribers.Completion<Failure>) {
            guard subscription != nil else { return }
            subscription = nil
            
            switch completion {
            case .finished:
                if let value = receivedValue {
                    receiveCompletion(.success(value))
                }
                
            case .failure(let error):
                receiveCompletion(.failure(error))
            }
        }
        
        final public func cancel() {
            subscription?.cancel()
            subscription = nil
        }
    }
}

#endif
