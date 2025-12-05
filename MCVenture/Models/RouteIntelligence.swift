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

// MARK: - Route Telemetry Vector
struct RouteTelemetryVector: Identifiable, Codable {
    let id: UUID
    let routeName: String
    let sourceRouteId: UUID?
    let tripId: UUID?
    let date: Date
    let distance: Double
    let duration: TimeInterval
    let averageSpeed: Double
    let maxSpeed: Double
    let elevationGain: Double
    let elevationVariance: Double
    let twistinessIndex: Double
    let leanAggression: Double
    let surfaceQuality: Double
    let potholeDensity: Double
    let lateralG: Double
    let flowScore: Double
    let brakingIntensity: Double
    
    func featureVector() -> [Double] {
        func normalize(_ value: Double, min: Double, max: Double) -> Double {
            guard max - min > 0 else { return 0 }
            return max(0, min(1, (value - min) / (max - min)))
        }
        
        let normalizedDistance = normalize(distance, min: 0, max: 600)
        let normalizedElevation = normalize(elevationVariance, min: 0, max: 250000)
        let normalizedSpeed = normalize(averageSpeed, min: 10, max: 140)
        let normalizedMaxSpeed = normalize(maxSpeed, min: 30, max: 200)
        
        return [
            normalizedDistance,
            min(1, twistinessIndex),
            min(1, leanAggression),
            min(1, surfaceQuality),
            min(1, potholeDensity),
            min(1, lateralG),
            normalizedElevation,
            min(1, flowScore),
            min(1, brakingIntensity),
            normalizedSpeed,
            normalizedMaxSpeed
        ]
    }
}

struct RouteCluster: Identifiable, Codable {
    let id: UUID
    let label: String
    let centroid: [Double]
    let memberRouteNames: [String]
}

struct RouteRecommendation: Identifiable {
    let id = UUID()
    let route: EuropeanRoute
    let similarity: Double
    let rationale: String
}

struct RouteQualityScore {
    let overall: Double
    let smoothness: Double
    let flow: Double
    let technicality: Double
    let safety: Double
    let dataConfidence: Double
}

// MARK: - Route Intelligence Engine
@MainActor
final class RouteIntelligenceEngine: ObservableObject {
    static let shared = RouteIntelligenceEngine()
    
    @Published private(set) var telemetryVectors: [RouteTelemetryVector] = []
    @Published private(set) var clusters: [RouteCluster] = []
    
