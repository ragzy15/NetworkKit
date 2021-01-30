//
//  Typealias Combine.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 04/10/20.
//

#if canImport(Combine)
import Foundation
import PublisherKit

@available(iOS 13.0, macOS 10.15, *)
public typealias NKDataTaskCombine = URLSession.DataTaskCOPublisher

@available(iOS 13.0, macOS 10.15, *)
public typealias NKUploadTaskCombine = URLSession.UploadTaskCOPublisher

#endif
