//
//  TripWaypoint.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import SwiftUI

enum TripWaypointType: String, Codable, CaseIterable {
    case gasStation = "Gas Station"
    case restStop = "Rest Stop"
    case photo = "Photo Spot"
    case viewpoint = "Viewpoint"
    case food = "Food & Drink"
    case danger = "Danger/Warning"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .gasStation: return "fuelpump.fill"
        case .restStop: return "bed.double.fill"
        case .photo: return "camera.fill"
        case .viewpoint: return "binoculars.fill"
        case .food: return "fork.knife"
        case .danger: return "exclamationmark.triangle.fill"
        case .custom: return "mappin.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .gasStation: return .blue
        case .restStop: return .green
        case .photo: return .purple
        case .viewpoint: return .orange
        case .food: return .red
        case .danger: return .yellow
        case .custom: return .gray
        }
    }
}

struct TripWaypoint: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let type: TripWaypointType
    let timestamp: Date
    var note: String
    var photoURL: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D, type: TripWaypointType, note: String = "", photoURL: String? = nil) {
        self.id = UUID()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.type = type
        self.timestamp = Date()
        self.note = note
        self.photoURL = photoURL
    }
}
