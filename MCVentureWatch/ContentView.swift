//
//  ContentView.swift
//  MCVentureWatch
//

import SwiftUI
import WatchKit

struct WatchContentView: View {
    @State private var isTracking = false
    @State private var speed: Double = 0
    @State private var distance: Double = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        TabView {
            // Quick Stats Tab
            VStack(spacing: 8) {
                Text("MCVenture")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(.blue)
                        Text("\(Int(speed)) km/h")
                            .font(.title2)
                    }
                    
                    HStack {
                        Image(systemName: "road.lanes")
                            .foregroundColor(.green)
                        Text(String(format: "%.1f km", distance))
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.purple)
                        Text(formatDuration(duration))
                    }
                }
                .font(.caption)
            }
            .padding()
            
            // Tracking Control Tab
            VStack(spacing: 12) {
                Button(action: {
                    isTracking.toggle()
                }) {
                    VStack {
                        Image(systemName: isTracking ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40))
                        Text(isTracking ? "Stop" : "Start")
                            .font(.caption)
                    }
                    .foregroundColor(isTracking ? .red : .green)
                }
                .buttonStyle(PlainButtonStyle())
                
                if isTracking {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "pause.circle.fill")
                            Text("Pause")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            
            // Complication Data Tab
            VStack(spacing: 8) {
                Text("Today")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Label("42 trips", systemImage: "map")
                    Label("1,250 km", systemImage: "road.lanes")
                    Label("8,500 m", systemImage: "mountain.2")
                }
                .font(.caption)
            }
            .padding()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

#Preview {
    WatchContentView()
}
