//
//  Typealias.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 20/04/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import PublisherKit

public typealias NKDataTask = URLSession.DataTaskPKPublisher
public typealias NKDownloadTask = URLSession.DownloadTaskPKPublisher
public typealias NKUploadTask = URLSession.UploadTaskPKPublisher

public typealias AnyCancellable = PublisherKit.AnyCancellable
public typealias Cancellable = PublisherKit.Cancellable
public typealias CancellableBag = PublisherKit.CancellableBag

public typealias Publishers = PublisherKit.Publishers
public typealias Subscribers = PublisherKit.Subscribers

public typealias Publisher = PublisherKit.Publisher
public typealias Subscriber = PublisherKit.Subscriber

public typealias Subscription = PublisherKit.Subscription
public typealias Subscriptions = PublisherKit.Subscriptions

public typealias NKAnyDataTask = AnyPublisher<NKDataTask.Output, NKDataTask.Failure>
public typealias NKAnyDownloadTask = AnyPublisher<NKDownloadTask.Output, NKDownloadTask.Failure>
public typealias NKAnyUploadTask = AnyPublisher<NKUploadTask.Output, NKUploadTask.Failure>
