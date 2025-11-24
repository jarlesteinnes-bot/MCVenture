//
//  EmergencySOSView.swift
//  MCVenture
//
//  Emergency SOS button and control panel
//

import SwiftUI
import CoreLocation

struct EmergencySOSButton: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    @State private var isLongPressing = false
    @State private var longPressProgress: CGFloat = 0
    @State private var showSOSSheet = false
    let currentLocation: CLLocation?
    
    var body: some View {
        VStack {
            if emergencyManager.crashCountdownActive {
                // Crash detection countdown overlay
                CrashDetectionOverlay()
            } else if emergencyManager.sosActivated {
                // SOS activated overlay
                SOSActivatedView()
            } else {
                // Normal SOS button
                Button(action: {
                    showSOSSheet = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                            .shadow(color: .red.opacity(0.5), radius: 10)
                        
                        Image(systemName: "sos.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .sheet(isPresented: $showSOSSheet) {
                    EmergencyControlPanel(currentLocation: currentLocation)
                }
            }
        }
    }
}

// MARK: - Emergency Control Panel
struct EmergencyControlPanel: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    @Environment(\.dismiss) var dismiss
    let currentLocation: CLLocation?
    
    var body: some View {
        VStack(spacing: 24) {
                // Country Info
                if let country = emergencyManager.currentCountryCode {
                    VStack(spacing: 8) {
                        Text("Current Location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(emergencyManager.currentEmergencyNumbers.countryName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Emergency Services Ready")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Main Emergency Button
                VStack(spacing: 16) {
                    Text("Hold to Activate SOS")
                        .font(.headline)
                    
                    EmergencySOSHoldButton(currentLocation: currentLocation) {
                        dismiss()
                    }
                    
                    Text("Emergency contacts will be notified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
                
                Divider()
                
                // Direct Service Calls
                VStack(alignment: .leading, spacing: 12) {
                    Text("Direct Service Calls")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    EmergencyServiceButton(
                        title: "Police",
                        number: emergencyManager.currentEmergencyNumbers.police,
                        icon: "shield.fill",
                        color: .blue
                    ) {
                        emergencyManager.callPolice()
                    }
                    
                    EmergencyServiceButton(
                        title: "Ambulance",
                        number: emergencyManager.currentEmergencyNumbers.ambulance,
                        icon: "cross.case.fill",
                        color: .red
                    ) {
                        emergencyManager.callAmbulance()
                    }
                    
                    EmergencyServiceButton(
                        title: "Fire",
                        number: emergencyManager.currentEmergencyNumbers.fire,
                        icon: "flame.fill",
                        color: .orange
                    ) {
                        emergencyManager.callFire()
                    }
                    
                    EmergencyServiceButton(
                        title: "Universal Emergency",
                        number: emergencyManager.currentEmergencyNumbers.universal,
                        icon: "phone.fill",
                        color: .green
                    ) {
                        emergencyManager.callEmergencyServices()
                    }
                }
                
                Spacer()
            }
        .padding()
        .navigationTitle("Emergency Services")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .onAppear {
            if let location = currentLocation {
                emergencyManager.detectCountryFromLocation(location)
            }
        }
    }
}

// MARK: - SOS Hold Button
struct EmergencySOSHoldButton: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    @State private var isHolding = false
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    let currentLocation: CLLocation?
    let onActivate: () -> Void
    
    var body: some View {
        ZStack {
            // Progress circle
            Circle()
                .stroke(Color.red.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // Button content
            Circle()
                .fill(isHolding ? Color.red : Color.red.opacity(0.8))
                .frame(width: 100, height: 100)
            
            VStack(spacing: 4) {
                Image(systemName: "sos")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("HOLD")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isHolding ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isHolding)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHolding {
                        startHolding()
                    }
                }
                .onEnded { _ in
                    stopHolding()
                }
        )
    }
    
    private func startHolding() {
        isHolding = true
        progress = 0
        
        HapticFeedbackManager.shared.heavyImpact()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            progress += 0.025 // 2 seconds to complete (0.025 * 40 = 1.0)
            
            if progress >= 1.0 {
                activateSOS()
            }
        }
    }
    
    private func stopHolding() {
        isHolding = false
        progress = 0
        timer?.invalidate()
        timer = nil
    }
    
    private func activateSOS() {
        timer?.invalidate()
        timer = nil
        
        emergencyManager.activateSOS(location: currentLocation)
        HapticFeedbackManager.shared.emergency()
        
        onActivate()
    }
}

// MARK: - Emergency Service Button
struct EmergencyServiceButton: View {
    let title: String
    let number: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(number)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.fill")
                    .foregroundColor(color)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Crash Detection Overlay
struct CrashDetectionOverlay: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    
    var body: some View {
        ZStack {
            // Full screen overlay
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Warning icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(emergencyManager.crashCountdownRemaining % 2 == 0 ? 1.0 : 1.1)
                    .animation(.easeInOut(duration: 0.5), value: emergencyManager.crashCountdownRemaining)
                
                VStack(spacing: 16) {
                    Text("CRASH DETECTED")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.red)
                    
                    Text("Emergency services will be called in")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    // Countdown
                    ZStack {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 12)
                            .frame(width: 150, height: 150)
                        
                        Text("\(emergencyManager.crashCountdownRemaining)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    Text("Tap below if you're OK")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Cancel button
                Button(action: {
                    emergencyManager.cancelCrashDetection()
                    HapticFeedbackManager.shared.success()
                }) {
                    Text("I'M OK - CANCEL")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color.green)
                        .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - SOS Activated View
struct SOSActivatedView: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("SOS ACTIVATED")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Emergency services have been notified")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if emergencyManager.emergencyContacts.count > 0 {
                    Text("\(emergencyManager.emergencyContacts.count) contacts notified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                emergencyManager.sosActivated = false
            }) {
                Text("Dismiss")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}
