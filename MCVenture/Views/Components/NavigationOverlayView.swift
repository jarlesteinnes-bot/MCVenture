//
//  NavigationOverlayView.swift
//  MCVenture
//
//  Created by AI Assistant on 2025-11-24.
//

import SwiftUI
import UIKit

/// Navigation overlay UI displayed during active navigation
struct NavigationOverlayView: View {
    @ObservedObject var navigationEngine: NavigationEngine
    @ObservedObject var voiceNavigator: VoiceNavigator
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation banner
            if navigationEngine.state == .navigating || navigationEngine.state == .offRoute {
                navigationBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            // Bottom progress bar
            if navigationEngine.state == .navigating {
                progressBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: navigationEngine.state)
    }
    
    // MARK: - Navigation Banner
    
    private var navigationBanner: some View {
        VStack(spacing: 8) {
            if navigationEngine.state == .offRoute {
                offRouteBanner
            } else if let instruction = navigationEngine.currentInstruction {
                currentInstructionView(instruction)
            }
            
            if let next = navigationEngine.nextInstruction {
                nextInstructionView(next)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .padding(.top, 50) // Below status bar
    }
    
    private var offRouteBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Off Route")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Getting you back on track...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func currentInstructionView(_ instruction: TurnInstruction) -> some View {
        HStack(spacing: 16) {
            // Turn icon
            Image(systemName: instruction.type.icon)
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                // Distance to turn
                Text(formatDistance(navigationEngine.distanceToNext))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                // Turn instruction
                Text(getTurnDescription(instruction))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Voice toggle
            Button(action: {
                voiceNavigator.toggle()
                HapticManager.shared.light()
            }) {
                Image(systemName: voiceNavigator.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.title2)
                    .foregroundColor(voiceNavigator.isEnabled ? .blue : .gray)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private func nextInstructionView(_ instruction: TurnInstruction) -> some View {
        HStack(spacing: 12) {
            Image(systemName: instruction.type.icon)
                .font(.system(size: 24))
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            Text("Then \(getTurnDescription(instruction).lowercased())")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.top, 4)
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            // ETA and distance remaining
            HStack {
                // ETA
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text(formatETA(navigationEngine.estimatedTimeRemaining))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Distance remaining
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                    Text(formatDistance(navigationEngine.distanceRemaining))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                    
                    // Progress
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * navigationEngine.routeProgress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.blue)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 100 {
            return "\(Int(distance)) m"
        } else if distance < 1000 {
            let rounded = Int(round(distance / 10) * 10)
            return "\(rounded) m"
        } else {
            let km = distance / 1000
            if km < 10 {
                return String(format: "%.1f km", km)
            } else {
                return String(format: "%.0f km", km)
            }
        }
    }
    
    private func formatETA(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
    
    private func getTurnDescription(_ instruction: TurnInstruction) -> String {
        switch instruction.type {
        case .left:
            return "Turn left"
        case .right:
            return "Turn right"
        case .slightLeft:
            return "Keep left"
        case .slightRight:
            return "Keep right"
        case .sharpLeft:
            return "Sharp left"
        case .sharpRight:
            return "Sharp right"
        case .straight:
            return "Continue straight"
        case .roundabout:
            return "Enter roundabout"
        case .uTurn:
            return "Make U-turn"
        case .arrive:
            return "Arrive at destination"
        }
    }
}

// MARK: - Preview

struct NavigationOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let engine = NavigationEngine()
        let voice = VoiceNavigator()
        
        NavigationOverlayView(
            navigationEngine: engine,
            voiceNavigator: voice
        )
        .previewLayout(.sizeThatFits)
    }
}
