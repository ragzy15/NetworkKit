//
//  NKSession.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import PublisherKit

final public class NKSession: NKConfiguration {
    
    public static let shared = NKSession()
    
    public override var isLoggingEnabled: Bool {
        get {
            Logger.default.isLoggingEnabled
        } set {
            Logger.default.isLoggingEnabled = newValue
        }
    }
    
    private init() {
        super.init(configuration: NKConfiguration.defaultConfiguration)
        
        #if DEBUG
        if let environmentValue = UserDefaults.standard.string(forKey: "api_environment") {
            NKEnvironment.current = NKEnvironment(value: environmentValue)
        } else {
            NKEnvironment.current = .none
        }
        #else
        NKEnvironment.current = .production
        #endif
    }
}
