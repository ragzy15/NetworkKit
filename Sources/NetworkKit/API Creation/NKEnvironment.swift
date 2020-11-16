//
//  NKEnvironment.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

/**
 Server Environment.
 
 ```
 let url = "https://api-staging.example.com/v1/users/all"
 // `staging` is Server Environment.
 ```
 
 It has a `current` property for maintaining the server environment.
 
 To update the `current` environment, use `NKConfiguration.updateEnvironment(:_)`.
 
 In `DEBUG` mode, it persists the `current` value in `UserDefaults`.
 */
public struct NKEnvironment: Hashable, Equatable {
    
    /// String value of the environment
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public internal(set) static var current: NKEnvironment = .none
    
    public static let none          = NKEnvironment(value: "")
    public static let staging      = NKEnvironment(value: "staging")
    public static let dev           = NKEnvironment(value: "dev")
    public static let production    = NKEnvironment(value: "")
}
