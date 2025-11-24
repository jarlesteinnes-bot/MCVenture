//
//  RoutePlanningModels.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Route Waypoint
struct RouteWaypoint: Identifiable, Codable {
    let id: UUID
    var name: String
    var coordinate: CLLocationCoordinate2D
    var type: WaypointType
    var address: String?
    var arrivalTime: Date?
    var departureTime: Date?
    var notes: String?
    var estimatedElevation: Double?
    
    static func == (lhs: RouteWaypoint, rhs: RouteWaypoint) -> Bool {
        lhs.id == rhs.id
    }
    
    enum WaypointType: String, Codable, CaseIterable {
        case start = "Start"
        case end = "End"
        case waypoint = "Waypoint"
        case fuel = "Fuel Stop"
        case rest = "Rest Stop"
        case hotel = "Hotel"
        case restaurant = "Restaurant"
        case attraction = "Attraction"
        case scenic = "Scenic Viewpoint"
        
        var icon: String {
            switch self {
            case .start: return "flag.fill"
            case .end: return "flag.checkered"
            case .waypoint: return "mappin.circle.fill"
            case .fuel: return "fuelpump.fill"
            case .rest: return "bed.double.fill"
            case .hotel: return "building.2.fill"
            case .restaurant: return "fork.knife"
            case .attraction: return "star.fill"
            case .scenic: return "camera.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .start: return .green
            case .end: return .red
            case .waypoint: return .blue
            case .fuel: return .orange
            case .rest: return .purple
            case .hotel: return .indigo
            case .restaurant: return .pink
            case .attraction: return .yellow
            case .scenic: return .cyan
            }
        }
    }
    
    init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D, type: WaypointType = .waypoint, address: String? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.type = type
        self.address = address
    }
}

// MARK: - Route Optimization Type
enum RouteOptimization: String, Codable, CaseIterable {
    case fastest = "Fastest"
    case shortest = "Shortest"
    case scenic = "Most Scenic"
    case twisty = "Twisty Roads"
    case balanced = "Balanced"
    
    var icon: String {
        switch self {
        case .fastest: return "bolt.fill"
        case .shortest: return "arrow.left.and.right"
        case .scenic: return "mountain.2.fill"
        case .twisty: return "point.3.connected.trianglepath.dotted"
        case .balanced: return "scale.3d"
        }
    }
    
    var description: String {
        switch self {
        case .fastest: return "Prioritize highways and faster roads"
        case .shortest: return "Minimize total distance"
        case .scenic: return "Prefer scenic routes and viewpoints"
        case .twisty: return "Maximize fun curves and bends"
        case .balanced: return "Balance speed, distance, and scenery"
        }
    }
}

// MARK: - Road Preferences
struct RoadPreferences: Codable, Equatable {
    var avoidHighways: Bool = false
    var avoidTolls: Bool = false
    var avoidFerries: Bool = false
    var avoidUnpavedRoads: Bool = false
    var preferScenicRoads: Bool = true
    var preferTwistyRoads: Bool = true
    var minimumRoadWidth: RoadWidth = .any
    
    enum RoadWidth: String, Codable, CaseIterable {
        case any = "Any Width"
        case narrow = "Narrow OK"
        case medium = "Medium+"
        case wide = "Wide Only"
        
        var minWidth: Double {
            switch self {
            case .any: return 0
            case .narrow: return 3.0
            case .medium: return 5.0
            case .wide: return 7.0
            }
        }
    }
}

// MARK: - Route Plan
struct RoutePlan: Identifiable, Codable {
    let id: UUID
    var name: String
    var waypoints: [RouteWaypoint]
    var optimization: RouteOptimization
    var roadPreferences: RoadPreferences
    var scheduledDate: Date?
    var departureTime: Date?
    var estimatedArrivalTime: Date?
    var createdDate: Date
    var lastModified: Date
    
    // Calculated properties
    var totalDistance: Double = 0
    var estimatedDuration: TimeInterval = 0
    var elevationGain: Double = 0
    var elevationLoss: Double = 0
    var difficultyRating: Double = 0 // 0-10 scale
    var twistinessScore: Double = 0 // 0-10 scale
    var scenicScore: Double = 0 // 0-10 scale
    
    // Fuel calculations
    var estimatedFuelConsumption: Double = 0 // Liters
    var estimatedFuelCost: Double = 0 // Currency (NOK/EUR/etc)
    var fuelPricePerLiter: Double = 19.50 // Default Norwegian fuel price in NOK
    
