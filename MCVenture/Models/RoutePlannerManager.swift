//
//  RoutePlannerManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Combine

class RoutePlannerManager: ObservableObject {
    static let shared = RoutePlannerManager()
    
    @Published var savedRoutes: [RoutePlan] = []
    @Published var currentRoute: RoutePlan?
    @Published var alternativeRoutes: [RoutePlan] = []
    @Published var aiSuggestions: [AIRouteSuggestion] = []
    @Published var elevationProfile: [RouteElevationPoint] = []
    @Published var isCalculating: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let savedRoutesKey = "savedRoutePlans"
    
    init() {
        loadSavedRoutes()
        generateAISuggestions()
    }
    
    // MARK: - Route Management
    
    func createNewRoute(name: String) -> RoutePlan {
        let route = RoutePlan(name: name)
        currentRoute = route
        return route
    }
    
    func saveRoute(_ route: RoutePlan) {
        var updatedRoute = route
        updatedRoute.lastModified = Date()
        
        if let index = savedRoutes.firstIndex(where: { $0.id == route.id }) {
            savedRoutes[index] = updatedRoute
        } else {
            savedRoutes.append(updatedRoute)
        }
        
        saveToDisk()
    }
    
    func deleteRoute(_ route: RoutePlan) {
        savedRoutes.removeAll { $0.id == route.id }
        saveToDisk()
    }
    
    func duplicateRoute(_ route: RoutePlan) -> RoutePlan {
        var newRoute = route
        newRoute = RoutePlan(id: UUID(), name: "\(route.name) (Copy)", waypoints: route.waypoints, optimization: route.optimization)
        newRoute.roadPreferences = route.roadPreferences
        savedRoutes.append(newRoute)
        saveToDisk()
        return newRoute
    }
    
    // MARK: - Waypoint Management
    
    func addWaypoint(to route: inout RoutePlan, waypoint: RouteWaypoint) {
        route.waypoints.append(waypoint)
        route.lastModified = Date()
        recalculateRoute(&route)
    }
    
    func removeWaypoint(from route: inout RoutePlan, at index: Int) {
        guard index < route.waypoints.count else { return }
        route.waypoints.remove(at: index)
        route.lastModified = Date()
        recalculateRoute(&route)
    }
    
    func moveWaypoint(in route: inout RoutePlan, from: Int, to: Int) {
        guard from < route.waypoints.count, to < route.waypoints.count else { return }
        let waypoint = route.waypoints.remove(at: from)
        route.waypoints.insert(waypoint, at: to)
        route.lastModified = Date()
        recalculateRoute(&route)
    }
    
    func updateWaypoint(in route: inout RoutePlan, waypoint: RouteWaypoint) {
        if let index = route.waypoints.firstIndex(where: { $0.id == waypoint.id }) {
            route.waypoints[index] = waypoint
            route.lastModified = Date()
            recalculateRoute(&route)
        }
    }
    
    // MARK: - Route Calculation
    
