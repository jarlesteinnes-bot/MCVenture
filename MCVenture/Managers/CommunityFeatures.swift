//
//  CommunityFeatures.swift
//  MCVenture
//

import Foundation
import CoreLocation
import Combine

// MARK: - Achievement System
class AchievementSystem: ObservableObject {
    static let shared = AchievementSystem()
    
    @Published var unlockedAchievements: Set<String> = []
    @Published var totalPoints: Int = 0
    @Published var level: Int = 1
    
    private init() { loadData() }
    
    func checkAchievements(totalKm: Double, totalTrips: Int) {
        if totalTrips >= 1 && !unlockedAchievements.contains("first_ride") {
            unlockAchievement(id: "first_ride", points: 10)
        }
        if totalKm >= 100 && !unlockedAchievements.contains("century") {
            unlockAchievement(id: "century", points: 50)
        }
        if totalKm >= 1000 && !unlockedAchievements.contains("thousand") {
            unlockAchievement(id: "thousand", points: 200)
        }
    }
    
    private func unlockAchievement(id: String, points: Int) {
        unlockedAchievements.insert(id)
        totalPoints += points
        level = max(1, totalPoints / 100)
        saveData()
    }
    
    private func saveData() {
        UserDefaults.standard.set(Array(unlockedAchievements), forKey: "achievements")
        UserDefaults.standard.set(totalPoints, forKey: "totalPoints")
        UserDefaults.standard.set(level, forKey: "level")
    }
    
    private func loadData() {
        if let achievements = UserDefaults.standard.array(forKey: "achievements") as? [String] {
            unlockedAchievements = Set(achievements)
        }
        totalPoints = UserDefaults.standard.integer(forKey: "totalPoints")
        level = max(1, UserDefaults.standard.integer(forKey: "level"))
    }
}

// MARK: - Hazard Reporting
class HazardReporter: ObservableObject {
    static let shared = HazardReporter()
    
    @Published var reportedHazards: [RoadHazard] = []
    
    private init() { loadHazards() }
    
    func reportHazard(type: RoadHazard.HazardType, location: CLLocationCoordinate2D, description: String, severity: RoadHazard.Severity) {
        let hazard = RoadHazard(
            id: UUID(),
            type: type,
            latitude: location.latitude,
            longitude: location.longitude,
            description: description,
            reportedBy: "Current User",
            reportedDate: Date(),
            severity: severity,
            isActive: true
        )
        reportedHazards.append(hazard)
        saveHazards()
    }
    
    func getNearbyHazards(userLocation: CLLocationCoordinate2D, radiusKm: Double = 5.0) -> [RoadHazard] {
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return reportedHazards.filter { hazard in
            let hazardLoc = CLLocation(latitude: hazard.latitude, longitude: hazard.longitude)
            let distance = userLoc.distance(from: hazardLoc) / 1000.0
            return distance <= radiusKm && hazard.isActive
        }
    }
    
    private func saveHazards() {
        if let data = try? JSONEncoder().encode(reportedHazards) {
            UserDefaults.standard.set(data, forKey: "roadHazards")
        }
    }
    
    private func loadHazards() {
        if let data = UserDefaults.standard.data(forKey: "roadHazards"),
           let hazards = try? JSONDecoder().decode([RoadHazard].self, from: data) {
            reportedHazards = hazards
        }
    }
}
