//
//  Auth.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 23/07/20.
//

import Foundation

public enum RequestFileType: Hashable {
    case url(URL)
    case select
    
    public var text: String {
        switch self {
        case .url(let url):
            return url.absoluteString
        case .select:
            return ""
        }
    }
}

public struct AuthKeyValue: Identifiable, Hashable {
    
    public enum ValueType: String, CaseIterable, Hashable, Identifiable {
        case text
        case file
        
        public var id: String {
            rawValue
        }
        
        public var value: Value {
            switch self {
            case .text:
                return .text("")
            case .file:
                return .file(.select)
            }
        }
    }
    
    public enum Value: Hashable {
        case text(String)
        case file(RequestFileType)
        
        public var text: String {
            switch self {
            case .text(let text):
                return text
            case .file(let file):
                return file.text
            }
        }
        
        public var valueType: ValueType {
            switch self {
            case .text:
                return .text
            case .file:
                return .file
            }
        }
    }
    
    public let id: UUID
    public var key: String
    public var value: Value
    public var itemDescription: String
    public var isEnabled: Bool
    public var canBeToggled: Bool
    public var sequence: Int
    public var isConflict: Bool = false
    public var canBeOverrided: Bool
    public var isOverriding: Bool = false
    
    public init(id: UUID = UUID(), key: String, value: Value, itemDescription: String = "",
                isEnabled: Bool = true, canBeToggled: Bool = true, canBeOverrided: Bool = true, sequence: Int) {
        self.id = id
        self.key = key
        self.value = value
        self.itemDescription = itemDescription
        self.isEnabled = isEnabled
        self.canBeToggled = canBeToggled
        self.canBeOverrided = canBeOverrided
        self.sequence = sequence
    }
    
    public static func empty(at index: Int) -> AuthKeyValue {
        AuthKeyValue(key: "", value: .text(""), sequence: index)
    }
}

public enum AuthType: String, Codable, CaseIterable, Identifiable {
    case header = "Request Header"
    case url = "Request URL"
//    case urlOrBody = "Request URL / Request Body"
    
    public var id: String { rawValue }
}

public enum OAuthType: String, Codable, CaseIterable, Identifiable {
    case header = "Request Header"
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

public protocol RequestAuthType {
    var auth: Auth { get }
    var query: [AuthKeyValue] { get }
    var header: [AuthKeyValue] { get }
}

public struct InheritFromParent: RequestAuthType {
    public let auth: Auth = .inheritFromParent
    
    public var parentAuth: RequestAuthType?
    public var parentName: String?
    
    public init(parentAuth: RequestAuthType?, parentName: String?) {
        self.parentAuth = parentAuth
        self.parentName = parentName
    }
    
    public var query: [AuthKeyValue] {
        parentAuth?.query ?? []
    }
    
    public var header: [AuthKeyValue] {
        parentAuth?.header ?? []
    }
    
    enum CodingKeys: CodingKey {
        case parentAuth
    }
}

public struct NoAuth: RequestAuthType, Codable {
    public let auth: Auth = .none
    
    public init() { }
    
    public var query: [AuthKeyValue] { [] }
    public var header: [AuthKeyValue] { [] }
    
    enum CodingKeys: CodingKey {
        
    }
}

public struct APIKeyAuth: RequestAuthType, Codable {
    
    public let auth: Auth = .apiKey
    
    public var key: String
    public var value: String
    public var addTo: AuthType
    
    public init() {
        key = ""
        value = ""
        addTo = .header
    }
    
    public var query: [AuthKeyValue] {
        guard addTo == .url else {
            return []
        }
        
        return [AuthKeyValue(key: key, value: .text(value),
                             canBeToggled: false, canBeOverrided: false, sequence: 0)]
    }
    
    public var header: [AuthKeyValue] {
        guard addTo == .header else {
            return []
        }
        
        return [AuthKeyValue(key: key, value: .text(value),
                             canBeToggled: false, canBeOverrided: false, sequence: 0)]
    }
    
    enum CodingKeys: String, CodingKey {
        case key, value, addTo
    }
}

public struct BearerTokenAuth: RequestAuthType, Codable {
    public let auth: Auth = .bearerToken
    
    public var token: String
    
    public init() {
        token = ""
    }
    
    public var query: [AuthKeyValue] { [] }
    
    public var header: [AuthKeyValue] {
        [AuthKeyValue(key: "Authorization", value: .text("Bearer \(token)"),
                      canBeToggled: false, canBeOverrided: false, sequence: 0)]
    }
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

public struct BasicAuth: RequestAuthType, Codable {
    public let auth: Auth
    
    public var username: String
    public var password: String
    
    public var showPassword: Bool = false
    
    public init(auth: Auth) {
        self.auth = auth
        username = ""
        password = ""
    }
    
    public var query: [AuthKeyValue] { [] }
    
    public var header: [AuthKeyValue] {
        guard let data = "\(username):\(password)".data(using: .utf8) else {
            return []
        }
        
        let value = data.base64EncodedString()
        
        return [
            AuthKeyValue(key: "Authorization", value: .text("Basic \(value)"),
                         canBeToggled: false, canBeOverrided: false, sequence: 0)
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case auth, username, password
    }
}

public struct OAuth1_0: RequestAuthType, Codable {
    public let auth: Auth = .oAuth_1_0
    
    public var signatureMethod                  : OAuthSignatureMethod
    public var consumerKey                      : String
    public var consumerSecret                   : String
    public var accessToken                      : String
    public var tokenSecret                      : String
    public var callbackURL                      : String
    public var verifier                         : String
    public var timestamp                        : String
    public var nonce                            : String
    public var version                          : String
    public var realm                            : String
    public var includeBodyHash                  : Bool
    public var addEmptyParametersToSignature    : Bool
    public var encodeParametersInHeader         : Bool
    public var addTo                            : OAuthType
    // signature -
    
