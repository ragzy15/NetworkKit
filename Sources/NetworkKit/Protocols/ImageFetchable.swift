//
//  ImageFetchable.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 19/04/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import PublisherKit
import os.log

/// Allows Image View to fetch image using `PublisherKit`
public protocol ImageFetchable: AnyObject {
    
    typealias ImageType = NKImageSession.ImageType
    
    var image: ImageType? { get set }
    
    /// Stores the reference to image download task.
    var cancellable: AnyCancellable? { get set }
    
    /// Fetches Image from provided URL and sets it on this UIImageView.
    /// - Parameter url: URL from where image has to be fetched.
    /// - Parameter flag: Bool to set image automatically after downloading. Default value is `true`.
    /// - Parameter placeholder: Place holder image to be displayed until image is downloaded. Default value is `nil`.
    /// - Parameter completion: Completion Block which provides image if downloaded successfully.
    func fetch(from url: URL, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?)
    
    /// Fetches Image from provided URL String and sets it on this UIImageView.
    /// - Parameter urlString: URL String from where image has to be fetched.
    /// - Parameter flag: Bool to set image automatically after downloading. Default value is `true`.
    /// - Parameter placeholder: Place holder image to be displayed until image is downloaded. Default value is `nil`.
    /// - Parameter completion: Completion Block which provides image if downloaded successfully.
    func fetch(fromURLString urlString: String?, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?)
    
    /// This method allows the image view to be prepared for reuse in reusable views.
    ///
    /// Call this method from `UITableViewCell.prepareForReuse()` and `UICollectionViewCell.prepareForReuse()` methods.
    ///
    /// - Parameter placeholder: Optional placeholder image on reuse.
    func prepareForReuse(_ placeholder: ImageType?)
}

extension ImageFetchable {
    
    public func prepareForReuse(_ placeholder: NKImageSession.ImageType?) {
        cancellable?.cancel()
        cancellable = nil
        image = placeholder
    }
}

extension ImageFetchable {
    
    public func fetch(from url: URL, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) {
        _fetch(from: url, setImageAutomatically: flag, placeholder: placeholder, completion: completion)
    }
    
    public func fetch(fromURLString urlString: String?, setImageAutomatically flag: Bool, placeholder: ImageType?, completion: ((ImageType?) -> ())?) {
        
        guard let urlStringValue = urlString, let url = URL(string: urlStringValue) else {
            #if DEBUG
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                os_log("❗️%{public}@", log: .imageSession, type: .error, NSError.badURL(for: urlString))
            } else {
                if NKImageSession.shared.isLoggingEnabled {
                    NSLog("❗️%@", NSError.badURL(for: urlString))
                }
            }
            #endif
            
            image = placeholder
            
            completion?(nil)
            return
        }
        
        _fetch(from: url, setImageAutomatically: flag, completion: completion)
    }
}

extension ImageFetchable {
    
    @inline(__always)
    private func _fetch(from url: URL,
                        setImageAutomatically flag: Bool = true, placeholder: ImageType? = nil,
                        completion: ((ImageType?) -> ())? = nil) {
        
        if let placeholder = placeholder {
            image = placeholder
        }
        
        cancellable = NKImageSession.shared.fetch(from: url) { [weak self] (result) in
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
