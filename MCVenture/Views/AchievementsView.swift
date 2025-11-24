//
//  AchievementsView.swift
//  MCVenture
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementSystem = AchievementSystem.shared
    
    let allAchievements = [
        ("first_ride", "First Ride", "Complete your first trip", "flag.fill", 10),
        ("century", "Century Club", "Ride 100 km in total", "100.circle.fill", 50),
        ("thousand", "Thousand KM", "Ride 1000 km in total", "star.fill", 200),
        ("early_bird", "Early Bird", "Start before 6 AM", "sunrise.fill", 25),
        ("night_owl", "Night Owl", "Ride after 10 PM", "moon.stars.fill", 25),
        ("explorer", "Explorer", "Visit 10 countries", "globe.europe.africa.fill", 100),
        ("week_warrior", "Week Warrior", "Ride 7 days in a row", "flame.fill", 75),
        ("speed_demon", "Speed Demon", "50 total trips", "bolt.fill", 150)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Level Card
                    VStack(spacing: 12) {
                        Text("Level \(achievementSystem.level)")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("\(achievementSystem.totalPoints) Points")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        ProgressView(value: Double(achievementSystem.totalPoints % 100), total: 100)
                            .tint(.orange)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        Text("\(100 - (achievementSystem.totalPoints % 100)) points to next level")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Achievements Grid
                    Text("Achievements")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(allAchievements, id: \.0) { achievement in
                            AchievementCard(
                                id: achievement.0,
                                title: achievement.1,
                                description: achievement.2,
                                icon: achievement.3,
                                points: achievement.4,
                                isUnlocked: achievementSystem.unlockedAchievements.contains(achievement.0)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AchievementCard: View {
    let id: String
    let title: String
    let description: String
    let icon: String
    let points: Int
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isUnlocked ? .yellow : .gray)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("\(points) pts")
                .font(.caption.bold())
                .foregroundColor(isUnlocked ? .orange : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isUnlocked ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
