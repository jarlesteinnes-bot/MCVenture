//
//  Route.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import Foundation
import CoreLocation

struct Route: Identifiable, Codable {
    let id = UUID()
    var name: String
    var distanceKm: Double
    var startLocation: String
    var endLocation: String
    var waypoints: [Waypoint]
    var createdDate: Date
    
    // Calculated properties
    var fuelCost: Double {
        UserProfileManager.shared.calculateFuelCost(distanceKm: distanceKm)
    }
    
    var litersNeeded: Double {
        UserProfileManager.shared.calculateLitersNeeded(distanceKm: distanceKm)
    }
    
    var fuelCostFormatted: String {
        String(format: "%.2f kr", fuelCost)
    }
    
    var litersNeededFormatted: String {
        String(format: "%.2f L", litersNeeded)
    }
    
    var distanceFormatted: String {
        String(format: "%.1f km", distanceKm)
    }
}

struct Waypoint: Identifiable, Codable {
    let id = UUID()
    var latitude: Double
    var longitude: Double
    var name: String?
    var notes: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Example route creation
extension Route {
    static func example(distanceKm: Double) -> Route {
        Route(
            name: "Example Route",
            distanceKm: distanceKm,
            startLocation: "Oslo",
            endLocation: "Bergen",
            waypoints: [],
            createdDate: Date()
        )
    }
}
