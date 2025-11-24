//
//  SearchFilterManager.swift
//  MCVenture
//

import Foundation
import CoreLocation
import Combine

// MARK: - Protocols for Filtering

protocol TripFilterable {
    var distance: Double { get }
    var duration: TimeInterval { get }
    var date: Date { get }
    var photoCount: Int { get }
    var name: String { get }
}

protocol RouteFilterable {
    var name: String { get }
    var distance: Double { get }
    var region: String { get }
    var hasTopography: Bool { get }
    var isUserCreated: Bool { get }
}

// MARK: - Filter Options

enum TripSortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case distanceLongest = "Distance (Longest)"
    case distanceShortest = "Distance (Shortest)"
    case durationLongest = "Duration (Longest)"
    case durationShortest = "Duration (Shortest)"
}

enum RouteSortOption: String, CaseIterable {
    case nameAZ = "Name (A-Z)"
    case nameZA = "Name (Z-A)"
    case distanceLongest = "Distance (Longest)"
    case distanceShortest = "Distance (Shortest)"
    case popularityHighest = "Popularity (Highest)"
    case difficultyEasiest = "Difficulty (Easiest)"
    case difficultyHardest = "Difficulty (Hardest)"
}

struct TripFilters {
    var minDistance: Double? = nil
    var maxDistance: Double? = nil
    var minDuration: TimeInterval? = nil
    var maxDuration: TimeInterval? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var hasPhotos: Bool? = nil
    var sortBy: TripSortOption = .dateNewest
    
    func matches<T>(_ trip: T) -> Bool where T: TripFilterable {
        // Check distance
        if let minDistance = minDistance, trip.distance < minDistance {
            return false
        }
        if let maxDistance = maxDistance, trip.distance > maxDistance {
            return false
        }
        
        // Check duration
        if let minDuration = minDuration, trip.duration < minDuration {
            return false
        }
        if let maxDuration = maxDuration, trip.duration > maxDuration {
            return false
        }
        
        // Check date range
        if let startDate = startDate, trip.date < startDate {
            return false
        }
        if let endDate = endDate, trip.date > endDate {
            return false
        }
        
        // Check photos
        if let hasPhotos = hasPhotos {
            let tripHasPhotos = trip.photoCount > 0
            if hasPhotos != tripHasPhotos {
                return false
            }
        }
        
        return true
    }
    
    var isActive: Bool {
        return minDistance != nil || maxDistance != nil ||
               minDuration != nil || maxDuration != nil ||
               startDate != nil || endDate != nil ||
               hasPhotos != nil
    }
    
    mutating func reset() {
        minDistance = nil
        maxDistance = nil
        minDuration = nil
        maxDuration = nil
        startDate = nil
        endDate = nil
        hasPhotos = nil
    }
}

struct RouteFilters {
    var difficulty: [String] = [] // Store as strings to avoid type conflicts
    var minDistance: Double? = nil
    var maxDistance: Double? = nil
    var region: String? = nil
    var hasTopography: Bool? = nil
    var userCreated: Bool? = nil
    var sortBy: RouteSortOption = .nameAZ
    
    func matches<R>(_ route: R) -> Bool where R: RouteFilterable {
        // Check difficulty (skipped in generic version - implement in specific models)
        // if !difficulty.isEmpty { return false }
        
        // Check distance
        if let minDistance = minDistance, route.distance < minDistance {
            return false
        }
        if let maxDistance = maxDistance, route.distance > maxDistance {
            return false
        }
        
        // Check region
        if let region = region, !route.region.localizedCaseInsensitiveContains(region) {
            return false
        }
        
        // Check topography
        if let hasTopography = hasTopography, route.hasTopography != hasTopography {
            return false
        }
        
        // Check user created
        if let userCreated = userCreated, route.isUserCreated != userCreated {
            return false
        }
        
        return true
    }
    
    var isActive: Bool {
        return !difficulty.isEmpty || minDistance != nil ||
               maxDistance != nil || region != nil ||
               hasTopography != nil || userCreated != nil
    }
    
    mutating func reset() {
        difficulty = []
        minDistance = nil
        maxDistance = nil
        region = nil
        hasTopography = nil
        userCreated = nil
    }
}

// MARK: - Placeholder Models
// Note: These are simplified protocol-like requirements.
// Replace with actual Trip/Route models from your data layer.
// The filter methods expect trips/routes with these properties:
// Trip: id, name, date, distance, duration, photoCount
// Route: id, name, distance, difficulty (enum), region, hasTopography, isUserCreated, popularity

