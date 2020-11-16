//
//  NKImageSessionDelegate.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import os.log

public protocol NKImageSessionDelegate: class {
    
    typealias ImageType = NKImageSession.ImageType
    
    var image: ImageType? { get set }
    
    /// Fetches Image from provided URL and sets it on this UIImageView.
    /// - Parameter url: URL from where image has to be fetched.
    /// - Parameter flag: Bool to set image automatically after downloading. Default value is `true`.
    /// - Parameter placeholder: Place holder image to be displayed until image is downloaded. Default value is `nil`.
    /// - Parameter completion: Completion Block which provides image if downloaded successfully.
    /// - Returns: `URLSessionDataTask` for image.
    @available(*, deprecated, message: "Use ImageFetchable protocol for fetching images.")
    func fetch(from url: URL, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) -> URLSessionDataTask
    
    /// Fetches Image from provided URL String and sets it on this UIImageView.
    /// - Parameter urlString: URL String from where image has to be fetched.
    /// - Parameter flag: Bool to set image automatically after downloading. Default value is `true`.
    /// - Parameter placeholder: Place holder image to be displayed until image is downloaded. Default value is `nil`.
    /// - Parameter completion: Completion Block which provides image if downloaded successfully.
    /// - Returns: `URLSessionDataTask` if URL is correctly formed else returns `nil`.
    @available(*, deprecated, message: "Use ImageFetchable protocol for fetching images.")
    func fetch(fromUrlString urlString: String?, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) -> URLSessionDataTask?
    
    /// This method allows the image view to be prepared for reuse in reusable views.
    ///
    /// Call this method from `UITableViewCell.prepareForReuse()` and `UICollectionViewCell.prepareForReuse()` methods.
    ///
    /// - Parameter placeholder: Optional placeholder image on reuse.
    func prepareForReuse(_ placeholder: ImageType?)
}

extension NKImageSessionDelegate {
    
    @available(*, deprecated, message: "Use ImageFetchable protocol for fetching images.")
    public func fetch(from url: URL, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) -> URLSessionDataTask {
        _fetch(from: url, setImageAutomatically: flag, placeholder: placeholder, completion: completion)
    }
    
    @available(*, deprecated, message: "Use ImageFetchable protocol for fetching images.")
    public func fetch(fromUrlString urlString: String?, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) -> URLSessionDataTask? {
        
        guard let urlStringValue = urlString, let url = URL(string: urlStringValue) else {
            #if DEBUG
            if #available(macOS 10.12, iOS 10.0, *) {
                os_log("❗️%{public}@", log: .imageSession, type: .error, NSError.badURL(for: urlString))
            } else {
                if NKImageSession.shared.isLoggingEnabled {
                    NSLog("❗️%@", NSError.badURL(for: urlString))
                }
            }
            #endif
            
            image = placeholder
            
            completion?(nil)
            return nil
        }
        
        return _fetch(from: url, setImageAutomatically: flag, completion: completion)
    }
}

extension NKImageSessionDelegate {
    
    @inline(__always)
    private func _fetch(from url: URL,
                        setImageAutomatically flag: Bool = true, placeholder: ImageType? = nil,
                        completion: ((ImageType?) -> ())? = nil) -> URLSessionDataTask {
        
        if let placeholder = placeholder {
            image = placeholder
        }
        
        return NKImageSession.shared.fetch(from: url) { [weak self] (result) in
            switch result {
            case .success(let newImage):
                if flag {
                    self?.image = newImage
                }
                completion?(newImage)
                
            case .failure:
                completion?(nil)
            }
        }
    }
}
