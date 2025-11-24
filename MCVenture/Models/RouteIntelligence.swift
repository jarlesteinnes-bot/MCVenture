import Foundation
import CoreLocation
import Combine
import CoreMotion

// MARK: - Saved Route
struct SavedRoute: Identifiable, Codable {
    let id: UUID
    var name: String
    let coordinates: [RouteCoordinate]
    let distance: Double
    let elevationProfile: [ElevationPoint]
    let difficulty: RouteDifficulty
    let dateCreated: Date
    var rating: Int
    var tags: [String]
    var surfaceQuality: Double // 0-1 scale
    var curvinessScore: Double // 0-1 scale
    
    init(id: UUID = UUID(), name: String, coordinates: [RouteCoordinate], distance: Double, elevationProfile: [ElevationPoint] = [], difficulty: RouteDifficulty = .medium, rating: Int = 0, tags: [String] = [], surfaceQuality: Double = 1.0, curvinessScore: Double = 0.5) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
        self.distance = distance
        self.elevationProfile = elevationProfile
        self.difficulty = difficulty
        self.dateCreated = Date()
        self.rating = rating
        self.tags = tags
        self.surfaceQuality = surfaceQuality
        self.curvinessScore = curvinessScore
    }
}

struct RouteCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let speed: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum RouteDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
}

// MARK: - Route Recorder
class RouteRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var currentRoute: SavedRoute?
    @Published var savedRoutes: [SavedRoute] = []
    
    private var recordedCoordinates: [RouteCoordinate] = []
    private var recordingStartTime: Date?
    
    func startRecording(name: String) {
        isRecording = true
        recordingStartTime = Date()
        recordedCoordinates = []
    }
    
    func recordLocation(location: CLLocation, speed: Double) {
        guard isRecording else { return }
        
        let coord = RouteCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date(),
            speed: speed
        )
        recordedCoordinates.append(coord)
    }
    
    func stopRecording(name: String, elevationProfile: [ElevationPoint]) -> SavedRoute {
        isRecording = false
        
        let distance = calculateDistance(coordinates: recordedCoordinates)
        let difficulty = calculateDifficulty(coordinates: recordedCoordinates, elevationProfile: elevationProfile)
        let surfaceQuality = 0.9 // Placeholder - would be calculated from accelerometer data
        let curvinessScore = calculateCurviness(coordinates: recordedCoordinates)
        
        let route = SavedRoute(
            name: name,
            coordinates: recordedCoordinates,
            distance: distance,
            elevationProfile: elevationProfile,
            difficulty: difficulty,
            surfaceQuality: surfaceQuality,
            curvinessScore: curvinessScore
        )
        
        savedRoutes.append(route)
        currentRoute = route
        recordedCoordinates = []
        
        return route
    }
    
    private func calculateDistance(coordinates: [RouteCoordinate]) -> Double {
        var distance: Double = 0
        for i in 1..<coordinates.count {
            let prev = CLLocation(latitude: coordinates[i-1].latitude, longitude: coordinates[i-1].longitude)
            let curr = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            distance += curr.distance(from: prev) / 1000.0 // km
        }
        return distance
    }
    
    private func calculateDifficulty(coordinates: [RouteCoordinate], elevationProfile: [ElevationPoint]) -> RouteDifficulty {
        let totalElevation = elevationProfile.reduce(0) { $0 + max(0, $1.altitude) }
        let avgSpeed = coordinates.map { $0.speed }.reduce(0, +) / Double(max(coordinates.count, 1))
        
        if totalElevation > 500 || avgSpeed < 40 { return .expert }
        if totalElevation > 300 || avgSpeed < 60 { return .hard }
        if totalElevation > 100 { return .medium }
        return .easy
    }
    
    private func calculateCurviness(coordinates: [RouteCoordinate]) -> Double {
        guard coordinates.count > 10 else { return 0 }
        
        var directionChanges = 0
        for i in 2..<coordinates.count {
            let prev = coordinates[i-2]
            let curr = coordinates[i-1]
            let next = coordinates[i]
            
            let angle1 = atan2(curr.latitude - prev.latitude, curr.longitude - prev.longitude)
            let angle2 = atan2(next.latitude - curr.latitude, next.longitude - curr.longitude)
            let diff = abs(angle2 - angle1)
            
            if diff > 0.3 { // ~17 degrees
                directionChanges += 1
            }
        }
        
        return min(1.0, Double(directionChanges) / Double(coordinates.count) * 10)
    }
    
    func saveRoute(_ route: SavedRoute) {
        if let index = savedRoutes.firstIndex(where: { $0.id == route.id }) {
            savedRoutes[index] = route
        }
    }
    
    func deleteRoute(_ route: SavedRoute) {
        savedRoutes.removeAll { $0.id == route.id }
    }
}

