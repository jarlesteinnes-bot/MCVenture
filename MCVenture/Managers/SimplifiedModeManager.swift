//
//  SimplifiedModeManager.swift
//  MCVenture
//

import Foundation
import Combine

class SimplifiedModeManager: ObservableObject {
    static let shared = SimplifiedModeManager()
    
    @Published var isSimplifiedMode: Bool {
        didSet {
            UserDefaults.standard.set(isSimplifiedMode, forKey: "isSimplifiedMode")
        }
    }
    
    private init() {
        self.isSimplifiedMode = UserDefaults.standard.bool(forKey: "isSimplifiedMode")
    }
    
    // Features to hide in simplified mode
    var showProMode: Bool {
        !isSimplifiedMode
    }
    
    var showAdvancedAnalytics: Bool {
        !isSimplifiedMode
    }
    
    var showCornerAnalysis: Bool {
        !isSimplifiedMode
    }
    
    var showLapTiming: Bool {
        !isSimplifiedMode
    }
    
    var showGForceTracking: Bool {
        !isSimplifiedMode
    }
    
    var showLeanAngleTracking: Bool {
        !isSimplifiedMode
    }
    
    var showSurfaceDetection: Bool {
        !isSimplifiedMode
    }
    
    var showAdvancedRoutePlanning: Bool {
        !isSimplifiedMode
    }
    
    var showFuelOptimization: Bool {
        !isSimplifiedMode
    }
    
    var showMaintenanceTracking: Bool {
        !isSimplifiedMode
    }
    
    // Simplified mode features that ARE shown
    var showBasicStats: Bool {
        true // Always show basic stats
    }
    
    var showSafetyFeatures: Bool {
        true // Always show safety features
    }
    
    var showBasicNavigation: Bool {
        true // Always show basic navigation
    }
}

// Speed limit warning settings
class SpeedLimitManager: ObservableObject {
    static let shared = SpeedLimitManager()
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "speedLimitWarningsEnabled")
        }
    }
    
    @Published var speedLimit: Double {
        didSet {
            UserDefaults.standard.set(speedLimit, forKey: "speedLimitThreshold")
        }
    }
    
    @Published var warningOffset: Double {
        didSet {
            UserDefaults.standard.set(warningOffset, forKey: "speedWarningOffset")
        }
    }
    
    private init() {
        self.isEnabled = UserDefaults.standard.object(forKey: "speedLimitWarningsEnabled") as? Bool ?? true
        
        let savedSpeedLimit = UserDefaults.standard.double(forKey: "speedLimitThreshold")
        self.speedLimit = savedSpeedLimit == 0 ? 80.0 : savedSpeedLimit
        
        let savedWarningOffset = UserDefaults.standard.double(forKey: "speedWarningOffset")
        self.warningOffset = savedWarningOffset == 0 ? 5.0 : savedWarningOffset
    }
    
    func shouldWarn(currentSpeed: Double) -> Bool {
        guard isEnabled else { return false }
        return currentSpeed > (speedLimit + warningOffset)
    }
    
    func getWarningMessage(currentSpeed: Double) -> String {
        let over = Int(currentSpeed - speedLimit)
        return "Speed \(over) km/h over limit"
    }
}