// MARK: - Search Manager

class SearchFilterManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var tripFilters = TripFilters()
    @Published var routeFilters = RouteFilters()
    
    // Search trips
    func searchTrips<T>(_ trips: [T]) -> [T] where T: TripFilterable {
        var results = trips
        
        // Apply text search
        if !searchText.isEmpty {
            results = results.filter { trip in
                trip.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filters
        results = results.filter { tripFilters.matches($0) }
        
        // Apply sorting
        results = sortTrips(results, by: tripFilters.sortBy)
        
        return results
    }
    
    // Search routes with Norwegian character support
    func searchRoutes<R>(_ routes: [R]) -> [R] where R: RouteFilterable {
        var results = routes
        
        // Apply text search with Norwegian support
        if !searchText.isEmpty {
            results = results.filter { route in
                let normalizedSearch = normalizeNorwegian(searchText)
                let normalizedName = normalizeNorwegian(route.name)
                return normalizedName.localizedCaseInsensitiveContains(normalizedSearch) ||
                       route.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply filters
        results = results.filter { routeFilters.matches($0) }
        
        // Apply sorting
        results = sortRoutes(results, by: routeFilters.sortBy)
        
        return results
    }
    
    // Norwegian character normalization
    private func normalizeNorwegian(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "æ", with: "ae")
            .replacingOccurrences(of: "ø", with: "o")
            .replacingOccurrences(of: "å", with: "aa")
            .replacingOccurrences(of: "Æ", with: "AE")
            .replacingOccurrences(of: "Ø", with: "O")
            .replacingOccurrences(of: "Å", with: "AA")
    }
    
    // Sort trips
    private func sortTrips<T>(_ trips: [T], by option: TripSortOption) -> [T] where T: TripFilterable {
        switch option {
        case .dateNewest:
            return trips.sorted { $0.date > $1.date }
        case .dateOldest:
            return trips.sorted { $0.date < $1.date }
        case .distanceLongest:
            return trips.sorted { $0.distance > $1.distance }
        case .distanceShortest:
            return trips.sorted { $0.distance < $1.distance }
        case .durationLongest:
            return trips.sorted { $0.duration > $1.duration }
        case .durationShortest:
            return trips.sorted { $0.duration < $1.duration }
        }
    }
    
    // Sort routes
    private func sortRoutes<R>(_ routes: [R], by option: RouteSortOption) -> [R] where R: RouteFilterable {
        switch option {
        case .nameAZ:
            return routes.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameZA:
            return routes.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .distanceLongest:
            return routes.sorted { $0.distance > $1.distance }
        case .distanceShortest:
            return routes.sorted { $0.distance < $1.distance }
        case .popularityHighest:
            return routes // Popularity sorting requires specific model implementation
        case .difficultyEasiest:
            return routes // Difficulty sorting requires specific model implementation
        case .difficultyHardest:
            return routes // Difficulty sorting requires specific model implementation
        }
    }
    
    // Difficulty comparison removed - implement in specific model extensions
    
    // Quick filter presets
    func applyQuickFilter(_ preset: QuickFilterPreset) {
        switch preset {
        case .recentTrips:
            tripFilters.reset()
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())
            tripFilters.startDate = weekAgo
            tripFilters.sortBy = .dateNewest
            
        case .longTrips:
            tripFilters.reset()
            tripFilters.minDistance = 100.0
            tripFilters.sortBy = .distanceLongest
            
        case .withPhotos:
            tripFilters.reset()
            tripFilters.hasPhotos = true
            tripFilters.sortBy = .dateNewest
            
        case .easyRoutes:
            routeFilters.reset()
            routeFilters.difficulty = ["Easy", "Moderate"]
            routeFilters.sortBy = .nameAZ
            
        case .challengingRoutes:
            routeFilters.reset()
            routeFilters.difficulty = ["Challenging", "Difficult", "Expert"]
            routeFilters.sortBy = .difficultyHardest
            
        case .nearbyRoutes:
            routeFilters.reset()
            // Would need location-based sorting
            routeFilters.sortBy = .distanceShortest
        }
    }
    
    func clearAllFilters() {
        searchText = ""
        tripFilters.reset()
        routeFilters.reset()
    }
}

enum QuickFilterPreset {
    case recentTrips
    case longTrips
    case withPhotos
    case easyRoutes
    case challengingRoutes
    case nearbyRoutes
}
