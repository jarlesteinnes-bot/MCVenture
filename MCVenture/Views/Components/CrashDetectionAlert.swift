//
//  CrashDetectionAlert.swift
//  MCVenture
//

import SwiftUI
import AVFoundation

/// Full-screen crash detection alert with countdown
struct CrashDetectionAlert: View {
    @Binding var isPresented: Bool
    let countdownSeconds: Int
    let onCancel: () -> Void
    let onEmergency: () -> Void
    
    @State private var remainingSeconds: Int
    @State private var audioPlayer: AVAudioPlayer?
    @State private var pulseScale: CGFloat = 1.0
    
    init(
        isPresented: Binding<Bool>,
        countdownSeconds: Int = 30,
        onCancel: @escaping () -> Void,
        onEmergency: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.countdownSeconds = countdownSeconds
        self._remainingSeconds = State(initialValue: countdownSeconds)
        self.onCancel = onCancel
        self.onEmergency = onEmergency
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Warning icon with pulse animation
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseScale)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                }
                
                // Title
                Text("CRASH DETECTED")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                // Countdown
                VStack(spacing: 8) {
                    Text("\(remainingSeconds)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Calling emergency services in...")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                // Cancel button (large and prominent)
                Button(action: cancelAlert) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("I'M OK - Cancel")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                // Emergency call button
                Button(action: callEmergency) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call Emergency Now")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            startCountdown()
            playAlarm()
            startHaptics()
            pulseScale = 1.2
        }
        .onDisappear {
            stopAlarm()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                
                // Play tick sound every second
                AudioServicesPlaySystemSound(1103)
                
                // Heavy haptic every 5 seconds
                if remainingSeconds % 5 == 0 {
                    HapticFeedbackManager.shared.heavyImpact()
                }
            } else {
                timer.invalidate()
                callEmergency()
            }
        }
    }
    
    private func playAlarm() {
        // Play loud system alert
        for _ in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(1005) // Loud beep
            }
        }
    }
    
    private func stopAlarm() {
        audioPlayer?.stop()
    }
    
    private func startHaptics() {
        // Emergency haptic pattern
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                HapticFeedbackManager.shared.heavyImpact()
            }
        }
    }
    
    private func cancelAlert() {
        isPresented = false
        onCancel()
        HapticFeedbackManager.shared.success()
    }
    
    private func callEmergency() {
        isPresented = false
        onEmergency()
    }
}

// MARK: - Compact Alert Variant (for use in sheets)
struct CompactCrashAlert: View {
    @Binding var isPresented: Bool
    let countdownSeconds: Int
    let onCancel: () -> Void
    let onEmergency: () -> Void
    
    @State private var remainingSeconds: Int
    
    init(
        isPresented: Binding<Bool>,
        countdownSeconds: Int = 30,
        onCancel: @escaping () -> Void,
        onEmergency: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.countdownSeconds = countdownSeconds
        self._remainingSeconds = State(initialValue: countdownSeconds)
        self.onCancel = onCancel
        self.onEmergency = onEmergency
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            // Title
            Text("Crash Detected")
                .font(.title)
                .fontWeight(.bold)
            
            // Message
            Text("Are you okay? Emergency services will be called in \(remainingSeconds) seconds.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Countdown circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(countdownSeconds))
                    .stroke(Color.red, lineWidth: 8)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Text("\(remainingSeconds)")
                    .font(.system(size: 40, weight: .bold))
            }
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: { onCancel(); isPresented = false }) {
                    Text("I'm OK")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: { onEmergency(); isPresented = false }) {
                    Text("Call Emergency Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
                AudioServicesPlaySystemSound(1103)
            } else {
                timer.invalidate()
                onEmergency()
                isPresented = false
            }
        }
    }
}

// MARK: - Usage
/*
// Full screen:
@State private var showCrashAlert = false

.fullScreenCover(isPresented: $showCrashAlert) {
    CrashDetectionAlert(
        isPresented: $showCrashAlert,
        countdownSeconds: 30,
        onCancel: {
            print("User is OK")
        },
        onEmergency: {
            print("Calling emergency services")
        }
    )
}

// Compact sheet:
.sheet(isPresented: $showCrashAlert) {
    CompactCrashAlert(
        isPresented: $showCrashAlert,
        countdownSeconds: 30,
        onCancel: { print("Cancelled") },
        onEmergency: { print("Emergency") }
    )
}
*/
