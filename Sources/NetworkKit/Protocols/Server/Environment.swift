//
//  Environment.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//  Copyright © 2019 Raghav Ahuja. All rights reserved.
//

import Foundation

/// Server Environment.
public struct Environment: Hashable, Equatable {
    
    public var value: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    public init(value: String) {
        self.value = value
    }
    
    public internal(set) static var current: Environment = .none
    
    public static let none      = Environment(value: "")
    public static let staging   = Environment(value: "staging")
    public static let dev       = Environment(value: "dev")
}