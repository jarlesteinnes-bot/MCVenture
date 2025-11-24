import SwiftUI

// MARK: - G-Force Meter Widget
struct GForceMeter: View {
    let gForce: GForceData
    let maxGForce: GForceData
    
    var body: some View {
        VStack(spacing: 10) {
            Text("G-FORCE")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .frame(width: 150, height: 150)
                
                // Grid lines
                Path { path in
                    path.move(to: CGPoint(x: 75, y: 0))
                    path.addLine(to: CGPoint(x: 75, y: 150))
                    path.move(to: CGPoint(x: 0, y: 75))
                    path.addLine(to: CGPoint(x: 150, y: 75))
                }
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .frame(width: 150, height: 150)
                
                // Current G-force indicator
                Circle()
                    .fill(Color.orange)
                    .frame(width: 20, height: 20)
                    .offset(
                        x: CGFloat(gForce.lateral * 60),
                        y: CGFloat(-gForce.longitudinal * 60)
                    )
                
                // Center dot
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
            .frame(width: 150, height: 150)
            
            // Readouts
            HStack(spacing: 20) {
                VStack {
                    Text("LONG")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2fG", gForce.longitudinal))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("LAT")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2fG", gForce.lateral))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("TOTAL")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2fG", gForce.total))
                        .font(.caption)
                        .foregroundColor(.orange)
                        .bold()
                }
            }
            
            // Max G-force
            Text("Max: \(String(format: "%.2fG", maxGForce.total))")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// MARK: - Lean Angle Gauge
struct LeanAngleGauge: View {
    let currentAngle: Double
    let maxLeft: Double
    let maxRight: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("LEAN ANGLE")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(180))
                
                // Angle scale markers
                ForEach([0, 15, 30, 45, 60], id: \.self) { angle in
                    // Left markers
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 10)
                        .offset(y: -70)
                        .rotationEffect(.degrees(Double(-angle)))
                    
                    // Right markers
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 10)
                        .offset(y: -70)
                        .rotationEffect(.degrees(Double(angle)))
                }
                
                // Current angle indicator
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4, height: 60)
                    .offset(y: -40)
                    .rotationEffect(.degrees(currentAngle))
                
                // Max markers
                Circle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .offset(y: -70)
                    .rotationEffect(.degrees(maxLeft))
                
                Circle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .offset(y: -70)
                    .rotationEffect(.degrees(maxRight))
                
                // Center
                VStack(spacing: 2) {
                    Text(String(format: "%.1f°", abs(currentAngle)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(currentAngle < 0 ? "LEFT" : "RIGHT")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(width: 140, height: 140)
            
            // Max readouts
            HStack(spacing: 30) {
                VStack {
                    Text("MAX L")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.1f°", abs(maxLeft)))
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                VStack {
                    Text("MAX R")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.1f°", maxRight))
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// MARK: - Corner Stats Widget
struct CornerStatsWidget: View {
    let corners: [Corner]
    
    var hairpinCount: Int {
        corners.filter { $0.difficulty == .hairpin }.count
    }
    
    var tightCount: Int {
        corners.filter { $0.difficulty == .tight }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CORNER ANALYSIS")
                .font(.headline)
                .foregroundColor(.orange)
            
            HStack(spacing: 20) {
                StatPill(label: "TOTAL", value: "\(corners.count)", color: .blue)
                StatPill(label: "HAIRPIN", value: "\(hairpinCount)", color: .red)
                StatPill(label: "TIGHT", value: "\(tightCount)", color: .orange)
            }
            
            if let lastCorner = corners.last {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("LAST CORNER")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Entry")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(Int(lastCorner.entrySpeed)) km/h")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white.opacity(0.3))
                        
                        VStack(alignment: .leading) {
                            Text("Apex")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(Int(lastCorner.apexSpeed)) km/h")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white.opacity(0.3))
                        
                        VStack(alignment: .leading) {
                            Text("Exit")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(Int(lastCorner.exitSpeed)) km/h")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(10)
    }
}

// MARK: - Lap Timer Widget
struct LapTimerWidget: View {
    let lapTimer: LapTimer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LAP TIMER")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Spacer()
                
                if lapTimer.isRecording {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("RECORDING")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            
            if let currentLap = lapTimer.currentLap {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LAP \(currentLap.number)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(formatLapTime(currentLap.time))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
            }
            
            if let bestLap = lapTimer.bestLap {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("BEST LAP")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Text(formatLapTime(bestLap.time))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("LAP \(bestLap.number)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(Int(bestLap.maxSpeed)) km/h")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func formatLapTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

// MARK: - Surface Quality Widget
struct SurfaceQualityWidget: View {
    let quality: Double
    let potholeCount: Int
    
    var qualityText: String {
        if quality > 0.8 { return "EXCELLENT" }
        if quality > 0.6 { return "GOOD" }
        if quality > 0.4 { return "FAIR" }
        if quality > 0.2 { return "POOR" }
        return "VERY POOR"
    }
    
    var qualityColor: Color {
        if quality > 0.8 { return .green }
        if quality > 0.6 { return .blue }
        if quality > 0.4 { return .yellow }
        if quality > 0.2 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SURFACE QUALITY")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                // Quality bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(qualityColor)
                            .frame(width: geometry.size.width * CGFloat(quality))
                            .cornerRadius(5)
                    }
                }
                .frame(height: 20)
                
                Text(qualityText)
                    .font(.caption)
                    .foregroundColor(qualityColor)
                    .bold()
            }
            
            if potholeCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("\(potholeCount) potholes detected")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}
