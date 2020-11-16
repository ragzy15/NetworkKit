//
//  String+Extension.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 15/10/19.
//

extension String.StringInterpolation {
    
    public mutating func appendInterpolation(_ value: NKEnvironment) {
        appendInterpolation(value.value)
    }
}
