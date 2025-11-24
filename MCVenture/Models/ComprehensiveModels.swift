//
//  ComprehensiveModels.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Trip History
struct CompletedTrip: Identifiable, Codable {
    let id: UUID
    let routeName: String
    let country: String
    let date: Date
    let distanceKm: Double
    let duration: TimeInterval // in seconds
    let fuelCost: Double
    let averageSpeed: Double
    let photoURLs: [String]
    var rating: Int // 1-5 stars
    var notes: String
    var weatherCondition: String
    var sourceRouteId: UUID? // Link to original route
    var difficulty: String?
    
    init(id: UUID = UUID(), routeName: String, country: String, date: Date = Date(), distanceKm: Double, duration: TimeInterval, fuelCost: Double, averageSpeed: Double, photoURLs: [String] = [], rating: Int = 0, notes: String = "", weatherCondition: String = "", sourceRouteId: UUID? = nil, difficulty: String? = nil) {
        self.id = id
        self.routeName = routeName
        self.country = country
        self.date = date
        self.distanceKm = distanceKm
        self.duration = duration
        self.fuelCost = fuelCost
        self.averageSpeed = averageSpeed
        self.photoURLs = photoURLs
        self.rating = rating
        self.notes = notes
        self.weatherCondition = weatherCondition
        self.sourceRouteId = sourceRouteId
        self.difficulty = difficulty
    }
}

// MARK: - Statistics
struct RiderStatistics: Codable {
    var totalDistanceKm: Double
    var totalFuelCost: Double
    var totalTrips: Int
    var countriesVisited: Set<String>
    var routesCompleted: Set<String>
    var totalRidingTime: TimeInterval
    var longestTrip: Double
    var favoriteCountry: String
    
    static var `default`: RiderStatistics {
        RiderStatistics(totalDistanceKm: 0, totalFuelCost: 0, totalTrips: 0, countriesVisited: [], routesCompleted: [], totalRidingTime: 0, longestTrip: 0, favoriteCountry: "")
    }
}

// MARK: - Achievements
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Double
    var isUnlocked: Bool
    var progress: Double
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_ride", title: "First Ride", description: "Complete your first route", icon: "flag.fill", requirement: 1, isUnlocked: false, progress: 0),
        Achievement(id: "century", title: "Century Rider", description: "Ride 100 routes", icon: "100.circle.fill", requirement: 100, isUnlocked: false, progress: 0),
        Achievement(id: "thousand_km", title: "1000km Club", description: "Ride 1000 kilometers", icon: "speedometer", requirement: 1000, isUnlocked: false, progress: 0),
        Achievement(id: "ten_countries", title: "European Explorer", description: "Visit 10 countries", icon: "globe.europe.africa.fill", requirement: 10, isUnlocked: false, progress: 0),
        Achievement(id: "arctic_circle", title: "Arctic Rider", description: "Complete a route above Arctic Circle", icon: "snowflake", requirement: 1, isUnlocked: false, progress: 0),
        Achievement(id: "alps_master", title: "Alps Master", description: "Complete 20 Alpine routes", icon: "mountain.2.fill", requirement: 20, isUnlocked: false, progress: 0),
        Achievement(id: "night_rider", title: "Night Rider", description: "Complete a ride after sunset", icon: "moon.stars.fill", requirement: 1, isUnlocked: false, progress: 0),
        Achievement(id: "early_bird", title: "Early Bird", description: "Start a ride before sunrise", icon: "sunrise.fill", requirement: 1, isUnlocked: false, progress: 0),
        Achievement(id: "marathon", title: "Marathon Rider", description: "Ride 500km in one day", icon: "bolt.fill", requirement: 500, isUnlocked: false, progress: 0),
        Achievement(id: "social", title: "Social Rider", description: "Share 10 routes with friends", icon: "person.3.fill", requirement: 10, isUnlocked: false, progress: 0)
    ]
}

// MARK: - Points of Interest
enum POICategory: String, Codable, CaseIterable {
    case restaurant = "Restaurant"
    case hotel = "Hotel"
    case camping = "Camping"
    case gasStation = "Gas Station"
    case mechanic = "Mechanic"
    case hospital = "Hospital"
    case viewpoint = "Viewpoint"
    case attraction = "Attraction"
    case bikeWash = "Bike Wash"
    case coffee = "Coffee Spot"
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .hotel: return "bed.double.fill"
        case .camping: return "tent.fill"
        case .gasStation: return "fuelpump.fill"
        case .mechanic: return "wrench.and.screwdriver.fill"
        case .hospital: return "cross.fill"
        case .viewpoint: return "camera.fill"
        case .attraction: return "star.fill"
        case .bikeWash: return "drop.fill"
        case .coffee: return "cup.and.saucer.fill"
        }
    }
}

