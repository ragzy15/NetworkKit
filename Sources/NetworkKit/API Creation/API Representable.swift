//
//  API Representable.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

/**
 A type that represents server api. It can also be used for managing server environment in URL.
 
 ```
 let url = "https://api-staging.example.com/v1/users/all"
 // `api` is a Server API.
 // `staging` is Server Environment.
 ```
 */
public protocol APIRepresentable {
    
    /**
     Sub URL for API.
     
     It may include server environment for the api.
     Use **Environment.current** to maintain environment.
     ```
     let url = "https://api.example.com/users/all"
     // `api` is sub url.
     ```
     */
    var subURL: String { get }
    
    /**
     EndPoint for API.
     
     ```
     let url = "https://api-staging.example.com/v1/users/all"
     // `/v1` is api endpoint.
     ```
     */
    var endPoint: String { get }
}
