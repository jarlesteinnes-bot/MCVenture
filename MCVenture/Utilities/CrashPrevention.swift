// CrashPrevention.swift - Prevent common crash scenarios

import Foundation
import CoreLocation
import UIKit

class CrashPrevention {
    
    // MARK: - Location Services
    static func checkLocationAuthorization(completion: @escaping (Bool, String?) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true, nil)
        case .denied, .restricted:
            completion(false, "Location access is required for GPS tracking. Please enable in Settings.")
        case .notDetermined:
            completion(false, "Please allow location access to use GPS features.")
        @unknown default:
            completion(false, "Unknown location authorization status")
        }
    }
    
    // MARK: - Network Availability
    static func requiresNetwork(action: String) -> Bool {
        let monitor = NetworkMonitor.shared
        if !monitor.isConnected {
            return false
        }
        return true
    }
    
    // MARK: - Storage Space
    static func checkStorageSpace() -> Bool {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return false
        }
        
        do {
            let values = try URL(fileURLWithPath: path).resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let capacity = values.volumeAvailableCapacity {
                // Require at least 100MB free
                return capacity > 100 * 1024 * 1024
            }
        } catch {
            print("Storage check error: \(error)")
        }
        
        return true
    }
    
    // MARK: - Safe Array Access
    static func safelyAccess<T>(_ array: [T], at index: Int) -> T? {
        guard index >= 0 && index < array.count else {
            return nil
        }
        return array[index]
    }
    
    // MARK: - Safe Dictionary Access
    static func safelyAccess<K, V>(_ dict: [K: V], key: K) -> V? {
        return dict[key]
    }
    
    // MARK: - Safe Unwrapping
    static func unwrapOrDefault<T>(_ optional: T?, default: T) -> T {
        return optional ?? `default`
    }
}

// MARK: - Safe String Extensions
extension String {
    var safeString: String {
        return InputValidator.sanitize(self)
    }
    
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + "..."
    }
}

// MARK: - Safe Array Extensions
extension Array {
    subscript(safe index: Int) -> Element? {
        return CrashPrevention.safelyAccess(self, at: index)
    }
}
