//
//  EnhancedEmergencyManager.swift
//  MCVenture
//

import Foundation
import CoreLocation
import AVFoundation
import MessageUI
import Combine

class EnhancedEmergencyManager: ObservableObject {
    static let shared = EnhancedEmergencyManager()
    
    @Published var sosCountdownActive = false
    @Published var sosCountdownSeconds = 30
    @Published var crashDetectionActive = false
    @Published var isInEmergencyMode = false
    
    private var countdownTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    // MARK: - SOS Activation
    func activateSOS(location: CLLocation?, medicalInfo: MedicalInfo?) {
        isInEmergencyMode = true
        sosCountdownActive = true
        sosCountdownSeconds = 30
        
        // Start countdown
        startCountdown()
        
        // Play loud alarm
        playEmergencyAlarm()
        
        // Heavy haptic feedback
        triggerEmergencyHaptics()
        
        // After countdown, execute emergency protocol
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            if self?.sosCountdownActive == true {
                self?.executeEmergencyProtocol(location: location, medicalInfo: medicalInfo)
            }
        }
    }
    
    func cancelSOS() {
        sosCountdownActive = false
        countdownTimer?.invalidate()
        audioPlayer?.stop()
        isInEmergencyMode = false
        HapticFeedbackManager.shared.success()
    }
    
    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.sosCountdownSeconds > 0 {
                self.sosCountdownSeconds -= 1
                // Play tick sound
                if self.sosCountdownSeconds % 5 == 0 {
                    AudioServicesPlaySystemSound(1103)
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func playEmergencyAlarm() {
        // Use system sounds for emergency
        for _ in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(1005) // Loud beep
            }
        }
    }
    
    private func triggerEmergencyHaptics() {
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                HapticFeedbackManager.shared.heavyImpact()
            }
        }
    }
    
    // MARK: - Emergency Protocol Execution
    private func executeEmergencyProtocol(location: CLLocation?, medicalInfo: MedicalInfo?) {
        sosCountdownActive = false
        
        // 1. Call emergency services (112 in Europe)
        callEmergencyServices()
        
        // 2. Send SMS to emergency contacts
        if let location = location {
            sendEmergencySMS(location: location, medicalInfo: medicalInfo)
        }
        
        // 3. Share live location
        if let location = location {
            generateShareableLocationLink(location: location)
        }
        
        // 4. Log emergency event
        logEmergencyEvent(location: location)
    }
    
    private func callEmergencyServices() {
        if let url = URL(string: "tel://112") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func sendEmergencySMS(location: CLLocation, medicalInfo: MedicalInfo?) {
        var message = "🚨 EMERGENCY ALERT 🚨\n\n"
        message += "MCVenture Emergency SOS Activated\n"
        message += "Location: https://maps.apple.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)\n"
        message += "Time: \(Date().formatted())\n"
        
        if let medical = medicalInfo {
            message += "\n--- MEDICAL INFO ---\n"
            if !medical.bloodType.isEmpty {
                message += "Blood Type: \(medical.bloodType)\n"
            }
            if !medical.allergies.isEmpty {
                message += "Allergies: \(medical.allergies.joined(separator: ", "))\n"
            }
            if !medical.medications.isEmpty {
                message += "Medications: \(medical.medications.joined(separator: ", "))\n"
            }
        }
        
        // In production, send actual SMS via MessageUI framework
        print("Emergency SMS would be sent: \(message)")
    }
    
    private func generateShareableLocationLink(location: CLLocation) -> String {
        return "https://maps.apple.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
    }
    
    private func logEmergencyEvent(location: CLLocation?) {
        let event = EmergencyEvent(
            timestamp: Date(),
            type: .sosActivated,
            location: location,
            resolved: false
        )
        // Save to persistent storage
        saveEmergencyEvent(event)
    }
    
    // MARK: - Crash Detection
    func detectCrash(gForce: Double) {
        // Threshold: 3G sudden deceleration
        if gForce > 3.0 && !crashDetectionActive {
            crashDetectionActive = true
            activateCrashDetectionCountdown()
        }
    }
    
    private func activateCrashDetectionCountdown() {
        // Similar to SOS but auto-triggered
        sosCountdownActive = true
        sosCountdownSeconds = 30
        
        playEmergencyAlarm()
        triggerEmergencyHaptics()
        
        // Show crash detection UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            if self?.sosCountdownActive == true {
                // Auto-execute if not cancelled
                self?.executeEmergencyProtocol(location: nil, medicalInfo: nil)
            }
            self?.crashDetectionActive = false
        }
    }
    
    // MARK: - Data Persistence
    private func saveEmergencyEvent(_ event: EmergencyEvent) {
        var events = loadEmergencyEvents()
        events.append(event)
        
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: "emergencyEvents")
        }
    }
    
    private func loadEmergencyEvents() -> [EmergencyEvent] {
        guard let data = UserDefaults.standard.data(forKey: "emergencyEvents"),
              let events = try? JSONDecoder().decode([EmergencyEvent].self, from: data) else {
            return []
        }
        return events
    }
}

// MARK: - Supporting Types
struct EmergencyEvent: Codable {
    let id = UUID()
    let timestamp: Date
    let type: EmergencyType
    let location: CLLocation?
    var resolved: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, type, resolved
        case latitude, longitude
    }
    
    init(timestamp: Date, type: EmergencyType, location: CLLocation?, resolved: Bool) {
        self.timestamp = timestamp
        self.type = type
        self.location = location
        self.resolved = resolved
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let type = try container.decode(EmergencyType.self, forKey: .type)
        let resolved = try container.decode(Bool.self, forKey: .resolved)
        
        let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        let location = (latitude != nil && longitude != nil) ? CLLocation(latitude: latitude!, longitude: longitude!) : nil
        
        self.init(timestamp: timestamp, type: type, location: location, resolved: resolved)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(type, forKey: .type)
        try container.encode(resolved, forKey: .resolved)
        
        if let location = location {
            try container.encode(location.coordinate.latitude, forKey: .latitude)
            try container.encode(location.coordinate.longitude, forKey: .longitude)
        }
    }
}

enum EmergencyType: String, Codable {
    case sosActivated = "SOS Activated"
    case crashDetected = "Crash Detected"
    case manualCall = "Manual Emergency Call"
}
