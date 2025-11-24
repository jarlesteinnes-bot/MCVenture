//
//  ScrapedRoute.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation

// MARK: - Scraped Route Model
struct ScrapedRoute: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var region: String?
    var distanceKm: Double
    var duration: TimeInterval? // estimated riding time in seconds
    var difficulty: ScrapedRouteDifficulty
    var scenicRating: Double // 1-5
    var description: String
    var highlights: [String]
    var bestMonths: [String] // e.g., ["May", "June", "September"]
    var roadTypes: [RoadType]
    var coordinates: [ScrapedRouteCoordinate]
    var startPoint: ScrapedRoutePoint
    var endPoint: ScrapedRoutePoint
    var waypoints: [ScrapedRoutePoint]
    var elevationGainMeters: Double?
    var elevationLossMeters: Double?
    var maxElevationMeters: Double?
    var surfaceCondition: SurfaceCondition
    var trafficLevel: TrafficLevel
    var tollRoad: Bool
    var imageURLs: [String]
    var sourceURL: String
    var sourceWebsite: String
    var scrapedDate: Date
    var lastUpdated: Date?
    var tags: [String] // e.g., ["Alpine", "Coastal", "Mountain Pass", "Twisty"]
    var nearbyPOIs: [ScrapedPOIReference]
    var reviews: [RouteReviewData]?
    var averageRating: Double?
    
    // Offline caching
    var isCached: Bool = false
    var cachedDate: Date?
    var cacheExpiryDate: Date?
    
    // Favorites
    var isFavorite: Bool = false
    
    init(id: UUID = UUID(),
         name: String,
         country: String,
         region: String? = nil,
         distanceKm: Double,
         duration: TimeInterval? = nil,
         difficulty: ScrapedRouteDifficulty = .intermediate,
         scenicRating: Double = 3.0,
         description: String,
         highlights: [String] = [],
         bestMonths: [String] = [],
         roadTypes: [RoadType] = [],
         coordinates: [ScrapedRouteCoordinate] = [],
         startPoint: ScrapedRoutePoint,
         endPoint: ScrapedRoutePoint,
         waypoints: [ScrapedRoutePoint] = [],
         elevationGainMeters: Double? = nil,
         elevationLossMeters: Double? = nil,
         maxElevationMeters: Double? = nil,
         surfaceCondition: SurfaceCondition = .good,
         trafficLevel: TrafficLevel = .moderate,
         tollRoad: Bool = false,
         imageURLs: [String] = [],
         sourceURL: String,
         sourceWebsite: String,
         scrapedDate: Date = Date(),
         lastUpdated: Date? = nil,
         tags: [String] = [],
         nearbyPOIs: [ScrapedPOIReference] = [],
         reviews: [RouteReviewData]? = nil,
         averageRating: Double? = nil,
         isCached: Bool = false,
         cachedDate: Date? = nil,
         cacheExpiryDate: Date? = nil,
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.region = region
        self.distanceKm = distanceKm
        self.duration = duration
        self.difficulty = difficulty
        self.scenicRating = scenicRating
        self.description = description
        self.highlights = highlights
        self.bestMonths = bestMonths
        self.roadTypes = roadTypes
        self.coordinates = coordinates
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.waypoints = waypoints
        self.elevationGainMeters = elevationGainMeters
        self.elevationLossMeters = elevationLossMeters
        self.maxElevationMeters = maxElevationMeters
        self.surfaceCondition = surfaceCondition
        self.trafficLevel = trafficLevel
        self.tollRoad = tollRoad
        self.imageURLs = imageURLs
        self.sourceURL = sourceURL
        self.sourceWebsite = sourceWebsite
        self.scrapedDate = scrapedDate
        self.lastUpdated = lastUpdated
        self.tags = tags
        self.nearbyPOIs = nearbyPOIs
        self.reviews = reviews
        self.averageRating = averageRating
        self.isCached = isCached
        self.cachedDate = cachedDate
        self.cacheExpiryDate = cacheExpiryDate
        self.isFavorite = isFavorite
    }
    
    // Cache management helpers
    var isCacheValid: Bool {
        guard isCached, let expiryDate = cacheExpiryDate else { return false }
        return Date() < expiryDate
    }
    
    mutating func markAsCached() {
        isCached = true
        cachedDate = Date()
        // Cache expires after 30 days
        cacheExpiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
    }
    
    mutating func clearCache() {
        isCached = false
        cachedDate = nil
        cacheExpiryDate = nil
    }
    
    // Helper: Get center coordinate of route
    var centerCoordinate: CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return startPoint.coordinate.clCoordinate }
        let totalLat = coordinates.reduce(0.0) { $0 + $1.latitude }
        let totalLon = coordinates.reduce(0.0) { $0 + $1.longitude }
        return CLLocationCoordinate2D(
            latitude: totalLat / Double(coordinates.count),
            longitude: totalLon / Double(coordinates.count)
        )
    }
    
    // Helper: Convert to CLLocationCoordinate2D array for navigation
    var clLocationCoordinates: [CLLocationCoordinate2D] {
        coordinates.map { $0.clCoordinate }
    }
}

