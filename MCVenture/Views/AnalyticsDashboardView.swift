//
//  AnalyticsDashboardView.swift
//  MCVenture
//

import SwiftUI
import Charts
import Combine

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeframe: Timeframe = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time frame picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Overview Stats
                OverviewStatsSection(stats: viewModel.overviewStats)
                
                // Distance Chart
                DistanceChartCard(
                    data: viewModel.distanceData,
                    timeframe: selectedTimeframe
                )
                
                // Speed Statistics
                SpeedStatsCard(stats: viewModel.speedStats)
                
                // Elevation Profile
                ElevationChartCard(data: viewModel.elevationData)
                
                // Trip Breakdown
                TripBreakdownCard(trips: viewModel.recentTrips)
                
                // Achievements
                AchievementsSection(achievements: viewModel.achievements)
                
                // Heat Map (Placeholder)
                HeatMapCard()
            }
            .padding(.vertical)
        }
        .navigationTitle("Analytics")
        .onAppear {
            viewModel.loadData(for: selectedTimeframe)
        }
        .onChange(of: selectedTimeframe) { newValue in
            viewModel.loadData(for: newValue)
        }
    }
}

// MARK: - Timeframe Enum
enum Timeframe: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"
    
    var id: String { rawValue }
}

// MARK: - Overview Stats Section
struct OverviewStatsSection: View {
    let stats: OverviewStats
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 12)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalyticsStatCard(
                    icon: "arrow.forward",
                    title: "Total Distance",
                    value: "\(Int(stats.totalDistance)) km",
                    color: .blue
                )
                
                AnalyticsStatCard(
                    icon: "clock",
                    title: "Ride Time",
                    value: formatHours(stats.totalDuration),
                    color: .green
                )
                
                AnalyticsStatCard(
                    icon: "road.lanes",
                    title: "Total Trips",
                    value: "\(stats.totalTrips)",
                    color: .orange
                )
                
                AnalyticsStatCard(
                    icon: "arrow.up",
                    title: "Elevation Gain",
                    value: "\(Int(stats.totalElevationGain)) m",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func formatHours(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        return "\(hours)h"
    }
}

