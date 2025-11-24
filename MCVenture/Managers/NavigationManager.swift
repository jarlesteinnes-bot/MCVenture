//
//  NavigationManager.swift
//  MCVenture
//
//  Created by BNTF on 24/11/2025.
//

import Foundation
import MapKit
import CoreLocation
import AVFoundation
import Combine

// MARK: - Navigation Instruction
struct NavigationInstruction: Identifiable {
    let id = UUID()
    let type: InstructionType
    let distance: Double // meters
    let roadName: String?
    let arrivalTime: Date?
    
    enum InstructionType {
        case start
        case turnLeft
        case turnRight
        case turnSlightLeft
        case turnSlightRight
        case turnSharpLeft
        case turnSharpRight
        case uturn
        case merge
        case keepLeft
        case keepRight
        case continueForward
        case roundaboutEnter(exit: Int)
        case arrive
        case waypoint
        
        var icon: String {
            switch self {
            case .start: return "location.circle.fill"
            case .turnLeft: return "arrow.turn.up.left"
            case .turnRight: return "arrow.turn.up.right"
            case .turnSlightLeft: return "arrow.up.left"
            case .turnSlightRight: return "arrow.up.right"
            case .turnSharpLeft: return "arrow.uturn.left"
            case .turnSharpRight: return "arrow.uturn.right"
            case .uturn: return "arrow.uturn.down"
            case .merge: return "arrow.triangle.merge"
            case .keepLeft: return "arrow.up.left.circle"
            case .keepRight: return "arrow.up.right.circle"
            case .continueForward: return "arrow.up"
            case .roundaboutEnter: return "arrow.3.trianglepath"
            case .arrive: return "flag.checkered"
            case .waypoint: return "mappin.circle.fill"
            }
        }
        
        var instruction: String {
            switch self {
            case .start: return "Start your journey"
            case .turnLeft: return "Turn left"
            case .turnRight: return "Turn right"
            case .turnSlightLeft: return "Keep left"
            case .turnSlightRight: return "Keep right"
            case .turnSharpLeft: return "Sharp left turn"
            case .turnSharpRight: return "Sharp right turn"
            case .uturn: return "Make a U-turn"
            case .merge: return "Merge"
            case .keepLeft: return "Keep left"
            case .keepRight: return "Keep right"
            case .continueForward: return "Continue straight"
            case .roundaboutEnter(let exit): return "At roundabout, take exit \(exit)"
            case .arrive: return "You have arrived"
            case .waypoint: return "Waypoint reached"
            }
        }
    }
    
    func distanceText() -> String {
        if distance < 100 {
            return "\(Int(distance)) m"
        } else if distance < 1000 {
            return "\(Int(distance / 100) * 100) m"
        } else {
            return String(format: "%.1f km", distance / 1000.0)
        }
    }
    
    func voiceInstruction(withDistance: Bool = true) -> String {
        var text = type.instruction
        if let road = roadName {
            text += " onto \(road)"
        }
        if withDistance && distance > 0 {
            if distance < 100 {
                text = "In \(Int(distance)) meters, " + text.lowercased()
            } else if distance < 1000 {
                text = "In \(Int(distance / 100) * 100) meters, " + text.lowercased()
            } else {
                let km = distance / 1000.0
                text = String(format: "In %.1f kilometers, ", km) + text.lowercased()
            }
        }
        return text
    }
}

// MARK: - Navigation Manager
class NavigationManager: NSObject, ObservableObject {
    static let shared = NavigationManager()
    
    @Published var isNavigating = false
    @Published var currentInstruction: NavigationInstruction?
    @Published var upcomingInstructions: [NavigationInstruction] = []
    @Published var remainingDistance: Double = 0 // meters
    @Published var remainingTime: TimeInterval = 0
    @Published var currentSpeed: Double = 0 // km/h
    @Published var speedLimit: Double? = nil // km/h
    @Published var isOffRoute = false
    @Published var rerouting = false
    
    private var route: MKRoute?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var currentStepIndex: Int = 0
    private var locationManager: CLLocationManager?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var lastAnnouncedDistance: Double = 0
    private var lastLocation: CLLocation?
    
    // Voice settings
    @Published var voiceEnabled = true
    @Published var voiceVolume: Float = 1.0
    @Published var voiceLanguage: String = "en-US"
    
    // Speed warnings
    @Published var speedWarning: SpeedWarning?
    
    enum SpeedWarning {
        case exceeding
        case muchExceeding
        
        var message: String {
            switch self {
            case .exceeding: return "Speed limit exceeded"
            case .muchExceeding: return "Slow down!"
            }
        }
        
