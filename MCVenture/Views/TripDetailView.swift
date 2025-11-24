//
//  TripDetailView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct TripDetailView: View {
    let trip: CompletedTrip
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text(trip.routeName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text(trip.country)
                        
                        Spacer()
                        
                        Text(trip.date, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Stats
                VStack(spacing: 15) {
                    HStack {
                        StatItem(icon: "speedometer", title: "Distance", value: "\(Int(trip.distanceKm)) km")
                        Spacer()
                        StatItem(icon: "clock.fill", title: "Duration", value: formatDuration(trip.duration))
                    }
                    
                    HStack {
                        StatItem(icon: "gauge", title: "Avg Speed", value: "\(Int(trip.averageSpeed)) km/h")
                        Spacer()
                        StatItem(icon: "fuelpump.fill", title: "Fuel Cost", value: "€\(Int(trip.fuelCost))")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Rating
                if trip.rating > 0 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Rating")
                            .font(.headline)
                        
                        HStack(spacing: 5) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < trip.rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Weather
                if !trip.weatherCondition.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weather")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "cloud.sun.fill")
                            Text(trip.weatherCondition)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Notes
                if !trip.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(trip.notes)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Photos
                if !trip.photoURLs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photos")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(trip.photoURLs, id: \.self) { url in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 150, height: 150)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
        }
    }
}

// // #Preview {
//     // NavigationView {
//         TripDetailView(trip: CompletedTrip(
//             routeName: "Trollstigen",
//             country: "Norway",
//             date: Date(),
//             distanceKm: 120,
//             duration: 7200,
//             fuelCost: 45,
//             averageSpeed: 60,
//             rating: 5,
//             notes: "Amazing ride with stunning views!",
//             weatherCondition: "Sunny"
//         ))
//     }
// }
