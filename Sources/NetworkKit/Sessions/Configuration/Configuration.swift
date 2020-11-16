//
//  NKConfiguration.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - NKCONFIGURATION

/// A Class that coordinates a group of related network data transfer tasks.
open class NKConfiguration {
    
    /// Enables Logging for this session.
    /// Default value is `true`.
    open var isLoggingEnabled: Bool = true
    
    /// Should allow logging for all sessions.
    /// Default value is `false`.
    public static var allowLoggingOnAllSessions: Bool = true
    
    /// Should empty cache before application terminates.
    /// Default value is `true`.
    open var emptyCacheOnAppTerminate: Bool
    
    /// Should empty cache before application terminates.
    /// Default value is `false`.
    public static var emptyCacheOnAppTerminateOnAllSessions: Bool = false
    
    /// URL Cache for a URLSession
    public let urlCache: URLCache?
    
    /// An object that coordinates a group of related network data transfer tasks.
    public let session: URLSession
    
    #if !os(watchOS)
    private var cacheObserver: NSObjectProtocol?
    #endif
    
    /// A default session configuration object.
    public static var defaultConfiguration: URLSessionConfiguration = {
        let configuration: URLSessionConfiguration = .default
        
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.networkServiceType = .responsiveData
        configuration.timeoutIntervalForRequest = TimeInterval(integerLiteral: 20)
        configuration.timeoutIntervalForResource = TimeInterval(integerLiteral: 40)
        
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
        }
        