struct PointOfInterest: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: POICategory
    let latitude: Double
    let longitude: Double
    let address: String
    let phone: String?
    let website: String?
    var rating: Double // 0-5
    var userReviews: [String]
    var isOpen24Hours: Bool
    var bikerFriendly: Bool
    var averagePrice: String // €, $$, etc.
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Motorcycle Maintenance
struct MaintenanceRecord: Identifiable, Codable {
    let id: UUID
    let motorcycleId: UUID
    let date: Date
    let type: MaintenanceType
    let mileage: Double
    let cost: Double
    let description: String
    let nextServiceDue: Double? // mileage
    var receiptPhoto: String?
    
    enum MaintenanceType: String, Codable {
        case oilChange = "Oil Change"
        case tireReplacement = "Tire Replacement"
        case brakeService = "Brake Service"
        case chainMaintenance = "Chain Maintenance"
        case inspection = "Inspection"
        case repair = "Repair"
        case other = "Other"
    }
}

struct MotorcycleProfile: Identifiable, Codable {
    let id: UUID
    var brand: String
    var model: String
    var year: Int
    var nickname: String
    var currentMileage: Double
    var fuelConsumption: Double
    var tankSize: Double
    var tireSize: String
    var oilType: String
    var maintenanceRecords: [UUID] // IDs of MaintenanceRecords
    var nextServiceDue: Double
    var photoURL: String?
}

// MARK: - Packing & Preparation
struct PackingList: Identifiable, Codable {
    let id: UUID
    var name: String
    var tripType: TripType
    var items: [PackingItem]
    
    enum TripType: String, Codable {
        case dayTrip = "Day Trip"
        case weekend = "Weekend"
        case weekLong = "Week-Long"
        case multiWeek = "Multi-Week"
        case camping = "Camping"
        case touring = "Touring"
    }
}

struct PackingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var isPacked: Bool
    var isEssential: Bool
}

// MARK: - Road Hazards
struct RoadHazard: Identifiable, Codable {
    let id: UUID
    let type: HazardType
    let latitude: Double
    let longitude: Double
    let description: String
    let reportedBy: String
    let reportedDate: Date
    var severity: Severity
    var isActive: Bool
    
    enum HazardType: String, Codable {
        case pothole = "Pothole"
        case gravel = "Gravel on Road"
        case construction = "Construction"
        case accident = "Accident"
        case roadClosure = "Road Closure"
        case wildlife = "Wildlife"
        case speedCamera = "Speed Camera"
        case ice = "Ice/Snow"
        case flooding = "Flooding"
    }
    
    enum Severity: String, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Route Review
struct RouteReview: Identifiable, Codable {
    let id: UUID
    let routeName: String
    let userName: String
    let rating: Int // 1-5
    let date: Date
    let review: String
    var helpfulCount: Int
    var roadCondition: RoadCondition
    var traffic: TrafficLevel
    var scenicRating: Int // 1-5
    
    enum RoadCondition: String, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
    }
    
    enum TrafficLevel: String, Codable {
        case none = "None"
        case light = "Light"
        case moderate = "Moderate"
        case heavy = "Heavy"
    }
}

// MARK: - Group Ride
struct GroupRide: Identifiable, Codable {
    let id: UUID
    var routeName: String
    var organizer: String
    var date: Date
    var meetingPoint: String
    var maxRiders: Int
    var participants: [String]
    var description: String
    var difficulty: EuropeanRoute.Difficulty
    var isPrivate: Bool
}

// MARK: - Emergency Contact
struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String
    var relationship: String
    var isPrimary: Bool
}

// MARK: - Advanced Weather
struct DetailedWeather: Codable {
    let hourlyForecast: [HourlyWeather]
    let dailyForecast: [DailyWeather]
    let alerts: [WeatherAlert]
    let sunrise: Date
    let sunset: Date
    let moonPhase: String
}

struct HourlyWeather: Codable, Identifiable {
    let id = UUID()
    let hour: Date
    let temperature: Double
    let condition: String
    let windSpeed: Double
    let precipitation: Double
}

struct DailyWeather: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let tempHigh: Double
    let tempLow: Double
    let condition: String
    let windSpeed: Double
    let precipitationChance: Double
}

struct WeatherAlert: Codable, Identifiable {
    let id = UUID()
    let type: AlertType
    let severity: String
    let description: String
    let startTime: Date
    let endTime: Date
    
    enum AlertType: String, Codable {
        case storm = "Storm"
        case snow = "Snow"
        case ice = "Ice"
        case fog = "Fog"
        case wind = "High Wind"
        case heat = "Heat"
    }
}

// MARK: - Custom Route
struct CustomRoute: Identifiable, Codable {
    let id: UUID
    var name: String
    var waypoints: [CLLocationCoordinate2D]
    var totalDistance: Double
    var estimatedDuration: TimeInterval
    var createdBy: String
    var isPublic: Bool
    var tags: [String]
    var surfaceType: SurfaceType
    
    enum SurfaceType: String, Codable {
        case paved = "Paved"
        case mixed = "Mixed"
        case gravel = "Gravel"
        case offRoad = "Off-Road"
    }
}

// Extension to make CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
