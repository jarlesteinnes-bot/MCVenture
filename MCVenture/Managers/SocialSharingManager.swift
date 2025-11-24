//
//  SocialSharingManager.swift
//  MCVenture
//

import UIKit
import SwiftUI
import MapKit

class SocialSharingManager {
    static let shared = SocialSharingManager()
    
    private init() {}
    
    // MARK: - Share Trip Summary
    
    /// Create shareable image with trip stats overlay
    func createTripSummaryImage(
        distance: Double,
        duration: TimeInterval,
        elevationGain: Double,
        maxSpeed: Double,
        mapSnapshot: UIImage?
    ) -> UIImage? {
        
        let width: CGFloat = 1080
        let height: CGFloat = 1920
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Background gradient
        let colors = [UIColor(named: "AppOrange")?.cgColor ?? UIColor.orange.cgColor,
                      UIColor(named: "AppRed")?.cgColor ?? UIColor.red.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: [0.0, 1.0])!
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: height),
                                   options: [])
        
        // Map snapshot (if available)
        if let mapSnapshot = mapSnapshot {
            let mapRect = CGRect(x: 40, y: 200, width: width - 80, height: 600)
            context.saveGState()
            let path = UIBezierPath(roundedRect: mapRect, cornerRadius: 24)
            path.addClip()
            mapSnapshot.draw(in: mapRect)
            context.restoreGState()
        }
        
        // Stats panel
        let statsY: CGFloat = 880
        let statsHeight: CGFloat = 800
        let statsRect = CGRect(x: 40, y: statsY, width: width - 80, height: statsHeight)
        
        context.setFillColor(UIColor.white.withAlphaComponent(0.95).cgColor)
        let statsPath = UIBezierPath(roundedRect: statsRect, cornerRadius: 24)
        statsPath.fill()
        
        // App branding
        let brandingAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 48),
            .foregroundColor: UIColor.orange
        ]
        let branding = "MCVenture"
        branding.draw(at: CGPoint(x: 60, y: 920), withAttributes: brandingAttrs)
        
        // Title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 72),
            .foregroundColor: UIColor.darkGray
        ]
        let title = "Ride Summary"
        title.draw(at: CGPoint(x: 60, y: 1000), withAttributes: titleAttrs)
        
        // Stats
        let statLabelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 44, weight: .medium),
            .foregroundColor: UIColor.gray
        ]
        let statValueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 80),
            .foregroundColor: UIColor.darkGray
        ]
        
        var yPos: CGFloat = 1140
        let spacing: CGFloat = 160
        
        // Distance
        "DISTANCE".draw(at: CGPoint(x: 60, y: yPos), withAttributes: statLabelAttrs)
        "\(String(format: "%.1f", distance)) km".draw(at: CGPoint(x: 60, y: yPos + 50), withAttributes: statValueAttrs)
        
        // Duration
        yPos += spacing
        "DURATION".draw(at: CGPoint(x: 60, y: yPos), withAttributes: statLabelAttrs)
        formatDuration(duration).draw(at: CGPoint(x: 60, y: yPos + 50), withAttributes: statValueAttrs)
        
        // Elevation
        yPos += spacing
        "ELEVATION".draw(at: CGPoint(x: 60, y: yPos), withAttributes: statLabelAttrs)
        "\(Int(elevationGain)) m".draw(at: CGPoint(x: 60, y: yPos + 50), withAttributes: statValueAttrs)
        
        // Max Speed
        yPos += spacing
        "TOP SPEED".draw(at: CGPoint(x: 60, y: yPos), withAttributes: statLabelAttrs)
        "\(Int(maxSpeed)) km/h".draw(at: CGPoint(x: 60, y: yPos + 50), withAttributes: statValueAttrs)
        
        // Footer
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36),
            .foregroundColor: UIColor.lightGray
        ]
        "Track your rides with MCVenture 🏍️".draw(
            at: CGPoint(x: 60, y: height - 120),
            withAttributes: footerAttrs
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Share Actions
    
    /// Present share sheet for trip
    func shareTripSummary(
        from viewController: UIViewController,
        distance: Double,
        duration: TimeInterval,
        elevationGain: Double,
        maxSpeed: Double,
        mapSnapshot: UIImage? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let image = createTripSummaryImage(
            distance: distance,
            duration: duration,
            elevationGain: elevationGain,
            maxSpeed: maxSpeed,
            mapSnapshot: mapSnapshot
        ) else {
            completion?()
            return
        }
        
        let text = """
        Just completed an epic ride! 🏍️
        
        📍 Distance: \(String(format: "%.1f", distance)) km
        ⏱ Duration: \(formatDuration(duration))
        ⛰ Elevation: \(Int(elevationGain)) m
        🚀 Top Speed: \(Int(maxSpeed)) km/h
        
        Tracked with MCVenture
        """
        
        let items: [Any] = [text, image]
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Exclude some activities
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print
        ]
        
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            HapticManager.shared.success()
            completion?()
        }
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    /// Share route GPX file
    func shareRouteGPX(
        from viewController: UIViewController,
        routeName: String,
        gpxFileURL: URL,
        completion: (() -> Void)? = nil
    ) {
        let text = "Check out this motorcycle route: \(routeName) 🏍️\n\nShared from MCVenture"
        let items: [Any] = [text, gpxFileURL]
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            completion?()
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Social Media Templates
    
    /// Get Instagram-friendly square image
    func createInstagramStoryImage(
        distance: Double,
        duration: TimeInterval,
        elevationGain: Double
    ) -> UIImage? {
        let size = CGSize(width: 1080, height: 1920)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Simplified version optimized for Instagram Stories
        let colors = [UIColor.orange.cgColor, UIColor.red.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: [0.0, 1.0])!
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: size.height),
                                   options: [])
        
        // Large centered stats
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 120),
            .foregroundColor: UIColor.white
        ]
        
        "\(String(format: "%.1f", distance))".draw(
            at: CGPoint(x: 300, y: 700),
            withAttributes: titleAttrs
        )
        
        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 64, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        
        "KILOMETERS".draw(at: CGPoint(x: 350, y: 850), withAttributes: subtitleAttrs)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - SwiftUI Integration
// Note: ShareSheet is already defined in ExportTripView.swift
// Use that implementation for consistency
