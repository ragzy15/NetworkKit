//
//  Auth.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 23/07/20.
//

import Foundation

public enum AuthType: String, Codable, CaseIterable, Identifiable {
    case header = "Request Header"
    case url = "Request URL"
    case urlOrBody = "Request URL / Request Body"
    
    public var id: String { rawValue }
}

public enum OAuthSignatureMethod: String, CaseIterable, Codable, Identifiable {
    case hmacSha1   = "HMAC-SHA1"
    case hmacSha256 = "HMAC-SHA256"
    case hmacSha512 = "HMAC-SHA512"
    case rsaSha1    = "RSA-SHA1"
    case rsaSha256  = "RSA-SHA256"
    case rsaSha512  = "RSA-SHA512"
    case plainText  = "Plain Text"
    
    public var id: String { rawValue }
}

public protocol RequestAuthType: Codable {
    var auth: Auth { get }
}

public struct InheritFromParent: RequestAuthType {
    public let auth: Auth = .inheritFromParent
    
    public var parentAuth: RequestAuthenticationModel?
    
    public init(parentAuth: RequestAuthenticationModel?) {
        self.parentAuth = parentAuth
    }
    
    enum CodingKeys: CodingKey {
//        case parentAuth
    }
}

public struct NoAuth: RequestAuthType {
    public let auth: Auth = .none
    
    public init() { }
    
    enum CodingKeys: CodingKey {
        
    }
}

public struct OAuth1_0: RequestAuthType {
    public let auth: Auth = .oAuth_1_0
    
    public var signature: OAuthSignatureMethod
    public var consumerKey: String
    public var consumerSecret: String
    public var accessToken: String
    public var tokenSecret: String
    public var addTo: AuthType
    
    public init() {
        signature = .hmacSha1
        consumerKey = ""
        consumerSecret = ""
        accessToken = ""
        tokenSecret = ""
        addTo = .header
    }
    
    enum CodingKeys: String, CodingKey {
        case signature, consumerKey, consumerSecret, accessToken, tokenSecret, addTo
    }
}

public struct APIKeyAuth: RequestAuthType {
    
    public let auth: Auth = .apiKey
    
    public var key: String
    public var value: String
    public var addTo: AuthType
    
    public init() {
        key = ""
        value = ""
        addTo = .header
    }
    
    enum CodingKeys: String, CodingKey {
        case key, value, addTo
    }
}

public struct BearerTokenAuth: RequestAuthType {
    public let auth: Auth = .bearerToken
    
    public var token: String
    
    public init() {
        token = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

public struct BasicAuth: RequestAuthType {
    public let auth: Auth
    
    public var username: String
    public var password: String
    
    public var showPassword: Bool = false
    
    public init(auth: Auth) {
        self.auth = auth
        username = ""
        password = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case auth, username, password
    }
}

public struct OAuth2_0: RequestAuthType {
    public let auth: Auth = .oAuth_2_0
    
    public var accessToken: String
    public var headerPrefix: String
    public var addTo: AuthType
    
    public init() {
        accessToken = ""
        headerPrefix = ""
        addTo = .header
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken, headerPrefix, addTo
    }
}

public struct AWSSignature: RequestAuthType {
    public let auth: Auth = .awsSignature
    
    public var accessKey: String
    public var secretKey: String
    public var addTo: AuthType
    
    public init() {
        accessKey = ""
        secretKey = ""
        addTo = .header
    }
    
    enum CodingKeys: String, CodingKey {
        case accessKey, secretKey, addTo
    }
}

public enum Auth: String, CaseIterable, Identifiable, Codable {
    case inheritFromParent = "Inherit auth from parent"
    case none = "No Auth"
    case apiKey = "API Key"
    case bearerToken = "Bearer Token"
    case basicAuth = "Basic Auth"
    case digestAuth = "Digest Auth"
    case oAuth_1_0 = "OAuth 1.0"
    case oAuth_2_0 = "OAuth 2.0"
    case awsSignature = "AWS Signature"
    
    public var id: Int {
        switch self {
        case .inheritFromParent: return 0
        case .none: return 1
        case .apiKey: return 2
        case .bearerToken: return 3
        case .basicAuth: return 4
        case .digestAuth: return 5
        case .oAuth_1_0: return 6
        case .oAuth_2_0: return 7
        case .awsSignature: return 8
        }
    }
    
//    public var model: RequestAuthType {
//        switch self {
//        case .inheritFromParent: return InheritFromParent(p)
//        case .none: return NoAuth()
//        case .apiKey: return APIKeyAuth()
//        case .bearerToken: return   BearerTokenAuth()
//        case .basicAuth: return     BasicAuth(auth: .basicAuth)
//        case .digestAuth: return    BasicAuth(auth: .digestAuth)
//        case .oAuth_1_0: return     OAuth1_0()
//        case .oAuth_2_0: return     OAuth2_0()
//        case .awsSignature: return  AWSSignature()
//        }
//    }
    
//    public static var allModels: [RequestAuthType] {
//        allCases.map { $0.model }
//    }
}

public struct RequestAuthenticationModel: Codable {
    public var auth: RequestAuthType
    public var authType: Auth
    
    public init(auth: RequestAuthType) {
        self.auth = auth
        authType = auth.auth
    }
    
    public enum CodingKeys: String, CodingKey {
        case auth, authType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        authType = try container.decode(Auth.self, forKey: .auth)
        
        switch authType {
        case .inheritFromParent:
            auth = try container.decode(InheritFromParent.self, forKey: .auth)
        case .none:
            auth = try container.decode(NoAuth.self, forKey: .auth)
        case .apiKey:
            auth = try container.decode(APIKeyAuth.self, forKey: .auth)
        case .bearerToken:
            auth = try container.decode(BearerTokenAuth.self, forKey: .auth)
        case .basicAuth:
            auth = try container.decode(BasicAuth.self, forKey: .auth)
        case .digestAuth:
            auth = try container.decode(BasicAuth.self, forKey: .auth)
        case .oAuth_1_0:
            auth = try container.decode(OAuth1_0.self, forKey: .auth)
        case .oAuth_2_0:
            auth = try container.decode(OAuth2_0.self, forKey: .auth)
        case .awsSignature:
            auth = try container.decode(AWSSignature.self, forKey: .auth)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authType, forKey: .authType)
        
        switch authType {
        case .inheritFromParent:
            try container.encode(auth as! InheritFromParent, forKey: .auth)
        case .none:
            try container.encode(auth as! NoAuth, forKey: .auth)
        case .apiKey:
            try container.encode(auth as! APIKeyAuth, forKey: .auth)
        case .bearerToken:
            try container.encode(auth as! BearerTokenAuth, forKey: .auth)
        case .basicAuth:
            try container.encode(auth as! BasicAuth, forKey: .auth)
        case .digestAuth:
            try container.encode(auth as! BasicAuth, forKey: .auth)
        case .oAuth_1_0:
            try container.encode(auth as! OAuth1_0, forKey: .auth)
        case .oAuth_2_0:
            try container.encode(auth as! OAuth2_0, forKey: .auth)
        case .awsSignature:
            try container.encode(auth as! AWSSignature, forKey: .auth)
        }
    }
}
