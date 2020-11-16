//
//  RequestBodyType.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 01/11/20.
//

import Foundation

public enum RequestBodyType: String, CaseIterable, Identifiable {
    
    case none = "none"
    case formData = "form-data"
    case formUrlEncoded = "x-wwww-form-urlencoded"
    case raw = "raw"
    case binary = "binary"
    
    public var id: String { rawValue }
}

public enum RequestBodyRawType: String, CaseIterable, Identifiable {
    case text = "Text"
//    case javascript = "JavaScript"
    case json = "JSON"
    case html = "HTML"
    case xml = "XML"
    
    public var id: String { rawValue }
}