    public var signature: String {
        "" // oauth_signature
    }
    
    public var bodyHash: String {
        "" // oauth_body_hash
    }
    
    public init() {
        signatureMethod = .hmacSha1
        consumerKey = ""
        consumerSecret = "" // only for HMAC and plain text
        accessToken = ""
        tokenSecret = "" // only for HMAC and plain text
        callbackURL = ""
        verifier = ""
        timestamp = ""
        nonce = ""
        version = "1.0"
        realm = ""
        includeBodyHash = true // Disabled when you're using callback URL / verifier.
        addEmptyParametersToSignature = false
        encodeParametersInHeader = true
        addTo = .header
    }
    
    public var query: [AuthKeyValue] {
        guard addTo == .urlOrBody else {
            return []
        }
//        If the request method is POST or PUT, and if the request body type is x-www-form-urlencoded, in body else url
        
        return [
            
        ]
    }
    
    public var header: [AuthKeyValue] { [] }
    
//    OAuth realm="lol%40lo.com",oauth_consumer_key="test",oauth_token="tt",oauth_signature_method="HMAC-SHA1",oauth_timestamp="ss",oauth_nonce="uyuyggyg",oauth_version="1.0ab",oauth_body_hash="2jmj7l5rSw0yVb%2FvlWAYkK%2FYBwk%3D",oauth_callback="https%3A%2F%2Fgoogle.com",oauth_verifier="mkmjmkmk",oauth_signature="%2BRrKK2ZZny2gYpXBnRkEXNXozTA%3D"
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case signatureMethod = "oauth_signature_method", consumerKey = "oauth_consumer_key", consumerSecret, accessToken = "oauth_token", tokenSecret
        case callbackURL = "oauth_callback", verifier = "oauth_verifier", timestamp = "oauth_timestamp", nonce = "oauth_nonce", version = "oauth_version", realm = "realm"
        case includeBodyHash, addEmptyParametersToSignature, encodeParametersInHeader
        case addTo
    }
}

public struct OAuth2_0: RequestAuthType, Codable {
    public let auth: Auth = .oAuth_2_0
    
    public var accessToken: String
    public var headerPrefix: String
    public var addTo: AuthType
    
    public init() {
        accessToken = ""
        headerPrefix = ""
        addTo = .header
    }
    
    public var query: [AuthKeyValue] {
        guard addTo == .url else {
            return []
        }
        
        return []
    }
    
    public var header: [AuthKeyValue] {
        guard addTo == .header else {
            return []
        }
        
        return []
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken, headerPrefix, addTo
    }
}

public struct AWSSignature: RequestAuthType, Codable {
    public let auth: Auth = .awsSignature
    
    public var accessKey: String
    public var secretKey: String
    public var addTo: AuthType
    
    public init() {
        accessKey = ""
        secretKey = ""
        addTo = .header
    }
    
    public var query: [AuthKeyValue] {
        guard addTo == .url else {
            return []
        }
        
        return []
    }
    
    public var header: [AuthKeyValue] {
        guard addTo == .header else {
            return []
        }
        
        return []
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
}

//public struct RequestAuthenticationModel: Codable {
//    public var auth: RequestAuthType
//    public var authType: Auth
//    
//    public init(auth: RequestAuthType) {
//        self.auth = auth
//        authType = auth.auth
//    }
//    
//    public enum CodingKeys: String, CodingKey {
//        case auth, authType
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        authType = try container.decode(Auth.self, forKey: .authType)
//        
//        switch authType {
//        case .inheritFromParent:
//            auth = try container.decode(InheritFromParent.self, forKey: .auth)
//        case .none:
//            auth = try container.decode(NoAuth.self, forKey: .auth)
//        case .apiKey:
//            auth = try container.decode(APIKeyAuth.self, forKey: .auth)
//        case .bearerToken:
//            auth = try container.decode(BearerTokenAuth.self, forKey: .auth)
//        case .basicAuth:
//            auth = try container.decode(BasicAuth.self, forKey: .auth)
//        case .digestAuth:
//            auth = try container.decode(BasicAuth.self, forKey: .auth)
//        case .oAuth_1_0:
//            auth = try container.decode(OAuth1_0.self, forKey: .auth)
//        case .oAuth_2_0:
//            auth = try container.decode(OAuth2_0.self, forKey: .auth)
//        case .awsSignature:
//            auth = try container.decode(AWSSignature.self, forKey: .auth)
//        }
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(authType, forKey: .authType)
//        
//        switch authType {
//        case .inheritFromParent:
//            try container.encode(auth as! InheritFromParent, forKey: .auth)
//        case .none:
//            try container.encode(auth as! NoAuth, forKey: .auth)
//        case .apiKey:
//            try container.encode(auth as! APIKeyAuth, forKey: .auth)
//        case .bearerToken:
//            try container.encode(auth as! BearerTokenAuth, forKey: .auth)
//        case .basicAuth:
//            try container.encode(auth as! BasicAuth, forKey: .auth)
//        case .digestAuth:
//            try container.encode(auth as! BasicAuth, forKey: .auth)
//        case .oAuth_1_0:
//            try container.encode(auth as! OAuth1_0, forKey: .auth)
//        case .oAuth_2_0:
//            try container.encode(auth as! OAuth2_0, forKey: .auth)
//        case .awsSignature:
//            try container.encode(auth as! AWSSignature, forKey: .auth)
//        }
//    }
//}
