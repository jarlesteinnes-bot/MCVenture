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
        var mergedParams = parameters
        mergedParams["action"] = action
        logEvent("user_action", parameters: mergedParams)
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
    
    // MARK: - Social Features
    
    /// Log when user rates a route
    func routeRated(routeId: String, rating: Int) {
        trackAction("route_rated", parameters: [
            "route_id": routeId,
            "rating": rating
        ])
    }
    
    /// Log when user comments on a route
    func routeCommented(routeId: String, commentLength: Int) {
        trackAction("route_commented", parameters: [
            "route_id": routeId,
            "comment_length": commentLength
        ])
    }
    
    /// Log when user shares a route
    func routeShared(routeId: String, method: String) {
        trackAction("route_shared", parameters: [
            "route_id": routeId,
            "method": method // "link", "image", "social"
        ])
    }
    
    /// Log when user views route details
    func routeViewed(routeId: String, source: String) {
        trackAction("route_viewed", parameters: [
            "route_id": routeId,
            "source": source // "list", "map", "search", "recommendation"
        ])
    }
    
    // MARK: - Search & Discovery
    
    /// Log search query
    func searchPerformed(query: String, resultsCount: Int) {
        trackAction("search_performed", parameters: [
            "query": query,
            "results_count": resultsCount
        ])
    }
    
    /// Log filter usage
    func filterApplied(filterType: String, value: String) {
        trackAction("filter_applied", parameters: [
            "filter_type": filterType,
            "value": value
        ])
    }
    
    // MARK: - Engagement Metrics
    
    /// Track session start
    func sessionStarted() {
        trackAction("session_started", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Track session end
    func sessionEnded(duration: TimeInterval) {
        trackAction("session_ended", parameters: [
            "duration_seconds": duration
        ])
    }
    
    /// Track app foreground
    func appForegrounded() {
        trackAction("app_foregrounded")
    }
    
    /// Track app background
    func appBackgrounded(sessionDuration: TimeInterval) {
        trackAction("app_backgrounded", parameters: [
            "session_duration": sessionDuration
        ])
    }
    
    // MARK: - Navigation & Maps
    
    /// Log map interaction
    func mapInteraction(action: String) {
        trackAction("map_interaction", parameters: [
            "action": action // "zoom", "pan", "marker_tap", "cluster_expand"
        ])
    }
    
    /// Log offline map download
    func offlineMapDownloaded(region: String, sizeKB: Int) {
        trackAction("offline_map_downloaded", parameters: [
            "region": region,
            "size_kb": sizeKB
        ])
    }
    
    // MARK: - Performance Metrics
    
    /// Track app launch time
    func appLaunchCompleted(duration: TimeInterval) {
        trackAction("app_launch", parameters: [
            "duration_ms": Int(duration * 1000)
        ])
        
        if duration > 3.0 {
            logger.warning("⚠️ Slow app launch: \(String(format: "%.2f", duration))s")
        }
    }
    
    /// Track memory usage
    func memoryUsageReported(usedMB: Int, availableMB: Int) {
        logEvent("memory_usage", parameters: [
            "used_mb": usedMB,
            "available_mb": availableMB
        ])
    }
    
    // MARK: - Conversion Events
    
    /// Track premium feature viewed
    func premiumFeatureViewed(feature: String) {
        trackAction("premium_feature_viewed", parameters: [
            "feature": feature
        ])
    }
    
    /// Track upgrade prompt shown
    func upgradePromptShown(trigger: String) {
        trackAction("upgrade_prompt_shown", parameters: [
            "trigger": trigger
        ])
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
