//
//  UnitPreferences.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import SwiftUI

enum DistanceUnit: String, CaseIterable, Codable {
    case kilometers = "km"
    case miles = "mi"
    
    var displayName: String {
        switch self {
        case .kilometers: return "Kilometers"
        case .miles: return "Miles"
        }
    }
    
    var speedUnit: String {
        switch self {
        case .kilometers: return "km/h"
        case .miles: return "mph"
        }
    }
    
    var elevationUnit: String {
        switch self {
        case .kilometers: return "m"
        case .miles: return "ft"
        }
    }
    
    // Convert from kilometers
    func fromKilometers(_ km: Double) -> Double {
        switch self {
        case .kilometers: return km
        case .miles: return km * 0.621371
        }
    }
    
    // Convert to kilometers
    func toKilometers(_ value: Double) -> Double {
        switch self {
        case .kilometers: return value
        case .miles: return value / 0.621371
        }
    }
    
    // Convert speed from km/h
    func speedFromKmh(_ kmh: Double) -> Double {
        switch self {
        case .kilometers: return kmh
        case .miles: return kmh * 0.621371
        }
    }
    
    // Convert elevation from meters
    func elevationFromMeters(_ meters: Double) -> Double {
        switch self {
        case .kilometers: return meters
        case .miles: return meters * 3.28084
        }
    }
    
    // Format distance with unit
    func formatDistance(_ km: Double, decimals: Int = 1) -> String {
        let converted = fromKilometers(km)
        return String(format: "%.\(decimals)f %@", converted, self.rawValue)
    }
    
    // Format speed with unit
    func formatSpeed(_ kmh: Double, decimals: Int = 0) -> String {
        let converted = speedFromKmh(kmh)
        return String(format: "%.\(decimals)f %@", converted, speedUnit)
    }
    
    // Format elevation with unit
    func formatElevation(_ meters: Double, decimals: Int = 0) -> String {
        let converted = elevationFromMeters(meters)
        return String(format: "%.\(decimals)f %@", converted, elevationUnit)
    }
}

enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius = "°C"
    case fahrenheit = "°F"
    
    var displayName: String {
        switch self {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        }
    }
    
    func fromCelsius(_ celsius: Double) -> Double {
        switch self {
        case .celsius: return celsius
        case .fahrenheit: return (celsius * 9/5) + 32
        }
    }
    
    func toCelsius(_ value: Double) -> Double {
        switch self {
        case .celsius: return value
        case .fahrenheit: return (value - 32) * 5/9
        }
    }
    
    func format(_ celsius: Double, decimals: Int = 0) -> String {
        let converted = fromCelsius(celsius)
        return String(format: "%.\(decimals)f%@", converted, self.rawValue)
    }
}

// MARK: - User Preferences Manager

class UserPreferences {
    static let shared = UserPreferences()
    
    @AppStorage("distanceUnit") private var _distanceUnit: DistanceUnit = .kilometers
    @AppStorage("temperatureUnit") private var _temperatureUnit: TemperatureUnit = .celsius
    
    var distanceUnit: DistanceUnit {
        get { _distanceUnit }
        set { _distanceUnit = newValue }
    }
    
    var temperatureUnit: TemperatureUnit {
        get { _temperatureUnit }
        set { _temperatureUnit = newValue }
    }
    
    private init() {}
    
    // Convenience formatters
    func formatDistance(_ km: Double, decimals: Int = 1) -> String {
        distanceUnit.formatDistance(km, decimals: decimals)
    }
    
    func formatSpeed(_ kmh: Double, decimals: Int = 0) -> String {
        distanceUnit.formatSpeed(kmh, decimals: decimals)
    }
    
    func formatElevation(_ meters: Double, decimals: Int = 0) -> String {
        distanceUnit.formatElevation(meters, decimals: decimals)
    }
    
    func formatTemperature(_ celsius: Double, decimals: Int = 0) -> String {
        temperatureUnit.format(celsius, decimals: decimals)
    }
}

// MARK: - View Extensions

extension View {
    func formatDistance(_ km: Double, decimals: Int = 1) -> String {
        UserPreferences.shared.formatDistance(km, decimals: decimals)
    }
    
    func formatSpeed(_ kmh: Double, decimals: Int = 0) -> String {
        UserPreferences.shared.formatSpeed(kmh, decimals: decimals)
    }
    
    func formatElevation(_ meters: Double, decimals: Int = 0) -> String {
        UserPreferences.shared.formatElevation(meters, decimals: decimals)
    }
    
    func formatTemperature(_ celsius: Double, decimals: Int = 0) -> String {
        UserPreferences.shared.formatTemperature(celsius, decimals: decimals)
    }
}