    // POIs and stops
    var suggestedFuelStops: [RouteWaypoint] = []
    var suggestedRestStops: [RouteWaypoint] = []
    var nearbyPOIs: [RouteWaypoint] = []
    
    // Turn-by-turn
    var directions: [RouteDirection] = []
    
    // Weather forecast
    var weatherForecast: WeatherForecastData?
    
    // Sharing and social
    var isPublic: Bool = false
    var rating: Double = 0
    var reviews: [RouteReview] = []
    
    init(id: UUID = UUID(), name: String, waypoints: [RouteWaypoint] = [], optimization: RouteOptimization = .balanced) {
        self.id = id
        self.name = name
        self.waypoints = waypoints
        self.optimization = optimization
        self.roadPreferences = RoadPreferences()
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    var startPoint: RouteWaypoint? {
        waypoints.first
    }
    
    var endPoint: RouteWaypoint? {
        waypoints.last
    }
}

// MARK: - Route Direction
struct RouteDirection: Identifiable, Codable {
    let id: UUID
    var instruction: String
    var distance: Double
    var duration: TimeInterval
    var coordinate: CLLocationCoordinate2D
    var maneuverType: ManeuverType
    
    enum ManeuverType: String, Codable {
        case depart = "Depart"
        case turn = "Turn"
        case merge = "Merge"
        case roundabout = "Roundabout"
        case arrive = "Arrive"
        case straight = "Continue Straight"
        
        var icon: String {
            switch self {
            case .depart: return "location.fill"
            case .turn: return "arrow.turn.up.right"
            case .merge: return "arrow.triangle.merge"
            case .roundabout: return "arrow.triangle.2.circlepath"
            case .arrive: return "flag.checkered"
            case .straight: return "arrow.up"
            }
        }
    }
    
    init(id: UUID = UUID(), instruction: String, distance: Double, duration: TimeInterval, coordinate: CLLocationCoordinate2D, maneuverType: ManeuverType) {
        self.id = id
        self.instruction = instruction
        self.distance = distance
        self.duration = duration
        self.coordinate = coordinate
        self.maneuverType = maneuverType
    }
}

// MARK: - Weather Forecast Data
struct WeatherForecastData: Codable {
    var date: Date
    var temperature: Double
    var condition: String
    var precipitationChance: Double
    var windSpeed: Double
    var visibility: Double
    var recommendation: WeatherRecommendation
    
    enum WeatherRecommendation: String, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
        case dangerous = "Dangerous"
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .blue
            case .fair: return .yellow
            case .poor: return .orange
            case .dangerous: return .red
            }
        }
    }
}

// Using RouteReview from ComprehensiveModels.swift

// MARK: - AI Route Suggestion
struct AIRouteSuggestion: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var route: RoutePlan
    var suggestionType: SuggestionType
    var confidence: Double // 0-1
    
    enum SuggestionType: String {
        case basedOnHistory = "Based on Your History"
        case rideOfTheDay = "Ride of the Day"
        case seasonal = "Seasonal Favorite"
        case popular = "Popular Nearby"
        case similar = "Similar to Routes You Like"
        case exploration = "Explore New Areas"
        
        var icon: String {
            switch self {
            case .basedOnHistory: return "clock.arrow.circlepath"
            case .rideOfTheDay: return "star.circle.fill"
            case .seasonal: return "leaf.fill"
            case .popular: return "flame.fill"
            case .similar: return "heart.fill"
            case .exploration: return "map.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .basedOnHistory: return .blue
            case .rideOfTheDay: return .yellow
            case .seasonal: return .green
            case .popular: return .orange
            case .similar: return .pink
            case .exploration: return .purple
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, description: String, route: RoutePlan, suggestionType: SuggestionType, confidence: Double = 0.8) {
        self.id = id
        self.title = title
        self.description = description
        self.route = route
        self.suggestionType = suggestionType
        self.confidence = confidence
    }
}

// MARK: - Route Elevation Point (distinct from ElevationTracker's ElevationPoint)
struct RouteElevationPoint: Identifiable {
    let id: UUID
    var distance: Double // km from start
    var elevation: Double // meters
    var coordinate: CLLocationCoordinate2D
    var gradient: Double // percentage
    
    init(id: UUID = UUID(), distance: Double, elevation: Double, coordinate: CLLocationCoordinate2D, gradient: Double = 0) {
        self.id = id
        self.distance = distance
        self.elevation = elevation
        self.coordinate = coordinate
        self.gradient = gradient
    }
}
