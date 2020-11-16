//
//  _SCNetworkMonitor.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 21/04/20.
//

// MARK: REACHABILITY TAKEN FROM ALAMOFIRE

import Foundation
import PublisherKit

#if os(iOS) && !targetEnvironment(macCatalyst)
import CoreTelephony
#endif

#if !(os(watchOS))
import SystemConfiguration

/// The `NetworkReachabilityManager` class listens for reachability changes of hosts and addresses for both cellular and
/// WiFi network interfaces.
///
/// Reachability can be used to determine background information about why a network operation failed, or to retry
/// network requests when a connection is established. It should not be used to prevent a user from initiating a network
/// request, as it's possible that an initial request may be required to establish reachability.
final class _SCNetworkMonitor: _NetworkMonitorType {
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    let telephoneNetworkInfo = CTTelephonyNetworkInfo()
    
    var _isMonitoringCellularInfo: Bool = false
    
    var isMonitoringCellularInfo: Bool {
        _isMonitoringCellularInfo
    }
    #endif
    
    private(set) var currentPath: NetworkPath
    
    var _isMonitoringNetworkPath: Bool = false
    
    var isMonitoringNetworkPath: Bool {
        _isMonitoringNetworkPath
    }
    
    private let queue = DispatchQueue(label: "com.networkkit.network-monitor", qos: .background)
    
    func startMonitoringNetworkPath(handler: NetworkPathHandler?) {
        guard !isMonitoringNetworkPath else {
            return
        }
        
        _isMonitoringNetworkPath = startListening(listener: handler)
    }
    
    func stopMonitoringNetworkPath() {
        guard _isMonitoringNetworkPath else {
            return
        }
        
        _isMonitoringNetworkPath = false
        
        stopListening()
    }
    
    /// Defines the various states of network reachability.
    enum NetworkReachabilityStatus {
        
        /// It is unknown whether the network is reachable.
        case unknown(NetworkInterface)
        
        /// The network is not reachable.
        case notReachable(NetworkInterface)
        
        /// The network is reachable on the associated `NetworkInterface`.
        case reachable(NetworkInterface)
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        init(_ flags: SCNetworkReachabilityFlags, cellular: CellularInfo) {
            guard flags.isActuallyReachable else {
                
                if flags.isCellular {
                    self = .notReachable(.cellular(cellular))
                } else {
                    self = .notReachable(.wifi)
                }
                return
            }

            var networkStatus: NetworkReachabilityStatus = .reachable(.wifi)

            if flags.isCellular { networkStatus = .reachable(.cellular(cellular)) }

            self = networkStatus
        }
        #else
        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isActuallyReachable else {
                
                if flags.isCellular {
                    self = .notReachable(.other)
                } else {
                    self = .notReachable(.wifi)
                }
                return
            }

            var networkStatus: NetworkReachabilityStatus = .reachable(.wifi)

            if flags.isCellular { networkStatus = .reachable(.other) }