struct AnalyticsStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Distance Chart Card
struct DistanceChartCard: View {
    let data: [DistanceDataPoint]
    let timeframe: Timeframe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distance Over Time")
                .font(.headline)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Distance", point.distance)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .padding(.horizontal)
            } else {
                // Fallback for iOS 15
                LegacyBarChart(data: data)
                    .frame(height: 200)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Speed Stats Card
struct SpeedStatsCard: View {
    let stats: SpeedStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Speed Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                SpeedStatItem(
                    label: "Average",
                    value: stats.average,
                    icon: "speedometer",
                    color: .blue
                )
                
                SpeedStatItem(
                    label: "Max",
                    value: stats.max,
                    icon: "gauge.high",
                    color: .red
                )
                
                SpeedStatItem(
                    label: "Typical",
                    value: stats.typical,
                    icon: "gauge.medium",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SpeedStatItem: View {
    let label: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text("\(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("km/h")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Elevation Chart Card
struct ElevationChartCard: View {
    let data: [ElevationDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevation Profile")
                .font(.headline)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                Chart(data) { point in
                    AreaMark(
                        x: .value("Distance", point.distance),
                        y: .value("Elevation", point.elevation)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
                .frame(height: 180)
                .padding(.horizontal)
            } else {
                LegacyLineChart(data: data)
                    .frame(height: 180)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Trip Breakdown Card
struct TripBreakdownCard: View {
    let trips: [AnalyticsTripSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Trips")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(trips) { trip in
                TripRow(trip: trip)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct TripRow: View {
    let trip: AnalyticsTripSummary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(trip.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(trip.distance)) km")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(Int(trip.duration / 60)) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Achievements Section
struct AchievementsSection: View {
    let achievements: [AnalyticsAchievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        AnalyticsAchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AnalyticsAchievementCard: View {
    let achievement: AnalyticsAchievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Heat Map Card
struct HeatMapCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route Heat Map")
                .font(.headline)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 250)
                
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Heat map visualization")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Shows your most traveled routes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Legacy Chart Views (iOS 15 fallback)
struct LegacyBarChart: View {
    let data: [DistanceDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data) { point in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(height: normalizedHeight(point.distance, in: geometry.size.height))
                    }
                }
            }
        }
    }
    
    private func normalizedHeight(_ value: Double, in maxHeight: CGFloat) -> CGFloat {
        let maxValue = data.map { $0.distance }.max() ?? 1
        return CGFloat(value / maxValue) * maxHeight * 0.8
    }
}

struct LegacyLineChart: View {
    let data: [ElevationDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let first = data.first else { return }
                
                let xScale = geometry.size.width / CGFloat(data.count)
                let maxElevation = data.map { $0.elevation }.max() ?? 1
                let yScale = geometry.size.height / CGFloat(maxElevation)
                
                path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(first.elevation) * yScale))
                
                for (index, point) in data.enumerated() {
                    let x = CGFloat(index) * xScale
                    let y = geometry.size.height - CGFloat(point.elevation) * yScale
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}

// MARK: - View Model
@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var overviewStats = OverviewStats()
    @Published var distanceData: [DistanceDataPoint] = []
    @Published var speedStats = SpeedStats()
    @Published var elevationData: [ElevationDataPoint] = []
    @Published var recentTrips: [AnalyticsTripSummary] = []
    @Published var achievements: [AnalyticsAchievement] = []
    
    func loadData(for timeframe: Timeframe) {
        // Load from CoreData or UserDefaults
        loadOverviewStats(for: timeframe)
        loadDistanceData(for: timeframe)
        loadSpeedStats(for: timeframe)
        loadElevationData()
        loadRecentTrips()
        loadAchievements()
    }
    
    private func loadOverviewStats(for timeframe: Timeframe) {
        // Mock data - replace with actual data loading
        overviewStats = OverviewStats(
            totalDistance: 2543.0,
            totalDuration: 86400 * 5,
            totalTrips: 47,
            totalElevationGain: 12450
        )
    }
    
    private func loadDistanceData(for timeframe: Timeframe) {
        // Mock data
        distanceData = (0..<30).map { day in
            DistanceDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date())!,
                distance: Double.random(in: 20...150)
            )
        }.reversed()
    }
    
    private func loadSpeedStats(for timeframe: Timeframe) {
        speedStats = SpeedStats(
            average: 65.4,
            max: 142.0,
            typical: 58.2
        )
    }
    
    private func loadElevationData() {
        elevationData = (0..<50).map { point in
            ElevationDataPoint(
                distance: Double(point),
                elevation: Double.random(in: 200...800)
            )
        }
    }
    
    private func loadRecentTrips() {
        recentTrips = [
            AnalyticsTripSummary(name: "Coastal Route", date: Date(), distance: 145.3, duration: 7200),
            AnalyticsTripSummary(name: "Mountain Pass", date: Date().addingTimeInterval(-86400), distance: 89.7, duration: 5400),
            AnalyticsTripSummary(name: "City Loop", date: Date().addingTimeInterval(-172800), distance: 54.2, duration: 3600)
        ]
    }
    
    private func loadAchievements() {
        achievements = [
            AnalyticsAchievement(title: "First Ride", description: "Complete your first trip", icon: "flag.fill", isUnlocked: true),
            AnalyticsAchievement(title: "Century", description: "Ride 100+ km in one trip", icon: "star.fill", isUnlocked: true),
            AnalyticsAchievement(title: "Mountain Climber", description: "Gain 1000m elevation", icon: "mountain.2.fill", isUnlocked: false),
            AnalyticsAchievement(title: "Speed Demon", description: "Reach 150 km/h", icon: "bolt.fill", isUnlocked: false)
        ]
    }
}

// MARK: - Data Models
struct OverviewStats {
    var totalDistance: Double = 0
    var totalDuration: TimeInterval = 0
    var totalTrips: Int = 0
    var totalElevationGain: Double = 0
}

struct DistanceDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double
}

struct SpeedStats {
    var average: Double = 0
    var max: Double = 0
    var typical: Double = 0
}

struct ElevationDataPoint: Identifiable {
    let id = UUID()
    let distance: Double
    let elevation: Double
}

struct AnalyticsTripSummary: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let distance: Double
    let duration: TimeInterval
}

struct AnalyticsAchievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            AnalyticsDashboardView()
        }
    } else {
        SwiftUI.NavigationView {
            AnalyticsDashboardView()
        }
    }
}
