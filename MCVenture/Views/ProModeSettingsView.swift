import SwiftUI

struct ProModeSettingsView: View {
    @ObservedObject var proManager = ProModeManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingInfo = false
    
    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Pro Mode Master Toggle
                        VStack(spacing: 15) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("PRO MODE")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.orange)
                                    Text("Professional telemetry & analytics")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $proManager.isProModeEnabled)
                                    .tint(.orange)
                                    .scaleEffect(1.2)
                            }
                            
                            if proManager.isProModeEnabled {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Pro Mode features will consume more battery")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: proManager.isProModeEnabled ?
                                    [Color.orange.opacity(0.2), Color.red.opacity(0.1)] :
                                    [Color.white.opacity(0.05), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                        
                        if proManager.isProModeEnabled {
                            // Performance Analytics Section
                            FeatureSection(title: "PERFORMANCE ANALYTICS") {
                                FeatureToggle(
                                    title: "Lean Angle Tracking",
                                    description: "Real-time motorcycle tilt measurement",
                                    icon: "angle",
                                    isOn: $proManager.leanAngleEnabled
                                )
                                
                                FeatureToggle(
                                    title: "G-Force Tracking",
                                    description: "3-axis acceleration forces (20Hz)",
                                    icon: "speedometer",
                                    isOn: $proManager.gForceEnabled
                                )
                                
                                FeatureToggle(
                                    title: "Corner Analysis",
                                    description: "Entry/apex/exit speed breakdown",
                                    icon: "arrow.triangle.2.circlepath",
                                    isOn: $proManager.cornerAnalysisEnabled
                                )
                            }
                            
                            // Track Features Section
                            FeatureSection(title: "TRACK FEATURES") {
                                FeatureToggle(
                                    title: "Lap Timing",
                                    description: "Professional sector splits & best lap",
                                    icon: "flag.checkered",
                                    isOn: $proManager.lapTimingEnabled
                                )
                            }
                            
                            // Route Intelligence Section
                            FeatureSection(title: "ROUTE INTELLIGENCE") {
                                FeatureToggle(
                                    title: "Route Recording",
                                    description: "Save & replay favorite routes",
                                    icon: "map",
                                    isOn: $proManager.routeRecordingEnabled
                                )
                                
                                FeatureToggle(
                                    title: "Surface Detection",
                                    description: "Road quality & pothole alerts",
                                    icon: "road.lanes",
                                    isOn: $proManager.surfaceDetectionEnabled
                                )
                            }
                            
                            // Quick Presets
                            VStack(alignment: .leading, spacing: 15) {
                                Text("QUICK PRESETS")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                PresetButton(
                                    title: "Track Day",
                                    description: "Lap timing, G-force, corners",
                                    icon: "flag.checkered",
                                    color: .red
                                ) {
                                    applyTrackDayPreset()
                                }
                                
                                PresetButton(
                                    title: "Touring",
                                    description: "Route recording, surface detection",
                                    icon: "map",
                                    color: .blue
                                ) {
                                    applyTouringPreset()
                                }
                                
                                PresetButton(
                                    title: "Battery Saver",
                                    description: "Minimal features for long rides",
                                    icon: "battery.100",
                                    color: .green
                                ) {
                                    applyBatterySaverPreset()
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(15)
                            
                            // Info Card
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pro Tip")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                    Text("For best results, mount your device securely and start Pro Mode features before beginning your ride.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Pro Mode Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        .alert("About Pro Mode", isPresented: $showingInfo) {
            Button("OK") {}
        } message: {
            Text("Pro Mode provides professional-grade telemetry including lean angle, G-force tracking, corner analysis, and more. Data can be exported in GPX, KML, and CSV formats for use with racing analysis software.")
        }
    }
    
    private func applyTrackDayPreset() {
        proManager.leanAngleEnabled = true
        proManager.gForceEnabled = true
        proManager.cornerAnalysisEnabled = true
        proManager.lapTimingEnabled = true
        proManager.routeRecordingEnabled = false
        proManager.surfaceDetectionEnabled = false
    }
    
    private func applyTouringPreset() {
        proManager.leanAngleEnabled = false
        proManager.gForceEnabled = false
        proManager.cornerAnalysisEnabled = false
        proManager.lapTimingEnabled = false
        proManager.routeRecordingEnabled = true
        proManager.surfaceDetectionEnabled = true
    }
    
    private func applyBatterySaverPreset() {
        proManager.leanAngleEnabled = false
        proManager.gForceEnabled = false
        proManager.cornerAnalysisEnabled = true // Lightweight
        proManager.lapTimingEnabled = false
        proManager.routeRecordingEnabled = false
        proManager.surfaceDetectionEnabled = false
    }
}

struct FeatureSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.orange)
            
            content
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

struct FeatureToggle: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isOn ? .orange : .white.opacity(0.4))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.orange)
        }
        .padding(.vertical, 8)
    }
}

struct PresetButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