        return configuration
    }()
    
    private static let maxMemoryCapacity: Int = 5242880 // 5.24 MB
    private static let maxDiskCapacity: Int = 52428800 // 52.4 MB
    
    /// Inititalises Manager with `defaultURLSessionConfiguration` Configuration.
    public init(useDefaultCache: Bool, requestCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, cacheDiskPath diskPath: String? = nil) {
        let configuration = NKConfiguration.defaultConfiguration
        configuration.requestCachePolicy = requestCachePolicy
        
        if useDefaultCache {
            if #available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *) {
                let cache = URLCache(memoryCapacity: NKConfiguration.maxMemoryCapacity, diskCapacity: NKConfiguration.maxDiskCapacity)
                urlCache = cache
            } else {
                #if targetEnvironment(macCatalyst)
                let cache = URLCache(memoryCapacity: NKConfiguration.maxMemoryCapacity, diskCapacity: NKConfiguration.maxDiskCapacity)
                #else
                let cache = URLCache(memoryCapacity: NKConfiguration.maxMemoryCapacity, diskCapacity: NKConfiguration.maxDiskCapacity, diskPath: diskPath)
                #endif
                
                urlCache = cache
            }
            
            configuration.urlCache = urlCache
            
        } else {
            urlCache = nil
        }
        
        session = URLSession(configuration: configuration)
        emptyCacheOnAppTerminate = true
        setNotificationObservers()
    }
    
    public init(urlCache cache: URLCache? = nil, configuration config: URLSessionConfiguration) {
        urlCache = cache
        session = URLSession(configuration: config)
        emptyCacheOnAppTerminate = true
        setNotificationObservers()
    }
    
    public init(urlCache cache: URLCache? = nil, configuration config: URLSessionConfiguration, deleagte: URLSessionDelegate, delegateQueue: OperationQueue?) {
        urlCache = cache
        session = URLSession(configuration: config, delegate: deleagte, delegateQueue: delegateQueue)
        emptyCacheOnAppTerminate = true
        setNotificationObservers()
    }
    
    deinit {
        #if !os(watchOS)
        if let observer = cacheObserver {
            NotificationCenter.default.removeObserver(observer, name: notification, object: nil)
        }
        #endif
        
        session.invalidateAndCancel()
    }
    
    // MARK: - NOTIFICATION OBSERVERS
    private func setNotificationObservers() {
        #if !os(watchOS)
        cacheObserver = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .init()) { [weak self] (_) in
            if let `self` = self, self.emptyCacheOnAppTerminate || NKConfiguration.emptyCacheOnAppTerminateOnAllSessions {
                self.removeAllCachedResponses()
            }
        }
        #endif
    }
    
    // MARK: DATA TASK
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    @inlinable open func dataTask(_ request: @autoclosure () -> NKRequest) -> NKDataTask {
        dataTask(request)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given Network request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func dataTask(_ requestBlock: () -> NKRequest) -> NKDataTask {
        let nkRequest = requestBlock()
        guard let request = nkRequest.getRequest() else {
            preconditionFailure("Invalid Request Created for connection: \(nkRequest.connection)")
        }
        
        return session.dataTaskPKPublisher(for: request, name: nkRequest.apiName)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a data task.
    /// - Parameter apiName: API Name for debug console logging.
    /// - Returns: A publisher that wraps a data task for the URL request.
    open func dataTask(for request: URLRequest, apiName: String = "") -> URLSession.DataTaskPKPublisher {
        session.dataTaskPKPublisher(for: request, name: apiName)
    }
    
    /// Returns a publisher that wraps a URL session data task for a given URL.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter url: The URL for which to create a data task.
    /// - Parameter apiName: API Name for debug console logging.
    /// - Returns: A publisher that wraps a data task for the URL.
    open func dataTask(for url: URL, apiName: String = "") -> URLSession.DataTaskPKPublisher {
        session.dataTaskPKPublisher(for: url, name: apiName)
    }
    
    // MARK: DOWNLOAD TASK
    
    /// Returns a publisher that wraps a URL session download task for a given URL.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a download task for the URL.
    @inlinable open func downloadTask(_ request: @autoclosure () -> NKRequest) -> NKDownloadTask {
        downloadTask(request)
    }
    
    /// Returns a publisher that wraps a URL session download task for a given URL.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a download task for the URL.
    open func downloadTask(_ requestBlock: () -> NKRequest) -> NKDownloadTask {
        let nkRequest = requestBlock()
        guard let request = nkRequest.getRequest() else {
            preconditionFailure("Invalid Request Created for connection: \(nkRequest.connection)")
        }
        
        return session.downloadTaskPKPublisher(for: request, name: nkRequest.apiName)
    }
    
    /// Returns a publisher that wraps a URL session download task for a given URL.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter url: The URL for which to create a download task.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a download task for the URL.
    open func downloadTask(for url: URL, name: String = "") -> URLSession.DownloadTaskPKPublisher {
        session.downloadTaskPKPublisher(for: url, name: name)
    }
    
    /// Returns a publisher that wraps a URL session download task for a given URL request.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a download task.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a download task for the URL request.
    open func downloadTask(for request: URLRequest, name: String = "") -> URLSession.DownloadTaskPKPublisher {
        session.downloadTaskPKPublisher(for: request, name: name)
    }
    
    /// Returns a publisher that wraps a URL session download task for a given URL request.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter data: A data object that provides the data necessary to resume the download.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a download task for the URL request.
    open func downloadTask(withResumeData data: Data, name: String = "") -> URLSession.DownloadTaskPKPublisher {
        session.downloadTaskPKPublisher(withResumeData: data, name: name)
    }
    
    // MARK: UPLOAD TASK
    
    /// Returns a publisher that wraps a URL session upload task for a given URL.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter builder: `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a download task for the URL.
    @inlinable open func uploadTask(_ request: @autoclosure () -> NKRequest) -> NKUploadTask {
        uploadTask(request)
    }
    
    /// Returns a publisher that wraps a URL session upload task for a given URL.
    ///
    /// The publisher publishes file URL when the task completes, or terminates if the task fails with an error.
    /// - Parameter requestBlock: The block which returns a `NKRequest` to create a URL session data task.
    /// - Returns: A publisher that wraps a download task for the URL.
    open func uploadTask(_ requestBlock: () -> NKRequest) -> NKUploadTask {
        let nkRequest = requestBlock()
        guard let request = nkRequest.getRequest() else {
            preconditionFailure("Invalid Request Created for connection: \(nkRequest.connection)")
        }
        
        if let url = nkRequest.fileURL {
            return session.uploadTaskPKPublisher(for: request, from: url, name: nkRequest.apiName)
        } else {
            return session.uploadTaskPKPublisher(for: request, from: request.httpBody, name: nkRequest.apiName)
        }
    }
    
    /// Returns a publisher that wraps a URL session upload task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a upload task.
    /// - Parameter data: The body data for the request.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a upload task for the URL request.
    open func uploadTask(for request: URLRequest, from data: Data?, name: String = "") -> URLSession.UploadTaskPKPublisher {
        session.uploadTaskPKPublisher(for: request, from: data, name: name)
    }
    
    /// Returns a publisher that wraps a URL session upload task for a given URL request.
    ///
    /// The publisher publishes data when the task completes, or terminates if the task fails with an error.
    /// - Parameter request: The URL request for which to create a upload task.
    /// - Parameter file: The URL of the file to upload.
    /// - Parameter name: Name for the task. Used for logging purpose only.
    /// - Returns: A publisher that wraps a upload task for the URL request.
    open func uploadTask(for request: URLRequest, from file: URL, name: String = "") -> URLSession.UploadTaskPKPublisher {
        session.uploadTaskPKPublisher(for: request, from: file, name: name)
    }
}

// MARK: - URL CACHE MANAGER
extension NKConfiguration {
    
    /// Remove All Cached Responses from this session.
    open func removeAllCachedResponses() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
    
    public func printURLCacheDetails() {
        #if DEBUG
        guard let cache = session.configuration.urlCache else {
            print(
                "Cannot Print Cache Memory And Disk Capacity And Usage",
                "Error - No URL Cache Found")
            return
        }
        let byteToMb: Double = 1048576
        
        let memoryCapacity = Double(cache.memoryCapacity) / byteToMb
        let memoryUsage = Double(cache.currentMemoryUsage) / byteToMb
        
        let diskCapacity = Double(cache.diskCapacity) / byteToMb
        let diskUsage = Double(cache.currentDiskUsage) / byteToMb
        
        print(
            "Current URL Cache Memory And Disk Capacity And Usage",
            "Memory Capacity: \(String(format: "%.2f", memoryCapacity)) Mb",
            "Memory Usage: \(String(format: "%.3f", memoryUsage)) Mb",
            "Disk Capacity: \(String(format: "%.2f", diskCapacity)) Mb",
            "Disk Usage: \(String(format: "%.3f", diskUsage)) Mb"
        )
        #endif
    }
}

// MARK: - SERVER ENVIRONMENT
extension NKConfiguration {
    
    /// Updates the current environment.
    /// - Parameter newEnvironment: New Server Environment to be set.
    public static func updateEnvironment(_ newEnvironment: NKEnvironment) {
        NKEnvironment.current = newEnvironment
        
        #if DEBUG
        UserDefaults.standard.set(newEnvironment.value, forKey: "api_environment")
        #endif
    }
    
    /// Returns the current environment.
    public static var currentEnvironment: NKEnvironment? {
        return NKEnvironment.current
    }
}
