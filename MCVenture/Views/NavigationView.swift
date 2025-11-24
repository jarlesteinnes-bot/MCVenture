//
//  NavigationView.swift
//  MCVenture
//
//  Created by BNTF on 24/11/2025.
//

import SwiftUI
import MapKit

struct NavigationView: View {
    @StateObject private var navManager = NavigationManager.shared
    @StateObject private var gpsManager = GPSTrackingManager.shared
    @Environment(\.dismiss) var dismiss
    
    let destination: CLLocationCoordinate2D
    let destinationName: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top instruction banner
                if let instruction = navManager.currentInstruction {
                    instructionBanner(instruction)
                        .transition(.move(edge: .top))
                }
                
                // Map view
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: gpsManager.currentLocation?.coordinate ?? destination,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), showsUserLocation: true)
                    .ignoresSafeArea()
                
                // Bottom status bar
                bottomStatusBar
            }
            
            // Speed warning overlay
            if let warning = navManager.speedWarning {
                VStack {
                    speedWarningBanner(warning)
                        .padding()
                    Spacer()
                }
                .transition(.move(edge: .top))
            }
            
            // Rerouting overlay
            if navManager.rerouting {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Rerouting...")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top)
                }
            }
        }
        .onAppear {
            startNavigation()
        }
        .onDisappear {
            navManager.stopNavigation()
        }
    }
    
    // MARK: - Instruction Banner
    private func instructionBanner(_ instruction: NavigationInstruction) -> some View {
        HStack(spacing: 20) {
            Image(systemName: instruction.type.icon)
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(instruction.distanceText())
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(instruction.type.instruction)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if let road = instruction.roadName {
                    Text(road)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
    
    // MARK: - Bottom Status Bar
    private var bottomStatusBar: some View {
        HStack {
            // ETA
            VStack(alignment: .leading, spacing: 4) {
                Text("ETA")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text(formatETA())
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Distance
            VStack(spacing: 4) {
                Text("Distance")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text(formatDistance(navManager.remainingDistance))
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Speed
            VStack(alignment: .trailing, spacing: 4) {
                Text("Speed")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                HStack(spacing: 4) {
                    Text("\(Int(navManager.currentSpeed))")
                        .font(.headline)
                        .foregroundColor(speedColor())
                    if let limit = navManager.speedLimit {
                        Text("/ \(Int(limit))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            Spacer()
            
            // End button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }
    
    // MARK: - Speed Warning Banner
    private func speedWarningBanner(_ warning: NavigationManager.SpeedWarning) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(warning.message)
                .fontWeight(.bold)
        }
        .padding()
        .background(warning == .muchExceeding ? Color.red : Color.orange)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    // MARK: - Helpers
    private func startNavigation() {
        navManager.startNavigation(to: destination)
    }
    
    private func formatETA() -> String {
        let eta = Date().addingTimeInterval(navManager.remainingTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: eta)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters)) m"
        } else {
            return String(format: "%.1f km", meters / 1000.0)
        }
    }
    
    private func speedColor() -> Color {
        if let warning = navManager.speedWarning {
            return warning == .muchExceeding ? .red : .orange
        }
        return .white
    }
}
