//
//  LiveMapView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import MapKit
import UIKit

struct LiveMapView: View {
    @ObservedObject var gpsManager: GPSTrackingManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapType: MKMapType = .standard
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: gpsManager.waypoints) { waypoint in
                MapAnnotation(coordinate: waypoint.coordinate) {
                    WaypointMarker(waypoint: waypoint)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onReceive(gpsManager.$currentLocation) { location in
                if let location = location {
                    region.center = location.coordinate
                }
            }
            
            // Map type toggle
            VStack(spacing: 10) {
                Button(action: { cycleMapType() }) {
                    Image(systemName: mapTypeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                
                Button(action: { centerOnUser() }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            // Disable idle timer when map is visible
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            // Re-enable idle timer when map is hidden (only if not tracking)
            if !gpsManager.isTracking {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    private var mapTypeIcon: String {
        switch mapType {
        case .standard: return "map"
        case .satellite: return "globe"
        case .hybrid: return "map.fill"
        default: return "map"
        }
    }
    
    private func cycleMapType() {
        switch mapType {
        case .standard:
            mapType = .satellite
        case .satellite:
            mapType = .hybrid
        default:
            mapType = .standard
        }
    }
    
    private func centerOnUser() {
        if let location = gpsManager.currentLocation {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
}

struct WaypointMarker: View {
    let waypoint: TripWaypoint
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: waypoint.type.icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(colorForType(waypoint.type))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            if !waypoint.note.isEmpty {
                Text(waypoint.note)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
            }
        }
    }
    
    private func colorForType(_ type: TripWaypointType) -> Color {
        switch type {
        case .gasStation: return .blue
        case .restStop: return .green
        case .photo: return .purple
        case .viewpoint: return .orange
        case .food: return .red
        case .danger: return .yellow
        case .custom: return .gray
        }
    }
}

#Preview {
    LiveMapView(gpsManager: GPSTrackingManager.shared)
}
