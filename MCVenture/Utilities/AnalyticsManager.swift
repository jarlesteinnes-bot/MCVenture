//
//  AnalyticsManager.swift
//  MCVenture
//
//  Simple analytics and crash tracking
//  Can be extended with Firebase, Sentry, or other services later
//

import Foundation
import os.log

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MCVenture", category: "Analytics")
    
    private init() {}
    
    // MARK: - Event Tracking
    
    /// Log a screen view
    func screenView(_ screenName: String) {
        logEvent("screen_view", parameters: ["screen_name": screenName])
    }
    
    /// Log a user action
    func trackAction(_ action: String, parameters: [String: Any] = [:]) {
        logEvent("user_action", parameters: ["action": action] + parameters)
    }
    
    /// Log when a trip is started
    func tripStarted(routeId: String? = nil) {
        logEvent("trip_started", parameters: ["route_id": routeId ?? "custom"])
    }
    
    /// Log when a trip is completed
    func tripCompleted(distance: Double, duration: TimeInterval) {
        logEvent("trip_completed", parameters: [
            "distance_km": distance,
            "duration_seconds": duration
        ])
    }
    
    /// Log when a route is favorited
    func routeFavorited(routeId: String) {
        logEvent("route_favorited", parameters: ["route_id": routeId])
    }
    
    /// Log when language is changed
    func languageChanged(from: String, to: String) {
        logEvent("language_changed", parameters: [
            "from": from,
            "to": to
        ])
    }
    
    /// Log when routes are scraped
    func routesScraped(count: Int, source: String) {
        logEvent("routes_scraped", parameters: [
            "count": count,
            "source": source
        ])
    }
    
    // MARK: - Error Tracking
    
    /// Log a non-fatal error
    func logError(_ error: Error, context: String) {
        logger.error("❌ Error in \(context): \(error.localizedDescription)")
        
        // Store error for later analysis
        storeError(error, context: context)
    }
    
    /// Log a critical error (potential crash)
    func logCritical(_ error: Error, context: String) {
        logger.critical("🔥 Critical error in \(context): \(error.localizedDescription)")
        
        // Store error for later analysis
        storeError(error, context: context, isCritical: true)
    }
    
    // MARK: - Performance Tracking
    
    /// Track performance of an operation
    func trackPerformance(_ operation: String, duration: TimeInterval) {
        logger.info("⚡ \(operation) took \(String(format: "%.2f", duration))s")
        
        if duration > 3.0 {
            logger.warning("⚠️ \(operation) is slow: \(String(format: "%.2f", duration))s")
        }
    }
    
    /// Time an async operation
    func timeOperation<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let start = Date()
        let result = try await block()
        let duration = Date().timeIntervalSince(start)
        trackPerformance(operation, duration: duration)
        return result
    }
    
    // MARK: - Private Helpers
    
    private func logEvent(_ event: String, parameters: [String: Any]) {
        var paramString = ""
        if !parameters.isEmpty {
            paramString = " | " + parameters.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        
        logger.info("📊 Event: \(event)\(paramString)")
        
        // Here you would send to analytics service
        // For now, we just log to console
        // In production, integrate with:
        // - Firebase Analytics
        // - Sentry
        // - AppCenter
        // - Custom backend
    }
    
    private func storeError(_ error: Error, context: String, isCritical: Bool = false) {
        // Store error in UserDefaults for later upload
        let errorData: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "context": context,
            "error": error.localizedDescription,
            "critical": isCritical,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "osVersion": ProcessInfo.processInfo.operatingSystemVersionString
        ]
        
        var storedErrors = UserDefaults.standard.array(forKey: "stored_errors") as? [[String: Any]] ?? []
        storedErrors.append(errorData)
        
        // Keep only last 100 errors
        if storedErrors.count > 100 {
            storedErrors = Array(storedErrors.suffix(100))
        }
        
        UserDefaults.standard.set(storedErrors, forKey: "stored_errors")
    }
    
    // MARK: - Public Helpers
    
    /// Get stored errors for debugging or upload
    func getStoredErrors() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: "stored_errors") as? [[String: Any]] ?? []
    }
    
    /// Clear stored errors after successful upload
    func clearStoredErrors() {
        UserDefaults.standard.removeObject(forKey: "stored_errors")
    }
}

// MARK: - Convenience Methods
extension AnalyticsManager {
    /// Log feature usage
    func featureUsed(_ feature: String) {
        trackAction("feature_used", parameters: ["feature": feature])
    }
    
    /// Log when user completes onboarding
    func onboardingCompleted() {
        trackAction("onboarding_completed")
    }
    
    /// Log when user grants permission
    func permissionGranted(_ permission: String) {
        trackAction("permission_granted", parameters: ["permission": permission])
    }
    
    /// Log when user denies permission
    func permissionDenied(_ permission: String) {
        trackAction("permission_denied", parameters: ["permission": permission])
    }
}

// MARK: - Usage Examples
/*
 // Screen views
 AnalyticsManager.shared.screenView("RoutesView")
 
 // User actions
 AnalyticsManager.shared.trackAction("search_routes", parameters: ["query": "norway"])
 
 // Errors
 do {
     try await riskyOperation()
 } catch {
     AnalyticsManager.shared.logError(error, context: "Route scraping")
 }
 
 // Performance
 await AnalyticsManager.shared.timeOperation("Load routes") {
     await loadRoutes()
 }
 
 // Trip tracking
 AnalyticsManager.shared.tripStarted(routeId: route.id)
 AnalyticsManager.shared.tripCompleted(distance: 42.5, duration: 3600)
 */
