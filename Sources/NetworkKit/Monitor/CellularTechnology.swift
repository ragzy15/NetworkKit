//
//  CellularTechnology.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 29/04/20.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import CoreTelephony

public struct CellularInfo: Hashable, CustomStringConvertible {
    
    public let carriers: [CTCarrier]
    public let dataProvider: CTCarrier?
    public let dataTechnology: CellularTechnology
    
    public var description: String {
        "Carriers: \(carriers)\nTechnology: \(dataTechnology)"
    }
}

public enum CellularTechnology: String, CustomStringConvertible {
    
    /// The Long-Term Evolution (LTE) cellular technology.
    case lte = "LTE"
    
    /// The Enhanced Data rates for GSM Evolution (EDGE) cellular technology.
    case gen2 = "2G"
    
    /// The Universal Mobile Telecommunications System (UMTS) cellular technology.
    case gen3 = "3G"
    
    /// Other newer cellular technology that has not been handled.
    case other = "Other"
    
    /// No cellular connection available.
    case none = "none"
    
    public var description: String {
        rawValue
    }
}

// MARK: INTERNET CONNECTION INTERFACE
enum __CellularTechnology: CustomStringConvertible {
    case cdma
    case edge
    case gprs
    case hrpd
    case hsdpa
    case hsupa
    case lte
    case rev0
    case revA
    case revB
    case wcdma
    
    init?(rawValue: String) {
        switch rawValue {
        case CTRadioAccessTechnologyCDMA1x:         self = .cdma
        case CTRadioAccessTechnologyEdge:           self = .edge
        case CTRadioAccessTechnologyGPRS:           self = .gprs
        case CTRadioAccessTechnologyeHRPD:          self = .hrpd
        case CTRadioAccessTechnologyHSDPA:          self = .hsdpa
        case CTRadioAccessTechnologyHSUPA:          self = .hsupa
        case CTRadioAccessTechnologyLTE:            self = .lte
        case CTRadioAccessTechnologyCDMAEVDORev0:   self = .rev0
        case CTRadioAccessTechnologyCDMAEVDORevA:   self = .revA
        case CTRadioAccessTechnologyCDMAEVDORevB:   self = .revB
        case CTRadioAccessTechnologyWCDMA:          self = .wcdma
        default: return nil
        }
    }
    
    var version: CellularTechnology {
        switch self {
        case .gprs, .edge, .cdma:
            return .gen2
        case .lte:
            return .lte
        default:
            return .gen3
        }
    }
    
    var description: String {
        version.rawValue
    }
}
#endif
