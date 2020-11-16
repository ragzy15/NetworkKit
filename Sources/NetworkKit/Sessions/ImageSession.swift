//
//  NKImageSession.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import PublisherKit
import os.log

public final class NKImageSession: NKConfiguration {
    
    public static let shared = NKImageSession()
    
    public init(useCache: Bool = true, cacheDiskPath: String? = "cachedImages") {
        let requestCachePolicy: URLRequest.CachePolicy = useCache ? .returnCacheDataElseLoad : .useProtocolCachePolicy
        super.init(useDefaultCache: useCache, requestCachePolicy: requestCachePolicy, cacheDiskPath: cacheDiskPath)
        emptyCacheOnAppTerminate = false
    }
}

extension NKImageSession {
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
    /// - Parameter url: URL from where image has to be fetched.
    /// - Parameter useCache: Flag which allows Response and Data to be cached.
    /// - Parameter completion: The completion handler to call when the load request is complete. This handler is executed on the `main` queue
    /// - Returns: `URLSessionDataTask` for further operations.
    @discardableResult
    public func fetch(from url: URL, cacheImage useCache: Bool = true, completion: @escaping (Result<ImageType, Error>) -> ()) -> URLSessionDataTask {
        
        let requestCachePolicy: URLRequest.CachePolicy = useCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        let request = URLRequest(url: url, cachePolicy: requestCachePolicy, timeoutInterval: session.configuration.timeoutIntervalForRequest)
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard let `self` = self else {
                return
            }
            
            if let error = error as NSError? {
                
                #if DEBUG
                if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                    os_log("❗️%{public}@", log: .imageSession, type: .error, error)
                } else {
                    if NKImageSession.shared.isLoggingEnabled {
                        NSLog("❗️%@", error)
                    }
                }
                #endif
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let result = self.validateImageResponse(url: url, data: data)
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    completion(.success(image))
                }
                
            case .failure(let error):
                
                #if DEBUG
                if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                    os_log("❗️%{public}@", log: .imageSession, type: .error, error)
                } else {
                    if NKImageSession.shared.isLoggingEnabled {
                        NSLog("❗️%@", error)
                    }
                }
                #endif
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        return task
    }
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
    /// - Parameter url: URL from where image has to be fetched.
    /// - Parameter useCache: Flag which allows Response and Data to be cached.
    /// - Parameter completion: The completion handler to call when the load request is complete. This handler is executed on the main queue. This completion handler takes the Result as parameter. On Success, it returns the image.  On Failure, returns URLError.
    /// - Returns: `Cancellable` for cancelling image fetch task.
    public func fetch(from url: URL, cacheImage useCache: Bool = true, completion: @escaping (Result<ImageType, Error>) -> ()) -> AnyCancellable {
        
        let requestCachePolicy: URLRequest.CachePolicy = useCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        let request = URLRequest(url: url, cachePolicy: requestCachePolicy, timeoutInterval: session.configuration.timeoutIntervalForRequest)
        
        return session.dataTaskPKPublisher(for: request)
            .tryMap { (data, _) -> ImageType in
                
                guard !data.isEmpty else {
                    throw NSError.zeroByteResource(for: url)
                }
                
                guard let image = ImageType(data: data) else {
                    throw NSError.cannotDecodeImageData(for: url)
                }
                
                return image
        }
        .completion(completion)
    }
}

extension NKImageSession {
    
    /// Validates URL Request's HTTP Response.
    /// - Parameter data: Response Data containing Image Data sent by server.
    /// - Returns: Result Containing Image on success or URL Error if validation fails.
    private func validateImageResponse(url: URL, data: Data?) -> Result<ImageType, NSError> {
        
        guard let data = data, !data.isEmpty else {
            return .failure(.zeroByteResource(for: url))
        }
        
        guard let image = ImageType(data: data) else {
            return .failure(.cannotDecodeImageData(for: url))
        }
        
        return .success(image)
    }
}
