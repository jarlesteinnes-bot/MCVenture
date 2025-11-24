//
//  VoiceNavigator.swift
//  MCVenture
//
//  Created by AI Assistant on 2025-11-24.
//

import Foundation
import AVFoundation
import CoreLocation

/// Voice navigation announcements
@MainActor
class VoiceNavigator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking: Bool = false
    @Published var isEnabled: Bool = true
    
    private let synthesizer = AVSpeechSynthesizer()
    private var lastAnnouncementTime: Date?
    private let minimumAnnouncementInterval: TimeInterval = 3 // seconds
    
    // Distance thresholds for announcements
    private let farAnnouncementDistance: Double = 500 // meters
    private let nearAnnouncementDistance: Double = 100 // meters
    private let immediateAnnouncementDistance: Double = 30 // meters
    
    private var announcedFar = false
    private var announcedNear = false
    private var announcedImmediate = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    /// Announce navigation instruction based on distance
    func announceInstruction(_ instruction: TurnInstruction, distance: Double) {
        guard isEnabled else { return }
        
        // Reset announcement flags when instruction changes
        if distance > farAnnouncementDistance {
            announcedFar = false
            announcedNear = false
            announcedImmediate = false
            return
        }
        
        // Far announcement (500m)
        if distance <= farAnnouncementDistance && distance > nearAnnouncementDistance && !announcedFar {
            let text = generateAnnouncement(instruction, distance: distance)
            speak(text)
            announcedFar = true
        }
        
        // Near announcement (100m)
        if distance <= nearAnnouncementDistance && distance > immediateAnnouncementDistance && !announcedNear {
            let text = generateAnnouncement(instruction, distance: distance)
            speak(text)
            announcedNear = true
        }
        
        // Immediate announcement (30m)
        if distance <= immediateAnnouncementDistance && !announcedImmediate {
            let text = generateImmediateAnnouncement(instruction)
            speak(text)
            announcedImmediate = true
        }
    }
    
    /// Announce off-route warning
    func announceOffRoute() {
        guard isEnabled else { return }
        let text = getLocalizedString("off_route")
        speak(text)
    }
    
    /// Announce arrival
    func announceArrival() {
        guard isEnabled else { return }
        let text = getLocalizedString("arrived")
        speak(text)
    }
    
    /// Stop all speech
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    /// Toggle voice navigation on/off
    func toggle() {
        isEnabled.toggle()
        if !isEnabled {
            stopSpeaking()
        }
    }
    
    // MARK: - Private Methods
    
    private func generateAnnouncement(_ instruction: TurnInstruction, distance: Double) -> String {
        let distanceText = formatDistance(distance)
        let directionText = getDirectionText(instruction.type)
        
        if let streetName = instruction.streetName {
            return String(format: getLocalizedString("in_distance_turn_direction_onto_street"), distanceText, directionText, streetName)
        } else {
            return String(format: getLocalizedString("in_distance_turn_direction"), distanceText, directionText)
        }
    }
    
    private func generateImmediateAnnouncement(_ instruction: TurnInstruction) -> String {
        let directionText = getDirectionText(instruction.type)
        
        if let streetName = instruction.streetName {
            return String(format: getLocalizedString("turn_direction_now_onto_street"), directionText, streetName)
        } else {
            return String(format: getLocalizedString("turn_direction_now"), directionText)
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 100 {
            return "\(Int(distance)) " + getLocalizedString("meters")
        } else if distance < 1000 {
            let rounded = Int(round(distance / 50) * 50)
            return "\(rounded) " + getLocalizedString("meters")
        } else {
            let km = distance / 1000
            if km < 10 {
                return String(format: "%.1f ", km) + getLocalizedString("kilometers")
            } else {
                return String(format: "%.0f ", km) + getLocalizedString("kilometers")
            }
        }
    }
    
    private func getDirectionText(_ turnType: NavigationTurnType) -> String {
        switch turnType {
        case .left:
            return getLocalizedString("turn_left")
        case .right:
            return getLocalizedString("turn_right")
        case .slightLeft:
            return getLocalizedString("turn_slight_left")
        case .slightRight:
            return getLocalizedString("turn_slight_right")
        case .sharpLeft:
            return getLocalizedString("turn_sharp_left")
        case .sharpRight:
            return getLocalizedString("turn_sharp_right")
        case .straight:
            return getLocalizedString("continue_straight")
        case .roundabout:
            return getLocalizedString("enter_roundabout")
        case .uTurn:
            return getLocalizedString("make_uturn")
        case .arrive:
            return getLocalizedString("arrived")
        }
    }
    
    private func speak(_ text: String) {
        // Prevent too frequent announcements
        if let lastTime = lastAnnouncementTime {
            if Date().timeIntervalSince(lastTime) < minimumAnnouncementInterval {
                return
            }
        }
        
        lastAnnouncementTime = Date()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getVoiceForCurrentLanguage()
        utterance.rate = 0.5 // Slower than default for clarity
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func getVoiceForCurrentLanguage() -> AVSpeechSynthesisVoice? {
        let languageCode = LocalizationManager.shared.currentLanguage
        
        // Map app language codes to iOS voice codes
        let voiceCode: String
        switch languageCode {
        case "no":
            voiceCode = "nb-NO" // Norwegian Bokmål
        case "en":
            voiceCode = "en-US"
        case "de":
            voiceCode = "de-DE"
        case "fr":
            voiceCode = "fr-FR"
        case "es":
            voiceCode = "es-ES"
        case "it":
            voiceCode = "it-IT"
        case "sv":
            voiceCode = "sv-SE"
        case "da":
            voiceCode = "da-DK"
        default:
            voiceCode = "en-US"
        }
        
        return AVSpeechSynthesisVoice(language: voiceCode)
    }
    
    private func getLocalizedString(_ key: String) -> String {
        // Using LocalizationManager for consistency
        switch key {
        case "off_route":
            return "You are off route. Recalculating...".localized
        case "arrived":
            return "You have arrived at your destination".localized
        case "in_distance_turn_direction_onto_street":
            return "In %@, %@ onto %@".localized
        case "in_distance_turn_direction":
            return "In %@, %@".localized
        case "turn_direction_now_onto_street":
            return "%@ now onto %@".localized
        case "turn_direction_now":
            return "%@ now".localized
        case "meters":
            return "meters".localized
        case "kilometers":
            return "kilometers".localized
        case "turn_left":
            return "turn left".localized
        case "turn_right":
            return "turn right".localized
        case "turn_slight_left":
            return "keep left".localized
        case "turn_slight_right":
            return "keep right".localized
        case "turn_sharp_left":
            return "sharp left".localized
        case "turn_sharp_right":
            return "sharp right".localized
        case "continue_straight":
            return "continue straight".localized
        case "enter_roundabout":
            return "enter the roundabout".localized
        case "make_uturn":
            return "make a U-turn".localized
        default:
            return key
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("VoiceNavigator: Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
