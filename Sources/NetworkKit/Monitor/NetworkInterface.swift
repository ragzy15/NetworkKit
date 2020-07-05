//
//  NetworkInterface.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 25/04/20.
//

/// Network interface of device.
public enum NetworkInterface: Hashable, CustomStringConvertible {
    
    /// Network is available through **Wi-Fi** connection.
    case wifi
    
    /// Network is available through **Cellular** connection.
    case cellular(CellularInfo)
    
    /// A virtual or otherwise unknown interface type
    case other

    /// A Wired Ethernet link
    case wiredEthernet

    /// The Loopback Interface
    case loopback
    
    public var description: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular(let technology): return "Cellular: \(technology.description)"
        case .other: return "Virtual or unknown"
        case .wiredEthernet: return "Wired Ethernet"
        case .loopback: return "Loopback"
        }
    }
}
