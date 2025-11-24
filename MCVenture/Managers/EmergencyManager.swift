//
//  EmergencyManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import Combine
import MessageUI
import AVFoundation
import UIKit

// MARK: - European Emergency Numbers Database
struct EmergencyNumbers {
    let police: String
    let ambulance: String
    let fire: String
    let universal: String // 112 works everywhere in EU
    let countryName: String
    
    static let european = EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Europe")
    
    static let byCountryCode: [String: EmergencyNumbers] = [
        // Nordic Countries
        "NO": EmergencyNumbers(police: "112", ambulance: "113", fire: "110", universal: "112", countryName: "Norway"),
        "SE": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Sweden"),
        "FI": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Finland"),
        "DK": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Denmark"),
        "IS": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Iceland"),
        
        // Western Europe
        "GB": EmergencyNumbers(police: "999", ambulance: "999", fire: "999", universal: "112", countryName: "United Kingdom"),
        "IE": EmergencyNumbers(police: "999", ambulance: "999", fire: "999", universal: "112", countryName: "Ireland"),
        "FR": EmergencyNumbers(police: "17", ambulance: "15", fire: "18", universal: "112", countryName: "France"),
        "BE": EmergencyNumbers(police: "101", ambulance: "100", fire: "100", universal: "112", countryName: "Belgium"),
        "NL": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Netherlands"),
        "LU": EmergencyNumbers(police: "113", ambulance: "112", fire: "112", universal: "112", countryName: "Luxembourg"),
        
        // Central Europe
        "DE": EmergencyNumbers(police: "110", ambulance: "112", fire: "112", universal: "112", countryName: "Germany"),
        "AT": EmergencyNumbers(police: "133", ambulance: "144", fire: "122", universal: "112", countryName: "Austria"),
        "CH": EmergencyNumbers(police: "117", ambulance: "144", fire: "118", universal: "112", countryName: "Switzerland"),
        "PL": EmergencyNumbers(police: "997", ambulance: "999", fire: "998", universal: "112", countryName: "Poland"),
        "CZ": EmergencyNumbers(police: "158", ambulance: "155", fire: "150", universal: "112", countryName: "Czech Republic"),
        "SK": EmergencyNumbers(police: "158", ambulance: "155", fire: "150", universal: "112", countryName: "Slovakia"),
        "HU": EmergencyNumbers(police: "107", ambulance: "104", fire: "105", universal: "112", countryName: "Hungary"),
        
        // Southern Europe
        "ES": EmergencyNumbers(police: "091", ambulance: "061", fire: "080", universal: "112", countryName: "Spain"),
        "PT": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Portugal"),
        "IT": EmergencyNumbers(police: "113", ambulance: "118", fire: "115", universal: "112", countryName: "Italy"),
        "GR": EmergencyNumbers(police: "100", ambulance: "166", fire: "199", universal: "112", countryName: "Greece"),
        "MT": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Malta"),
        "CY": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Cyprus"),
        
        // Balkans
        "HR": EmergencyNumbers(police: "192", ambulance: "194", fire: "193", universal: "112", countryName: "Croatia"),
        "SI": EmergencyNumbers(police: "113", ambulance: "112", fire: "112", universal: "112", countryName: "Slovenia"),
        "BA": EmergencyNumbers(police: "122", ambulance: "124", fire: "123", universal: "112", countryName: "Bosnia"),
        "RS": EmergencyNumbers(police: "192", ambulance: "194", fire: "193", universal: "112", countryName: "Serbia"),
        "ME": EmergencyNumbers(police: "122", ambulance: "124", fire: "123", universal: "112", countryName: "Montenegro"),
        "MK": EmergencyNumbers(police: "192", ambulance: "194", fire: "193", universal: "112", countryName: "N. Macedonia"),
        "AL": EmergencyNumbers(police: "129", ambulance: "127", fire: "128", universal: "112", countryName: "Albania"),
        
        // Eastern Europe
        "RO": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Romania"),
        "BG": EmergencyNumbers(police: "166", ambulance: "150", fire: "160", universal: "112", countryName: "Bulgaria"),
        "UA": EmergencyNumbers(police: "102", ambulance: "103", fire: "101", universal: "112", countryName: "Ukraine"),
        "MD": EmergencyNumbers(police: "902", ambulance: "903", fire: "901", universal: "112", countryName: "Moldova"),
        
        // Baltic States
        "EE": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Estonia"),
        "LV": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Latvia"),
        "LT": EmergencyNumbers(police: "112", ambulance: "112", fire: "112", universal: "112", countryName: "Lithuania"),
    ]
    
    static func forCountryCode(_ code: String) -> EmergencyNumbers {
        return byCountryCode[code.uppercased()] ?? european
    }
}

// MARK: - Medical Info
struct MedicalInfo: Codable {
    var bloodType: String // e.g., "A+", "O-"
    var allergies: [String]
    var medications: [String]
    var medicalConditions: [String]
    var insuranceProvider: String
    var insurancePolicyNumber: String
    var doctorName: String
    var doctorPhone: String
    
