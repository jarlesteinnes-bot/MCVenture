//
//  HapticManager.swift
//  MCVenture
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Notification Feedback
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Impact Feedback
    
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
    
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Context-Specific Feedback
    
    func tripStarted() {
        // Double tap for important action
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }
    }
    
    func tripFinished() {
        // Success pattern
        success()
    }
    
    func waypointAdded() {
        light()
    }
    
    func photoCapture() {
        medium()
    }
    
    func crashDetected() {
        // Urgent pattern: heavy + warning
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.warning()
        }
    }
    
    func speedLimitWarning() {
        warning()
    }
    
    func sosActivated() {
        // Emergency pattern
        heavy()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.heavy()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.heavy()
        }
    }
    
    func routeSaved() {
        success()
    }
    
    func achievementUnlocked() {
        // Celebration pattern
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.light()
        }
    }
    
    // MARK: - Social Interactions
    
    func ratingSubmitted() {
        success()
    }
    
    func commentPosted() {
        light()
    }
    
    func routeLiked() {
        medium()
    }
    
    func shareCompleted() {
        success()
    }
    
    // MARK: - Navigation Feedback
    
    func turnAhead() {
        // Warning for upcoming turn
        medium()
    }
    
    func turnNow() {
        // Strong feedback for immediate turn
        heavy()
    }
    
    func arrivedAtDestination() {
        // Success pattern
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.success()
        }
    }
    
    func offRoute() {
        // Warning pattern
        warning()
    }
    
    // MARK: - UI Interactions
    
    func buttonTap() {
        light()
    }
    
    func cardFlip() {
        medium()
    }
    
    func swipeAction() {
        light()
    }
    
    func pullToRefresh() {
        light()
    }
    
    func dataLoaded() {
        soft()
    }
    
    func errorOccurred() {
        error()
    }
    
    func tabChanged() {
        selection()
    }
    
    func modalPresented() {
        medium()
    }
    
    func modalDismissed() {
        light()
    }
    
    // MARK: - Advanced Patterns
    
    /// Custom impact with intensity (0.0 - 1.0)
    func impact(intensity: CGFloat) {
        let generator = UIImpactFeedbackGenerator(style: intensity > 0.7 ? .heavy : intensity > 0.4 ? .medium : .light)
        generator.impactOccurred(intensity: intensity)
    }
    
    /// Prepare haptic engine for immediate feedback (reduces latency)
    func prepare() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
    }
}
