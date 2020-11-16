//
//  _NetworkMonitor.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 21/04/20.
//

import Network

#if os(iOS) && !targetEnvironment(macCatalyst)
import CoreTelephony
#endif

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
final class _NWNetworkMonitor: _NetworkMonitorType {
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    let telephoneNetworkInfo: CTTelephonyNetworkInfo
    
    var _isMonitoringCellularInfo: Bool = false
    
    var isMonitoringCellularInfo: Bool {
        _isMonitoringCellularInfo
    }
    #endif
    
    static let `default` = _NWNetworkMonitor()
    
    private let monitor: NWPathMonitor
    
    let queue = DispatchQueue(label: "com.networkkit.network-monitor", qos: .background)
    
    private(set) var currentPath: NetworkPath
    
    var _isMonitoringNetworkPath: Bool = false
    
    var isMonitoringNetworkPath: Bool {
        _isMonitoringNetworkPath
    }
    
    init() {
        let monitor = NWPathMonitor()
        self.monitor = monitor
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let telephoneNetwork = CTTelephonyNetworkInfo()
        self.telephoneNetworkInfo = telephoneNetwork
        currentPath = monitor.currentPath.networkPath(for: _NWNetworkMonitor.cellularInfo(using: telephoneNetwork))
        #else
        currentPath = monitor.currentPath.networkPath()
        #endif
    }
    
    deinit {
        monitor.cancel()
    }
    
    func startMonitoringNetworkPath(handler: NetworkPathHandler?) {
        guard !_isMonitoringNetworkPath else {
            return
        }
        
        _isMonitoringNetworkPath = true
        updates(handler)
        monitor.start(queue: queue)
    }
    
    private func updates(_ handler: NetworkPathHandler?) {
        guard let handler = handler else {
            return
        }
        
        monitor.pathUpdateHandler = { [weak self] (path) in
            
            guard let `self` = self else {
                return
            }
            
            #if os(iOS) && !targetEnvironment(macCatalyst)
            let networkPath = path.networkPath(for: self.cellularInfo)
            #else
            let networkPath = path.networkPath()
            #endif
            
            self.currentPath = networkPath
            
            handler(networkPath)
        }
    }
    
    func stopMonitoringNetworkPath() {
        guard _isMonitoringNetworkPath else {
            return
        }
        
        _isMonitoringNetworkPath = false
        monitor.cancel()
        monitor.pathUpdateHandler = nil
    }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
extension NWInterface.InterfaceType {
    
    #if (os(iOS) && !targetEnvironment(macCatalyst))
    func _networkInterface(cellular: CellularInfo) -> NetworkInterface {
        switch self {
            case .wifi                              : return .wifi
            case .cellular                          : return .cellular(cellular)
            case .other                             : return .other
            case .wiredEthernet                     : return .wiredEthernet
            case .loopback                          : return .loopback
            @unknown default                        : return .other
        }
    }
    
    #else
    func _networkInterface() -> NetworkInterface {
        switch self {
        case .wifi                              : return .wifi
        case .cellular                          : return .cellular
        case .other                             : return .other
        case .wiredEthernet                     : return .wiredEthernet
        case .loopback                          : return .loopback
        @unknown default                        : return .other
        }
    }
    #endif
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
extension NWPath.Status {
    
    var _status: NetworkPath.Status {
        switch self {
        case .satisfied             : return .satisfied
        case .unsatisfied           : return .unsatisfied
        case .requiresConnection    : return .requiresConnection
        @unknown default            : return .satisfied
        }
    }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
extension NWPath {
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func networkPath(for cellularInfo: CellularInfo) -> NetworkPath {
        
        let isExpensive = self.isExpensive
        let status = self.status._status
        let interfaces = availableInterfaces.map { $0.type._networkInterface(cellular: cellularInfo) }
        
        if #available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return NetworkPath(isConstrained: isConstrained, isExpensive: isExpensive, interfaces: interfaces, status: status)
        } else {
            return NetworkPath(isExpensive: isExpensive, interfaces: interfaces, status: status)
        }
    }
    
    #else
    func networkPath() -> NetworkPath {
        
        let isExpensive = self.isExpensive
        let status = self.status._status
        let interfaces = availableInterfaces.map { $0.type._networkInterface() }
        
        if #available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return NetworkPath(isConstrained: isConstrained, isExpensive: isExpensive, interfaces: interfaces, status: status)
        } else {
            return NetworkPath(isExpensive: isExpensive, interfaces: interfaces, status: status)
        }
    }
    #endif
}