    init(bloodType: String = "",
         allergies: [String] = [],
         medications: [String] = [],
         medicalConditions: [String] = [],
         insuranceProvider: String = "",
         insurancePolicyNumber: String = "",
         doctorName: String = "",
         doctorPhone: String = "") {
        self.bloodType = bloodType
        self.allergies = allergies
        self.medications = medications
        self.medicalConditions = medicalConditions
        self.insuranceProvider = insuranceProvider
        self.insurancePolicyNumber = insurancePolicyNumber
        self.doctorName = doctorName
        self.doctorPhone = doctorPhone
    }
}

// MARK: - Emergency Alert Type
enum EmergencyAlertType {
    case manualSOS
    case crashDetected
    case panicButton
    case medicalEmergency
    
    var title: String {
        switch self {
        case .manualSOS: return "Emergency SOS"
        case .crashDetected: return "CRASH DETECTED"
        case .panicButton: return "Panic Alert"
        case .medicalEmergency: return "Medical Emergency"
        }
    }
    
    var message: String {
        switch self {
        case .manualSOS: return "Emergency alert activated"
        case .crashDetected: return "Possible crash detected. Emergency services will be notified in 30 seconds."
        case .panicButton: return "Panic alert sent to emergency contacts"
        case .medicalEmergency: return "Medical emergency alert sent"
        }
    }
}

// MARK: - Emergency Manager
class EmergencyManager: NSObject, ObservableObject {
    static let shared = EmergencyManager()
    
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var medicalInfo = MedicalInfo()
    
    // Crash detection state
    @Published var crashDetected = false
    @Published var crashCountdownActive = false
    @Published var crashCountdownRemaining: Int = 30
    
    // SOS state
    @Published var sosActivated = false
    @Published var lastEmergencyLocation: CLLocation?
    @Published var currentCountryCode: String?
    @Published var currentEmergencyNumbers: EmergencyNumbers = .european
    
    private var crashCountdownTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private let geocoder = CLGeocoder()
    
    private override init() {
        super.init()
        loadEmergencyData()
    }
    
    // MARK: - Data Persistence
    private func loadEmergencyData() {
        if let contactsData = UserDefaults.standard.data(forKey: "emergencyContacts"),
           let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: contactsData) {
            emergencyContacts = decoded
        }
        
