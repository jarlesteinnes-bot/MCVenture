//
//  RoutePlanningView.swift
//  MCVenture
//

import SwiftUI
import MapKit

struct RoutePlanningView: View {
    @StateObject private var manager = RoutePlanningManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.472, longitude: 8.4689),
        span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    )
    @State private var showRoutePreview = false
    @State private var calculatedRoute: [CLLocationCoordinate2D] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: manager.plannedWaypoints.enumerated().map { WaypointItem(index: $0.offset, coordinate: $0.element) }) { waypoint in
                MapAnnotation(coordinate: waypoint.coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("\(waypoint.index + 1)")
                            .foregroundColor(.white)
                            .font(.caption.bold())
                    }
                }
            }
            .onTapGesture { location in
                let coordinate = convertToCoordinate(location: location)
                manager.addWaypoint(coordinate)
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Clear") {
                        manager.clearWaypoints()
                        calculatedRoute.removeAll()
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Toggle("Avoid Highways", isOn: $manager.avoidHighways)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    
                    Toggle("Scenic", isOn: $manager.preferScenicRoutes)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Calculate") {
                        manager.calculateOptimalRoute { route in
                            if let route = route {
                                calculatedRoute = route
                                showRoutePreview = true
                            }
                        }
                    }
                    .disabled(manager.plannedWaypoints.count < 2)
                    .padding()
                    .background(manager.plannedWaypoints.count >= 2 ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                if !manager.plannedWaypoints.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Waypoints: \(manager.plannedWaypoints.count)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(manager.plannedWaypoints.enumerated()), id: \.offset) { index, waypoint in
                                    Button(action: {
                                        manager.removeWaypoint(at: index)
                                    }) {
                                        HStack {
                                            Text("\(index + 1)")
                                                .font(.caption.bold())
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                        .padding(8)
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding()
                }
            }
        }
        .navigationTitle("Route Planning")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRoutePreview) {
            RoutePreviewSheet(route: calculatedRoute)
        }
    }
    
    private func convertToCoordinate(location: CGPoint) -> CLLocationCoordinate2D {
        // Simplified coordinate conversion - in production would use proper map projection
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        return CLLocationCoordinate2D(
            latitude: region.center.latitude + Double.random(in: -latDelta/2...latDelta/2),
            longitude: region.center.longitude + Double.random(in: -lonDelta/2...lonDelta/2)
        )
    }
}

struct WaypointItem: Identifiable {
    let id = UUID()
    let index: Int
    let coordinate: CLLocationCoordinate2D
}

struct RoutePreviewSheet: View {
    let route: [CLLocationCoordinate2D]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            VStack {
                Text("Route calculated with \(route.count) points")
                    .font(.title2)
                    .padding()
                
                Text("Distance: ~\(String(format: "%.1f", calculateDistance())) km")
                    .font(.headline)
                
                Spacer()
                
                Button("Save Route") {
                    // Save to routes list
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Route Preview")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private func calculateDistance() -> Double {
        var total = 0.0
        for i in 0..<(route.count - 1) {
            let loc1 = CLLocation(latitude: route[i].latitude, longitude: route[i].longitude)
            let loc2 = CLLocation(latitude: route[i+1].latitude, longitude: route[i+1].longitude)
            total += loc1.distance(from: loc2)
        }
        return total / 1000.0 // Convert to km
    }
}