            self = networkStatus
        }
        #endif
    }

    /// Default `NetworkReachabilityManager` for the zero address and a `listenerQueue` of `.main`.
    static let `default` = _SCNetworkMonitor()

    // MARK: - Properties
    /// Whether the network is currently reachable.
    var isReachable: Bool { isReachableOnCellular || isReachableOnEthernetOrWiFi }

    /// Whether the network is currently reachable over the cellular interface.
    ///
    /// - Note: Using this property to decide whether to make a high or low bandwidth request is not recommended.
    ///         Instead, set the `allowsCellularAccess` on any `URLRequest`s being issued.
    ///
    var isReachableOnCellular: Bool {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return status == .reachable(.cellular(cellularInfo))
        #else
        return status == .reachable(.other)
        #endif
    }

    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    var isReachableOnEthernetOrWiFi: Bool { status == .reachable(.wifi) }

    /// Flags of the current reachability type, if any.
    var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()

        return (SCNetworkReachabilityGetFlags(reachability, &flags)) ? flags : nil
    }

    /// The current network reachability status.
    var status: NetworkReachabilityStatus {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return flags.map { NetworkReachabilityStatus($0, cellular: cellularInfo) } ?? .unknown(.other)
        #else
        return flags.map { NetworkReachabilityStatus($0) } ?? .unknown(.other)
        #endif
    }

    /// Mutable state storage.
    struct MutableState {
        
        /// A closure executed when the network reachability status changes.
        var listener: NetworkPathHandler?
        
        /// `DispatchQueue` on which listeners will be called.
        var listenerQueue: DispatchQueue?
        
        /// Previously calculated status.
        var previousStatus: NetworkReachabilityStatus?
    }

    /// `SCNetworkReachability` instance providing notifications.
    private let reachability: SCNetworkReachability

    /// Protected storage for mutable state.
    @Protected
    private var mutableState = MutableState()

    /// Creates an instance that monitors the address 0.0.0.0.
    ///
    /// Reachability treats the 0.0.0.0 address as a special token that causes it to monitor the general routing
    /// status of the device, both IPv4 and IPv6.
    convenience init?() {
        var zero = sockaddr()
        zero.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zero.sa_family = sa_family_t(AF_INET)

        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zero) else { return nil }

        self.init(reachability: reachability)
    }

    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
        currentPath = NetworkPath(isExpensive: false, interfaces: [], status: .unsatisfied)
        
        let isExpensive: Bool
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if case .reachable(let interface) = status, case .cellular = interface {
            isExpensive = true
        } else {
            isExpensive = false
        }
        #else
        isExpensive = false
        #endif
        
        let interface: NetworkInterface
        
        switch status {
        case .reachable(let _interface): interface = _interface
        case .notReachable(let _interface): interface = _interface
        case .unknown: interface = .other
        }
        
        currentPath = NetworkPath(isExpensive: isExpensive, interfaces: [interface], status: flags?.pathStatus ?? .unsatisfied)
    }

    deinit {
        stopListening()
    }

    // MARK: - Listening
    /// Starts listening for changes in network reachability status.
    ///
    /// - Note: Stops and removes any existing listener.
    ///
    /// - Parameters:
    ///   - queue:    `DispatchQueue` on which to call the `listener` closure. `.main` by default.
    ///   - listener: `Listener` closure called when reachability changes.
    ///
    /// - Returns: `true` if listening was started successfully, `false` otherwise.
    @discardableResult
    func startListening(listener: NetworkPathHandler?) -> Bool {
        stopListening()

        $mutableState.write { state in
            state.listenerQueue = queue
            state.listener = listener
        }

        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: Unmanaged.passRetained(self).toOpaque(),
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)
        let callback: SCNetworkReachabilityCallBack = { _, flags, info in
            guard let info = info else { return }

            let instance = Unmanaged<_SCNetworkMonitor>.fromOpaque(info).takeUnretainedValue()
            instance.notifyListener(flags)
        }

        let queueAdded = SCNetworkReachabilitySetDispatchQueue(reachability, queue)
        let callbackAdded = SCNetworkReachabilitySetCallback(reachability, callback, &context)

        // Manually call listener to give initial state, since the framework may not.
        if let currentFlags = flags {
            queue.async {
                self.notifyListener(currentFlags)
            }
        }

        return callbackAdded && queueAdded
    }

    /// Stops listening for changes in network reachability status.
    func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        
        $mutableState.write { state in
            state.listener = nil
            state.listenerQueue = nil
            state.previousStatus = nil
        }
    }

    // MARK: - Internal - Listener Notification
    /// Calls the `listener` closure of the `listenerQueue` if the computed status hasn't changed.
    ///
    /// - Note: Should only be called from the `reachabilityQueue`.
    ///
    /// - Parameter flags: `SCNetworkReachabilityFlags` to use to calculate the status.
    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let newStatus = NetworkReachabilityStatus(flags, cellular: cellularInfo)
        #else
        let newStatus = NetworkReachabilityStatus(flags)
        #endif

        $mutableState.write { state in
            guard state.previousStatus != newStatus else { return }

            state.previousStatus = newStatus

            let listener = state.listener
            
            let currentInterface: NetworkInterface
            
            switch newStatus {
            case .reachable(let interface): currentInterface = interface
            case .notReachable(let interface): currentInterface = interface
            case .unknown: currentInterface = .other
            }
            
            let isExpensive: Bool
            
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if case .cellular = currentInterface {
                isExpensive = true
            } else {
                isExpensive = false
            }
            #else
            isExpensive = false
            #endif
            
            let details = NetworkPath(isExpensive: isExpensive, interfaces: [currentInterface], status: flags.pathStatus)
            
            state.listenerQueue?.async {
                listener?(details)
            }
        }
    }
}

// MARK: -
extension _SCNetworkMonitor.NetworkReachabilityStatus: Equatable {}

extension SCNetworkReachabilityFlags {
    
    var isReachable: Bool { contains(.reachable) }
    var isConnectionRequired: Bool { contains(.connectionRequired) }
    var canConnectAutomatically: Bool { contains(.connectionOnDemand) || contains(.connectionOnTraffic) }
    var canConnectWithoutUserInteraction: Bool { canConnectAutomatically && !contains(.interventionRequired) }
    var isActuallyReachable: Bool { isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction) }
    
    var isCellular: Bool {
        #if os(iOS) || os(tvOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }
    
    var pathStatus: NetworkPath.Status {
        if isConnectionRequired {
            return .requiresConnection
        } else {
            return isActuallyReachable ? .satisfied : .unsatisfied
        }
    }
}
#endif

/// A thread-safe wrapper around a value.
@propertyWrapper
@dynamicMemberLookup
fileprivate final class Protected<T> {
    
    private let lock = Lock()
    
    private var value: T

    init(_ value: T) {
        self.value = value
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    var wrappedValue: T {
        get { lock.do { value } }
        set { lock.do { value = newValue } }
    }

    var projectedValue: Protected<T> { self }

    init(wrappedValue: T) {
        value = wrappedValue
    }

    /// Synchronously read or transform the contained value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The return value of the closure passed.
    func read<U>(_ closure: (T) -> U) -> U {
        lock.do { closure(self.value) }
    }

    /// Synchronously modify the protected value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The modified value.
    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.do { closure(&self.value) }
    }

    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.do { value[keyPath: keyPath] } }
        set { lock.do { value[keyPath: keyPath] = newValue } }
    }
}
