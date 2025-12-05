//
//  ActiveTripView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import MapKit
import UIKit

struct ActiveTripView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gpsManager = GPSTrackingManager.shared
    @StateObject private var emergencyManager = EmergencyManager.shared
    @EnvironmentObject var dataManager: DataManager
    
    @State private var showFinishAlert = false
    @State private var selectedMotorcycle: MotorcycleProfile?
    @State private var fuelPricePerLiter: String = ""
    @State private var isPaused = false
    @State private var showFuelPriceInput = false
    @GestureState private var sosLongPressActive = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Crash Detection Countdown Overlay
            if emergencyManager.crashCountdownActive {
                crashDetectionOverlay
            }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        showFinishAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("TRACKING")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button(action: {
                        if isPaused {
                            gpsManager.resumeTracking()
                        } else {
                            gpsManager.pauseTracking()
                        }
                        isPaused.toggle()
                    }) {
                        Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                // Stats Cards
                ScrollView {
                    VStack(spacing: 20) {
                        // Distance Card
                        TripStatCard(
                            icon: "road.lanes",
                            title: "DISTANCE",
                            value: String(format: "%.2f", gpsManager.tripDistance),
                            unit: "km",
                            color: .orange
                        )
                        
                        // Duration Card
                        TripStatCard(
                            icon: "timer",
                            title: "DURATION",
                            value: formatDuration(gpsManager.tripDuration),
                            unit: "",
                            color: .blue
                        )
                        
                        // Speed Cards
                        HStack(spacing: 15) {
                            TripStatCard(
                                icon: "speedometer",
                                title: "CURRENT",
                                value: String(format: "%.0f", gpsManager.currentSpeed),
                                unit: "km/h",
                                color: .green
                            )
                            
                            TripStatCard(
                                icon: "gauge.medium",
                                title: "AVERAGE",
                                value: String(format: "%.0f", gpsManager.averageSpeed),
                                unit: "km/h",
                                color: .purple
                            )
                        }
                        
                        // Max Speed Card
                        TripStatCard(
                            icon: "bolt.fill",
                            title: "MAX SPEED",
                            value: String(format: "%.0f", gpsManager.maxSpeed),
                            unit: "km/h",
                            color: .red
                        )
                        
                        // Elevation Cards
                        HStack(spacing: 15) {
                            TripStatCard(
                                icon: "arrow.up.forward",
                                title: "ELEVATION GAIN",
                                value: String(format: "%.0f", gpsManager.elevationTracker.elevationGain),
                                unit: "m",
                                color: .green
                            )
                            
                            TripStatCard(
                                icon: "arrow.down.forward",
                                title: "ELEVATION LOSS",
                                value: String(format: "%.0f", gpsManager.elevationTracker.elevationLoss),
                                unit: "m",
                                color: .orange
                            )
                        }
                        
                        // Current Altitude
                        TripStatCard(
                            icon: "mountain.2.fill",
                            title: "ALTITUDE",
                            value: String(format: "%.0f", gpsManager.elevationTracker.currentAltitude),
                            unit: "m",
                            color: .purple
                        )
                        
                        // Advanced Stats
                        HStack(spacing: 15) {
                            TripStatCard(
                                icon: "flame.fill",
                                title: "CALORIES",
                                value: String(format: "%.0f", gpsManager.calories),
                                unit: "kcal",
                                color: .orange
                            )
                            
                            TripStatCard(
                                icon: "leaf.fill",
                                title: "CO₂ SAVED",
                                value: String(format: "%.2f", gpsManager.carbonSaved),
                                unit: "kg",
                                color: .green
                            )
                        }
                        
                        // Waypoints Count
                        if !gpsManager.waypoints.isEmpty {
                            TripStatCard(
                                icon: "mappin.and.ellipse",
                                title: "WAYPOINTS",
                                value: "\(gpsManager.waypoints.count)",
                                unit: "",
                                color: .blue
                            )
                        }
                        
                        // Fuel Gauge (if motorcycle selected)
                        if selectedMotorcycle != nil {
                            fuelGaugeCard
                        }
                        
                        // Fuel Warning Banner
                        if gpsManager.fuelTrackingManager.showWarningAlert {
                            fuelWarningBanner
                        }
                        
                        // SOS Button
                        sosButton
                        
                        // Auto-Pause Status
                        if gpsManager.isPaused {
                            HStack {
                                Image(systemName: "pause.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("AUTO-PAUSED")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(15)
                        }
                        
                        // Fuel Price Input
                        if let motorcycle = selectedMotorcycle {
                            VStack(spacing: 15) {
                                // Fuel price input card
                                VStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.yellow)
                                        
                                        Spacer()
                                        
                                        Text("FUEL PRICE")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    HStack(spacing: 10) {
                                        TextField("Enter price", text: $fuelPricePerLiter)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("kr/L")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                                )
                                
                                // Fuel Cost Estimation (if fuel price entered)
                                if let fuelPrice = Double(fuelPricePerLiter), fuelPrice > 0 {
                                    let fuelUsed = (gpsManager.tripDistance * motorcycle.fuelConsumption) / 100.0
                                    let fuelCost = fuelUsed * fuelPrice
                                    
                                    TripStatCard(
                                        icon: "fuelpump.fill",
                                        title: "ESTIMATED FUEL COST",
                                        value: String(format: "%.2f", fuelCost),
                                        unit: "kr",
                                        color: .red
                                    )
                                    
                                    TripStatCard(
                                        icon: "drop.fill",
                                        title: "FUEL USED",
                                        value: String(format: "%.2f", fuelUsed),
                                        unit: "L",
                                        color: .cyan
                                    )
                                } else {
                                    Text("Enter fuel price above to calculate cost")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding()
                                }
                                
                                Text("\(motorcycle.brand) \(motorcycle.model) (\(motorcycle.year))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Consumption: \(String(format: "%.1f", motorcycle.fuelConsumption)) L/100km")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        } else {
                            VStack(spacing: 10) {
                                Text("Select a motorcycle from your profile")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("to calculate fuel costs")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                
                // Finish Button
                Button(action: {
                    showFinishAlert = true
                }) {
                    Text("FINISH TRIP")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                }
                .padding()
            }
        }
        .onAppear {
            gpsManager.requestPermission()
            gpsManager.startTracking()
            // Auto-select first motorcycle if available
            selectedMotorcycle = dataManager.motorcycles.first
            
            // Start fuel tracking if motorcycle selected
            if let motorcycleProfile = selectedMotorcycle {
                // Convert MotorcycleProfile to Motorcycle for fuel tracking
                let motorcycle = Motorcycle(
                    brand: motorcycleProfile.brand,
                    model: motorcycleProfile.model,
                    year: motorcycleProfile.year,
                    fuelConsumption: motorcycleProfile.fuelConsumption,
                    engineSize: 0, // Not needed for fuel tracking
                    tankSize: motorcycleProfile.tankSize
                )
                gpsManager.fuelTrackingManager.startTracking(motorcycle: motorcycle)
            }
            
            // Announce trip started
            VoiceAnnouncer.shared.announceStart()
            VoiceAnnouncer.shared.resetMilestones()
        }
        .alert("Finish Trip?", isPresented: $showFinishAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Finish", role: .destructive) {
                finishTrip()
            }
        } message: {
            Text("Save this trip to your profile?")
        }
    }
    
    private func finishTrip() {
        guard let summary = gpsManager.stopTracking() else { return }
        
        // Don't save trips with 0 km
        guard summary.distance > 0 else {
            dismiss()
            return
        }
        
        let fuelPrice = Double(fuelPricePerLiter) ?? 0.0
        let fuelCost: Double
        
        if let motorcycle = selectedMotorcycle {
            let fuelUsed = (summary.distance * motorcycle.fuelConsumption) / 100.0
            fuelCost = fuelUsed * fuelPrice
            
            // Update motorcycle mileage
            var updatedMotorcycle = motorcycle
            updatedMotorcycle.currentMileage += summary.distance
            dataManager.updateMotorcycle(updatedMotorcycle)
        } else {
            fuelCost = 0.0
        }
        
        // Create completed trip
        let trip = CompletedTrip(
            id: UUID(),
            routeName: "GPS Tracked Trip",
            country: "Unknown",
            date: summary.startTime,
            distanceKm: summary.distance,
            duration: summary.duration,
            fuelCost: fuelCost,
            averageSpeed: summary.averageSpeed,
            photoURLs: [],
            rating: 0,
            notes: "Tracked via GPS from \(formatTime(summary.startTime)) to \(formatTime(summary.endTime))",
            weatherCondition: ""
        )
        
        dataManager.addCompletedTrip(trip)
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Fuel Gauge Card
    private var fuelGaugeCard: some View {
        let fuelManager = gpsManager.fuelTrackingManager
        let fuelColor: Color = {
            switch fuelManager.warningLevel {
            case .green: return .green
            case .yellow: return .yellow
            case .red, .empty: return .red
            }
        }()
        
        return VStack(spacing: 15) {
            HStack {
                Image(systemName: "fuelpump.fill")
                    .font(.system(size: 24))
                    .foregroundColor(fuelColor)
                
                Spacer()
                
                Text("FUEL LEVEL")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Fuel level gauge
            VStack(spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(String(format: "%.1f", fuelManager.currentFuelLevel))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("L")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Fuel bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(fuelColor)
                            .frame(width: geometry.size.width * CGFloat(fuelManager.getUsableFuelPercentage() / 100.0))
                    }
                }
                .frame(height: 16)
                
                // Remaining range
                HStack {
                    Image(systemName: "arrow.forward")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    Text(String(format: "%.0f km range", fuelManager.remainingRange))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text(fuelManager.warningLevel.message)
                        .font(.caption)
                        .foregroundColor(fuelColor)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(fuelColor.opacity(0.5), lineWidth: 2)
        )
    }
    
    // Fuel Warning Banner
    private var fuelWarningBanner: some View {
        let fuelManager = gpsManager.fuelTrackingManager
        let warningColor: Color = fuelManager.lastWarningLevel == .red ? .red : .yellow
        
        return HStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(warningColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(fuelManager.lastWarningLevel.message)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(String(format: "%.1fL remaining • %.0f km range", fuelManager.currentFuelLevel, fuelManager.remainingRange))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                fuelManager.dismissWarning()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(warningColor.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(warningColor, lineWidth: 2)
        )
        .onAppear {
            // Trigger haptic feedback
            let generator = UIImpactFeedbackGenerator(style: fuelManager.lastWarningLevel == .red ? .heavy : .medium)
            generator.impactOccurred()
        }
    }
    
    // SOS Button
    private var sosButton: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: "sos.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("EMERGENCY SOS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(sosLongPressActive ? "Release to activate" : "Hold for 2 seconds")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.red, .red.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.red.opacity(0.8), lineWidth: 3)
            )
            .scaleEffect(sosLongPressActive ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: sosLongPressActive)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 2.0)
                .updating($sosLongPressActive) { currentState, gestureState, transaction in
                    gestureState = currentState
                }
                .onEnded { _ in
                    activateSOS()
                }
        )
    }
    
    // Crash Detection Overlay
    private var crashDetectionOverlay: some View {
        ZStack {
            // Dark backdrop
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Warning icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                
                // Title
                Text("CRASH DETECTED")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.red)
                
                // Countdown
                Text("\(emergencyManager.crashCountdownRemaining)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                // Message
                VStack(spacing: 10) {
                    Text("Emergency services will be called in")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Are you OK?")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                    .frame(height: 40)
                
                // Cancel button
                Button(action: {
                    emergencyManager.cancelCrashDetection()
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 24))
                        Text("I'M OK - CANCEL")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 25)
                    .padding(.horizontal, 40)
                    .background(
                        Capsule()
                            .fill(.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(.green, lineWidth: 4)
                    )
                }
                .shadow(color: .white.opacity(0.5), radius: 20)
            }
            .padding()
        }
    }
    
    private func activateSOS() {
        emergencyManager.activateSOS(location: gpsManager.currentLocation)
        
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

struct TripStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.5), lineWidth: 2)
        )
    }
}

#Preview {
    ActiveTripView()
        .environmentObject(DataManager.shared)
}
