//
//  ReviewRequestManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import StoreKit
import SwiftUI

class ReviewRequestManager {
    static let shared = ReviewRequestManager()
    
    @AppStorage("tripCountAtLastReview") private var tripCountAtLastReview: Int = 0
    @AppStorage("lastReviewRequestDate") private var lastReviewRequestDate: TimeInterval = 0
    
    private let minimumDaysBetweenReviews: Int = 90
    private let reviewTriggerPoints: [Int] = [5, 20, 50, 100]
    
    private init() {}
    
    func requestReviewIfAppropriate(tripCount: Int) {
        guard shouldRequestReview(for: tripCount) else { return }
        
        // Request review on main thread with slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                
                // Update tracking
                self.tripCountAtLastReview = tripCount
                self.lastReviewRequestDate = Date().timeIntervalSince1970
                
                HapticFeedbackManager.shared.success()
            }
        }
    }
    
    private func shouldRequestReview(for tripCount: Int) -> Bool {
        // Check if trip count matches a trigger point
        guard reviewTriggerPoints.contains(tripCount) else { return false }
        
        // Check if we haven't requested at this count before
        guard tripCount > tripCountAtLastReview else { return false }
        
        // Check if enough time has passed since last review
        let lastRequestDate = Date(timeIntervalSince1970: lastReviewRequestDate)
        let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
        
        guard daysSinceLastRequest >= minimumDaysBetweenReviews else { return false }
        
        return true
    }
    
    // Manual review request (for settings page)
    func requestReviewManually() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                HapticFeedbackManager.shared.lightTap()
            }
        }
    }
}