// MARK: - Supporting Enums
enum ScrapedRouteDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
}

enum RoadType: String, Codable {
    case highway = "Highway"
    case scenic = "Scenic Road"
    case mountain = "Mountain Pass"
    case coastal = "Coastal Road"
    case twisty = "Twisty Road"
    case gravel = "Gravel"
    case mixed = "Mixed"
}

enum SurfaceCondition: String, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case variable = "Variable"
}

enum TrafficLevel: String, Codable {
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    case variable = "Variable"
}

// MARK: - Supporting Structures
struct ScrapedRouteCoordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    var elevation: Double?
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ScrapedRoutePoint: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var coordinate: ScrapedRouteCoordinate
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case name, coordinate, description
    }
}

struct ScrapedPOIReference: Codable, Hashable {
    var name: String
    var type: String // e.g., "Fuel", "Restaurant", "Viewpoint"
    var coordinate: ScrapedRouteCoordinate
    var distanceFromRouteKm: Double?
}

struct RouteReviewData: Codable, Hashable {
    var author: String
    var rating: Double
    var comment: String
    var date: Date
}

// MARK: - Scraper Source Configuration
struct ScraperSource: Codable, Identifiable {
    let id: UUID
    var name: String
    var baseURL: String
    var isEnabled: Bool
    var priority: Int // Higher priority sources scraped first
    var lastScraped: Date?
    var routesFound: Int
    var countryFocus: [String] // Countries this source specializes in
    
    init(id: UUID = UUID(),
         name: String,
         baseURL: String,
         isEnabled: Bool = true,
         priority: Int = 1,
         lastScraped: Date? = nil,
         routesFound: Int = 0,
         countryFocus: [String] = []) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
        self.isEnabled = isEnabled
        self.priority = priority
        self.lastScraped = lastScraped
        self.routesFound = routesFound
        self.countryFocus = countryFocus
    }
}

// MARK: - European Countries
enum EuropeanCountry: String, CaseIterable, Codable {
    case norway = "Norway"
    case sweden = "Sweden"
    case denmark = "Denmark"
    case finland = "Finland"
    case iceland = "Iceland"
    case germany = "Germany"
    case austria = "Austria"
    case switzerland = "Switzerland"
    case france = "France"
    case italy = "Italy"
    case spain = "Spain"
    case portugal = "Portugal"
    case netherlands = "Netherlands"
    case belgium = "Belgium"
    case uk = "United Kingdom"
    case ireland = "Ireland"
    case scotland = "Scotland"
    case poland = "Poland"
    case czech = "Czech Republic"
    case slovenia = "Slovenia"
    case croatia = "Croatia"
    case greece = "Greece"
    case romania = "Romania"
    case bulgaria = "Bulgaria"
    case hungary = "Hungary"
    case slovakia = "Slovakia"
    case montenegro = "Montenegro"
    case albania = "Albania"
    case macedonia = "North Macedonia"
    case serbia = "Serbia"
    case bosnia = "Bosnia and Herzegovina"
    
    var flag: String {
        switch self {
        case .norway: return "🇳🇴"
        case .sweden: return "🇸🇪"
        case .denmark: return "🇩🇰"
        case .finland: return "🇫🇮"
        case .iceland: return "🇮🇸"
        case .germany: return "🇩🇪"
        case .austria: return "🇦🇹"
        case .switzerland: return "🇨🇭"
        case .france: return "🇫🇷"
        case .italy: return "🇮🇹"
        case .spain: return "🇪🇸"
        case .portugal: return "🇵🇹"
        case .netherlands: return "🇳🇱"
        case .belgium: return "🇧🇪"
        case .uk: return "🇬🇧"
        case .ireland: return "🇮🇪"
        case .scotland: return "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
        case .poland: return "🇵🇱"
        case .czech: return "🇨🇿"
        case .slovenia: return "🇸🇮"
        case .croatia: return "🇭🇷"
        case .greece: return "🇬🇷"
        case .romania: return "🇷🇴"
        case .bulgaria: return "🇧🇬"
        case .hungary: return "🇭🇺"
        case .slovakia: return "🇸🇰"
        case .montenegro: return "🇲🇪"
        case .albania: return "🇦🇱"
        case .macedonia: return "🇲🇰"
        case .serbia: return "🇷🇸"
        case .bosnia: return "🇧🇦"
        }
    }
}
