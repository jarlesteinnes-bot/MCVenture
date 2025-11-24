//
//  SuccessAnimationView.swift
//  MCVenture
//

import SwiftUI

struct SuccessAnimationView: View {
    let icon: String
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -20
    @State private var confettiOpacity: Double = 0
    @State private var confettiOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 24) {
                // Confetti particles
                ZStack {
                    ForEach(0..<20, id: \.self) { index in
                        ConfettiPiece(index: index, offset: confettiOffset)
                    }
                }
                .opacity(confettiOpacity)
                
                // Success icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .green.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(opacity)
                
                Button(action: dismiss) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .opacity(opacity)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .padding(40)
        }
        .onAppear {
            animateIn()
            HapticManager.shared.success()
        }
    }
    
    private func animateIn() {
        // Icon bounce in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
        }
        
        // Fade in text
        withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
            opacity = 1.0
        }
        
        // Confetti animation
        withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
            confettiOpacity = 1.0
            confettiOffset = 300
        }
        
        // Fade out confetti
        withAnimation(.easeIn(duration: 0.4).delay(1.5)) {
            confettiOpacity = 0
        }
    }
    
    private func dismiss() {
        HapticManager.shared.light()
        withAnimation(.easeIn(duration: 0.2)) {
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

struct ConfettiPiece: View {
    let index: Int
    let offset: CGFloat
    
    private var randomColor: Color {
        [.red, .orange, .yellow, .green, .blue, .purple, .pink].randomElement() ?? .orange
    }
    
    private var angle: Double {
        Double(index) * 18.0 // 360 / 20 pieces
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(randomColor)
            .frame(width: 8, height: 12)
            .offset(
                x: cos(angle * .pi / 180) * offset,
                y: sin(angle * .pi / 180) * offset
            )
            .rotationEffect(.degrees(Double(index) * 36))
    }
}

// Preset success animations
extension SuccessAnimationView {
    static func tripCompleted(distance: Double, duration: TimeInterval, onDismiss: @escaping () -> Void) -> some View {
        let distanceStr = String(format: "%.1f", distance)
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        let durationStr = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        
        return SuccessAnimationView(
            icon: "checkmark.circle.fill",
            title: "Trip Completed!",
            message: "You rode \(distanceStr) km in \(durationStr). Great ride!",
            onDismiss: onDismiss
        )
    }
    
    static func routeSaved(routeName: String, onDismiss: @escaping () -> Void) -> some View {
        SuccessAnimationView(
            icon: "map.circle.fill",
            title: "Route Saved!",
            message: "\"\(routeName)\" has been saved to your collection.",
            onDismiss: onDismiss
        )
    }
    
    static func achievementUnlocked(achievement: String, onDismiss: @escaping () -> Void) -> some View {
        SuccessAnimationView(
            icon: "trophy.fill",
            title: "Achievement Unlocked!",
            message: achievement,
            onDismiss: onDismiss
        )
    }
    
    static func photoSaved(count: Int, onDismiss: @escaping () -> Void) -> some View {
        let message = count == 1 ? "Your photo has been saved!" : "\(count) photos have been saved!"
        return SuccessAnimationView(
            icon: "camera.fill",
            title: "Photos Saved!",
            message: message,
            onDismiss: onDismiss
        )
    }
}

#Preview {
    SuccessAnimationView.tripCompleted(distance: 125.4, duration: 7320) { }
}
