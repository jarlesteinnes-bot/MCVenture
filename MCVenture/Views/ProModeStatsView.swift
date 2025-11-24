//
//  ProModeStatsView.swift
//  MCVenture
//

import SwiftUI

struct ProModeStatsView: View {
    @StateObject private var proMode = ProModeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("Stats Type", selection: $selectedTab) {
                Text("Lean Angle").tag(0)
                Text("G-Forces").tag(1)
                Text("Corners").tag(2)
                Text("Surface").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                LeanAngleStatsView()
                    .tag(0)
                
                GForceStatsView()
                    .tag(1)
                
                CornerStatsView()
                    .tag(2)
                
                SurfaceStatsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Pro Mode Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LeanAngleStatsView: View {
    @StateObject private var proMode = ProModeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Lean Angle
                VStack(spacing: 8) {
                    Text("Current Lean Angle")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(String(format: "%.1f", abs(proMode.leanAngleTracker.currentLeanAngle)))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(leanAngleColor(proMode.leanAngleTracker.currentLeanAngle))
                        Text("°")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                    
                    Text(proMode.leanAngleTracker.currentLeanAngle > 0 ? "Right" : "Left")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Max Lean Stats
                HStack(spacing: 15) {
                    StatBox(
                        title: "Max Left",
                        value: String(format: "%.1f°", proMode.leanAngleTracker.maxLeftLean),
                        color: .blue
                    )
                    
                    StatBox(
                        title: "Max Right",
                        value: String(format: "%.1f°", proMode.leanAngleTracker.maxRightLean),
                        color: .orange
                    )
                }
                
                // Lean Angle Distribution
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lean Angle Distribution")
                        .font(.headline)
                    
                    ForEach([
                        ("0-10°", "Straight", Color.green),
                        ("10-20°", "Light", Color.yellow),
                        ("20-30°", "Moderate", Color.orange),
                        ("30-40°", "Sport", Color.red),
                        ("40°+", "Extreme", Color.purple)
                    ], id: \.0) { range, label, color in
                        HStack {
                            Text(range)
                                .font(.subheadline)
                                .frame(width: 70, alignment: .leading)
                            
                            Text(label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            ProgressView(value: Double.random(in: 0...1))
                                .tint(color)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Safety Tips
                VStack(alignment: .leading, spacing: 8) {
                    Label("Safety Tips", systemImage: "exclamationmark.shield.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("• Professional riders reach 50-60° lean angles")
                    Text("• Street riding: Stay under 40° for safety")
                    Text("• Check tire pressure and condition regularly")
                    Text("• Practice in safe, controlled environments")
                }
                .font(.caption)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
            }
            .padding()
        }
    }
    
    private func leanAngleColor(_ angle: Double) -> Color {
        let absAngle = abs(angle)
        if absAngle < 10 { return .green }
        if absAngle < 20 { return .yellow }
        if absAngle < 30 { return .orange }
        return .red
    }
}

struct GForceStatsView: View {
    @StateObject private var proMode = ProModeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current G-Forces
                HStack(spacing: 15) {
                    GForceIndicator(
                        title: "Lateral",
                        value: proMode.gForceTracker.currentGForce.lateral,
                        icon: "arrow.left.and.right",
                        color: .blue
                    )
                    
                    GForceIndicator(
                        title: "Longitudinal",
                        value: proMode.gForceTracker.currentGForce.longitudinal,
                        icon: "arrow.up.and.down",
                        color: .green
                    )
                }
                
                // Max G-Forces
                VStack(alignment: .leading, spacing: 12) {
                    Text("Maximum G-Forces")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Max Accel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f g", proMode.gForceTracker.maxGForce.longitudinal))
                                .font(.title3.bold())
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Max Braking")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f g", abs(proMode.gForceTracker.maxGForce.longitudinal)))
                                .font(.title3.bold())
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // G-Force Meter Visual
                GForceMeterView(
                    lateral: proMode.gForceTracker.currentGForce.lateral,
                    longitudinal: proMode.gForceTracker.currentGForce.longitudinal
                )
                .frame(height: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            .padding()
        }
    }
}

struct CornerStatsView: View {
    @StateObject private var proMode = ProModeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Corner Summary
                HStack(spacing: 15) {
                    StatBox(
                        title: "Total Corners",
                        value: "\(proMode.cornerAnalyzer.corners.count)",
                        color: .blue
                    )
                    
                    StatBox(
                        title: "Avg Speed",
                        value: String(format: "%.0f km/h", avgCornerSpeed()),
                        color: .green
                    )
                }
                
                // Recent Corners
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Corners")
                        .font(.headline)
                    
                    ForEach(proMode.cornerAnalyzer.corners.prefix(10)) { corner in
                        CornerRowView(corner: corner)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            .padding()
        }
    }
    
    private func avgCornerSpeed() -> Double {
        let corners = proMode.cornerAnalyzer.corners
        guard !corners.isEmpty else { return 0 }
        return corners.map { $0.apexSpeed }.reduce(0, +) / Double(corners.count)
    }
}

struct SurfaceStatsView: View {
    @StateObject private var proMode = ProModeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Surface
                VStack(spacing: 8) {
                    Text("Current Surface")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Unknown")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Surface Quality
                VStack(alignment: .leading, spacing: 12) {
                    Text("Surface Quality")
                        .font(.headline)
                    
                    HStack {
                        Text("Quality Score")
                            .font(.subheadline)
                        Spacer()
                        Text("N/A")
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                    }
                    
                    ProgressView(value: 0.0)
                        .tint(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            .padding()
        }
    }
    
    // Placeholder surface helper functions
    private func surfaceColor(_ surface: Any) -> Color {
        return .green
    }
    
    private func surfaceIcon(_ surface: Any) -> String {
        return "checkmark.circle.fill"
    }
    
    private func qualityColor(_ quality: Double) -> Color {
        if quality > 0.7 { return .green }
        if quality > 0.4 { return .orange }
        return .red
    }
}

// Supporting Views
struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct GForceIndicator: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f g", value))
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct GForceMeterView: View {
    let lateral: Double
    let longitudinal: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circles
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: geometry.size.width * scale, height: geometry.size.width * scale)
                }
                
                // Center point
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                // G-Force indicator
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .offset(
                        x: CGFloat(lateral) * geometry.size.width / 2 * 0.8,
                        y: CGFloat(-longitudinal) * geometry.size.height / 2 * 0.8
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct CornerRowView: View {
    let corner: Corner
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Corner #\(corner.id.uuidString.prefix(8))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(String(format: "%.0f km/h", corner.apexSpeed), systemImage: "speedometer")
                        .font(.caption)
                    Label(String(format: "%.1fs", corner.duration), systemImage: "timer")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Text(corner.difficulty.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(cornerDifficultyColor(corner.difficulty).opacity(0.2))
                .foregroundColor(cornerDifficultyColor(corner.difficulty))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
    
    private func cornerDifficultyColor(_ difficulty: CornerDifficulty) -> Color {
        switch difficulty {
        case .hairpin: return .red
        case .tight: return .orange
        case .medium: return .yellow
        case .fast: return .green
        }
    }
}
