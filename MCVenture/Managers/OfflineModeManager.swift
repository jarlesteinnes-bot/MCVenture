//
//  OfflineModeManager.swift
//  MCVenture
//

import Foundation
import Network
import Combine

class OfflineModeManager: ObservableObject {
    static let shared = OfflineModeManager()
    
    @Published var isOffline: Bool = false
    @Published var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
        case none
        
        var displayName: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .ethernet: return "Ethernet"
            case .none: return "Offline"
            case .unknown: return "Unknown"
            }
        }
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = path.status != .satisfied
                
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else if path.status == .satisfied {
                    self?.connectionType = .unknown
                } else {
                    self?.connectionType = .none
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    var canSyncToCloud: Bool {
        !isOffline && (connectionType == .wifi || connectionType == .cellular)
    }
    
    var shouldShowOfflineWarning: Bool {
        isOffline
    }
}
