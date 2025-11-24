//
//  FuelTrackingManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import Combine

enum FuelWarningLevel {
    case green      // > 4L remaining (safe zone)
    case yellow     // 2-4L remaining (warning zone)
    case red        // < 2L remaining (critical - into safety buffer)
    case empty      // <= 0L (theoretical empty)
    
    var color: String {
        switch self {
        case .green: return "green"
        case .yellow: return "yellow"
        case .red: return "red"
        case .empty: return "red"
        }
    }
    
    var message: String {
        switch self {
        case .green: return "Fuel Level OK"
        case .yellow: return "Refuel Soon"
        case .red: return "Low Fuel - Find Gas Station!"
        case .empty: return "Empty Tank - Refuel Immediately!"
        }
    }
}

class FuelTrackingManager: ObservableObject {
    static let shared = FuelTrackingManager()
    
    // MARK: - Constants
    private let safetyBufferLiters: Double = 2.0
    private let yellowWarningThreshold: Double = 4.0  // 2L + 2L buffer
    
    // MARK: - Published Properties
    @Published var currentFuelLevel: Double = 0.0  // Liters
    @Published var startingFuelLevel: Double = 0.0  // Liters
    @Published var fuelConsumed: Double = 0.0  // Liters
    @Published var warningLevel: FuelWarningLevel = .green
    @Published var remainingRange: Double = 0.0  // Kilometers
    @Published var showWarningAlert: Bool = false
    @Published var lastWarningLevel: FuelWarningLevel = .green
    
    // MARK: - Motorcycle Properties
    private var tankCapacity: Double = 0.0
    private var fuelConsumptionRate: Double = 0.0  // L/100km
    
    // MARK: - Tracking State
    private var isTracking: Bool = false
    private var previousWarningLevel: FuelWarningLevel = .green
    
    private init() {}
    
    // MARK: - Start/Stop Tracking
    func startTracking(motorcycle: Motorcycle, startingFuel: Double? = nil) {
        self.tankCapacity = motorcycle.tankSize
        self.fuelConsumptionRate = motorcycle.fuelConsumption
        
        // Use provided starting fuel or assume full tank
        self.startingFuelLevel = startingFuel ?? tankCapacity
        self.currentFuelLevel = self.startingFuelLevel
        self.fuelConsumed = 0.0
        self.isTracking = true
        self.previousWarningLevel = .green
        self.warningLevel = .green
        self.showWarningAlert = false
        
        updateRemainingRange()
    }
    
    func stopTracking() {
        self.isTracking = false
    }
    
    func resetTracking() {
        self.currentFuelLevel = 0.0
        self.startingFuelLevel = 0.0
        self.fuelConsumed = 0.0
        self.warningLevel = .green
        self.remainingRange = 0.0
        self.isTracking = false
        self.showWarningAlert = false
    }
    
    // MARK: - Update Fuel Based on Distance
    func updateFuelConsumption(distanceTraveledKm: Double) {
        guard isTracking, fuelConsumptionRate > 0 else { return }
        
        // Calculate fuel consumed
        let fuelUsed = (distanceTraveledKm / 100.0) * fuelConsumptionRate
        fuelConsumed = fuelUsed
        
        // Update current fuel level
        currentFuelLevel = max(0, startingFuelLevel - fuelConsumed)
        
        // Update warning level
        updateWarningLevel()
        
        // Update remaining range
        updateRemainingRange()
    }
    
    // MARK: - Manual Fuel Adjustment (for refueling during trip)
    func refuel(liters: Double) {
        let newFuelLevel = min(tankCapacity, currentFuelLevel + liters)
        let fuelAdded = newFuelLevel - currentFuelLevel
        
        currentFuelLevel = newFuelLevel
        startingFuelLevel += fuelAdded
        
        updateWarningLevel()
        updateRemainingRange()
    }
    
    func setFuelLevel(liters: Double) {
        currentFuelLevel = max(0, min(tankCapacity, liters))
        updateWarningLevel()
        updateRemainingRange()
    }
    
    // MARK: - Calculations
    private func updateWarningLevel() {
        let previousLevel = warningLevel
        
        if currentFuelLevel <= 0 {
            warningLevel = .empty
        } else if currentFuelLevel <= safetyBufferLiters {
            warningLevel = .red
        } else if currentFuelLevel <= yellowWarningThreshold {
            warningLevel = .yellow
        } else {
            warningLevel = .green
        }
        
        // Trigger alert if warning level worsened
        if warningLevel != previousLevel && 
           (warningLevel == .red || warningLevel == .yellow) &&
           previousLevel == .green {
            showWarningAlert = true
            lastWarningLevel = warningLevel
        }
    }
    
    private func updateRemainingRange() {
        guard fuelConsumptionRate > 0 else {
            remainingRange = 0.0
            return
        }
        
        // Calculate range with safety buffer factored in
        let usableFuel = max(0, currentFuelLevel - safetyBufferLiters)
        remainingRange = (usableFuel / fuelConsumptionRate) * 100.0
    }
    
    // MARK: - Getters
    func getFuelPercentage() -> Double {
        guard tankCapacity > 0 else { return 0.0 }
        return (currentFuelLevel / tankCapacity) * 100.0
    }
    
    func getUsableFuelPercentage() -> Double {
        guard tankCapacity > 0 else { return 0.0 }
        let usableFuel = max(0, currentFuelLevel - safetyBufferLiters)
        let usableCapacity = max(0, tankCapacity - safetyBufferLiters)
        return (usableFuel / usableCapacity) * 100.0
    }
    
    func isInSafetyBuffer() -> Bool {
        return currentFuelLevel > 0 && currentFuelLevel <= safetyBufferLiters
    }
    
    func getFuelStatus() -> String {
        if currentFuelLevel <= 0 {
            return "Empty"
        } else if isInSafetyBuffer() {
            return "Safety Buffer Only"
        } else {
            return String(format: "%.1fL / %.1fL", currentFuelLevel, tankCapacity)
        }
    }
    
    func dismissWarning() {
        showWarningAlert = false
    }
}
