//
//  DataManager.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import Foundation
import SwiftUI
import Combine
import UIKit

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    // MARK: - Published Properties
    @Published var completedTrips: [CompletedTrip] = []
    @Published var statistics: RiderStatistics = .default
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var motorcycles: [MotorcycleProfile] = []
    @Published var maintenanceRecords: [MaintenanceRecord] = []
    @Published var packingLists: [PackingList] = []
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var customRoutes: [CustomRoute] = []
    @Published var roadHazards: [RoadHazard] = []
    @Published var routeReviews: [RouteReview] = []
    @Published var groupRides: [GroupRide] = []
    @Published var savedPOIs: [PointOfInterest] = []
    @Published var favoriteRouteIds: Set<UUID> = [] // Store favorite route UUIDs
    
    // MARK: - File URLs
    private var tripsURL: URL {
        getDocumentsDirectory().appendingPathComponent("completedTrips.json")
    }
    
    private var statisticsURL: URL {
        getDocumentsDirectory().appendingPathComponent("statistics.json")
    }
    
    private var achievementsURL: URL {
        getDocumentsDirectory().appendingPathComponent("achievements.json")
    }
    
    private var motorcyclesURL: URL {
        getDocumentsDirectory().appendingPathComponent("motorcycles.json")
    }
    
    private var maintenanceURL: URL {
        getDocumentsDirectory().appendingPathComponent("maintenance.json")
    }
    
    private var packingURL: URL {
        getDocumentsDirectory().appendingPathComponent("packing.json")
    }
    
    private var emergencyURL: URL {
        getDocumentsDirectory().appendingPathComponent("emergency.json")
    }
    
    private var customRoutesURL: URL {
        getDocumentsDirectory().appendingPathComponent("customRoutes.json")
    }
    
    private var hazardsURL: URL {
        getDocumentsDirectory().appendingPathComponent("hazards.json")
    }
    
    private var reviewsURL: URL {
        getDocumentsDirectory().appendingPathComponent("reviews.json")
    }
    
    private var groupRidesURL: URL {
        getDocumentsDirectory().appendingPathComponent("groupRides.json")
    }
    
    private var poisURL: URL {
        getDocumentsDirectory().appendingPathComponent("pois.json")
    }
    
    private var favoritesURL: URL {
        getDocumentsDirectory().appendingPathComponent("favorites.json")
    }
    
    private init() {
        loadAllData()
    }
    
    // MARK: - Load Data
    func loadAllData() {
        completedTrips = load(from: tripsURL) ?? []
        statistics = load(from: statisticsURL) ?? .default
        
        // Load achievements with progress
        if let savedAchievements: [Achievement] = load(from: achievementsURL) {
            achievements = savedAchievements
        } else {
            achievements = Achievement.allAchievements
        }
        
        motorcycles = load(from: motorcyclesURL) ?? []
        maintenanceRecords = load(from: maintenanceURL) ?? []
        packingLists = load(from: packingURL) ?? createDefaultPackingLists()
        emergencyContacts = load(from: emergencyURL) ?? []
        customRoutes = load(from: customRoutesURL) ?? []
        roadHazards = load(from: hazardsURL) ?? []
        routeReviews = load(from: reviewsURL) ?? []
        groupRides = load(from: groupRidesURL) ?? []
        savedPOIs = load(from: poisURL) ?? []
        favoriteRouteIds = load(from: favoritesURL) ?? []
        
        updateAchievements()
    }
    
    private func load<T: Codable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Save Data
    func saveAllData() {
        save(completedTrips, to: tripsURL)
        save(statistics, to: statisticsURL)
        save(achievements, to: achievementsURL)
        save(motorcycles, to: motorcyclesURL)
        save(maintenanceRecords, to: maintenanceURL)
        save(packingLists, to: packingURL)
        save(emergencyContacts, to: emergencyURL)
        save(customRoutes, to: customRoutesURL)
        save(roadHazards, to: hazardsURL)
        save(routeReviews, to: reviewsURL)
        save(groupRides, to: groupRidesURL)
        save(savedPOIs, to: poisURL)
        save(favoriteRouteIds, to: favoritesURL)
    }
    
    private func save<T: Codable>(_ data: T, to url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(data) {
            try? encoded.write(to: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Trip Management
    func addCompletedTrip(_ trip: CompletedTrip) {
        completedTrips.append(trip)
        
        // Update statistics
        statistics.totalTrips += 1
        statistics.totalDistanceKm += trip.distanceKm
        statistics.totalFuelCost += trip.fuelCost
        statistics.totalRidingTime += trip.duration
        statistics.countriesVisited.insert(trip.country)
        statistics.routesCompleted.insert(trip.routeName)
        
        if trip.distanceKm > statistics.longestTrip {
            statistics.longestTrip = trip.distanceKm
        }
        
        updateFavoriteCountry()
        checkAndUnlockAchievements()
        saveAllData()
        
        // Request review at key milestones
        ReviewRequestManager.shared.requestReviewIfAppropriate(tripCount: completedTrips.count)
    }
    
    func deleteTrip(_ trip: CompletedTrip) {
        completedTrips.removeAll { $0.id == trip.id }
        recalculateStatistics()
        updateAchievements()
        saveAllData()
    }
    
    private func recalculateStatistics() {
        statistics = .default
        for trip in completedTrips {
            statistics.totalTrips += 1
            statistics.totalDistanceKm += trip.distanceKm
            statistics.totalFuelCost += trip.fuelCost
            statistics.totalRidingTime += trip.duration
            statistics.countriesVisited.insert(trip.country)
            statistics.routesCompleted.insert(trip.routeName)
            
            if trip.distanceKm > statistics.longestTrip {
                statistics.longestTrip = trip.distanceKm
            }
        }
        updateFavoriteCountry()
    }
    
    private func updateFavoriteCountry() {
        let countryCounts = completedTrips.reduce(into: [:]) { counts, trip in
            counts[trip.country, default: 0] += 1
        }
        statistics.favoriteCountry = countryCounts.max(by: { $0.value < $1.value })?.key ?? ""
    }
    
    // MARK: - Achievement Management
    private func checkAndUnlockAchievements() {
        var newlyUnlocked: [Achievement] = []
        
        achievements = achievements.map { achievement in
            var updated = achievement
            let wasUnlocked = updated.isUnlocked
            
            switch achievement.id {
            case "first_ride":
                updated.progress = Double(statistics.totalTrips)
                updated.isUnlocked = statistics.totalTrips >= 1
                
            case "century":
                updated.progress = Double(statistics.totalTrips)
                updated.isUnlocked = statistics.totalTrips >= 100
                
            case "thousand_km":
                updated.progress = statistics.totalDistanceKm
                updated.isUnlocked = statistics.totalDistanceKm >= 1000
                
            case "ten_countries":
                updated.progress = Double(statistics.countriesVisited.count)
                updated.isUnlocked = statistics.countriesVisited.count >= 10
                
            case "arctic_circle":
                let arcticRoutes = completedTrips.filter { $0.routeName.lowercased().contains("arctic") || $0.routeName.lowercased().contains("nordkyn") || $0.routeName.lowercased().contains("nordkapp") }
                updated.progress = Double(arcticRoutes.count)
                updated.isUnlocked = !arcticRoutes.isEmpty
                
            case "alps_master":
                let alpineRoutes = completedTrips.filter { $0.routeName.lowercased().contains("alps") || $0.country == "Switzerland" || $0.country == "Austria" }
                updated.progress = Double(alpineRoutes.count)
                updated.isUnlocked = alpineRoutes.count >= 20
                
            case "marathon":
                let marathonTrips = completedTrips.filter { $0.distanceKm >= 500 }
                updated.progress = marathonTrips.isEmpty ? 0 : marathonTrips[0].distanceKm
                updated.isUnlocked = !marathonTrips.isEmpty
                
            default:
                break
            }
            
            // Track newly unlocked achievements
            if !wasUnlocked && updated.isUnlocked {
                newlyUnlocked.append(updated)
            }
            
            return updated
        }
        
        // Show notifications for newly unlocked achievements
        for achievement in newlyUnlocked {
            showAchievementNotification(achievement)
        }
    }
    
    func updateAchievements() {
        achievements = achievements.map { achievement in
            var updated = achievement
            
            switch achievement.id {
            case "first_ride":
                updated.progress = Double(statistics.totalTrips)
                updated.isUnlocked = statistics.totalTrips >= 1
                
            case "century":
                updated.progress = Double(statistics.totalTrips)
                updated.isUnlocked = statistics.totalTrips >= 100
                
            case "thousand_km":
                updated.progress = statistics.totalDistanceKm
                updated.isUnlocked = statistics.totalDistanceKm >= 1000
                
            case "ten_countries":
                updated.progress = Double(statistics.countriesVisited.count)
                updated.isUnlocked = statistics.countriesVisited.count >= 10
                
            case "arctic_circle":
                let arcticRoutes = completedTrips.filter { $0.routeName.lowercased().contains("arctic") || $0.routeName.lowercased().contains("nordkyn") || $0.routeName.lowercased().contains("nordkapp") }
                updated.progress = Double(arcticRoutes.count)
                updated.isUnlocked = !arcticRoutes.isEmpty
                
            case "alps_master":
                let alpineRoutes = completedTrips.filter { $0.routeName.lowercased().contains("alps") || $0.country == "Switzerland" || $0.country == "Austria" }
                updated.progress = Double(alpineRoutes.count)
                updated.isUnlocked = alpineRoutes.count >= 20
                
            case "marathon":
                let marathonTrips = completedTrips.filter { $0.distanceKm >= 500 }
                updated.progress = marathonTrips.isEmpty ? 0 : marathonTrips[0].distanceKm
                updated.isUnlocked = !marathonTrips.isEmpty
                
            default:
                break
            }
            
            return updated
        }
    }
    
    private func showAchievementNotification(_ achievement: Achievement) {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Post notification for UI to show
        NotificationCenter.default.post(
            name: NSNotification.Name("AchievementUnlocked"),
            object: nil,
            userInfo: ["achievement": achievement]
        )
    }
    
    // MARK: - Motorcycle Management
    func addMotorcycle(_ motorcycle: MotorcycleProfile) {
        motorcycles.append(motorcycle)
        saveAllData()
    }
    
    func updateMotorcycle(_ motorcycle: MotorcycleProfile) {
        if let index = motorcycles.firstIndex(where: { $0.id == motorcycle.id }) {
            motorcycles[index] = motorcycle
            saveAllData()
        }
    }
    
    func deleteMotorcycle(_ motorcycle: MotorcycleProfile) {
        motorcycles.removeAll { $0.id == motorcycle.id }
        maintenanceRecords.removeAll { $0.motorcycleId == motorcycle.id }
        saveAllData()
    }
    
    // MARK: - Maintenance Management
    func addMaintenanceRecord(_ record: MaintenanceRecord) {
        maintenanceRecords.append(record)
        
        // Update motorcycle mileage
        if let index = motorcycles.firstIndex(where: { $0.id == record.motorcycleId }) {
            motorcycles[index].currentMileage = record.mileage
            if let nextService = record.nextServiceDue {
                motorcycles[index].nextServiceDue = nextService
            }
        }
        
        saveAllData()
    }
    
    func getMaintenanceRecords(for motorcycleId: UUID) -> [MaintenanceRecord] {
        maintenanceRecords.filter { $0.motorcycleId == motorcycleId }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Packing Lists
    private func createDefaultPackingLists() -> [PackingList] {
        let dayTripItems = [
            PackingItem(id: UUID(), name: "Helmet", category: "Gear", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Jacket", category: "Gear", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Gloves", category: "Gear", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Water Bottle", category: "Essentials", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Phone Charger", category: "Electronics", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Sunglasses", category: "Accessories", isPacked: false, isEssential: false),
            PackingItem(id: UUID(), name: "Rain Gear", category: "Weather", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "First Aid Kit", category: "Safety", isPacked: false, isEssential: true),
            PackingItem(id: UUID(), name: "Tire Repair Kit", category: "Tools", isPacked: false, isEssential: true)
        ]
        
        return [
            PackingList(id: UUID(), name: "Day Trip Essentials", tripType: .dayTrip, items: dayTripItems)
        ]
    }
    
    func addPackingList(_ list: PackingList) {
        packingLists.append(list)
        saveAllData()
    }
    
    func updatePackingList(_ list: PackingList) {
        if let index = packingLists.firstIndex(where: { $0.id == list.id }) {
            packingLists[index] = list
            saveAllData()
        }
    }
    
    // MARK: - Emergency Contacts
    func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
        saveAllData()
    }
    
    func updateEmergencyContact(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index] = contact
            saveAllData()
        }
    }
    
    func deleteEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.removeAll { $0.id == contact.id }
        saveAllData()
    }
    
    // MARK: - Road Hazards
    func addRoadHazard(_ hazard: RoadHazard) {
        roadHazards.append(hazard)
        saveAllData()
    }
    
    func getActiveHazards() -> [RoadHazard] {
        roadHazards.filter { $0.isActive }
    }
    
    // MARK: - Route Reviews
    func addRouteReview(_ review: RouteReview) {
        routeReviews.append(review)
        saveAllData()
    }
    
    func getReviews(for routeName: String) -> [RouteReview] {
        routeReviews.filter { $0.routeName == routeName }.sorted { $0.date > $1.date }
    }
    
    func getAverageRating(for routeName: String) -> Double {
        let reviews = getReviews(for: routeName)
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
    }
    
    // MARK: - Group Rides
    func addGroupRide(_ ride: GroupRide) {
        groupRides.append(ride)
        saveAllData()
    }
    
    func joinGroupRide(_ rideId: UUID, userName: String) {
        if let index = groupRides.firstIndex(where: { $0.id == rideId }) {
            if !groupRides[index].participants.contains(userName) && groupRides[index].participants.count < groupRides[index].maxRiders {
                groupRides[index].participants.append(userName)
                saveAllData()
            }
        }
    }
    
    // MARK: - Custom Routes
    func addCustomRoute(_ route: CustomRoute) {
        customRoutes.append(route)
        saveAllData()
    }
    
    // MARK: - POIs
    func addPOI(_ poi: PointOfInterest) {
        savedPOIs.append(poi)
        saveAllData()
    }
    
    func getPOIs(category: POICategory) -> [PointOfInterest] {
        savedPOIs.filter { $0.category == category }
    }
    
    // MARK: - Favorites Management
    func toggleFavorite(routeId: UUID) {
        if favoriteRouteIds.contains(routeId) {
            favoriteRouteIds.remove(routeId)
        } else {
            favoriteRouteIds.insert(routeId)
        }
        saveAllData()
        HapticFeedbackManager.shared.mediumImpact()
    }
    
    func isFavorite(routeId: UUID) -> Bool {
        favoriteRouteIds.contains(routeId)
    }
}
