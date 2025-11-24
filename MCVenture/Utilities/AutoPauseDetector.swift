// AutoPauseDetector.swift - Detect when rider stops

import Foundation
import CoreLocation
import Combine

class AutoPauseDetector: ObservableObject {
    @Published var isPaused = false
    @Published var pauseStartTime: Date?
    
    private var lowSpeedStartTime: Date?
    private let pauseThreshold: Double = 2.0 // km/h
    private let pauseDelay: TimeInterval = 30.0 // seconds
    
    func updateSpeed(_ speed: Double) {
        let settings = AppSettings.shared
        guard settings.autoPause else { return }
        
        if speed < pauseThreshold {
            if lowSpeedStartTime == nil {
                lowSpeedStartTime = Date()
            } else if let start = lowSpeedStartTime,
                      Date().timeIntervalSince(start) >= pauseDelay && !isPaused {
                pauseTracking()
            }
        } else {
            if isPaused {
                resumeTracking()
            }
            lowSpeedStartTime = nil
        }
    }
    
    private func pauseTracking() {
        isPaused = true
        pauseStartTime = Date()
        HapticFeedbackManager.shared.lightTap()
    }
    
    private func resumeTracking() {
        isPaused = false
        pauseStartTime = nil
        HapticFeedbackManager.shared.success()
    }
    
    func reset() {
        isPaused = false
        pauseStartTime = nil
        lowSpeedStartTime = nil
    }
}