    private let storageURL: URL
    
    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        storageURL = documents.appendingPathComponent("routeTelemetry.json")
        loadVectors()
        recomputeClusters()
    }
    
    func ingestTrip(routeName: String,
                    sourceRouteId: UUID?,
                    summary: TripSummary,
                    snapshot: TelemetrySnapshot?,
                    metadata: CompletedTrip?) {
        let vector = makeVector(routeName: routeName,
                                sourceRouteId: sourceRouteId,
                                summary: summary,
                                snapshot: snapshot,
                                metadata: metadata)
        telemetryVectors.append(vector)
        saveVectors()
        recomputeClusters()
    }
    
    func routeQuality(for route: EuropeanRoute) -> RouteQualityScore {
        let vector = representativeVector(forRouteName: route.name) ?? syntheticVector(for: route)
        let smoothness = clamp(vector.surfaceQuality)
        let flow = clamp(vector.flowScore)
        let technicality = clamp((vector.twistinessIndex + vector.leanAggression) / 2)
        let safety = clamp(1.0 - (vector.potholeDensity * 0.7 + vector.lateralG * 0.3))
        let confidence = dataConfidence(for: route.name)
        let overall = clamp((smoothness * 0.25) + (flow * 0.2) + (technicality * 0.2) + (safety * 0.25) + (confidence * 0.1))
        
        return RouteQualityScore(
            overall: overall,
            smoothness: smoothness,
            flow: flow,
            technicality: technicality,
            safety: safety,
            dataConfidence: confidence
        )
    }
    
    func recommendedRoutes(for route: EuropeanRoute, limit: Int = 3) -> [RouteRecommendation] {
        let baseVector = representativeVector(forRouteName: route.name) ?? syntheticVector(for: route)
        let baseFeatures = baseVector.featureVector()
        
        let candidates = EuropeanRoutesDatabase.shared.routes.filter { $0.id != route.id }
        var scored: [RouteRecommendation] = []
        
        for candidate in candidates {
            let vector = representativeVector(forRouteName: candidate.name) ?? syntheticVector(for: candidate)
            let similarity = cosineSimilarity(baseFeatures, vector.featureVector())
            guard similarity > 0.4 else { continue }
            
            let rationale = buildRationale(base: baseVector, candidate: vector)
            scored.append(RouteRecommendation(route: candidate, similarity: similarity, rationale: rationale))
        }
        
        return Array(scored.sorted { $0.similarity > $1.similarity }.prefix(limit))
    }
    
    // MARK: - Internal Helpers
    private func makeVector(routeName: String,
                            sourceRouteId: UUID?,
                            summary: TripSummary,
                            snapshot: TelemetrySnapshot?,
                            metadata: CompletedTrip?) -> RouteTelemetryVector {
        let snap = snapshot ?? TelemetrySnapshot.placeholder
        let elevationVariance = variance(values: summary.elevationProfile.map { $0.altitude })
        let twistiness = min(1.0, snap.turnDensityPer10Km / 8.0)
        let leanAggression = min(1.0, (abs(snap.maxLeanLeft) + snap.maxLeanRight) / 120.0)
        let potholeDensity = min(1.0, snap.potholeDensityPer100Km / 25.0)
        let lateralG = min(1.0, snap.averageLateralG / 1.5)
        let flow = clamp(summary.averageSpeed / max(summary.maxSpeed, 1))
        
        return RouteTelemetryVector(
            id: UUID(),
            routeName: routeName,
            sourceRouteId: sourceRouteId,
            tripId: metadata?.id,
            date: Date(),
            distance: summary.distance,
            duration: summary.duration,
            averageSpeed: summary.averageSpeed,
            maxSpeed: summary.maxSpeed,
            elevationGain: summary.elevationGain,
            elevationVariance: elevationVariance,
            twistinessIndex: twistiness,
            leanAggression: leanAggression,
            surfaceQuality: snap.averageSurfaceQuality,
            potholeDensity: potholeDensity,
            lateralG: lateralG,
            flowScore: flow,
            brakingIntensity: min(1.0, snap.brakingIntensity)
        )
    }
    
    private func representativeVector(forRouteName name: String) -> RouteTelemetryVector? {
        let matches = telemetryVectors.filter { $0.routeName == name }
        guard !matches.isEmpty else { return nil }
        
        func average(_ keyPath: KeyPath<RouteTelemetryVector, Double>) -> Double {
            matches.map { $0[keyPath: keyPath] }.reduce(0, +) / Double(matches.count)
        }
        
        return RouteTelemetryVector(
            id: UUID(),
            routeName: name,
            sourceRouteId: matches.first?.sourceRouteId,
            tripId: nil,
            date: Date(),
            distance: average(\.distance),
            duration: average(\.duration),
            averageSpeed: average(\.averageSpeed),
            maxSpeed: average(\.maxSpeed),
            elevationGain: average(\.elevationGain),
            elevationVariance: average(\.elevationVariance),
            twistinessIndex: average(\.twistinessIndex),
            leanAggression: average(\.leanAggression),
            surfaceQuality: average(\.surfaceQuality),
            potholeDensity: average(\.potholeDensity),
            lateralG: average(\.lateralG),
            flowScore: average(\.flowScore),
            brakingIntensity: average(\.brakingIntensity)
        )
    }
    
    private func syntheticVector(for route: EuropeanRoute) -> RouteTelemetryVector {
        let difficultyWeight: Double
        switch route.difficulty {
        case .easy: difficultyWeight = 0.25
        case .moderate: difficultyWeight = 0.45
        case .challenging: difficultyWeight = 0.65
        case .expert: difficultyWeight = 0.85
        }
        
        let distance = route.distanceKm
        let estimatedDuration = (distance / (45 + difficultyWeight * 40)) * 3600
        let twistiness = difficultyWeight + min(0.2, Double(route.highlights.count) * 0.01)
        let leanAggression = difficultyWeight
        
        return RouteTelemetryVector(
            id: UUID(),
            routeName: route.name,
            sourceRouteId: route.id,
            tripId: nil,
            date: Date(),
            distance: distance,
            duration: estimatedDuration,
            averageSpeed: max(35, 80 * (1 - difficultyWeight / 2)),
            maxSpeed: 140,
            elevationGain: 400 * difficultyWeight,
            elevationVariance: 120000 * difficultyWeight,
            twistinessIndex: min(1.0, twistiness),
            leanAggression: min(1.0, leanAggression),
            surfaceQuality: 0.85 - (difficultyWeight * 0.15),
            potholeDensity: 0.1 + difficultyWeight * 0.1,
            lateralG: 0.3 + difficultyWeight * 0.3,
            flowScore: 0.7 - difficultyWeight * 0.2,
            brakingIntensity: 0.3 + difficultyWeight * 0.4
        )
    }
    
    private func saveVectors() {
        do {
            let data = try JSONEncoder().encode(telemetryVectors)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            print("Failed to persist telemetry vectors: \(error.localizedDescription)")
        }
    }
    
    private func loadVectors() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            telemetryVectors = try JSONDecoder().decode([RouteTelemetryVector].self, from: data)
        } catch {
            telemetryVectors = []
            print("Failed to load telemetry vectors: \(error.localizedDescription)")
        }
    }
    
    private func recomputeClusters() {
        guard telemetryVectors.count >= 6 else {
            clusters = []
            return
        }
        
        let clusterCount = max(2, min(6, telemetryVectors.count / 6))
        clusters = KMeansClusterer.cluster(vectors: telemetryVectors, k: clusterCount)
    }
    
    private func dataConfidence(for routeName: String) -> Double {
        let sampleCount = telemetryVectors.filter { $0.routeName == routeName }.count
        return min(1.0, Double(sampleCount) / 5.0)
    }
    
    private func cosineSimilarity(_ lhs: [Double], _ rhs: [Double]) -> Double {
        guard lhs.count == rhs.count else { return 0 }
        let dot = zip(lhs, rhs).reduce(0) { $0 + $1.0 * $1.1 }
        let lhsMag = sqrt(lhs.reduce(0) { $0 + $1 * $1 })
        let rhsMag = sqrt(rhs.reduce(0) { $0 + $1 * $1 })
        guard lhsMag > 0 && rhsMag > 0 else { return 0 }
        return (dot / (lhsMag * rhsMag)).clamped()
    }
    
    private func buildRationale(base: RouteTelemetryVector, candidate: RouteTelemetryVector) -> String {
        var reasons: [String] = []
        
        if abs(base.twistinessIndex - candidate.twistinessIndex) < 0.1 {
            reasons.append("similar corner density")
        }
        
        if abs(base.surfaceQuality - candidate.surfaceQuality) < 0.15 {
            reasons.append("matching surface quality")
        }
        
        if abs(base.elevationVariance - candidate.elevationVariance) < 30000 {
            reasons.append("comparable elevation profile")
        }
        
        if base.flowScore > 0.6 && candidate.flowScore > 0.6 {
            reasons.append("fast flowing character")
        } else if base.flowScore < 0.4 && candidate.flowScore < 0.4 {
            reasons.append("technical riding pace")
        }
        
        return reasons.isEmpty ? "Telemetry signature overlap" : reasons.joined(separator: ", ")
    }
    
    private func clamp(_ value: Double) -> Double {
        max(0, min(1, value))
    }
    
    private func variance(values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squared = values.map { pow($0 - mean, 2) }
        return squared.reduce(0, +) / Double(values.count)
    }
}

