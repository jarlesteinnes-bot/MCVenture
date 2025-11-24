//
//  NavigationEngine.swift
//  MCVenture
//
//  Created by AI Assistant on 2025-11-24.
//

import Foundation
import CoreLocation
import MapKit

/// Turn types for navigation instructions
enum NavigationTurnType: String, CaseIterable {
    case left = "left"
    case right = "right"
    case slightLeft = "slight_left"
    case slightRight = "slight_right"
    case sharpLeft = "sharp_left"
    case sharpRight = "sharp_right"
    case straight = "straight"
    case roundabout = "roundabout"
    case uTurn = "u_turn"
    case arrive = "arrive"
    
    var icon: String {
        switch self {
        case .left: return "arrow.turn.up.left"
        case .right: return "arrow.turn.up.right"
        case .slightLeft: return "arrow.up.left"
        case .slightRight: return "arrow.up.right"
        case .sharpLeft: return "arrow.turn.down.left"
        case .sharpRight: return "arrow.turn.down.right"
        case .straight: return "arrow.up"
        case .roundabout: return "arrow.triangle.2.circlepath"
        case .uTurn: return "arrow.uturn.down"
        case .arrive: return "flag.checkered"
        }
    }
}

/// Single navigation instruction
struct TurnInstruction: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
    let type: NavigationTurnType
    let streetName: String?
    let distance: Double // meters from start
    let heading: Double // bearing in degrees
    
    var distanceDescription: String {
        if distance < 100 {
            return "\(Int(distance))m"
        } else if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

/// Navigation state
enum NavigationState {
    case idle
    case navigating
    case offRoute
    case arrived
}

/// Main navigation engine
@MainActor
class NavigationEngine: ObservableObject {
    @Published var currentInstruction: TurnInstruction?
    @Published var nextInstruction: TurnInstruction?
    @Published var distanceToNext: Double = 0
    @Published var state: NavigationState = .idle
    @Published var routeProgress: Double = 0 // 0-1
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var distanceRemaining: Double = 0
    
    private var instructions: [TurnInstruction] = []
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentInstructionIndex: Int = 0
    private var lastLocation: CLLocation?
    
    // Configuration
    private let offRouteThreshold: Double = 50 // meters
    private let instructionProximityThreshold: Double = 30 // meters
    private let rerouteDistance: Double = 100 // meters off route before rerouting
    
    // MARK: - Public Methods
    
    /// Start navigation with a route
    func startNavigation(route: ScrapedRoute) {
        let coordinates = route.clLocationCoordinates
        guard !coordinates.isEmpty else {
            print("NavigationEngine: Route has no coordinates")
            return
        }
        
        routeCoordinates = coordinates
        instructions = parseRoute(coordinates)
        currentInstructionIndex = 0
        state = .navigating
        
        if !instructions.isEmpty {
            currentInstruction = instructions[0]
            nextInstruction = instructions.count > 1 ? instructions[1] : nil
        }
        
        calculateTotalDistance()
        print("NavigationEngine: Started navigation with \(instructions.count) instructions")
    }
    
    /// Update navigation with new location
    func updateLocation(_ location: CLLocation) {
        guard state == .navigating else { return }
        
        lastLocation = location
        
        // Check if off route
        if isOffRoute(location) {
            state = .offRoute
            return
        } else if state == .offRoute {
            state = .navigating
        }
        
        // Update current instruction
        if let current = currentInstruction {
            let currentLoc = CLLocation(latitude: current.location.latitude, longitude: current.location.longitude)
            distanceToNext = location.distance(from: currentLoc)
            
            // Check if passed current instruction
            if distanceToNext < instructionProximityThreshold {
                advanceToNextInstruction()
            }
        }
        
        // Update progress
        updateProgress(location)
    }
    
    /// Stop navigation
    func stopNavigation() {
        state = .idle
        instructions.removeAll()
        routeCoordinates.removeAll()
        currentInstructionIndex = 0
        currentInstruction = nil
        nextInstruction = nil
        distanceToNext = 0
        routeProgress = 0
    }
    
    /// Get reroute if needed
    func calculateReroute(from location: CLLocation) -> [CLLocationCoordinate2D]? {
        guard !routeCoordinates.isEmpty else { return nil }
        
        // Find closest point on route ahead
        var closestIndex = 0
        var closestDistance = Double.infinity
        
        for (index, coord) in routeCoordinates.enumerated() {
            let coordLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = location.distance(from: coordLocation)
            
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        // Return remaining route from closest point
        if closestIndex < routeCoordinates.count {
            return Array(routeCoordinates[closestIndex...])
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func parseRoute(_ coordinates: [CLLocationCoordinate2D]) -> [TurnInstruction] {
        var instructions: [TurnInstruction] = []
        
        guard coordinates.count >= 2 else { return instructions }
        
        // Add start instruction
        let startHeading = heading(from: coordinates[0], to: coordinates[1])
        instructions.append(TurnInstruction(
            location: coordinates[0],
            type: .straight,
            streetName: nil,
            distance: 0,
            heading: startHeading
        ))
        
        var totalDistance: Double = 0
        
        // Analyze each segment for turns
        for i in 1..<coordinates.count - 1 {
            let prev = coordinates[i - 1]
            let current = coordinates[i]
            let next = coordinates[i + 1]
            
            // Calculate distance
            let prevLoc = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let currentLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
            totalDistance += prevLoc.distance(from: currentLoc)
            
            // Detect turn
            let turnType = detectTurn(from: prev, via: current, to: next)
            
            // Only add instruction if it's a significant turn
            if turnType != .straight {
                let turnHeading = heading(from: current, to: next)
                instructions.append(TurnInstruction(
                    location: current,
                    type: turnType,
                    streetName: nil,
                    distance: totalDistance,
                    heading: turnHeading
                ))
            }
        }
        
        // Add arrival instruction
        let lastCoord = coordinates[coordinates.count - 1]
        let secondLastCoord = coordinates[coordinates.count - 2]
        let secondLastLoc = CLLocation(latitude: secondLastCoord.latitude, longitude: secondLastCoord.longitude)
        let lastLoc = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
        totalDistance += secondLastLoc.distance(from: lastLoc)
        
        let finalHeading = heading(from: secondLastCoord, to: lastCoord)
        instructions.append(TurnInstruction(
            location: lastCoord,
            type: .arrive,
            streetName: nil,
            distance: totalDistance,
            heading: finalHeading
        ))
        
        return instructions
    }
    
    private func detectTurn(from: CLLocationCoordinate2D, via: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> NavigationTurnType {
        let heading1 = heading(from: from, to: via)
        let heading2 = heading(from: via, to: to)
        
        var angle = heading2 - heading1
        
        // Normalize angle to -180 to 180
        while angle > 180 { angle -= 360 }
        while angle < -180 { angle += 360 }
        
        let absAngle = abs(angle)
        
        // Classify turn based on angle
        if absAngle < 15 {
            return .straight
        } else if absAngle > 160 {
            return .uTurn
        } else if angle > 0 { // Right turn
            if absAngle < 45 {
                return .slightRight
            } else if absAngle < 120 {
                return .right
            } else {
                return .sharpRight
            }
        } else { // Left turn
            if absAngle < 45 {
                return .slightLeft
            } else if absAngle < 120 {
                return .left
            } else {
                return .sharpLeft
            }
        }
    }
    
    private func heading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let heading = atan2(y, x) * 180 / .pi
        
        return (heading + 360).truncatingRemainder(dividingBy: 360)
    }
    
    private func isOffRoute(_ location: CLLocation) -> Bool {
        guard !routeCoordinates.isEmpty else { return false }
        
        // Find closest point on route
        var minDistance = Double.infinity
        
        for coord in routeCoordinates {
            let coordLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = location.distance(from: coordLocation)
            minDistance = min(minDistance, distance)
        }
        
        return minDistance > rerouteDistance
    }
    
    private func advanceToNextInstruction() {
        currentInstructionIndex += 1
        
        if currentInstructionIndex < instructions.count {
            currentInstruction = instructions[currentInstructionIndex]
            
            if currentInstructionIndex + 1 < instructions.count {
                nextInstruction = instructions[currentInstructionIndex + 1]
            } else {
                nextInstruction = nil
            }
            
            // Check if arrived
            if currentInstruction?.type == .arrive {
                state = .arrived
            }
        } else {
            state = .arrived
            currentInstruction = nil
            nextInstruction = nil
        }
    }
    
    private func updateProgress(_ location: CLLocation) {
        guard !routeCoordinates.isEmpty else { return }
        
        // Calculate total distance traveled
        var traveledDistance: Double = 0
        if let firstCoord = routeCoordinates.first {
            let firstLoc = CLLocation(latitude: firstCoord.latitude, longitude: firstCoord.longitude)
            traveledDistance = firstLoc.distance(from: location)
        }
        
        // Calculate remaining distance
        distanceRemaining = 0
        if let current = currentInstruction, currentInstructionIndex < instructions.count - 1 {
            for i in currentInstructionIndex..<instructions.count - 1 {
                let inst1 = instructions[i]
                let inst2 = instructions[i + 1]
                let loc1 = CLLocation(latitude: inst1.location.latitude, longitude: inst1.location.longitude)
                let loc2 = CLLocation(latitude: inst2.location.latitude, longitude: inst2.location.longitude)
                distanceRemaining += loc1.distance(from: loc2)
            }
        }
        
        // Calculate progress (0-1)
        let totalDistance = instructions.last?.distance ?? 1
        routeProgress = totalDistance > 0 ? (totalDistance - distanceRemaining) / totalDistance : 0
        routeProgress = max(0, min(1, routeProgress))
        
        // Estimate time remaining (assuming 60 km/h average)
        let averageSpeed: Double = 60000 / 3600 // meters per second
        estimatedTimeRemaining = distanceRemaining / averageSpeed
    }
    
    private func calculateTotalDistance() {
        guard !routeCoordinates.isEmpty else { return }
        
        var total: Double = 0
        for i in 0..<routeCoordinates.count - 1 {
            let loc1 = CLLocation(latitude: routeCoordinates[i].latitude, longitude: routeCoordinates[i].longitude)
            let loc2 = CLLocation(latitude: routeCoordinates[i + 1].latitude, longitude: routeCoordinates[i + 1].longitude)
            total += loc1.distance(from: loc2)
        }
        distanceRemaining = total
    }
}
