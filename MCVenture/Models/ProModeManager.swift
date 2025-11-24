import Foundation
import Combine
import CoreLocation

@MainActor
class ProModeManager: ObservableObject {
    static let shared = ProModeManager()
    
    // Feature toggles
    @Published var isProModeEnabled = false
    @Published var leanAngleEnabled = true
    @Published var gForceEnabled = true
    @Published var cornerAnalysisEnabled = true
    @Published var lapTimingEnabled = false
    @Published var routeRecordingEnabled = false
    @Published var surfaceDetectionEnabled = true
    
    // Analytics
    @Published var leanAngleTracker = LeanAngleTracker()
    @Published var gForceTracker = GForceTracker()
    @Published var cornerAnalyzer = CornerAnalyzer()
    @Published var lapTimer = LapTimer()
    
    // Route Intelligence
    @Published var routeRecorder = RouteRecorder()
    @Published var surfaceDetector = SurfaceQualityDetector()
    @Published var curvatureAnalyzer = CurvatureAnalyzer()
    
    // Exporters
    let telemetryExporter = TelemetryExporter()
    
    private init() {}
    
    func startProTracking() {
        guard isProModeEnabled else { return }
        
        if leanAngleEnabled {
            leanAngleTracker.startTracking()
        }
        
        if gForceEnabled {
            gForceTracker.startTracking()
        }
        
        if surfaceDetectionEnabled {
            surfaceDetector.startDetecting()
        }
    }
    
    func stopProTracking() {
        leanAngleTracker.stopTracking()
        gForceTracker.stopTracking()
        surfaceDetector.stopDetecting()
        
        if lapTimingEnabled {
            lapTimer.stopRecording()
        }
        
        if routeRecordingEnabled && routeRecorder.isRecording {
            // Route will be saved by user action
        }
    }
    
    func updateAnalytics(speed: Double, location: CLLocationCoordinate2D, heading: Double) {
        if cornerAnalysisEnabled {
            cornerAnalyzer.analyzeCorner(
                speed: speed,
                heading: heading,
                location: location,
                leanAngle: leanAngleTracker.currentLeanAngle
            )
        }
        
        if let currentCorner = cornerAnalyzer.currentCorner {
            curvatureAnalyzer.analyzeTurn(
                entrySpeed: currentCorner.entrySpeed,
                exitSpeed: currentCorner.exitSpeed,
                duration: currentCorner.duration,
                location: location
            )
        }
    }
    
    func reset() {
        leanAngleTracker.reset()
        gForceTracker.reset()
        cornerAnalyzer.reset()
        lapTimer.reset()
        surfaceDetector.reset()
        curvatureAnalyzer.reset()
    }
    
    // MARK: - AI Insights
    func getRidingStyleAnalysis(avgSpeed: Double, corners: [Corner], maxLean: Double) -> RidingStyle {
        let avgCornerSpeed = corners.map { $0.apexSpeed }.reduce(0, +) / Double(max(corners.count, 1))
        
        if maxLean > 45 && avgSpeed > 80 {
            return .aggressive
        } else if maxLean < 20 && avgSpeed < 60 {
            return .touring
        } else if avgCornerSpeed > avgSpeed * 0.7 {
            return .smooth
        } else {
            return .sport
        }
    }
    
    func getSkillSuggestions(corners: [Corner], gForceData: [GForceDataPoint]) -> [String] {
        var suggestions: [String] = []
        
        // Analyze corners
        let hardBraking = corners.filter { $0.entrySpeed - $0.apexSpeed > 50 }
        if hardBraking.count > corners.count / 2 {
            suggestions.append("Try smoother braking into corners - trail braking technique")
        }
        
        // Analyze G-forces
        let avgLateralG = gForceData.map { abs($0.gForce.lateral) }.reduce(0, +) / Double(max(gForceData.count, 1))
        if avgLateralG < 0.5 {
            suggestions.append("You can carry more speed through corners")
        } else if avgLateralG > 1.2 {
            suggestions.append("Consider smoother turn-in for better tire grip")
        }
        
        return suggestions
    }
    
    // MARK: - Maintenance Predictions
    func predictMaintenanceDue(totalKm: Double, lastServiceKm: Double) -> [ProModeMaintenanceItem] {
        var items: [ProModeMaintenanceItem] = []
        
        let kmSinceService = totalKm - lastServiceKm
        
        if kmSinceService > 5000 {
            items.append(ProModeMaintenanceItem(type: "Oil Change", dueIn: 6000 - kmSinceService, priority: .high))
        }
        
        if kmSinceService > 10000 {
            items.append(ProModeMaintenanceItem(type: "Chain Adjustment", dueIn: 12000 - kmSinceService, priority: .medium))
        }
        
        if kmSinceService > 15000 {
            items.append(ProModeMaintenanceItem(type: "Tire Inspection", dueIn: 16000 - kmSinceService, priority: .high))
        }
        
        return items
    }
}

// MARK: - Supporting Types

enum RidingStyle: String {
    case aggressive = "Aggressive"
    case sport = "Sport"
    case smooth = "Smooth"
    case touring = "Touring"
}

struct ProModeMaintenanceItem {
    let type: String
    let dueIn: Double // km
    let priority: MaintenancePriority
}

enum MaintenancePriority {
    case low, medium, high, urgent
}

// MARK: - Achievement System
struct RideAchievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let requirement: AchievementRequirement
    var isUnlocked: Bool
}

enum AchievementRequirement {
    case distance(Double)
    case elevation(Double)
    case maxSpeed(Double)
    case perfectCorners(Int)
    case consistency(Double)
}

class AchievementManager: ObservableObject {
    @Published var achievements: [RideAchievement] = [
        RideAchievement(title: "Century Rider", description: "Ride 100km in a single trip", icon: "road.lanes", requirement: .distance(100), isUnlocked: false),
        RideAchievement(title: "Mountain Climber", description: "Gain 1000m elevation", icon: "mountain.2.fill", requirement: .elevation(1000), isUnlocked: false),
        RideAchievement(title: "Speed Demon", description: "Reach 200 km/h", icon: "bolt.fill", requirement: .maxSpeed(200), isUnlocked: false),
        RideAchievement(title: "Smooth Operator", description: "Complete 50 perfect corners", icon: "arrow.triangle.2.circlepath", requirement: .perfectCorners(50), isUnlocked: false)
    ]
    
    func checkAchievements(distance: Double, elevation: Double, maxSpeed: Double, corners: Int) {
        for index in achievements.indices {
            switch achievements[index].requirement {
            case .distance(let required):
                if distance >= required {
                    achievements[index].isUnlocked = true
                }
            case .elevation(let required):
                if elevation >= required {
                    achievements[index].isUnlocked = true
                }
            case .maxSpeed(let required):
                if maxSpeed >= required {
                    achievements[index].isUnlocked = true
                }
            case .perfectCorners(let required):
                if corners >= required {
                    achievements[index].isUnlocked = true
                }
            case .consistency:
                break
            }
        }
    }
}
