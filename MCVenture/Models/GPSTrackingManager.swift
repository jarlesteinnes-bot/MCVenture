//
//  GPSTrackingManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import Combine
import CoreMotion
import UIKit

class GPSTrackingManager: NSObject, ObservableObject {
    static let shared = GPSTrackingManager()
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    
    // Basic tracking
    @Published var isTracking = false
    @Published var isPaused = false
    @Published var currentLocation: CLLocation?
    @Published var currentTripId: UUID?
    @Published var tripDistance: Double = 0.0 // in km
    @Published var tripDuration: TimeInterval = 0
    @Published var averageSpeed: Double = 0.0 // km/h
    @Published var currentSpeed: Double = 0.0 // km/h
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    // Advanced stats
    @Published var maxSpeed: Double = 0.0 // km/h
    @Published var calories: Double = 0.0
    @Published var carbonSaved: Double = 0.0 // kg CO2
    @Published var speedZones: [String: TimeInterval] = [
        "0-30": 0, "30-60": 0, "60-90": 0, "90+": 0
    ]
    
    // Elevation tracking
    @Published var elevationTracker = ElevationTracker()
    
    // Waypoints
    @Published var waypoints: [TripWaypoint] = []
    
    // Photos
    @Published var photos: [TripPhoto] = []
    
    // Safety Monitor
    @Published var safetyMonitor = SafetyMonitor()
    
    // Auto-pause
    @Published var autoPauseEnabled = true
    private var lowSpeedStartTime: Date?
    private let autoPauseThreshold: Double = 2.0 // km/h
    private let autoPauseDelay: TimeInterval = 30 // seconds
    
    // Crash detection
    @Published var crashDetected = false
    @Published var crashThreshold: Double {
        didSet {
            UserDefaults.standard.set(crashThreshold, forKey: "crashDetectionThreshold")
        }
    }
    private var recentAccelerations: [Double] = []
    private let accelerationHistorySize = 10
    
    // Pro Mode
    let proModeManager = ProModeManager.shared
    
    // Fuel Tracking
    let fuelTrackingManager = FuelTrackingManager.shared
    
    private var tripStartTime: Date?
    private var lastLocation: CLLocation?
    private var timer: Timer?
    private var lastSpeedZoneUpdate: Date?
    private var activeDuration: TimeInterval = 0
    
    private override init() {
        // Load crash detection threshold from settings BEFORE super.init
        let savedThreshold = UserDefaults.standard.double(forKey: "crashDetectionThreshold")
        self.crashThreshold = savedThreshold > 0 ? savedThreshold : 4.5 // Default 4.5 G (reduced false positives)
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        guard !isTracking else { return }
        
        isTracking = true
        isPaused = false
        currentTripId = UUID()
        tripStartTime = Date()
        tripDistance = 0.0
        tripDuration = 0
        activeDuration = 0
        routeCoordinates = []
        waypoints = []
        photos = []
        lastLocation = nil
        maxSpeed = 0.0
        calories = 0.0
        carbonSaved = 0.0
        speedZones = ["0-30": 0, "30-60": 0, "60-90": 0, "90+": 0]
        crashDetected = false
        lastSpeedZoneUpdate = Date()
        
        elevationTracker.reset()
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Keep app awake during tracking
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start crash detection
        startCrashDetection()
        
        // Start Pro Mode tracking
        proModeManager.startProTracking()
        
        // Start timer for duration and calculations
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
            self?.updateCalories()
            self?.updateSpeedZones()
        }
    }
    
    func stopTracking() -> TripSummary? {
        guard isTracking else { return nil }
        
        isTracking = false
        isPaused = false
        currentTripId = nil
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        
        // Re-enable idle timer
        UIApplication.shared.isIdleTimerDisabled = false
        
        // Stop crash detection
        motionManager.stopAccelerometerUpdates()
        
        // Stop Pro Mode tracking
        proModeManager.stopProTracking()
        
        let summary = TripSummary(
            distance: tripDistance,
            duration: activeDuration > 0 ? activeDuration : tripDuration,
            averageSpeed: averageSpeed,
            maxSpeed: maxSpeed,
            elevationGain: elevationTracker.elevationGain,
            elevationLoss: elevationTracker.elevationLoss,
            coordinates: routeCoordinates,
            elevationProfile: elevationTracker.elevationProfile,
            waypoints: waypoints,
            photos: photos,
            speedZones: speedZones,
            calories: calories,
            carbonSaved: carbonSaved,
            startTime: tripStartTime ?? Date(),
            endTime: Date()
        )
        
        // Request app review at appropriate milestones
        // Only for successful trips (> 1km and > 2 minutes)
        if tripDistance > 1.0 && tripDuration > 120 {
            let totalTrips = UserDefaults.standard.integer(forKey: "totalCompletedTrips") + 1
            UserDefaults.standard.set(totalTrips, forKey: "totalCompletedTrips")
            ReviewRequestManager.shared.requestReviewIfAppropriate(tripCount: totalTrips)
        }
        
        return summary
    }
    
    func pauseTracking() {
        guard isTracking, !isPaused else { return }
        isPaused = true
        locationManager.stopUpdatingLocation()
    }
    
    func resumeTracking() {
        guard isTracking, isPaused else { return }
        isPaused = false
        locationManager.startUpdatingLocation()
    }
    
    func addWaypoint(type: TripWaypointType, note: String = "", photoURL: String? = nil) {
        guard let location = currentLocation else { return }
        let waypoint = TripWaypoint(
            coordinate: location.coordinate,
            type: type,
            note: note,
            photoURL: photoURL
        )
        waypoints.append(waypoint)
    }
    
    func addPhoto(_ photo: TripPhoto) {
        photos.append(photo)
    }
    
    private func updateDuration() {
        // Only count duration when bike is actually moving (speed > 1 km/h)
        if !isPaused && currentSpeed > 1.0 {
            tripDuration += 1.0
            activeDuration += 1.0
        }
    }
    
    private func updateCalories() {
        // Rough estimate: ~40 calories per hour of riding
        let hoursRidden = activeDuration / 3600.0
        calories = hoursRidden * 40.0
    }
    
    private func updateSpeedZones() {
        guard !isPaused, let lastUpdate = lastSpeedZoneUpdate else { return }
        
        // Only count speed zones when bike is actually moving (speed > 1 km/h)
        guard currentSpeed > 1.0 else {
            lastSpeedZoneUpdate = Date()
            return
        }
        
        let elapsed = Date().timeIntervalSince(lastUpdate)
        
        let speed = currentSpeed
        if speed < 30 {
            speedZones["0-30"]! += elapsed
        } else if speed < 60 {
            speedZones["30-60"]! += elapsed
        } else if speed < 90 {
            speedZones["60-90"]! += elapsed
        } else {
            speedZones["90+"]! += elapsed
        }
        
        lastSpeedZoneUpdate = Date()
    }
    
    private func checkAutoPause(speed: Double) {
        guard autoPauseEnabled else { return }
        
        if speed < autoPauseThreshold {
            if lowSpeedStartTime == nil {
                lowSpeedStartTime = Date()
            } else if let startTime = lowSpeedStartTime,
                      Date().timeIntervalSince(startTime) >= autoPauseDelay {
                pauseTracking()
            }
        } else {
            lowSpeedStartTime = nil
            if isPaused && isTracking {
                resumeTracking()
            }
        }
    }
    
    private func startCrashDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.05 // 20Hz sampling
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, let self = self else { return }
            
            // Calculate total acceleration (G-force)
            let acceleration = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            // Remove gravity (1G)
            let netAcceleration = abs(acceleration - 1.0)
            
            // Keep history for trend analysis
            self.recentAccelerations.append(netAcceleration)
            if self.recentAccelerations.count > self.accelerationHistorySize {
                self.recentAccelerations.removeFirst()
            }
            
            // Only detect crash if:
            // 1. Above threshold
            // 2. Vehicle is moving (reduce false positives from phone drops)
            // 3. Not already detected (debounce)
            if netAcceleration > self.crashThreshold && 
               self.currentSpeed > 5.0 && // Must be moving at least 5 km/h
               !self.crashDetected {
                
                // Check if this is a sustained spike (not just a bump)
                let recentAverage = self.recentAccelerations.suffix(3).reduce(0, +) / Double(min(3, self.recentAccelerations.count))
                
                if recentAverage > self.crashThreshold * 0.6 {
                    self.crashDetected = true
                    HapticManager.shared.crashDetected()
                    
                    // Trigger emergency manager crash detection
                    EmergencyManager.shared.detectCrash(gForce: netAcceleration, location: self.currentLocation)
                }
            }
        }
    }
}

