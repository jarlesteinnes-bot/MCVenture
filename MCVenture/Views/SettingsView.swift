//  SettingsView.swift - COMPLETE Professional Settings Panel with Validation

import SwiftUI
import StoreKit
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // Units
    @Published var distanceUnit: String = "km"
    @Published var temperatureUnit: String = "C"
    
    // Appearance
    @Published var theme: String = "auto"
    
    // Notifications
    @Published var notificationsEnabled = false
    @Published var hapticsEnabled = true
    @Published var voiceEnabled = false
    
    // Safety - with validation
    @Published var crashDetection = true
    @Published var autoPause = true
    @Published var crashThreshold: Double = 4.5 {
        didSet {
            // Clamp to valid range
            crashThreshold = min(max(crashThreshold, 2.0), 10.0)
            UserDefaults.standard.set(crashThreshold, forKey: "crashDetectionThreshold")
        }
    }
    
    // Speed limit - with validation
    @Published var speedLimitWarning = true
    @Published var speedLimit: Double = 80.0 {
        didSet {
            // Clamp to valid range
            speedLimit = min(max(speedLimit, 20.0), 200.0)
            UserDefaults.standard.set(speedLimit, forKey: "speedLimitThreshold")
        }
    }
    @Published var speedOffset: Double = 5.0 {
        didSet {
            // Clamp to valid range
            speedOffset = min(max(speedOffset, 0.0), 20.0)
        }
    }
    
    private init() {
        // Load saved values
        crashThreshold = UserDefaults.standard.double(forKey: "crashDetectionThreshold")
        if crashThreshold == 0 { crashThreshold = 4.5 }
        
        speedLimit = UserDefaults.standard.double(forKey: "speedLimitThreshold")
        if speedLimit == 0 { speedLimit = 80.0 }
    }
    
    // Validation helpers
    var isCrashThresholdValid: Bool {
        crashThreshold >= 2.0 && crashThreshold <= 10.0
    }
    
    var isSpeedLimitValid: Bool {
        speedLimit >= 20.0 && speedLimit <= 200.0
    }
    
    var isSpeedOffsetValid: Bool {
        speedOffset >= 0.0 && speedOffset <= 20.0
    }
    
    var allSettingsValid: Bool {
        isCrashThresholdValid && isSpeedLimitValid && isSpeedOffsetValid
    }
}

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var network = NetworkMonitor.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showingLanguagePicker = false
    @State private var showingUserManual = false
    
    var body: some View {
        Form {
            Section("General") {
                Button(action: {
                    showingLanguagePicker = true
                }) {
                    HStack {
                        Text("settings.language".localized)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(currentLanguageName())
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Units") {
                Picker("Distance", selection: $settings.distanceUnit) {
                    Text("Kilometers").tag("km")
                    Text("Miles").tag("mi")
                }
                Picker("Temperature", selection: $settings.temperatureUnit) {
                    Text("Celsius").tag("C")
                    Text("Fahrenheit").tag("F")
                }
            }
            Section("Appearance") {
                Picker("Theme", selection: $settings.theme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("Auto").tag("auto")
                }
            }
            Section(header: Text("Safety"), footer: Text("Crash detection uses accelerometer data to detect sudden impacts")) {
                Toggle("Crash Detection", isOn: $settings.crashDetection)
                
                if settings.crashDetection {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Crash Threshold")
                            Spacer()
                            Text(String(format: "%.1fG", settings.crashThreshold))
                                .foregroundColor(settings.isCrashThresholdValid ? .primary : .red)
                        }
                        Slider(value: $settings.crashThreshold, in: 2.0...10.0, step: 0.5)
                        Text("Higher = less sensitive (2.0G - 10.0G)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle("Auto-Pause Detection", isOn: $settings.autoPause)
            }
            Section(header: Text("Speed Warnings"), footer: Text("Get notified when exceeding speed limits")) {
                Toggle("Speed Limit Warnings", isOn: $settings.speedLimitWarning)
                
                if settings.speedLimitWarning {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Speed Limit")
                            Spacer()
                            Text("\(Int(settings.speedLimit)) km/h")
                                .foregroundColor(settings.isSpeedLimitValid ? .primary : .red)
                        }
                        Slider(value: $settings.speedLimit, in: 20...200, step: 5)
                        Text("Default speed limit (20-200 km/h)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Warning Offset")
                            Spacer()
                            Text("+\(Int(settings.speedOffset)) km/h")
                                .foregroundColor(settings.isSpeedOffsetValid ? .primary : .red)
                        }
                        Slider(value: $settings.speedOffset, in: 0...20, step: 1)
                        Text("Warning triggers at limit + offset (0-20 km/h)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Feedback") {
                Toggle("Haptic Feedback", isOn: $settings.hapticsEnabled)
                Toggle("Voice Announcements", isOn: $settings.voiceEnabled)
            }
            Section("Network") {
                HStack {
                    Text("Status")
                    Spacer()
                    Circle().fill(network.isConnected ? Color.green : Color.red).frame(width: 8, height: 8)
                    Text(network.connectionType.description)
                }
            }
            
            Section(header: Text("help.title".localized)) {
                Button(action: {
                    showingUserManual = true
                }) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("help.manual".localized)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "https://jarlesteinnes-bot.github.io/mcventure-legal/") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("help.faq".localized)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "https://github.com/jarlesteinnes-bot/MCVenture") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Text("help.github".localized)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "mailto:support@mcventure.app?subject=MCVenture%20Support") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text("help.contact".localized)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("settings.title".localized)
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView()
        }
        .fullScreenCover(isPresented: $showingUserManual) {
            UserManualView()
        }
    }
    
    private func currentLanguageName() -> String {
        SupportedLanguage.allCases
            .first { $0.code == localizationManager.currentLanguage }?
            .rawValue ?? "English"
    }
}
