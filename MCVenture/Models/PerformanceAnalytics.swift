import Foundation
import CoreMotion
import Combine

// MARK: - Lean Angle Tracker
class LeanAngleTracker: ObservableObject {
    @Published var currentLeanAngle: Double = 0.0 // degrees
    @Published var maxLeftLean: Double = 0.0
    @Published var maxRightLean: Double = 0.0
    @Published var leanHistory: [LeanDataPoint] = []
    
    private let motionManager = CMMotionManager()
    
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, let self = self else { return }
            
            // Calculate lean angle from roll (in degrees)
            let roll = motion.attitude.roll * 180 / .pi
            self.currentLeanAngle = roll
            
            // Track max lean angles
            if roll < 0 { // Left lean
                self.maxLeftLean = min(self.maxLeftLean, roll)
            } else { // Right lean
                self.maxRightLean = max(self.maxRightLean, roll)
            }
            
            // Record history
            let dataPoint = LeanDataPoint(timestamp: Date(), angle: roll)
            self.leanHistory.append(dataPoint)
            
            // Keep only last 1000 points
            if self.leanHistory.count > 1000 {
                self.leanHistory.removeFirst()
            }
        }
    }
    
    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func reset() {
        currentLeanAngle = 0.0
        maxLeftLean = 0.0
        maxRightLean = 0.0
        leanHistory = []
    }
}

struct LeanDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let angle: Double
}

// MARK: - G-Force Tracker
class GForceTracker: ObservableObject {
    @Published var currentGForce: GForceData = GForceData()
    @Published var maxGForce: GForceData = GForceData()
    @Published var gForceHistory: [GForceDataPoint] = []
    
    private let motionManager = CMMotionManager()
    
    func startTracking() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.05 // 20Hz
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, let self = self else { return }
            
            // Convert to G-force (1G = 9.81 m/s²)
            let xG = data.acceleration.x
            let yG = data.acceleration.y
            let zG = data.acceleration.z
            
            let gForce = GForceData(
                longitudinal: yG,  // Acceleration/braking
                lateral: xG,       // Cornering
                vertical: zG       // Suspension/bumps
            )
            
            self.currentGForce = gForce
            
            // Update max G-forces
            self.maxGForce = GForceData(
                longitudinal: max(abs(gForce.longitudinal), abs(self.maxGForce.longitudinal)) * (gForce.longitudinal < 0 ? -1 : 1),
                lateral: max(abs(gForce.lateral), abs(self.maxGForce.lateral)) * (gForce.lateral < 0 ? -1 : 1),
                vertical: max(abs(gForce.vertical), abs(self.maxGForce.vertical))
            )
            
            // Record history
            let dataPoint = GForceDataPoint(timestamp: Date(), gForce: gForce)
            self.gForceHistory.append(dataPoint)
            
            // Keep only last 2000 points (100 seconds at 20Hz)
            if self.gForceHistory.count > 2000 {
                self.gForceHistory.removeFirst()
            }
        }
    }
    
    func stopTracking() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func reset() {
        currentGForce = GForceData()
        maxGForce = GForceData()
        gForceHistory = []
    }
}

struct GForceData {
    var longitudinal: Double = 0.0  // Forward/backward
    var lateral: Double = 0.0       // Left/right
    var vertical: Double = 0.0      // Up/down
    
    var total: Double {
        sqrt(pow(longitudinal, 2) + pow(lateral, 2) + pow(vertical, 2))
    }
}

struct GForceDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let gForce: GForceData
}

// MARK: - Corner Analyzer
class CornerAnalyzer: ObservableObject {
    @Published var corners: [Corner] = []
    @Published var currentCorner: Corner?
    
    private var isInCorner = false
    private var cornerStartTime: Date?
    private var cornerStartSpeed: Double = 0
    private var cornerMinSpeed: Double = 0
    private var cornerStartLocation: CLLocationCoordinate2D?
    
    func analyzeCorner(speed: Double, heading: Double, location: CLLocationCoordinate2D, leanAngle: Double) {
        let isCorneringNow = abs(leanAngle) > 5.0 // 5 degree threshold
        
        if isCorneringNow && !isInCorner {
            // Corner entry
            startCorner(speed: speed, location: location)
        } else if isCorneringNow && isInCorner {
            // In corner - track apex
            if speed < cornerMinSpeed {
                cornerMinSpeed = speed
            }
        } else if !isCorneringNow && isInCorner {
            // Corner exit
            endCorner(speed: speed, location: location)
        }
    }
    
