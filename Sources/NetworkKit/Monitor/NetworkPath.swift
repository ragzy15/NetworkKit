//
//  NetworkPath.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 25/04/20.
//

/// An NetworkPath object represents a snapshot of network state. This state represents the known information about the local interface and routes that may be used to send and receive data. If the network details for a connection changes due to interface characteristics, addresses, or other attributes, a new NetworkDetails object will be generated.
public struct NetworkPath: Equatable {
    
    private let _isConstrained: Bool
    
    /// Checks if the path uses an NetworkInterface that is considered to be constrained by user preference
    @available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public var isConstrained: Bool {
        _isConstrained
    }
    
    /// Checks if the path uses an NetworkInterface that is considered to be expensive
    ///
    /// Cellular interfaces are considered expensive. WiFi hotspots from an iOS device are considered expensive. Other
    /// interfaces may appear as expensive in the future.
    public let isExpensive: Bool
    
    /// A list of all interfaces available to the path, in order of preference.
    public let interfaces: [NetworkInterface]
    
    /// An NetworkPath status indicates if there is a usable route available upon which to send and receive data.
    public enum Status: Hashable {
        
        /// The path is available to establish connections and send data.
        ///
        /// The path has a usable route upon which to send and receive data.
        case satisfied
        
        /// The path is not available for use.
        ///
        /// The path does not have a usable route. This may be due to a network interface being down, or due to system policy.
        case unsatisfied
        
        /// The path is not currently available, but establishing a new connection may activate the path.
        ///
        /// The path does not currently have a usable route, but a connection attempt will trigger network attachment.
        case requiresConnection
    }
    
    /// A status indicating whether a path can be used by connections.
    public let status: Status
    
    /// Convenience variable to check if internet is available. But you should always
    public var isConnectedToInternet: Bool {
        status == .satisfied
    }
    
    init(isConstrained: Bool = false, isExpensive: Bool, interfaces: [NetworkInterface], status: Status) {
        self._isConstrained = isConstrained
        self.isExpensive = isExpensive
        self.interfaces = interfaces
        self.status = status
    }
}
