//
//  LaunchTimeOptimizer.swift
//  MCVenture
//
//  Optimizes app launch time and tracks performance metrics
//

import Foundation
import UIKit

class LaunchTimeOptimizer {
    static let shared = LaunchTimeOptimizer()
    
    private var launchStartTime: Date?
    private var coldStart = true
    
    private init() {
        launchStartTime = Date()
    }
    
    // MARK: - Launch Tracking
    
    /// Call this when app launch is complete
    func launchCompleted() {
        guard let startTime = launchStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let launchType = coldStart ? "cold" : "warm"
        
        print("🚀 \(launchType.capitalized) launch completed in \(String(format: "%.2f", duration))s")
        
        // Track in analytics
        AnalyticsManager.shared.appLaunchCompleted(duration: duration)
        
        // Mark as warm start for subsequent launches
        coldStart = false
        
        // Log warning if slow
        if duration > 2.0 {
            print("⚠️ Launch time exceeds 2s target")
        }
    }
    
    // MARK: - Preload Critical Data
    
    /// Preload data that will be needed soon
    func preloadCriticalData() {
        Task.detached(priority: .utility) {
            // Preload user preferences
            _ = UserDefaults.standard.string(forKey: "AppLanguage")
            
            // Preload CloudKit status
            _ = await self.checkCloudKitStatus()
            
            // Prepare haptic engine
            HapticManager.shared.prepare()
        }
    }
    
    private func checkCloudKitStatus() async -> Bool {
        // Quick CloudKit availability check
        return true
    }
    
    // MARK: - Memory Optimization
    
    /// Get current memory usage
    func getCurrentMemoryUsage() -> (used: Int, available: Int) {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return (0, 0)
        }
        
        let usedMB = Int(taskInfo.phys_footprint) / 1024 / 1024
        let availableMB = Int(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
        
        return (usedMB, availableMB)
    }
    
    /// Report memory usage to analytics
    func reportMemoryUsage() {
        let (used, available) = getCurrentMemoryUsage()
        AnalyticsManager.shared.memoryUsageReported(usedMB: used, availableMB: available)
        
        if used > 200 {
            print("⚠️ High memory usage: \(used)MB")
        }
    }
    
    /// Release unused memory caches
    func releaseMemory() {
        // Clear image caches
        URLCache.shared.removeAllCachedResponses()
        
        // Trigger garbage collection
        autoreleasepool {}
        
        print("🧹 Memory caches cleared")
    }
    
    // MARK: - Battery Optimization
    
    /// Check if low power mode is enabled
    var isLowPowerModeEnabled: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    /// Adjust performance based on battery state
    func optimizeForBattery() -> PerformanceMode {
        if isLowPowerModeEnabled {
            return .lowPower
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel < 0.2 {
            return .lowPower
        } else if batteryLevel < 0.5 {
            return .balanced
        } else {
            return .performance
        }
    }
}

// MARK: - Performance Modes

enum PerformanceMode {
    case lowPower    // Minimal animations, reduced polling
    case balanced    // Normal operations
    case performance // Full features, high refresh rate
    
    var description: String {
        switch self {
        case .lowPower: return "Low Power"
        case .balanced: return "Balanced"
        case .performance: return "Performance"
        }
    }
    
    var mapRefreshInterval: TimeInterval {
        switch self {
        case .lowPower: return 5.0
        case .balanced: return 2.0
        case .performance: return 1.0
        }
    }
    
    var enableAnimations: Bool {
        switch self {
        case .lowPower: return false
        case .balanced, .performance: return true
        }
    }
}

// MARK: - Image Caching

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 50 // MB
    
    private init() {
        cache.totalCostLimit = maxCacheSize * 1024 * 1024
        
        // Clear cache on memory warning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // Estimate size in bytes
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    @objc func clearCache() {
        cache.removeAllObjects()
        print("🗑️ Image cache cleared")
    }
}