extension GPSTrackingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isTracking, !isPaused else { return }
        
        currentLocation = location
        currentSpeed = location.speed >= 0 ? location.speed * 3.6 : 0 // Convert m/s to km/h
        
        // Update max speed
        if currentSpeed > maxSpeed {
            maxSpeed = currentSpeed
        }
        
        // Check auto-pause
        checkAutoPause(speed: currentSpeed)
        
        // Add coordinate to route (only if moving)
        if currentSpeed > 1.0 {
            routeCoordinates.append(location.coordinate)
        }
        
        // Calculate distance
        if let lastLoc = lastLocation {
            let distance = location.distance(from: lastLoc) / 1000.0 // Convert to km
            tripDistance += distance
            
            // Update elevation
            elevationTracker.update(location: location, distance: tripDistance)
            
            // Update average speed (based on active duration)
            if activeDuration > 0 {
                averageSpeed = (tripDistance / activeDuration) * 3600 // km/h
            }
            
            // Calculate carbon saved (vs car: ~120g CO2/km)
            carbonSaved = tripDistance * 0.12 // kg
            
            // Update fuel consumption
            fuelTrackingManager.updateFuelConsumption(distanceTraveledKm: tripDistance)
            
            // Update Pro Mode analytics
            if proModeManager.isProModeEnabled {
                let heading = location.course >= 0 ? location.course : 0
                proModeManager.updateAnalytics(speed: currentSpeed, location: location.coordinate, heading: heading)
                
                // Record route if enabled
                if proModeManager.routeRecordingEnabled {
                    proModeManager.routeRecorder.recordLocation(location: location, speed: currentSpeed)
                }
            }
        }
        
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            requestPermission()
        @unknown default:
            break
        }
    }
}

// Trip summary model
struct TripSummary {
    let distance: Double // km
    let duration: TimeInterval // seconds
    let averageSpeed: Double // km/h
    let maxSpeed: Double // km/h
    let elevationGain: Double // meters
    let elevationLoss: Double // meters
    let coordinates: [CLLocationCoordinate2D]
    let elevationProfile: [ElevationPoint]
    let waypoints: [TripWaypoint]
    let photos: [TripPhoto]
    let speedZones: [String: TimeInterval]
    let calories: Double
    let carbonSaved: Double // kg CO2
    let startTime: Date
    let endTime: Date
}
