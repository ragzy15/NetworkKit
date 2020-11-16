//
//  HTTP Body Encoding.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPBodyEncodingType {
    case formURLEncoded
    case json
    
    public var headers: HTTPHeaderParameters {
        switch self {
        case .formURLEncoded:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        case .json:
            return ["Content-Type": "application/json"]
        }
    }
    
    public func encode(body: [String: Any]) -> Data? {
        switch self {
        case .formURLEncoded:
            if let bodyData = query(body).data(using: .utf8, allowLossyConversion: false) {
            
            #if DEBUG
            print("""
                Request Body:
                \(String(data: bodyData, encoding: .utf8) ?? "nil")
                ---------------------------------------------
                
                """)
            #endif

                return bodyData
                
            } else {
                #if DEBUG
                print("""
                    Request Body: nil
                    Error Encoding: - Unknown
                    ---------------------------------------------
                    
                    """)
                #endif
                
                return nil
            }
            
            
        case .json:
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                
                #if DEBUG
                print("""
                    Request Body:
                    \(String(data: bodyData, encoding: .utf8) ?? "nil")
                    ---------------------------------------------
                    
                    """)
                #endif
                
                return bodyData
                
            } catch {
                #if DEBUG
                print("""
                    Request Body: nil
                    Error Encoding: -
                    \(error)
                    ---------------------------------------------
                    
                    """)
                #endif
                
                return nil
            }
        }
    }
}

private extension HTTPBodyEncodingType {
    
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    func queryComponents(fromKey key: String,
                                 value: Any, arrayEncoding: ArrayEncoding = .brackets,
                                 boolEncoding: BoolEncoding = .numeric) -> [(String, String)] {
        
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
            }
        } else if let value = value as? NSNumber {
            if value.boolValue {
                components.append((escape(key), escape(boolEncoding.encode(value: value.boolValue))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
    }
}


enum BoolEncoding {
    case numeric
    case literal
    
    func encode(value: Bool) -> String {
        switch self {
        case .numeric:
            return value ? "1" : "0"
        case .literal:
            return value ? "true" : "false"
        }
    }
}

enum ArrayEncoding {
    case brackets
    case noBrackets
    
    func encode(key: String) -> String {
        switch self {
        case .brackets:
            return "\(key)[]"
        case .noBrackets:
            return key
        }
    }
}
