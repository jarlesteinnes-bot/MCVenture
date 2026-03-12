//
//  RoutePlanningHelpers.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import CoreLocation
import MapKit
import UIKit

// MARK: - Add Waypoint View

struct AddWaypointView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var route: RoutePlan
    @State private var waypointName = ""
    @State private var waypointType: RouteWaypoint.WaypointType = .waypoint
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522)
    @State private var address = ""
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
            Form {
                Section(header: Text("Waypoint Details")) {
                    TextField("Name", text: $waypointName)
                    
                    Picker("Type", selection: $waypointType) {
                        ForEach(RouteWaypoint.WaypointType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Location")) {
                    TextField("Search location", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    Map(coordinateRegion: $region, interactionModes: .all, annotationItems: [selectedCoordinate]) { coord in
                        MapPin(coordinate: coord, tint: waypointType.color)
                    }
                    .frame(height: 250)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Latitude: \(selectedCoordinate.latitude, specifier: "%.6f")")
                            .font(.caption)
                        Text("Longitude: \(selectedCoordinate.longitude, specifier: "%.6f")")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    TextField("Address (optional)", text: $address)
                }
                
                Section {
                    Button(action: addWaypoint) {
                        HStack {
                            Spacer()
                            Text("Add Waypoint")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(waypointName.isEmpty)
                }
            }
            .navigationTitle("Add Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
    }
    
    private func addWaypoint() {
        let waypoint = RouteWaypoint(
            name: waypointName,
            coordinate: selectedCoordinate,
            type: waypointType,
            address: address.isEmpty ? nil : address
        )
        
        route.waypoints.append(waypoint)
        dismiss()
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude),\(longitude)"
    }
}

// MARK: - Route Preferences View

struct RoutePreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var route: RoutePlan
    @State private var roadPreferences: RoadPreferences
    @State private var scheduledDate: Date
    @State private var departureTime: Date
    @State private var useScheduledDate = false
    @State private var useDepartureTime = false
    
    init(route: Binding<RoutePlan>) {
        self._route = route
        self._roadPreferences = State(initialValue: route.wrappedValue.roadPreferences)
        self._scheduledDate = State(initialValue: route.wrappedValue.scheduledDate ?? Date())
        self._departureTime = State(initialValue: route.wrappedValue.departureTime ?? Date())
        self._useScheduledDate = State(initialValue: route.wrappedValue.scheduledDate != nil)
        self._useDepartureTime = State(initialValue: route.wrappedValue.departureTime != nil)
    }
    
    var body: some View {
            Form {
                Section(header: Text("Route Name")) {
                    TextField("Route Name", text: Binding(
                        get: { route.name },
                        set: { route.name = $0 }
                    ))
                }
                
                Section(header: Text("Road Preferences")) {
                    Toggle("Avoid Highways", isOn: $roadPreferences.avoidHighways)
                    Toggle("Avoid Tolls", isOn: $roadPreferences.avoidTolls)
                    Toggle("Avoid Ferries", isOn: $roadPreferences.avoidFerries)
                    Toggle("Avoid Unpaved Roads", isOn: $roadPreferences.avoidUnpavedRoads)
                }
                
                Section(header: Text("Motorcycle Preferences")) {
                    Toggle("Prefer Scenic Roads", isOn: $roadPreferences.preferScenicRoads)
                    Toggle("Prefer Twisty Roads", isOn: $roadPreferences.preferTwistyRoads)
                    
                    Picker("Minimum Road Width", selection: $roadPreferences.minimumRoadWidth) {
                        ForEach(RoadPreferences.RoadWidth.allCases, id: \.self) { width in
                            Text(width.rawValue).tag(width)
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    Toggle("Schedule for specific date", isOn: $useScheduledDate)
                    
                    if useScheduledDate {
                        DatePicker("Date", selection: $scheduledDate, displayedComponents: .date)
                    }
                    
                    Toggle("Set departure time", isOn: $useDepartureTime)
                    
                    if useDepartureTime {
                        DatePicker("Departure", selection: $departureTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Sharing")) {
                    Toggle("Make route public", isOn: Binding(
                        get: { route.isPublic },
                        set: { route.isPublic = $0 }
                    ))
                    
                    if route.isPublic {
                        Text("Other riders will be able to see and use this route")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Route Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        savePreferences()
                        dismiss()
                    }
                }
            }
    }
    
    private func savePreferences() {
        route.roadPreferences = roadPreferences
        route.scheduledDate = useScheduledDate ? scheduledDate : nil
        route.departureTime = useDepartureTime ? departureTime : nil
    }
}

// MARK: - Route Export View

struct RouteExportView: View {
    @Environment(\.dismiss) var dismiss
    let route: RoutePlan
    @State private var exportFormat: ExportFormat = .gpx
    @State private var showingShareSheet = false
    @State private var exportedContent = ""
    
    enum ExportFormat: String, CaseIterable {
        case gpx = "GPX (GPS Exchange)"
        case kml = "KML (Google Earth)"
        case json = "JSON"
        case text = "Text Summary"
        
        var fileExtension: String {
            switch self {
            case .gpx: return "gpx"
            case .kml: return "kml"
            case .json: return "json"
            case .text: return "txt"
            }
        }
    }
    
    var body: some View {
            Form {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Route Summary")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(route.name)
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            Label("\(String(format: "%.1f", route.totalDistance)) km", systemImage: "arrow.left.and.right")
                            Label(formatDuration(route.estimatedDuration), systemImage: "clock")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text("\(route.waypoints.count) waypoints")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: { exportRoute() }) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Route")
                            Spacer()
                        }
                    }
                    
                    Button(action: { saveToFiles() }) {
                        HStack {
                            Spacer()
                            Image(systemName: "folder.badge.plus")
                            Text("Save to Files")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Export Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if !exportedContent.isEmpty {
                    RoutePlanShareSheet(items: [exportedContent])
                }
            }
    }
    
    private func exportRoute() {
        switch exportFormat {
        case .gpx:
            exportedContent = RoutePlannerManager.shared.exportToGPX(route)
        case .kml:
            exportedContent = generateKML()
        case .json:
            exportedContent = generateJSON()
        case .text:
            exportedContent = generateTextSummary()
        }
        
        showingShareSheet = true
    }
    
    private func saveToFiles() {
        exportRoute()
        // In a real app, would use document picker to save
    }
    
    private func generateKML() -> String {
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(route.name)</name>
            <Placemark>
              <name>\(route.name)</name>
              <LineString>
                <coordinates>
        """
        
        for waypoint in route.waypoints {
            kml += "\(waypoint.coordinate.longitude),\(waypoint.coordinate.latitude),0\n"
        }
        
        kml += """
                </coordinates>
              </LineString>
            </Placemark>
          </Document>
        </kml>
        """
        
        return kml
    }
    
    private func generateJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(route),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
    
    private func generateTextSummary() -> String {
        var summary = """
        Route: \(route.name)
        Distance: \(String(format: "%.1f", route.totalDistance)) km
        Duration: \(formatDuration(route.estimatedDuration))
        Elevation Gain: \(Int(route.elevationGain)) m
        Difficulty: \(String(format: "%.1f", route.difficultyRating))/10
        
        Waypoints:
        
        """
        
        for (index, waypoint) in route.waypoints.enumerated() {
            summary += "\(index + 1). \(waypoint.name) (\(waypoint.type.rawValue))\n"
            if let address = waypoint.address {
                summary += "   \(address)\n"
            }
        }
        
        return summary
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

// MARK: - Share Sheet

struct RoutePlanShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AddWaypointView(route: .constant(RoutePlan(name: "Test")))
}