    func calculateRoute(_ route: inout RoutePlan, completion: @escaping () -> Void) {
        guard route.waypoints.count >= 2 else {
            completion()
            return
        }
        
        isCalculating = true
        
        // Calculate main route
        recalculateRoute(&route)
        
        // Calculate alternative routes
        calculateAlternativeRoutes(for: route)
        
        // Calculate elevation profile
        calculateElevationProfile(for: route)
        
        // Suggest fuel and rest stops
        suggestStops(for: &route)
        
        // Find nearby POIs
        findNearbyPOIs(for: &route)
        
        // Get weather forecast
        fetchWeatherForecast(for: &route)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isCalculating = false
            completion()
        }
    }
    
    private func recalculateRoute(_ route: inout RoutePlan) {
        guard route.waypoints.count >= 2 else { return }
        
        // Simulate route calculation with optimization
        var totalDistance: Double = 0
        var totalDuration: TimeInterval = 0
        var elevationGain: Double = 0
        var elevationLoss: Double = 0
        
        for i in 0..<route.waypoints.count - 1 {
            let start = route.waypoints[i].coordinate
            let end = route.waypoints[i + 1].coordinate
            
            let distance = calculateDistance(from: start, to: end)
            let duration = estimateDuration(distance: distance, optimization: route.optimization)
            
            totalDistance += distance
            totalDuration += duration
            
            // Simulate elevation changes
            let elevDiff = Double.random(in: -100...100)
            if elevDiff > 0 {
                elevationGain += elevDiff
            } else {
                elevationLoss += abs(elevDiff)
            }
        }
        
        route.totalDistance = totalDistance
        route.estimatedDuration = totalDuration
        route.elevationGain = elevationGain
        route.elevationLoss = elevationLoss
        
        // Calculate fuel consumption and cost
        if let motorcycle = UserProfileManager.shared.profile.selectedMotorcycle {
            // Fuel consumption (L/100km) * distance (km) / 100 = total liters needed
            route.estimatedFuelConsumption = (motorcycle.fuelConsumption * totalDistance) / 100
            route.estimatedFuelCost = route.estimatedFuelConsumption * route.fuelPricePerLiter
        }
        
        // Calculate scores based on optimization
        route.difficultyRating = calculateDifficultyRating(elevationGain: elevationGain, distance: totalDistance)
        route.twistinessScore = calculateTwistinessScore(optimization: route.optimization)
        route.scenicScore = calculateScenicScore(optimization: route.optimization)
        
        // Generate turn-by-turn directions
        generateDirections(for: &route)
        
        // Calculate arrival time if departure is set
        if let departure = route.departureTime {
            route.estimatedArrivalTime = departure.addingTimeInterval(totalDuration)
        }
    }
    
    private func calculateAlternativeRoutes(for route: RoutePlan) {
        guard route.waypoints.count >= 2 else { return }
        
        alternativeRoutes.removeAll()
        
        // Generate 2-3 alternative routes with different optimizations
        let alternativeOptimizations: [RouteOptimization] = [.fastest, .scenic, .shortest]
            .filter { $0 != route.optimization }
            .prefix(2)
            .map { $0 }
        
        for optimization in alternativeOptimizations {
            var altRoute = route
            altRoute = RoutePlan(id: UUID(), name: "\(route.name) (\(optimization.rawValue))", waypoints: route.waypoints, optimization: optimization)
            altRoute.roadPreferences = route.roadPreferences
            recalculateRoute(&altRoute)
            alternativeRoutes.append(altRoute)
        }
    }
    
    private func calculateElevationProfile(for route: RoutePlan) {
        guard route.waypoints.count >= 2 else { return }
        
        elevationProfile.removeAll()
        
        let totalDistance = route.totalDistance
        let samples = min(100, Int(totalDistance)) // Sample every km or 100 points max
        
        var currentDistance: Double = 0
        var currentElevation: Double = Double.random(in: 100...500)
        
        for i in 0...samples {
            let distance = (Double(i) / Double(samples)) * totalDistance
            
            // Simulate elevation changes with some randomness
            let elevationChange = Double.random(in: -20...20)
            currentElevation += elevationChange
            currentElevation = max(0, currentElevation)
            
            // Calculate gradient
            let gradient = (i > 0) ? ((currentElevation - elevationProfile.last!.elevation) / 1000) * 100 : 0
            
            // Interpolate coordinate
            let progress = Double(i) / Double(samples)
            let waypointIndex = min(Int(progress * Double(route.waypoints.count - 1)), route.waypoints.count - 2)
            let coord = route.waypoints[waypointIndex].coordinate
            
            let point = RouteElevationPoint(
                distance: distance,
                elevation: currentElevation,
                coordinate: coord,
                gradient: gradient
            )
            elevationProfile.append(point)
            currentDistance = distance
        }
    }
    
    // MARK: - Stop Suggestions
    
    private func suggestStops(for route: inout RoutePlan) {
        route.suggestedFuelStops.removeAll()
        route.suggestedRestStops.removeAll()
        
        guard let motorcycle = UserProfileManager.shared.profile.selectedMotorcycle else { return }
        
        // Use actual motorcycle tank size, with safety margin of 90%
        let usableTankSize = motorcycle.tankSize * 0.9
        let fuelRange = usableTankSize / motorcycle.fuelConsumption * 100
        let numberOfFuelStops = Int(ceil(route.totalDistance / fuelRange)) - 1
        
        // Suggest fuel stops every fuelRange km
        for i in 1...numberOfFuelStops {
            let distance = Double(i) * fuelRange
            let progress = distance / route.totalDistance
            let waypointIndex = min(Int(progress * Double(route.waypoints.count - 1)), route.waypoints.count - 2)
            let baseCoord = route.waypoints[waypointIndex].coordinate
            
            let fuelStop = RouteWaypoint(
                name: "Fuel Stop \(i)",
                coordinate: CLLocationCoordinate2D(
                    latitude: baseCoord.latitude + Double.random(in: -0.01...0.01),
                    longitude: baseCoord.longitude + Double.random(in: -0.01...0.01)
                ),
                type: .fuel,
                address: "Suggested location at ~\(Int(distance)) km"
            )
            route.suggestedFuelStops.append(fuelStop)
        }
        
        // Suggest rest stops every 2 hours
        let restInterval: TimeInterval = 2 * 3600 // 2 hours
        let numberOfRestStops = Int(floor(route.estimatedDuration / restInterval))
        
        for i in 1...numberOfRestStops {
            let time = Double(i) * restInterval
            let progress = time / route.estimatedDuration
            let waypointIndex = min(Int(progress * Double(route.waypoints.count - 1)), route.waypoints.count - 2)
            let baseCoord = route.waypoints[waypointIndex].coordinate
            
            let restStop = RouteWaypoint(
                name: "Rest Stop \(i)",
                coordinate: CLLocationCoordinate2D(
                    latitude: baseCoord.latitude + Double.random(in: -0.01...0.01),
                    longitude: baseCoord.longitude + Double.random(in: -0.01...0.01)
                ),
                type: .rest,
                address: "Suggested break after \(i * 2) hours"
            )
            route.suggestedRestStops.append(restStop)
        }
    }
    
    private func findNearbyPOIs(for route: inout RoutePlan) {
        route.nearbyPOIs.removeAll()
        
        // Simulate finding POIs near the route
        let poiTypes: [RouteWaypoint.WaypointType] = [.restaurant, .hotel, .attraction, .scenic]
        let numberOfPOIs = Int.random(in: 3...8)
        
        for i in 0..<numberOfPOIs {
            let randomWaypointIndex = Int.random(in: 0..<route.waypoints.count)
            let baseCoord = route.waypoints[randomWaypointIndex].coordinate
            let randomType = poiTypes.randomElement() ?? .attraction
            
            let poi = RouteWaypoint(
                name: "\(randomType.rawValue) \(i + 1)",
                coordinate: CLLocationCoordinate2D(
                    latitude: baseCoord.latitude + Double.random(in: -0.02...0.02),
                    longitude: baseCoord.longitude + Double.random(in: -0.02...0.02)
                ),
                type: randomType,
                address: "Nearby \(randomType.rawValue.lowercased())"
            )
            route.nearbyPOIs.append(poi)
        }
    }
    
    // MARK: - Weather
    
    private func fetchWeatherForecast(for route: inout RoutePlan) {
        guard let scheduledDate = route.scheduledDate else { return }
        
        // Simulate weather forecast
        let conditions = ["Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Rain"]
        let condition = conditions.randomElement() ?? "Sunny"
        let temp = Double.random(in: 10...25)
        let precipitation = condition.contains("Rain") ? Double.random(in: 40...80) : Double.random(in: 0...30)
        
        var recommendation: WeatherForecastData.WeatherRecommendation = .excellent
        if precipitation > 60 {
            recommendation = .poor
        } else if precipitation > 30 {
            recommendation = .fair
        } else if temp < 15 {
            recommendation = .good
        }
        
        route.weatherForecast = WeatherForecastData(
            date: scheduledDate,
            temperature: temp,
            condition: condition,
            precipitationChance: precipitation,
            windSpeed: Double.random(in: 5...20),
            visibility: Double.random(in: 8...15),
            recommendation: recommendation
        )
    }
    
    // MARK: - Directions
    
    private func generateDirections(for route: inout RoutePlan) {
        route.directions.removeAll()
        
        guard route.waypoints.count >= 2 else { return }
        
        // Generate simplified turn-by-turn directions
        for i in 0..<route.waypoints.count {
            let waypoint = route.waypoints[i]
            let distance = (i < route.waypoints.count - 1) ? calculateDistance(from: waypoint.coordinate, to: route.waypoints[i + 1].coordinate) : 0
            let duration = estimateDuration(distance: distance, optimization: route.optimization)
            
            var maneuverType: RouteDirection.ManeuverType = .straight
            var instruction = ""
            
            if i == 0 {
                maneuverType = .depart
                instruction = "Depart from \(waypoint.name)"
            } else if i == route.waypoints.count - 1 {
                maneuverType = .arrive
                instruction = "Arrive at \(waypoint.name)"
            } else {
                let maneuvers: [RouteDirection.ManeuverType] = [.turn, .straight, .merge, .roundabout]
                maneuverType = maneuvers.randomElement() ?? .straight
                instruction = "Continue to \(waypoint.name)"
            }
            
            let direction = RouteDirection(
                instruction: instruction,
                distance: distance,
                duration: duration,
                coordinate: waypoint.coordinate,
                maneuverType: maneuverType
            )
            route.directions.append(direction)
        }
    }
    
    // MARK: - AI Suggestions
    
    func generateAISuggestions() {
        aiSuggestions.removeAll()
        
        // Ride of the Day
        let rideOfTheDay = createSampleRoute(name: "Coastal Highway Adventure", type: .rideOfTheDay)
        aiSuggestions.append(AIRouteSuggestion(
            title: "Today's Featured Ride",
            description: "Beautiful coastal route with stunning ocean views. Perfect weather today!",
            route: rideOfTheDay,
            suggestionType: .rideOfTheDay,
            confidence: 0.95
        ))
        
        // Seasonal
        let seasonalRoute = createSampleRoute(name: "Autumn Forest Loop", type: .seasonal)
        aiSuggestions.append(AIRouteSuggestion(
            title: "Fall Colors Route",
            description: "Experience peak autumn foliage on this scenic mountain loop.",
            route: seasonalRoute,
            suggestionType: .seasonal,
            confidence: 0.88
        ))
        
        // Popular Nearby
        let popularRoute = createSampleRoute(name: "Twisty Mountain Pass", type: .popular)
        aiSuggestions.append(AIRouteSuggestion(
            title: "Most Popular This Week",
            description: "Highly rated by local riders. 127 rides this week!",
            route: popularRoute,
            suggestionType: .popular,
            confidence: 0.92
        ))
        
        // Based on History
        if DataManager.shared.completedTrips.count > 0 {
            let historyRoute = createSampleRoute(name: "Similar Ride You'll Love", type: .basedOnHistory)
            aiSuggestions.append(AIRouteSuggestion(
                title: "Based on Your Rides",
                description: "Similar to your recent trips but with new scenic sections.",
                route: historyRoute,
                suggestionType: .basedOnHistory,
                confidence: 0.85
            ))
        }
    }
    
    private func createSampleRoute(name: String, type: AIRouteSuggestion.SuggestionType) -> RoutePlan {
        // Create sample waypoints based on type
        let start = RouteWaypoint(
            name: "Start Point",
            coordinate: CLLocationCoordinate2D(latitude: 59.9139 + Double.random(in: -0.5...0.5), longitude: 10.7522 + Double.random(in: -0.5...0.5)),
            type: .start
        )
        
        let mid1 = RouteWaypoint(
            name: "Scenic Stop",
            coordinate: CLLocationCoordinate2D(latitude: start.coordinate.latitude + 0.3, longitude: start.coordinate.longitude + 0.2),
            type: .scenic
        )
        
        let mid2 = RouteWaypoint(
            name: "Rest Area",
            coordinate: CLLocationCoordinate2D(latitude: mid1.coordinate.latitude + 0.2, longitude: mid1.coordinate.longitude + 0.3),
            type: .rest
        )
        
        let end = RouteWaypoint(
            name: "End Point",
            coordinate: CLLocationCoordinate2D(latitude: mid2.coordinate.latitude + 0.3, longitude: mid2.coordinate.longitude - 0.4),
            type: .end
        )
        
        var route = RoutePlan(name: name, waypoints: [start, mid1, mid2, end], optimization: .scenic)
        
        // Set optimization based on type
        switch type {
        case .rideOfTheDay, .seasonal:
            route.optimization = .scenic
        case .popular:
            route.optimization = .twisty
        case .basedOnHistory:
            route.optimization = .balanced
        default:
            route.optimization = .balanced
        }
        
        recalculateRoute(&route)
        return route
    }
    
    // MARK: - Export
    
    func exportToGPX(_ route: RoutePlan) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVentures">
            <metadata>
                <name>\(route.name)</name>
                <time>\(ISO8601DateFormatter().string(from: Date()))</time>
            </metadata>
            <trk>
                <name>\(route.name)</name>
                <trkseg>
        
        """
        
        for waypoint in route.waypoints {
            gpx += """
                    <trkpt lat="\(waypoint.coordinate.latitude)" lon="\(waypoint.coordinate.longitude)">
                        <name>\(waypoint.name)</name>
                    </trkpt>
            
            """
        }
        
        gpx += """
                </trkseg>
            </trk>
        </gpx>
        """
        
        return gpx
    }
    
    // MARK: - Utility Functions
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0 // Convert to km
    }
    
    private func estimateDuration(distance: Double, optimization: RouteOptimization) -> TimeInterval {
        var avgSpeed: Double
        
        switch optimization {
        case .fastest:
            avgSpeed = 80.0 // km/h
        case .shortest:
            avgSpeed = 60.0
        case .scenic:
            avgSpeed = 50.0
        case .twisty:
            avgSpeed = 45.0
        case .balanced:
            avgSpeed = 65.0
        }
        
        return (distance / avgSpeed) * 3600 // Convert to seconds
    }
    
    private func calculateDifficultyRating(elevationGain: Double, distance: Double) -> Double {
        let elevationPerKm = elevationGain / max(distance, 1)
        return min(10, (elevationPerKm / 50) * 10) // 0-10 scale
    }
    
    private func calculateTwistinessScore(optimization: RouteOptimization) -> Double {
        switch optimization {
        case .twisty:
            return Double.random(in: 7...10)
        case .scenic:
            return Double.random(in: 5...8)
        case .balanced:
            return Double.random(in: 4...7)
        case .fastest:
            return Double.random(in: 2...5)
        case .shortest:
            return Double.random(in: 3...6)
        }
    }
    
    private func calculateScenicScore(optimization: RouteOptimization) -> Double {
        switch optimization {
        case .scenic:
            return Double.random(in: 8...10)
        case .twisty:
            return Double.random(in: 6...9)
        case .balanced:
            return Double.random(in: 5...8)
        case .fastest:
            return Double.random(in: 2...5)
        case .shortest:
            return Double.random(in: 3...6)
        }
    }
    
    // MARK: - Persistence
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedRoutes) {
            userDefaults.set(encoded, forKey: savedRoutesKey)
        }
    }
    
    private func loadSavedRoutes() {
        if let data = userDefaults.data(forKey: savedRoutesKey),
           let decoded = try? JSONDecoder().decode([RoutePlan].self, from: data) {
            savedRoutes = decoded
        }
    }
}
