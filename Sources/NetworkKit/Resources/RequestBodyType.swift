//
//  RequestBodyType.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 01/11/20.
//

import Foundation

public enum RequestBodyType: String, CaseIterable, Identifiable {
    
    case none = "None"
    case formData = "Form-data"
    case formUrlEncoded = "x-wwww-form-urlencoded"
    case raw = "Raw"
    case binary = "Binary"
    
    public var id: String { rawValue }
}

public enum RequestBodyRawType: String, CaseIterable, Identifiable {
    case text = "Text"
    case javascript = "JavaScript"
    case json = "JSON"
    case html = "HTML"
    case xml = "XML"
    
    public var id: String { rawValue }
}
