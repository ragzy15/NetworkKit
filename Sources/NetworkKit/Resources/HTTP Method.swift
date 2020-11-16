//
//  HTTP Method.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

public enum HTTPMethod: String, Hashable, CaseIterable {
    
    case get        = "GET"
    case post       = "POST"
    case put        = "PUT"
    case patch      = "PATCH"
    case delete     = "DELETE"
    case copy       = "COPY"
    case head       = "HEAD"
    case options    = "OPTIONS"
    case connect    = "CONNECT"
    case trace      = "TRACE"
    case link       = "LINK"
    case unlink     = "UNLINK"
    case purge      = "PURGE"
    case lock       = "LOCK"
    case unlock     = "UNLOCK"
    case propfind   = "PROPFIND"
    case view       = "VIEW"
}

#if canImport(SwiftUI)
extension HTTPMethod: Identifiable {

    public var id: String {
        rawValue
    }
}
#endif
