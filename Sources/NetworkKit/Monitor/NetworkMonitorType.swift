//
//  NetworkMonitorType.swift
//  NetworkKit
//
//  Created by Raghav Ahuja on 21/04/20.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import CoreTelephony
#endif

public protocol NetworkMonitorType: class {
    
    typealias NetworkPathHandler = (NetworkPath) -> Void
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    typealias CellularInfoHandler = (CellularInfo) -> Void
    
    var cellularInfo: CellularInfo { get }
    
    /// Flag which tells if network is being monitored or not.
    var isMonitoringCellularInfo: Bool { get }
    
    /// Start monitoring cellular carrier updates.
    /// - Parameter handler: A handler that receives carrier updates.
    func startMonitoringCellularInfo(handler: @escaping CellularInfoHandler)
    
    /// Stop monitoring cellular carrier updates.
    func stopMonitoringCellularInfo()
    #endif
    
    /// The currently available network path observed by the path monitor.
    var currentPath: NetworkPath { get }
    
    /// Flag which tells if network is being monitored or not.
    var isMonitoringNetworkPath: Bool { get }
    
    /// Start monitoring network changes.
    /// - Parameter handler: A handler that receives network updates.
    func startMonitoringNetworkPath(handler: NetworkPathHandler?)
    
    /// Stop monitoring network changes.
    func stopMonitoringNetworkPath()
}

protocol _NetworkMonitorType: NetworkMonitorType {
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    var telephoneNetworkInfo: CTTelephonyNetworkInfo { get }
    
    var _isMonitoringCellularInfo: Bool { get set }
    #endif
    
    var _isMonitoringNetworkPath: Bool { get set }
}

// MARK: CELLULAR HANDLING

#if os(iOS) && !targetEnvironment(macCatalyst)
extension _NetworkMonitorType {
    
    var cellularInfo: CellularInfo {
        Self.cellularInfo(using: telephoneNetworkInfo)
    }
    
    func startMonitoringCellularInfo(handler: @escaping CellularInfoHandler) {
        guard !_isMonitoringCellularInfo else { return }
        _isMonitoringCellularInfo = true
        
        if #available(iOS 12.0, *) {
            telephoneNetworkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = { [weak self] (_) in
                guard let `self` = self else {
                    return
                }
                
                handler(self.cellularInfo)
            }
        } else {
            telephoneNetworkInfo.subscriberCellularProviderDidUpdateNotifier = { [weak self] (_) in
                guard let `self` = self else {
                    return
                }
                
                handler(self.cellularInfo)
            }
        }
    }
    
    func stopMonitoringCellularInfo() {
        guard _isMonitoringCellularInfo else { return }
        _isMonitoringCellularInfo = false
        
        if #available(iOS 12.0, *) {
            telephoneNetworkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = nil
        } else {
            telephoneNetworkInfo.subscriberCellularProviderDidUpdateNotifier = nil
        }
    }
}

extension _NetworkMonitorType {
    
    static func cellularInfo(using telephoneNetworkInfo: CTTelephonyNetworkInfo) -> CellularInfo {
        
        let carriers: [CTCarrier]
        
        if #available(iOS 12.0, *) {
            carriers = telephoneNetworkInfo.serviceSubscriberCellularProviders?.compactMap { $0.value } ?? []
        } else {
            if let carrier = telephoneNetworkInfo.subscriberCellularProvider {
                carriers = [carrier]
            } else {
                carriers = []
            }
        }
        
        let dataProvider: CTCarrier?
        
        if #available(iOS 13.0, *) {
            if let provider = telephoneNetworkInfo.dataServiceIdentifier {
                dataProvider = telephoneNetworkInfo.serviceSubscriberCellularProviders?[provider]
            } else {
                dataProvider = nil
            }
        } else {
            if #available(iOS 12.0, *) {
                dataProvider = telephoneNetworkInfo.serviceSubscriberCellularProviders?.first?.value
            } else {
                dataProvider = telephoneNetworkInfo.subscriberCellularProvider
            }
        }
        
        let dataTechnology: CellularTechnology
        
        if #available(iOS 13.0, *), let dataProvider = telephoneNetworkInfo.dataServiceIdentifier, let tech = telephoneNetworkInfo.serviceCurrentRadioAccessTechnology?[dataProvider] {
            dataTechnology = __CellularTechnology(rawValue: tech)?.version ?? .other
        } else if #available(iOS 12.0, *), let tech = telephoneNetworkInfo.serviceCurrentRadioAccessTechnology?.first?.value {
            dataTechnology = __CellularTechnology(rawValue: tech)?.version ?? .other
        } else if let tech = telephoneNetworkInfo.currentRadioAccessTechnology {
            dataTechnology = __CellularTechnology(rawValue: tech)?.version ?? .other
        } else {
            dataTechnology = .none
        }
        
        return CellularInfo(carriers: carriers,
                            dataProvider: dataProvider,
                            dataTechnology: dataTechnology)
    }
}
#endif
