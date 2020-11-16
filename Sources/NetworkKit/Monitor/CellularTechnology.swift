//
//  CellularTechnology.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 29/04/20.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import CoreTelephony
#endif

public struct CellularInfo: Hashable {
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public let carriers: [CTCarrier]
    public let dataProvider: CTCarrier?
    
    public let dataTechnology: CellularTechnology
    #endif
}

#if os(iOS) && !targetEnvironment(macCatalyst)
extension CellularInfo: CustomStringConvertible {
    public var description: String {
        return "Carriers: \(carriers)\nTechnology: \(dataTechnology)"
    }
}
#endif

public enum CellularTechnology: String, CustomStringConvertible {
    
    
    #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(watchOS)
    /// The Long-Term Evolution (LTE) cellular technology.
    case lte = "LTE"
    #endif
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// The Enhanced Data rates for GSM Evolution (EDGE) cellular technology.
    case gen2 = "2G"
    
    /// The Universal Mobile Telecommunications System (UMTS) cellular technology.
    case gen3 = "3G"
    
    /// Other newer cellular technology that has not been handled.
    case other = "Other"
    #endif
    
    /// No cellular connection available.
    case none = "none"
    
    public var description: String {
        rawValue
    }
}

#if (os(iOS) && !targetEnvironment(macCatalyst))
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
