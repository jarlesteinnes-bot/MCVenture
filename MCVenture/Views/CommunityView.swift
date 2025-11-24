//
//  CommunityView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedTab) {
                Text("Reviews").tag(0)
                Text("Group Rides").tag(1)
                Text("Hazards").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                RouteReviewsView()
            } else if selectedTab == 1 {
                GroupRidesView()
            } else {
                RoadHazardsView()
            }
        }
        .navigationTitle("Community")
    }
}

// MARK: - Route Reviews
struct RouteReviewsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddReview = false
    
    var body: some View {
        List {
            if dataManager.routeReviews.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "star.bubble")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No reviews yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Be the first to review a route!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                ForEach(dataManager.routeReviews.sorted(by: { $0.date > $1.date })) { review in
                    ReviewRow(review: review)
                }
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddReview = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddReview) {
            Text("Add Review View (TODO)")
        }
    }
}

struct ReviewRow: View {
    let review: RouteReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(review.routeName)
                    .font(.headline)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Text(review.review)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Label(review.roadCondition.rawValue, systemImage: "road.lanes")
                    .font(.caption)
                
                Label(review.traffic.rawValue, systemImage: "car.fill")
                    .font(.caption)
                
                Spacer()
                
                Text(review.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Group Rides
struct GroupRidesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingCreateRide = false
    
    var upcomingRides: [GroupRide] {
        dataManager.groupRides.filter { $0.date > Date() }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        List {
            if upcomingRides.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No upcoming group rides")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Create one and ride with friends!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                ForEach(upcomingRides) { ride in
                    GroupRideRow(ride: ride)
                }
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateRide = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingCreateRide) {
            Text("Create Group Ride View (TODO)")
        }
    }
}

struct GroupRideRow: View {
    let ride: GroupRide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ride.routeName)
                    .font(.headline)
                Spacer()
                Image(systemName: ride.difficulty.icon)
                    .foregroundColor(ride.difficulty.color)
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(ride.date, style: .date)
                
                Text("•")
                
                Image(systemName: "clock")
                Text(ride.date, style: .time)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "person.fill")
                Text("\(ride.participants.count)/\(ride.maxRiders) riders")
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "mappin.circle.fill")
                Text(ride.meetingPoint)
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Road Hazards
struct RoadHazardsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddHazard = false
    
    var activeHazards: [RoadHazard] {
        dataManager.getActiveHazards().sorted { $0.reportedDate > $1.reportedDate }
    }
    
    var body: some View {
        List {
            if activeHazards.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No active hazards")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Report hazards to help other riders!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                ForEach(activeHazards) { hazard in
                    HazardRow(hazard: hazard)
                }
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddHazard = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddHazard) {
            Text("Report Hazard View (TODO)")
        }
    }
}

struct HazardRow: View {
    let hazard: RoadHazard
    
    var severityColor: Color {
        switch hazard.severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(severityColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(hazard.type.rawValue)
                    .font(.headline)
                
                Text(hazard.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("Reported: \(hazard.reportedDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(hazard.severity.rawValue)
                        .font(.caption)
                        .foregroundColor(severityColor)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

// // #Preview {
//     // NavigationView {
//         CommunityView()
//             .environmentObject(DataManager.shared)
//     }
// }
