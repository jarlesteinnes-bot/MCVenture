//
//  MCVentureWidgets.swift
//  MCVentureWidgets
//

import WidgetKit
import SwiftUI

struct StatsWidget: Widget {
    let kind: String = "StatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            StatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Trip Stats")
        .description("Your recent trip statistics")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatsEntry {
        StatsEntry(date: Date(), totalDistance: 0, totalTrips: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> ()) {
        let entry = StatsEntry(date: Date(), totalDistance: 1250.5, totalTrips: 42)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = StatsEntry(date: Date(), totalDistance: 1250.5, totalTrips: 42)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct StatsEntry: TimelineEntry {
    let date: Date
    let totalDistance: Double
    let totalTrips: Int
}

struct StatsWidgetEntryView: View {
    var entry: StatsProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MCVenture Stats")
                .font(.headline)
                .foregroundColor(.orange)
            
            HStack {
                Image(systemName: "road.lanes")
                    .foregroundColor(.blue)
                Text("\(String(format: "%.1f", entry.totalDistance)) km")
                    .font(.title2.bold())
            }
            
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(.green)
                Text("\(entry.totalTrips) trips")
                    .font(.subheadline)
            }
        }
        .padding()
    }
}

struct NextRideWidget: Widget {
    let kind: String = "NextRideWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextRideProvider()) { entry in
            NextRideWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Ride")
        .description("Your upcoming ride details")
        .supportedFamilies([.systemMedium])
    }
}

struct NextRideProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextRideEntry {
        NextRideEntry(date: Date(), rideName: "Loading...", rideDate: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (NextRideEntry) -> ()) {
        let entry = NextRideEntry(date: Date(), rideName: "Norwegian Fjords Tour", rideDate: Date().addingTimeInterval(86400))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = NextRideEntry(date: Date(), rideName: "Norwegian Fjords Tour", rideDate: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct NextRideEntry: TimelineEntry {
    let date: Date
    let rideName: String
    let rideDate: Date
}

struct NextRideWidgetEntryView: View {
    var entry: NextRideProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.orange)
                Text("Next Ride")
                    .font(.headline)
            }
            
            Text(entry.rideName)
                .font(.title3.bold())
            
            Text(entry.rideDate, style: .relative)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

@main
struct MCVentureWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StatsWidget()
        NextRideWidget()
    }
}
