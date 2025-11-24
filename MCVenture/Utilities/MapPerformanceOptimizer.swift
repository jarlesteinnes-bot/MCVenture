//
//  MapPerformanceOptimizer.swift
//  MCVenture
//
//  Map performance optimization with clustering and lazy loading
//

import Foundation
import MapKit
import CoreLocation

class MapPerformanceOptimizer {
    static let shared = MapPerformanceOptimizer()
    
    private init() {}
    
    // MARK: - Annotation Clustering
    
    /// Cluster annotations that are close together
    func clusterAnnotations(_ routes: [ScrapedRoute], in region: MKCoordinateRegion, clusterRadius: Double = 0.05) -> [RouteCluster] {
        var clusters: [RouteCluster] = []
        var processedRoutes: Set<String> = []
        
        for route in routes {
            guard !processedRoutes.contains(route.id.uuidString) else { continue }
            
            // Get route center coordinate
            guard let routeCoord = route.centerCoordinate else { continue }
            
            // Find nearby routes
            let nearbyRoutes = routes.filter { otherRoute in
                guard let otherCoord = otherRoute.centerCoordinate else { return false }
                return !processedRoutes.contains(otherRoute.id.uuidString) &&
                       distance(from: routeCoord, to: otherCoord) < clusterRadius
            }
            
            if nearbyRoutes.count > 1 {
                // Create cluster
                let cluster = RouteCluster(routes: nearbyRoutes)
                clusters.append(cluster)
                nearbyRoutes.forEach { processedRoutes.insert($0.id.uuidString) }
            } else {
                // Single route (no clustering needed)
                let cluster = RouteCluster(routes: [route])
                clusters.append(cluster)
                processedRoutes.insert(route.id.uuidString)
            }
        }
        
        return clusters
    }
    
    /// Filter routes to only those visible in the current map region
    func filterVisibleRoutes(_ routes: [ScrapedRoute], in region: MKCoordinateRegion) -> [ScrapedRoute] {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2
        
        return routes.filter { route in
            guard let coord = route.centerCoordinate else { return false }
            return coord.latitude >= minLat &&
                   coord.latitude <= maxLat &&
                   coord.longitude >= minLon &&
                   coord.longitude <= maxLon
        }
    }
    
    /// Check if clustering should be enabled based on route count
    func shouldCluster(routeCount: Int, zoomLevel: Double) -> Bool {
        // Cluster if more than 50 routes and zoomed out
        return routeCount > 50 && zoomLevel > 0.5
    }
    
    // MARK: - Distance Calculation
    
    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let latDiff = from.latitude - to.latitude
        let lonDiff = from.longitude - to.longitude
        return sqrt(latDiff * latDiff + lonDiff * lonDiff)
    }
    
    // MARK: - Lazy Loading
    
    /// Load routes in batches for better performance
    func batchLoadRoutes(_ allRoutes: [ScrapedRoute], batchSize: Int = 50, offset: Int = 0) -> [ScrapedRoute] {
        let startIndex = offset
        let endIndex = min(offset + batchSize, allRoutes.count)
        
        guard startIndex < allRoutes.count else { return [] }
        
        return Array(allRoutes[startIndex..<endIndex])
    }
    
    /// Calculate optimal batch size based on device capabilities
    func optimalBatchSize() -> Int {
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = processInfo.physicalMemory
        
        // Adjust batch size based on available memory
        if physicalMemory > 8_000_000_000 { // > 8GB
            return 100
        } else if physicalMemory > 4_000_000_000 { // > 4GB
            return 75
        } else {
            return 50
        }
    }
}

// MARK: - Route Cluster Model

struct RouteCluster: Identifiable {
    let id = UUID()
    let routes: [ScrapedRoute]
    
    var coordinate: CLLocationCoordinate2D {
        guard !routes.isEmpty else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let totalLat = routes.compactMap { $0.centerCoordinate?.latitude }.reduce(0.0, +)
        let totalLon = routes.compactMap { $0.centerCoordinate?.longitude }.reduce(0.0, +)
        
        return CLLocationCoordinate2D(
            latitude: totalLat / Double(routes.count),
            longitude: totalLon / Double(routes.count)
        )
    }
    
    var count: Int {
        routes.count
    }
    
    var isSingleRoute: Bool {
        routes.count == 1
    }
    
    var representativeRoute: ScrapedRoute? {
        routes.first
    }
}

// MARK: - Map Region Extensions

extension MKCoordinateRegion {
    /// Check if a coordinate is within this region
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let minLat = center.latitude - span.latitudeDelta / 2
        let maxLat = center.latitude + span.latitudeDelta / 2
        let minLon = center.longitude - span.longitudeDelta / 2
        let maxLon = center.longitude + span.longitudeDelta / 2
        
        return coordinate.latitude >= minLat &&
               coordinate.latitude <= maxLat &&
               coordinate.longitude >= minLon &&
               coordinate.longitude <= maxLon
    }
    
    /// Get the zoom level (0 = zoomed out, 1 = zoomed in)
    var zoomLevel: Double {
        // Normalize span to 0-1 range (larger span = more zoomed out)
        let maxSpan = 180.0
        let normalizedSpan = (span.latitudeDelta + span.longitudeDelta) / 2.0
        return 1.0 - min(normalizedSpan / maxSpan, 1.0)
    }
}
