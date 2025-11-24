//
//  TrackedTripsView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct TrackedTripsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @State private var tripToDelete: CompletedTrip?
    @State private var showingDeleteAlert = false
    
    var sortedTrips: [CompletedTrip] {
        dataManager.completedTrips.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            if sortedTrips.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "map")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Trips Yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Start tracking your rides to see them here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedTrips) { trip in
                    TrackedTripRow(trip: trip)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                tripToDelete = trip
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Trip History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.orange)
            }
        }
        .alert("Delete Trip?", isPresented: $showingDeleteAlert, presenting: tripToDelete) { trip in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTrip(trip)
            }
        } message: { trip in
            Text("Are you sure you want to delete this trip? This action cannot be undone.")
        }
    }
    
    private func deleteTrip(_ trip: CompletedTrip) {
        dataManager.deleteTrip(trip)
        tripToDelete = nil
    }
}

struct TrackedTripRow: View {
    let trip: CompletedTrip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with route name and date
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    Text(trip.routeName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(formatDate(trip.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats grid
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    TrackedTripStatItem(
                        icon: "road.lanes",
                        value: String(format: "%.2f km", trip.distanceKm),
                        color: .orange
                    )
                    
                    TrackedTripStatItem(
                        icon: "timer",
                        value: formatDuration(trip.duration),
                        color: .blue
                    )
                }
                
                HStack(spacing: 15) {
                    TrackedTripStatItem(
                        icon: "speedometer",
                        value: String(format: "%.1f km/h", trip.averageSpeed),
                        color: .green
                    )
                    
                    TrackedTripStatItem(
                        icon: "fuelpump.fill",
                        value: String(format: "%.2f kr", trip.fuelCost),
                        color: .red
                    )
                }
            }
            
            // Notes if available
            if !trip.notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(trip.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.top, 4)
            }
            
            // Rating if available
            if trip.rating > 0 {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= trip.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(star <= trip.rating ? .yellow : .gray)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TrackedTripStatItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// // #Preview {
//     // NavigationView {
//         TrackedTripsView()
//             .environmentObject(DataManager.shared)
//     }
// }
