//
//  TripsView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedSegment = 0
    @State private var showingAddTrip = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented control
            Picker("View", selection: $selectedSegment) {
                Text("History").tag(0)
                Text("Statistics").tag(1)
                Text("Achievements").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Content based on selection
            if selectedSegment == 0 {
                TripHistoryView()
            } else if selectedSegment == 1 {
                StatisticsView()
            } else {
                AchievementsView()
            }
        }
        .navigationTitle("My Trips")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTrip = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView()
        }
    }
}

// MARK: - Trip History View
struct TripHistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            if dataManager.completedTrips.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "road.lanes.curved.right")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No trips yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Complete your first route to start tracking!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                ForEach(dataManager.completedTrips.sorted(by: { $0.date > $1.date })) { trip in
                    NavigationLink(destination: TripDetailView(trip: trip)) {
                        TripRowView(trip: trip)
                    }
                }
                .onDelete(perform: deleteTrips)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        let sortedTrips = dataManager.completedTrips.sorted(by: { $0.date > $1.date })
        offsets.forEach { index in
            dataManager.deleteTrip(sortedTrips[index])
        }
    }
}

// MARK: - Trip Row
struct TripRowView: View {
    let trip: CompletedTrip
    
    var body: some View {
        HStack(spacing: 15) {
            // Country flag or icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: "flag.fill")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(trip.routeName)
                    .font(.headline)
                
                HStack {
                    Text(trip.country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(trip.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 15) {
                    HStack(spacing: 5) {
                        Image(systemName: "speedometer")
                            .font(.caption)
                        Text("\(Int(trip.distanceKm)) km")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text(formatDuration(trip.duration))
                            .font(.caption)
                    }
                    
                    if trip.rating > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<trip.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 5)
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

// MARK: - Statistics View
struct StatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Cards
                VStack(spacing: 15) {
                    StatCard(
                        icon: "road.lanes",
                        title: "Total Distance",
                        value: "\(Int(dataManager.statistics.totalDistanceKm))",
                        unit: "km",
                        color: .blue
                    )
                    
                    HStack(spacing: 15) {
                        StatCard(
                            icon: "map.fill",
                            title: "Routes",
                            value: "\(dataManager.statistics.totalTrips)",
                            unit: "completed",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "globe.europe.africa.fill",
                            title: "Countries",
                            value: "\(dataManager.statistics.countriesVisited.count)",
                            unit: "visited",
                            color: .orange
                        )
                    }
                    
                    HStack(spacing: 15) {
                        StatCard(
                            icon: "clock.fill",
                            title: "Riding Time",
                            value: "\(Int(dataManager.statistics.totalRidingTime / 3600))",
                            unit: "hours",
                            color: .purple
                        )
                        
                        StatCard(
                            icon: "fuelpump.fill",
                            title: "Fuel Cost",
                            value: "\(Int(dataManager.statistics.totalFuelCost))",
                            unit: "€",
                            color: .red
                        )
                    }
                    
                    if !dataManager.statistics.favoriteCountry.isEmpty {
                        StatCard(
                            icon: "heart.fill",
                            title: "Favorite Country",
                            value: dataManager.statistics.favoriteCountry,
                            unit: "",
                            color: .pink
                        )
                    }
                    
                    StatCard(
                        icon: "trophy.fill",
                        title: "Longest Trip",
                        value: "\(Int(dataManager.statistics.longestTrip))",
                        unit: "km",
                        color: .yellow
                    )
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Countries Visited List
                if !dataManager.statistics.countriesVisited.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Countries Visited")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(dataManager.statistics.countriesVisited.sorted()), id: \.self) { country in
                                    Text(country)
                                        .font(.subheadline)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 30)
        }
    }
}


// MARK: - Old Achievements View (deprecated)
struct OldAchievementsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var unlockedAchievements: [Achievement] {
        dataManager.achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        dataManager.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress summary
                VStack(spacing: 10) {
                    Text("\(unlockedAchievements.count)/\(dataManager.achievements.count)")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Achievements Unlocked")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(unlockedAchievements.count), total: Double(dataManager.achievements.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 8)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Unlocked achievements
                if !unlockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Unlocked")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(unlockedAchievements) { achievement in
                            AchievementRowView(achievement: achievement, isUnlocked: true)
                        }
                    }
                }
                
                // Locked achievements
                if !lockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Locked")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        ForEach(lockedAchievements) { achievement in
                            AchievementRowView(achievement: achievement, isUnlocked: false)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Achievement Row
struct AchievementRowView: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title)
                    .foregroundColor(isUnlocked ? .yellow : .gray)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !isUnlocked {
                    ProgressView(value: achievement.progress, total: achievement.requirement)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 6)
                    
                    Text("\(Int(achievement.progress))/\(Int(achievement.requirement))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// // #Preview {
//     // NavigationView {
//         TripsView()
//             .environmentObject(DataManager.shared)
//     }
// }
