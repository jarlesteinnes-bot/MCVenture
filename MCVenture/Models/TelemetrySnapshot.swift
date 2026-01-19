//
//  TelemetrySnapshot.swift
//  MCVenture
//
//  Captures condensed riding telemetry for on-device ML
//

import Foundation

/// Aggregate metrics captured from Pro Mode sensors during a ride.
struct TelemetrySnapshot: Codable {
    let timestamp: Date
    let averageLeanAngle: Double
    let maxLeanLeft: Double
    let maxLeanRight: Double
    let averageSurfaceQuality: Double
    let potholeDensityPer100Km: Double
    let turnDensityPer10Km: Double
    let hairpinDensityPer10Km: Double
    let averageLateralG: Double
    let maxLateralG: Double
    let vibrationScore: Double
    let brakingIntensity: Double
    
    static let placeholder = TelemetrySnapshot(
        timestamp: Date(),
        averageLeanAngle: 0,
        maxLeanLeft: 0,
        maxLeanRight: 0,
        averageSurfaceQuality: 0.85,
        potholeDensityPer100Km: 0,
        turnDensityPer10Km: 0.2,
        hairpinDensityPer10Km: 0.02,
        averageLateralG: 0.35,
        maxLateralG: 0.8,
        vibrationScore: 0.15,
        brakingIntensity: 0.2
    )
}
