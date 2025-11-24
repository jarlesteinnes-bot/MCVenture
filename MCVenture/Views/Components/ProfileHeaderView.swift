//
//  ProfileHeaderView.swift
//  MCVenture
//
//  Created by BNTF on 22/11/2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userName") private var userName = ""
    @State private var showingImagePicker = false
    @State private var showingEditProfile = false
    @State private var showingTripHistory = false
    
    var totalKilometers: Double {
        dataManager.motorcycles.reduce(0) { $0 + $1.currentMileage }
    }
    
    var totalTrips: Int {
        dataManager.completedTrips.count
    }
    
    var totalBikes: Int {
        dataManager.motorcycles.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 375
            let headerHeight: CGFloat = isSmallScreen ? 160 : 200
            let avatarSize: CGFloat = isSmallScreen ? 100 : 130
            let totalHeight: CGFloat = headerHeight + (avatarSize / 2) + (isSmallScreen ? 160 : 200)
            
            makeContent(headerHeight: headerHeight, avatarSize: avatarSize, isSmallScreen: isSmallScreen)
                .frame(height: totalHeight)
        }
        .frame(height: 450)
    }
    
    @ViewBuilder
    private func makeContent(headerHeight: CGFloat, avatarSize: CGFloat, isSmallScreen: Bool) -> some View {
        VStack(spacing: 0) {
            // Background gradient header
            ZStack(alignment: .bottom) {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.8),
                        Color.red.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: headerHeight)
                
                // Pattern overlay
                GeometryReader { patternGeometry in
                    HStack(spacing: isSmallScreen ? 10 : 15) {
                        ForEach(0..<10, id: \.self) { _ in
                            Image(systemName: "figure.motorcycling")
                                .font(.system(size: isSmallScreen ? 24 : 30))
                                .foregroundStyle(.white.opacity(0.1))
                        }
                    }
                    .frame(width: patternGeometry.size.width * 2)
                    .offset(x: -50, y: headerHeight * 0.4)
                    .rotationEffect(.degrees(-15))
                }
                .frame(height: headerHeight)
                
                // Profile avatar - positioned to overlap
                VStack(spacing: 0) {
                    Spacer()
                    
                    ZStack(alignment: .bottomTrailing) {
                        // Avatar with gradient border
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: avatarSize, height: avatarSize)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: avatarSize - 10, height: avatarSize - 10)
                            
                            // Avatar content
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: avatarSize - 15, height: avatarSize - 15)
                                
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: avatarSize - 15, height: avatarSize - 15)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        
                        // Edit button
                        Button(action: { showingImagePicker = true }) {
                            let buttonSize: CGFloat = isSmallScreen ? 30 : 36
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: buttonSize, height: buttonSize)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: buttonSize - 4, height: buttonSize - 4)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: isSmallScreen ? 11 : 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .offset(x: -5, y: -5)
                    }
                }
                .offset(y: avatarSize / 2)
            }
            
            // White space for avatar overlap
            Color.clear
                .frame(height: avatarSize / 2)
            
            // User info section
            VStack(spacing: isSmallScreen ? 6 : 8) {
                Text(userName.isEmpty ? "Rider" : userName)
                    .font(.system(size: isSmallScreen ? 24 : 28, weight: .bold, design: .rounded))
                
                Text("Adventure Seeker")
                    .font(.system(size: isSmallScreen ? 12 : 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                // Edit profile button
                Button(action: { showingEditProfile = true }) {
                    HStack(spacing: isSmallScreen ? 4 : 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: isSmallScreen ? 10 : 12, weight: .semibold))
                        Text("Edit Profile")
                            .font(.system(size: isSmallScreen ? 12 : 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, isSmallScreen ? 16 : 20)
                    .padding(.vertical, isSmallScreen ? 6 : 8)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, isSmallScreen ? 6 : 8)
            }
            .padding(.top, isSmallScreen ? 8 : 12)
            
            // Stats section
            HStack(spacing: 0) {
                StatItemView(
                    icon: "speedometer",
                    value: String(format: "%.0f", totalKilometers),
                    label: "Total KM",
                    color: .orange,
                    isSmallScreen: isSmallScreen
                )
                
                Divider()
                    .frame(height: isSmallScreen ? 40 : 50)
                
                Button(action: { showingTripHistory = true }) {
                    StatItemView(
                        icon: "map.fill",
                        value: "\(totalTrips)",
                        label: "Routes",
                        color: .blue,
                        isSmallScreen: isSmallScreen
                    )
                }
                
                Divider()
                    .frame(height: isSmallScreen ? 40 : 50)
                
                StatItemView(
                    icon: "figure.motorcycling",
                    value: "\(totalBikes)",
                    label: "Bikes",
                    color: .red,
                    isSmallScreen: isSmallScreen
                )
            }
            .padding(.vertical, isSmallScreen ? 15 : 20)
            .padding(.horizontal, isSmallScreen ? 8 : 16)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingImagePicker) {
            Text("Image Picker (TODO)")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingTripHistory) {
            TrackedTripsView()
                .environmentObject(dataManager)
        }
    }
}

struct StatItemView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var isSmallScreen: Bool = false
    
    var body: some View {
        VStack(spacing: isSmallScreen ? 6 : 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: isSmallScreen ? 40 : 50, height: isSmallScreen ? 40 : 50)
                
                Image(systemName: icon)
                    .font(.system(size: isSmallScreen ? 16 : 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: isSmallScreen ? 16 : 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(label)
                .font(.system(size: isSmallScreen ? 10 : 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// // #Preview {
//     // NavigationView {
//         ScrollView {
//             ProfileHeaderView()
//                 .environmentObject(DataManager.shared)
//         }
//     }
// }