        if let medicalData = UserDefaults.standard.data(forKey: "medicalInfo"),
           let decoded = try? JSONDecoder().decode(MedicalInfo.self, from: medicalData) {
            medicalInfo = decoded
        }
    }
    
    func saveEmergencyData() {
        if let contactsEncoded = try? JSONEncoder().encode(emergencyContacts) {
            UserDefaults.standard.set(contactsEncoded, forKey: "emergencyContacts")
        }
        
        if let medicalEncoded = try? JSONEncoder().encode(medicalInfo) {
            UserDefaults.standard.set(medicalEncoded, forKey: "medicalInfo")
        }
    }
    
    // MARK: - Emergency Contact Management
    func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
        saveEmergencyData()
    }
    
    func removeEmergencyContact(at index: Int) {
        guard index < emergencyContacts.count else { return }
        emergencyContacts.remove(at: index)
        saveEmergencyData()
    }
    
    func updateEmergencyContact(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index] = contact
            saveEmergencyData()
        }
    }
    
    // MARK: - GPS-Based Country Detection
    func detectCountryFromLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first,
                  let countryCode = placemark.isoCountryCode else {
                self?.currentCountryCode = nil
                self?.currentEmergencyNumbers = .european
                return
            }
            self?.currentCountryCode = countryCode
            self?.currentEmergencyNumbers = EmergencyNumbers.forCountryCode(countryCode)
        }
    }
    
    // MARK: - Manual SOS Activation
    func activateSOS(location: CLLocation?) {
        sosActivated = true
        lastEmergencyLocation = location
        
        // Detect country for correct emergency numbers
        if let location = location {
            detectCountryFromLocation(location)
        }
        
        // Trigger haptic feedback
        triggerEmergencyHaptics()
        
        // Send alerts to emergency contacts
        sendEmergencyAlerts(type: .manualSOS, location: location)
        
        // Play alarm sound
        playEmergencyAlarm()
        
        // Call emergency services
        callEmergencyServices()
    }
    
    // MARK: - Crash Detection
    func detectCrash(gForce: Double, location: CLLocation?) {
        guard !crashDetected else { return }
        
        crashDetected = true
        crashCountdownActive = true
        crashCountdownRemaining = 30
        lastEmergencyLocation = location
        
        // Detect country for correct emergency numbers
        if let location = location {
            detectCountryFromLocation(location)
        }
        
        // Trigger strong haptic feedback
        triggerEmergencyHaptics()
        
        // Play loud alarm
        playEmergencyAlarm()
        
        // Start countdown timer
        startCrashCountdown()
    }
    
    private func startCrashCountdown() {
        crashCountdownTimer?.invalidate()
        crashCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.crashCountdownRemaining -= 1
            
            // Play beep every second
            self.playCountdownBeep()
            
            if self.crashCountdownRemaining <= 0 {
                self.crashCountdownTimer?.invalidate()
                self.executeCrashEmergency()
            }
        }
    }
    
    func cancelCrashDetection() {
        crashDetected = false
        crashCountdownActive = false
        crashCountdownRemaining = 30
        crashCountdownTimer?.invalidate()
        stopEmergencyAlarm()
    }
    
    private func executeCrashEmergency() {
        crashCountdownActive = false
        
        // Send emergency alerts
        sendEmergencyAlerts(type: .crashDetected, location: lastEmergencyLocation)
        
        // Call emergency services
        callEmergencyServices()
    }
    
    // MARK: - Emergency Communications
    private func sendEmergencyAlerts(type: EmergencyAlertType, location: CLLocation?) {
        let message = generateEmergencyMessage(type: type, location: location)
        
        // Send SMS to all emergency contacts
        for contact in emergencyContacts {
            sendSMS(to: contact.phone, message: message)
        }
        
        // Log emergency event
        logEmergencyEvent(type: type, location: location)
    }
    
    private func generateEmergencyMessage(type: EmergencyAlertType, location: CLLocation?) -> String {
        var message = "🚨 EMERGENCY ALERT - MCVenture 🚨\n\n"
        message += "\(type.title)\n\n"
        
        if let location = location {
            message += "Location: https://maps.apple.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)\n"
            message += "Coordinates: \(String(format: "%.6f", location.coordinate.latitude)), \(String(format: "%.6f", location.coordinate.longitude))\n\n"
        } else {
            message += "Location: Unknown\n\n"
        }
        
        message += "Time: \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium))\n\n"
        
        // Add medical info if available
        if !medicalInfo.bloodType.isEmpty {
            message += "Medical Info:\n"
            message += "Blood Type: \(medicalInfo.bloodType)\n"
            
            if !medicalInfo.allergies.isEmpty {
                message += "Allergies: \(medicalInfo.allergies.joined(separator: ", "))\n"
            }
            
            if !medicalInfo.medications.isEmpty {
                message += "Medications: \(medicalInfo.medications.joined(separator: ", "))\n"
            }
        }
        
        return message
    }
    
    private func sendSMS(to phone: String, message: String) {
        // Use iOS MessageUI to send SMS
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.recipients = [phone]
            messageVC.body = message
            
            // Present from top view controller
            if let topController = getTopViewController() {
                messageVC.messageComposeDelegate = self
                topController.present(messageVC, animated: true)
            }
        } else {
            // Fallback: Open SMS URL scheme
            let smsURL = "sms:\(phone)&body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            if let url = URL(string: smsURL) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func callEmergencyServices() {
        let number = currentEmergencyNumbers.universal // Always use universal 112
        let phoneURL = "tel://\(number)"
        if let url = URL(string: phoneURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func callPolice() {
        let number = currentEmergencyNumbers.police
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    
    func callAmbulance() {
        let number = currentEmergencyNumbers.ambulance
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    
    func callFire() {
        let number = currentEmergencyNumbers.fire
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Audio & Haptics
    private func playEmergencyAlarm() {
        // Use system sound for emergency
        AudioServicesPlaySystemSound(1304) // Long vibration
        
        // Play alert sound multiple times
        for _ in 0..<3 {
            AudioServicesPlaySystemSound(SystemSoundID(1005)) // Alert sound
        }
    }
    
    private func stopEmergencyAlarm() {
        audioPlayer?.stop()
    }
    
    private func playCountdownBeep() {
        AudioServicesPlaySystemSound(1057) // Beep sound
    }
    
    private func triggerEmergencyHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // Trigger multiple times for urgency
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.notificationOccurred(.error)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.notificationOccurred(.error)
        }
    }
    
    // MARK: - Logging
    private func logEmergencyEvent(type: EmergencyAlertType, location: CLLocation?) {
        let event: [String: Any] = [
            "type": type.title,
            "timestamp": Date().timeIntervalSince1970,
            "latitude": location?.coordinate.latitude ?? 0,
            "longitude": location?.coordinate.longitude ?? 0
        ]
        
        var emergencyLog = UserDefaults.standard.array(forKey: "emergencyLog") as? [[String: Any]] ?? []
        emergencyLog.append(event)
        UserDefaults.standard.set(emergencyLog, forKey: "emergencyLog")
    }
    
    // MARK: - Utilities
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return nil
        }
        
        var topController = rootVC
        while let presentedVC = topController.presentedViewController {
            topController = presentedVC
        }
        
        return topController
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension EmergencyManager: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