// MARK: - KMeans Clusterer
enum KMeansClusterer {
    static func cluster(vectors: [RouteTelemetryVector], k: Int) -> [RouteCluster] {
        guard !vectors.isEmpty else { return [] }
        
        var centroids = vectors.shuffled().prefix(k).map { $0.featureVector() }
        var assignments = Array(repeating: [RouteTelemetryVector](), count: k)
        
        for _ in 0..<8 {
            assignments = Array(repeating: [], count: k)
            
            for vector in vectors {
                let features = vector.featureVector()
                let closestIndex = closestCentroid(for: features, centroids: centroids)
                assignments[closestIndex].append(vector)
            }
            
            for index in 0..<k {
                guard !assignments[index].isEmpty else { continue }
                let summed = assignments[index].map { $0.featureVector() }
                centroids[index] = averageVectors(summed)
            }
        }
        
        return assignments.enumerated().compactMap { (idx, members) in
            guard !members.isEmpty else { return nil }
            let centroid = centroids[idx]
            return RouteCluster(
                id: UUID(),
                label: describeCluster(centroid),
                centroid: centroid,
                memberRouteNames: members.map { $0.routeName }
            )
        }
    }
    
    private static func closestCentroid(for vector: [Double], centroids: [[Double]]) -> Int {
        var bestIndex = 0
        var bestDistance = Double.infinity
        
        for (idx, centroid) in centroids.enumerated() {
            let distance = zip(vector, centroid).reduce(0) { $0 + pow($1.0 - $1.1, 2) }
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = idx
            }
        }
        return bestIndex
    }
    
    private static func averageVectors(_ vectors: [[Double]]) -> [Double] {
        guard let first = vectors.first else { return [] }
        var totals = Array(repeating: 0.0, count: first.count)
        
        for vector in vectors {
            for (idx, value) in vector.enumerated() {
                totals[idx] += value
            }
        }
        
        return totals.map { $0 / Double(vectors.count) }
    }
    
    private static func describeCluster(_ centroid: [Double]) -> String {
        guard centroid.count >= 6 else { return "Mixed" }
        let twistiness = centroid[1]
        let surface = centroid[3]
        let flow = centroid[7]
        let braking = centroid[8]
        
        switch (twistiness, surface, flow, braking) {
        case let (t, s, f, _) where t > 0.7 && s > 0.6:
            return "High-grip twisties"
        case let (t, _, f, b) where t > 0.7 && b > 0.6:
            return "Technical mountain"
        case let (_, s, f, _) where s > 0.8 && f > 0.6:
            return "Silky fast sweepers"
        case let (_, s, _, b) where s < 0.5 && b > 0.5:
            return "Rugged adventure"
        default:
            return "Balanced explorer"
        }
    }
}

private extension Double {
    func clamped() -> Double {
        max(0, min(1, self))
    }
}
