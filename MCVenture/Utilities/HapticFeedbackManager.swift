//
//  HapticFeedbackManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import UIKit
import AVFoundation

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare generators for reduced latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    var isEnabled: Bool {
        return AppSettings.shared.hapticsEnabled
    }
    
    // MARK: - Standard Haptic Patterns
    
    /// Light tap for UI interactions (button taps, selections)
    func lightTap() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }
    
    /// Medium impact for significant actions (navigation, confirmations)
    func mediumImpact() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }
    
    /// Heavy impact for critical actions (starting trip, emergencies)
    func heavyImpact() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }
    
    /// Selection change (scrolling through lists, picker changes)
    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Notification Patterns
    
    /// Success notification (trip saved, route added)
    func success() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Warning notification (fuel low, weather alert)
    func warning() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    /// Error notification (operation failed, invalid input)
    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Custom Patterns
    
    /// Double tap pattern (confirmation actions)
    func doubleTap() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactLight.impactOccurred()
        }
    }
    
    /// Triple tap pattern (special actions)
    func tripleTap() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactLight.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactLight.impactOccurred()
        }
    }
    
    /// Pulse pattern (loading, processing)
    func pulse(duration: Double = 1.0) {
        guard isEnabled else { return }
        let pulseCount = Int(duration / 0.3)
        for i in 0..<pulseCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.impactLight.impactOccurred()
            }
        }
    }
    
    /// Emergency pattern (SOS, crash detection)
    func emergency() {
        guard isEnabled else { return }
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.impactHeavy.impactOccurred()
            }
        }
    }
    
    /// Achievement pattern (milestone reached)
    func achievement() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    /// Navigation pattern (route guidance, turn alerts)
    func navigation() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.impactMedium.impactOccurred()
        }
    }
    
    // MARK: - Context-Specific Patterns
    
    /// Trip started
    func tripStarted() {
        guard isEnabled else { return }
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.lightTap()
        }
    }
    
    /// Trip paused
    func tripPaused() {
        guard isEnabled else { return }
        mediumImpact()
    }
    
    /// Trip resumed
    func tripResumed() {
        guard isEnabled else { return }
        lightTap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightTap()
        }
    }
    
    /// Trip finished
    func tripFinished() {
        guard isEnabled else { return }
        achievement()
    }
    
    /// Route selected
    func routeSelected() {
        guard isEnabled else { return }
        mediumImpact()
    }
    
    /// Route favorited
    func routeFavorited() {
        guard isEnabled else { return }
        success()
    }
    
    /// Waypoint added
    func waypointAdded() {
        guard isEnabled else { return }
        lightTap()
    }
    
    /// Photo taken
    func photoTaken() {
        guard isEnabled else { return }
        mediumImpact()
    }
    
    /// Fuel warning (low fuel)
    func fuelWarning(level: FuelWarningLevel) {
        guard isEnabled else { return }
        switch level {
        case .yellow:
            warning()
        case .red:
            error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.error()
            }
        case .empty:
            emergency()
        default:
            break
        }
    }
    
    /// Weather alert
    func weatherAlert(severity: String) {
        guard isEnabled else { return }
        switch severity {
        case "warning":
            warning()
        case "severe", "extreme":
            error()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.error()
            }
        default:
            lightTap()
        }
    }
    
    /// Milestone reached (distance, time)
    func milestoneReached() {
        guard isEnabled else { return }
        achievement()
    }
    
    /// Speed zone change
    func speedZoneChange() {
        guard isEnabled else { return }
        selection()
    }
    
    /// Elevation milestone (peak reached, valley reached)
    func elevationMilestone() {
        guard isEnabled else { return }
        doubleTap()
    }
    
    /// Navigation turn soon
    func turnSoon() {
        guard isEnabled else { return }
        lightTap()
    }
    
    /// Navigation turn now
    func turnNow() {
        guard isEnabled else { return }
        navigation()
    }
    
    /// GPS signal lost
    func gpsSignalLost() {
        guard isEnabled else { return }
        warning()
    }
    
    /// GPS signal restored
    func gpsSignalRestored() {
        guard isEnabled else { return }
        success()
    }
    
    /// Offline mode activated
    func offlineModeActivated() {
        guard isEnabled else { return }
        warning()
    }
    
    /// Online mode restored
    func onlineModeRestored() {
        guard isEnabled else { return }
        success()
    }
    
    /// Route downloaded
    func routeDownloaded() {
        guard isEnabled else { return }
        success()
    }
    
    /// Settings changed
    func settingsChanged() {
        guard isEnabled else { return }
        lightTap()
    }
    
    /// Emergency contact added
    func emergencyContactAdded() {
        guard isEnabled else { return }
        success()
    }
    
    /// SOS activated
    func sosActivated() {
        guard isEnabled else { return }
        emergency()
    }
    
    /// Crash detected
    func crashDetected() {
        guard isEnabled else { return }
        emergency()
        // Continue emergency pattern
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.heavyImpact()
            }
        }
    }
    
    /// SOS cancelled
    func sosCancelled() {
        guard isEnabled else { return }
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.success()
        }
    }
    
    // MARK: - Audio Feedback (for critical alerts)
    
    /// Play alert sound with haptic
    func playAlertWithHaptic() {
        guard isEnabled else { return }
        error()
        AudioServicesPlaySystemSound(1005) // Alert sound
    }
    
    /// Play success sound with haptic
    func playSuccessWithHaptic() {
        guard isEnabled else { return }
        success()
        AudioServicesPlaySystemSound(1054) // Success sound
    }
}

enum HapticFeedbackStyle {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}