        var color: String {
            switch self {
            case .exceeding: return "orange"
            case .muchExceeding: return "red"
            }
        }
    }
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Start Navigation
    func startNavigation(to destination: CLLocationCoordinate2D, from origin: CLLocationCoordinate2D? = nil, waypoints: [CLLocationCoordinate2D] = []) {
        isNavigating = true
        currentStepIndex = 0
        lastAnnouncedDistance = 0
        destinationCoordinate = destination
        
        // Request route from MapKit
        let request = MKDirections.Request()
        
        if let origin = origin {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        } else {
            request.source = MKMapItem.forCurrentLocation()
        }
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else {
                print("Navigation error: \(error?.localizedDescription ?? "Unknown")")
                self?.isNavigating = false
                return
            }
            
            self.route = route
            self.remainingDistance = route.distance
            self.remainingTime = route.expectedTravelTime
            self.parseInstructions(from: route)
            self.announceNavigationStart()
        }
    }
    
    // MARK: - Stop Navigation
    func stopNavigation() {
        isNavigating = false
        currentInstruction = nil
        upcomingInstructions = []
        remainingDistance = 0
        remainingTime = 0
        route = nil
        currentStepIndex = 0
        isOffRoute = false
        rerouting = false
        speedWarning = nil
    }
    
    // MARK: - Update Location
    func updateLocation(_ location: CLLocation, speed: Double) {
        guard isNavigating, let route = route else { return }
        
        currentSpeed = speed
        lastLocation = location
        
        // Check if off route
        let distanceFromRoute = location.distance(from: CLLocation(latitude: route.polyline.coordinate.latitude, longitude: route.polyline.coordinate.longitude))
        
        if distanceFromRoute > 100 { // 100 meters off route
            if !isOffRoute {
                isOffRoute = true
                announceOffRoute()
            }
            // Auto-reroute after 5 seconds off route
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if self?.isOffRoute == true {
                    self?.reroute(from: location.coordinate)
                }
            }
            return
        } else {
            isOffRoute = false
        }
        
        // Update remaining distance and time
        if let currentInstruction = currentInstruction {
            let distanceToInstruction = location.distance(from: CLLocation(latitude: currentInstruction.id.uuidString.isEmpty ? 0 : currentInstruction.distance, longitude: 0))
            
            // Check if we need to advance to next instruction
            if distanceToInstruction < 20 { // Within 20 meters
                advanceToNextInstruction()
            } else {
                // Announce instruction at specific distances
                announceAtDistance(distanceToInstruction)
            }
        }
        
        // Check speed limit
        checkSpeedLimit()
    }
    
    private func checkSpeedLimit() {
        guard let speedLimit = speedLimit, currentSpeed > 0 else {
            speedWarning = nil
            return
        }
        
        let overage = currentSpeed - speedLimit
        if overage > 20 {
            speedWarning = .muchExceeding
        } else if overage > 10 {
            speedWarning = .exceeding
        } else {
            speedWarning = nil
        }
    }
    
    // MARK: - Reroute
    func reroute(from location: CLLocationCoordinate2D) {
        guard let destination = destinationCoordinate else { return }
        
        rerouting = true
        isOffRoute = false
        
        announceRerouting()
        
        // Calculate new route
        startNavigation(to: destination, from: location)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.rerouting = false
        }
    }
    
    // MARK: - Parse Instructions
    private func parseInstructions(from route: MKRoute) {
        var instructions: [NavigationInstruction] = []
        
        for step in route.steps {
            let type = instructionType(from: step)
            let instruction = NavigationInstruction(
                type: type,
                distance: step.distance,
                roadName: step.instructions.isEmpty ? nil : step.instructions,
                arrivalTime: nil
            )
            instructions.append(instruction)
        }
        
        upcomingInstructions = instructions
        if !instructions.isEmpty {
            currentInstruction = instructions[0]
            if instructions.count > 1 {
                upcomingInstructions = Array(instructions[1...])
            } else {
                upcomingInstructions = []
            }
        }
    }
    
    private func instructionType(from step: MKRoute.Step) -> NavigationInstruction.InstructionType {
        let instruction = step.instructions.lowercased()
        
        if instruction.contains("arrive") {
            return .arrive
        } else if instruction.contains("u-turn") || instruction.contains("u turn") {
            return .uturn
        } else if instruction.contains("sharp left") {
            return .turnSharpLeft
        } else if instruction.contains("sharp right") {
            return .turnSharpRight
        } else if instruction.contains("slight left") || instruction.contains("bear left") {
            return .turnSlightLeft
        } else if instruction.contains("slight right") || instruction.contains("bear right") {
            return .turnSlightRight
        } else if instruction.contains("turn left") {
            return .turnLeft
        } else if instruction.contains("turn right") {
            return .turnRight
        } else if instruction.contains("keep left") {
            return .keepLeft
        } else if instruction.contains("keep right") {
            return .keepRight
        } else if instruction.contains("merge") {
            return .merge
        } else if instruction.contains("roundabout") {
            // Try to parse exit number
            if let exitMatch = instruction.range(of: "\\d+", options: .regularExpression) {
                let exitNumber = Int(instruction[exitMatch]) ?? 1
                return .roundaboutEnter(exit: exitNumber)
            }
            return .roundaboutEnter(exit: 1)
        } else if instruction.contains("continue") || instruction.contains("straight") {
            return .continueForward
        }
        
        return .continueForward
    }
    
    // MARK: - Advance to Next Instruction
    private func advanceToNextInstruction() {
        currentStepIndex += 1
        lastAnnouncedDistance = 0
        
        if !upcomingInstructions.isEmpty {
            currentInstruction = upcomingInstructions[0]
            upcomingInstructions.remove(at: 0)
        } else {
            currentInstruction = nil
        }
    }
    
    // MARK: - Voice Announcements
    private func announceAtDistance(_ distance: Double) {
        guard voiceEnabled else { return }
        
        // Announce at 500m, 200m, 100m, 50m
        let thresholds: [Double] = [500, 200, 100, 50]
        
        for threshold in thresholds {
            if distance <= threshold && distance > threshold - 20 && lastAnnouncedDistance > threshold {
                if let instruction = currentInstruction {
                    speak(instruction.voiceInstruction(withDistance: true))
                    lastAnnouncedDistance = threshold
                    break
                }
            }
        }
    }
    
    private func announceNavigationStart() {
        guard voiceEnabled else { return }
        speak("Navigation started")
    }
    
    private func announceOffRoute() {
        guard voiceEnabled else { return }
        speak("You are off route. Rerouting...")
    }
    
    private func announceRerouting() {
        guard voiceEnabled else { return }
        speak("Calculating new route")
    }
    
    func announceArrival() {
        guard voiceEnabled else { return }
        speak("You have arrived at your destination")
    }
    
    // MARK: - Speech Synthesis
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = 0.5 // Slower speech for better clarity
        utterance.volume = voiceVolume
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}
