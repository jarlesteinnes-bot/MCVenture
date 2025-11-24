//
//  ElevationTracker.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import Combine

struct ElevationPoint: Codable {
    let altitude: Double // meters
    let distance: Double // km from start
    let timestamp: Date
}

class ElevationTracker: ObservableObject {
    @Published var currentAltitude: Double = 0.0
    @Published var elevationGain: Double = 0.0
    @Published var elevationLoss: Double = 0.0
    @Published var maxAltitude: Double = 0.0
    @Published var minAltitude: Double = Double.greatestFiniteMagnitude
    @Published var elevationProfile: [ElevationPoint] = []
    
    private var lastAltitude: Double?
    private let smoothingWindow: Int = 3  // Number of readings to average
    private var altitudeBuffer: [Double] = []
    
    func reset() {
        currentAltitude = 0.0
        elevationGain = 0.0
        elevationLoss = 0.0
        maxAltitude = 0.0
        minAltitude = Double.greatestFiniteMagnitude
        elevationProfile = []
        lastAltitude = nil
        altitudeBuffer = []
    }
    
    func update(location: CLLocation, distance: Double) {
        guard location.verticalAccuracy >= 0 && location.verticalAccuracy < 50 else {
            return  // Ignore inaccurate readings
        }
        
        let altitude = location.altitude
        
        // Add to smoothing buffer
        altitudeBuffer.append(altitude)
        if altitudeBuffer.count > smoothingWindow {
            altitudeBuffer.removeFirst()
        }
        
        // Calculate smoothed altitude
        let smoothedAltitude = altitudeBuffer.reduce(0.0, +) / Double(altitudeBuffer.count)
        currentAltitude = smoothedAltitude
        
        // Update min/max
        if smoothedAltitude > maxAltitude {
            maxAltitude = smoothedAltitude
        }
        if smoothedAltitude < minAltitude {
            minAltitude = smoothedAltitude
        }
        
        // Calculate gain/loss
        if let last = lastAltitude {
            let change = smoothedAltitude - last
            if change > 1.0 {  // Only count changes > 1 meter
                elevationGain += change
            } else if change < -1.0 {
                elevationLoss += abs(change)
            }
        }
        
        lastAltitude = smoothedAltitude
        
        // Add to profile (every 100 meters of distance)
        if elevationProfile.isEmpty || distance - elevationProfile.last!.distance >= 0.1 {
            elevationProfile.append(ElevationPoint(
                altitude: smoothedAltitude,
                distance: distance,
                timestamp: Date()
            ))
        }
    }
    
    var totalElevationChange: Double {
        elevationGain + elevationLoss
    }
    
    var averageGradient: Double {
        guard !elevationProfile.isEmpty,
              let first = elevationProfile.first,
              let last = elevationProfile.last,
              last.distance > 0 else {
            return 0.0
        }
        
        let heightChange = last.altitude - first.altitude
        let distance = last.distance * 1000 // Convert to meters
        return (heightChange / distance) * 100 // Percentage
    }
}