// MARK: - Route Comparison
struct RouteComparison {
    let route: SavedRoute
    let previousTime: TimeInterval
    let currentTime: TimeInterval
    let previousMaxSpeed: Double
    let currentMaxSpeed: Double
    let previousAvgSpeed: Double
    let currentAvgSpeed: Double
    
    var timeImprovement: TimeInterval {
        previousTime - currentTime
    }
    
    var speedImprovement: Double {
        currentAvgSpeed - previousAvgSpeed
    }
    
    var improvementPercentage: Double {
        (timeImprovement / previousTime) * 100
    }
}

// MARK: - Surface Quality Detector
class SurfaceQualityDetector: ObservableObject {
    @Published var currentQuality: Double = 1.0 // 0-1 scale
    @Published var potholeCount: Int = 0
    @Published var roughSections: [RoughSection] = []
    
    private let motionManager = CMMotionManager()
    private var verticalAccelerationHistory: [Double] = []
    
    func startDetecting() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, let self = self else { return }
            
            let verticalG = abs(data.acceleration.z)
            self.verticalAccelerationHistory.append(verticalG)
            
            // Keep last 100 readings (10 seconds)
            if self.verticalAccelerationHistory.count > 100 {
                self.verticalAccelerationHistory.removeFirst()
            }
            
            // Detect pothole (sudden spike > 2.5G)
            if verticalG > 2.5 {
                self.potholeCount += 1
            }
            
            // Calculate surface quality (smoothness)
            let variance = self.calculateVariance(self.verticalAccelerationHistory)
            self.currentQuality = max(0, 1.0 - (variance * 2))
        }
    }
    
    func stopDetecting() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func calculateVariance(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0, +) / Double(values.count)
    }
    
    func reset() {
        currentQuality = 1.0
        potholeCount = 0
        roughSections = []
    }
}

struct RoughSection: Identifiable {
    let id = UUID()
    let location: CLLocationCoordinate2D
    let severity: Double
    let timestamp: Date
}

// MARK: - Curvature Analyzer
class CurvatureAnalyzer: ObservableObject {
    @Published var turnCount: Int = 0
    @Published var hairpinCount: Int = 0
    @Published var sweepersCount: Int = 0
    @Published var turns: [Turn] = []
    
    func analyzeTurn(entrySpeed: Double, exitSpeed: Double, duration: TimeInterval, location: CLLocationCoordinate2D) {
        let speedDrop = entrySpeed - exitSpeed
        
        let type: TurnType
        if speedDrop > 40 {
            type = .hairpin
            hairpinCount += 1
        } else if speedDrop > 20 {
            type = .tight
        } else if speedDrop < 5 {
            type = .sweeper
            sweepersCount += 1
        } else {
            type = .medium
        }
        
        let turn = Turn(type: type, entrySpeed: entrySpeed, exitSpeed: exitSpeed, location: location)
        turns.append(turn)
        turnCount += 1
    }
    
    func reset() {
        turnCount = 0
        hairpinCount = 0
        sweepersCount = 0
        turns = []
    }
}

struct Turn: Identifiable {
    let id = UUID()
    let type: TurnType
    let entrySpeed: Double
    let exitSpeed: Double
    let location: CLLocationCoordinate2D
    let timestamp = Date()
}

enum TurnType: String {
    case hairpin = "Hairpin"
    case tight = "Tight Turn"
    case medium = "Medium Turn"
    case sweeper = "Sweeper"
}
