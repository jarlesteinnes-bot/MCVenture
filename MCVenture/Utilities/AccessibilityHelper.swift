//
//  AccessibilityHelper.swift
//  MCVenture
//

import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    /// Add VoiceOver label and hint
    func accessible(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Make button accessible
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self.accessible(label: label, hint: hint, traits: .isButton)
    }
    
    /// Make header accessible
    func accessibleHeader(_ label: String) -> some View {
        self.accessible(label: label, traits: .isHeader)
    }
    
    /// Combine accessibility elements
    func accessibilityGrouped(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

// MARK: - Dynamic Type Support
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

extension View {
    func scaledFont(name: String, size: CGFloat) -> some View {
        self.modifier(ScaledFont(name: name, size: size))
    }
}

// MARK: - Color Accessibility
extension Color {
    /// Check if color meets WCAG AA contrast ratio (4.5:1 for normal text)
    func contrastRatio(with otherColor: Color) -> Double {
        let luminance1 = self.luminance()
        let luminance2 = otherColor.luminance()
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Calculate relative luminance
    private func luminance() -> Double {
        // Simplified luminance calculation
        // In production, use proper RGB component extraction
        return 0.5 // Placeholder
    }
    
    /// Get accessible text color (black or white) for this background
    var accessibleTextColor: Color {
        // Simplified - in production calculate actual contrast
        return self == .black || self == .blue || self == .red ? .white : .black
    }
}

// MARK: - Accessibility Helpers
struct AccessibilityHelper {
    /// Check if VoiceOver is running
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Check if user prefers reduced motion
    static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    /// Check if user prefers reduced transparency
    static var prefersReducedTransparency: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    /// Post accessibility announcement
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Post screen changed notification
    static func screenChanged() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}

// MARK: - Accessible Components

/// Accessible stat card with proper labels
struct AccessibleStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .accessibilityHidden(true)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .accessible(label: "\(title): \(value)")
    }
}

/// Accessible toggle with clear states
struct AccessibleToggle: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool
    let onChange: (() -> Void)?
    
    init(label: String, icon: String, isOn: Binding<Bool>, onChange: (() -> Void)? = nil) {
        self.label = label
        self.icon = icon
        self._isOn = isOn
        self.onChange = onChange
    }
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Label(label, systemImage: icon)
        }
        .accessible(
            label: label,
            hint: isOn ? "Currently enabled. Tap to disable." : "Currently disabled. Tap to enable.",
            traits: .isButton
        )
        .onChange(of: isOn) { _ in
            onChange?()
            HapticFeedbackManager.shared.selection()
            
            if AccessibilityHelper.isVoiceOverRunning {
                AccessibilityHelper.announce(isOn ? "\(label) enabled" : "\(label) disabled")
            }
        }
    }
}

/// Accessible progress indicator
struct AccessibleProgressView: View {
    let progress: Double  // 0.0 to 1.0
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
            
            ProgressView(value: progress)
                .accessible(label: "\(label): \(Int(progress * 100))% complete")
        }
    }
}

// MARK: - Usage Examples in Comments
/*
 // Usage in views:
 
 Button("Save Route") {
     saveRoute()
 }
 .accessibleButton(label: "Save Route", hint: "Double tap to save this route to your favorites")
 
 Text("Distance")
     .accessibleHeader("Distance")
 
 HStack {
     Text("100 km")
     Text("2 hours")
 }
 .accessibilityGrouped(label: "Trip summary: 100 kilometers, 2 hours")
 
 AccessibleStatCard(
     title: "Distance",
     value: "150 km",
     icon: "arrow.left.and.right",
     color: .blue
 )
 
 AccessibleToggle(
     label: "Enable GPS",
     icon: "location.fill",
     isOn: $gpsEnabled
 ) {
     print("GPS toggled")
 }
 */