    private func startCorner(speed: Double, location: CLLocationCoordinate2D) {
        isInCorner = true
        cornerStartTime = Date()
        cornerStartSpeed = speed
        cornerMinSpeed = speed
        cornerStartLocation = location
    }
    
    private func endCorner(speed: Double, location: CLLocationCoordinate2D) {
        guard let startTime = cornerStartTime,
              let startLocation = cornerStartLocation else { return }
        
        let corner = Corner(
            entrySpeed: cornerStartSpeed,
            apexSpeed: cornerMinSpeed,
            exitSpeed: speed,
            duration: Date().timeIntervalSince(startTime),
            startLocation: startLocation,
            endLocation: location
        )
        
        corners.append(corner)
        currentCorner = corner
        
        isInCorner = false
        cornerStartTime = nil
        cornerStartLocation = nil
    }
    
    func reset() {
        corners = []
        currentCorner = nil
        isInCorner = false
    }
}

struct Corner: Identifiable {
    let id = UUID()
    let entrySpeed: Double
    let apexSpeed: Double
    let exitSpeed: Double
    let duration: TimeInterval
    let startLocation: CLLocationCoordinate2D
    let endLocation: CLLocationCoordinate2D
    let timestamp = Date()
    
    var difficulty: CornerDifficulty {
        let speedDrop = entrySpeed - apexSpeed
        if speedDrop > 40 { return .hairpin }
        if speedDrop > 20 { return .tight }
        if speedDrop > 10 { return .medium }
        return .fast
    }
}

enum CornerDifficulty: String {
    case hairpin = "Hairpin"
    case tight = "Tight"
    case medium = "Medium"
    case fast = "Fast"
}

// MARK: - Lap Timer
class LapTimer: ObservableObject {
    @Published var laps: [Lap] = []
    @Published var currentLap: Lap?
    @Published var sectors: [Sector] = []
    @Published var isRecording = false
    
    private var lapStartTime: Date?
    private var lapStartLocation: CLLocationCoordinate2D?
    private var sectorTimes: [TimeInterval] = []
    
    func startLap(location: CLLocationCoordinate2D) {
        isRecording = true
        lapStartTime = Date()
        lapStartLocation = location
        sectorTimes = []
    }
    
    func recordSector(location: CLLocationCoordinate2D) {
        guard let startTime = lapStartTime else { return }
        let sectorTime = Date().timeIntervalSince(startTime) - sectorTimes.reduce(0, +)
        sectorTimes.append(sectorTime)
        
        let sector = Sector(number: sectorTimes.count, time: sectorTime)
        sectors.append(sector)
    }
    
    func finishLap(location: CLLocationCoordinate2D, distance: Double, maxSpeed: Double, avgSpeed: Double) {
        guard let startTime = lapStartTime,
              let startLocation = lapStartLocation else { return }
        
        let lapTime = Date().timeIntervalSince(startTime)
        
        let lap = Lap(
            number: laps.count + 1,
            time: lapTime,
            distance: distance,
            maxSpeed: maxSpeed,
            avgSpeed: avgSpeed,
            sectorTimes: sectorTimes,
            startLocation: startLocation,
            timestamp: startTime
        )
        
        laps.append(lap)
        currentLap = lap
        
        // Reset for next lap
        lapStartTime = Date()
        sectorTimes = []
    }
    
    func stopRecording() {
        isRecording = false
        lapStartTime = nil
        currentLap = nil
    }
    
    var bestLap: Lap? {
        laps.min(by: { $0.time < $1.time })
    }
    
    func reset() {
        laps = []
        currentLap = nil
        sectors = []
        sectorTimes = []
    }
}

struct Lap: Identifiable {
    let id = UUID()
    let number: Int
    let time: TimeInterval
    let distance: Double
    let maxSpeed: Double
    let avgSpeed: Double
    let sectorTimes: [TimeInterval]
    let startLocation: CLLocationCoordinate2D
    let timestamp: Date
}

struct Sector: Identifiable {
    let id = UUID()
    let number: Int
    let time: TimeInterval
}
