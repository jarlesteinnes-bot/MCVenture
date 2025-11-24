//
//  WeatherComponents.swift
//  MCVenture
//
//  Created by BNTF on 24/11/2025.
//

import SwiftUI
import CoreLocation

// MARK: - Weather Alert Banner
struct WeatherAlertBanner: View {
    let alert: RouteWeatherAlert
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.type.icon)
                .font(.title2)
                .foregroundColor(alertColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(alertColor)
        }
        .padding()
        .background(alertColor.opacity(0.15))
        .cornerRadius(12)
    }
    
    private var alertColor: Color {
        switch alert.severity {
        case .info: return .blue
        case .warning: return .yellow
        case .severe: return .orange
        case .extreme: return .red
        }
    }
}

// MARK: - Route Weather Forecast Card
struct RouteWeatherForecastCard: View {
    let forecast: [WeatherForecastPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                Text("Weather Along Route")
                    .font(.headline)
                Spacer()
            }
            
            if forecast.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading weather...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(forecast) { point in
                            WeatherForecastPointView(point: point)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Weather Forecast Point View
struct WeatherForecastPointView: View {
    let point: WeatherForecastPoint
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(point.distanceKm)) km")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Image(systemName: point.icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("\(Int(point.temperature))°")
                .font(.title3)
                .fontWeight(.bold)
            
            if point.precipitationChance > 30 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(point.precipitationChance))%")
                        .font(.caption2)
                }
            }
            
            if point.windSpeed > 30 {
                HStack(spacing: 2) {
                    Image(systemName: "wind")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(Int(point.windSpeed))")
                        .font(.caption2)
                }
            }
            
            Text(point.estimatedArrivalTime, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .frame(width: 100)
    }
}

// MARK: - Gear Recommendations View
struct GearRecommendationsView: View {
    let recommendations: [GearRecommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                Text("Recommended Gear")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(recommendations) { recommendation in
                GearRecommendationRow(recommendation: recommendation)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Gear Recommendation Row
struct GearRecommendationRow: View {
    let recommendation: GearRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: recommendation.icon)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendation.category)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(recommendation.reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            FlowLayout(spacing: 6) {
                ForEach(recommendation.items, id: \.self) { item in
                    Text(item)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Best Departure Time Widget
struct BestDepartureTimeWidget: View {
    let bestTime: Date?
    
    var body: some View {
        if let bestTime = bestTime {
            HStack(spacing: 12) {
                Image(systemName: isBestTimeNow ? "checkmark.circle.fill" : "clock.fill")
                    .font(.title2)
                    .foregroundColor(isBestTimeNow ? .green : .orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isBestTimeNow ? "Good Time to Ride" : "Better Time Available")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if !isBestTimeNow {
                        Text("Consider departing at \(bestTime, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Weather conditions are favorable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background((isBestTimeNow ? Color.green : Color.orange).opacity(0.15))
            .cornerRadius(12)
        }
    }
    
    private var isBestTimeNow: Bool {
        guard let bestTime = bestTime else { return false }
        return abs(bestTime.timeIntervalSinceNow) < 600 // Within 10 minutes
    }
}

// MARK: - Compact Weather Badge
struct CompactWeatherBadge: View {
    let temperature: Double
    let condition: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Text("\(Int(temperature))°")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Weather Timeline View
struct WeatherTimelineView: View {
    let forecast: [WeatherForecastPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Timeline")
                .font(.headline)
            
            if forecast.isEmpty {
                Text("No weather data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(forecast.enumerated()), id: \.element.id) { index, point in
                    HStack(spacing: 12) {
                        // Time
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(point.estimatedArrivalTime, style: .time)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("\(Int(point.distanceKm)) km")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 60)
                        
                        // Timeline connector
                        VStack(spacing: 0) {
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 15)
                            }
                            
                            Circle()
                                .fill(temperatureColor(point.temperature))
                                .frame(width: 10, height: 10)
                            
                            if index < forecast.count - 1 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 15)
                            }
                        }
                        
                        // Weather info
                        HStack(spacing: 12) {
                            Image(systemName: point.icon)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("\(Int(point.temperature))°C")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    if point.precipitationChance > 30 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "drop.fill")
                                                .font(.caption2)
                                            Text("\(Int(point.precipitationChance))%")
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    if point.windSpeed > 20 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "wind")
                                                .font(.caption2)
                                            Text("\(Int(point.windSpeed)) km/h")
                                                .font(.caption2)
                                        }
                                    }
                                    
                                    if point.visibility < 5 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "eye.slash")
                                                .font(.caption2)
                                            Text("\(String(format: "%.1f", point.visibility)) km")
                                                .font(.caption2)
                                        }
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private func temperatureColor(_ temp: Double) -> Color {
        if temp < 5 { return .blue }
        else if temp < 15 { return .cyan }
        else if temp < 25 { return .green }
        else if temp < 30 { return .orange }
        else { return .red }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
