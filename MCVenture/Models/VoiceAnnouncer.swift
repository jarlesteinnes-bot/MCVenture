//
//  VoiceAnnouncer.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import AVFoundation
import Combine

class VoiceAnnouncer: ObservableObject {
    static let shared = VoiceAnnouncer()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isEnabled = true
    @Published var voiceLanguage = "en-US"
    
    private var lastDistanceMilestone: Double = 0
    private let milestonInterval: Double = 10.0 // km
    
    private init() {}
    
    init(enabled: Bool = true) {
        self.isEnabled = enabled
    }
    
    func announceDistanceMilestone(_ distance: Double) {
        guard isEnabled else { return }
        
        let milestone = floor(distance / milestonInterval) * milestonInterval
        if milestone > lastDistanceMilestone && milestone > 0 {
            lastDistanceMilestone = milestone
            speak("You have ridden \(Int(milestone)) kilometers")
        }
    }
    
    func announceSpeedWarning(_ speed: Double, limit: Double = 120.0) {
        guard isEnabled, speed > limit else { return }
        speak("Warning: Speed is \(Int(speed)) kilometers per hour")
    }
    
    func announceAutoPause() {
        guard isEnabled else { return }
        speak("Tracking paused")
    }
    
    func announceAutoResume() {
        guard isEnabled else { return }
        speak("Tracking resumed")
    }
    
    func announceWaypointAdded(_ type: TripWaypointType) {
        guard isEnabled else { return }
        speak("\(type.rawValue) waypoint added")
    }
    
    func announceStart() {
        guard isEnabled else { return }
        speak("Trip tracking started. Ride safe!")
    }
    
    func announcePaused() {
        announceAutoPause()
    }
    
    func announceResumed() {
        announceAutoResume()
    }
    
    func announceFinish(distance: Double, duration: TimeInterval) {
        guard isEnabled else { return }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        var message = "Trip finished. "
        message += "Distance: \(String(format: "%.1f", distance)) kilometers. "
        if hours > 0 {
            message += "Duration: \(hours) hours and \(minutes) minutes"
        } else {
            message += "Duration: \(minutes) minutes"
        }
        
        speak(message)
    }
    
    func announceCrashDetected() {
        guard isEnabled else { return }
        speak("Crash detected! Emergency services will be notified if you don't respond")
    }
    
    func announceLowBattery(_ level: Int) {
        guard isEnabled, level <= 20 else { return }
        speak("Warning: Battery level is \(level) percent")
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func resetMilestones() {
        lastDistanceMilestone = 0
    }
}
