//
//  RouteDetailView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine
import UIKit

struct RouteDetailView: View {
    let route: EuropeanRoute
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager.shared
    @State private var showingMap = false
    @State private var currentDistance: Double = 0
    @State private var currentCost: Double = 0
    @State private var isTracking = false
    @State private var showingAddToMaps = false
    @State private var isNavigating = false
    @State private var currentLocationName = "Finding location..."
    @State private var showingActiveTrip = false
    @EnvironmentObject var dataManager: DataManager
    
    var fuelRange: Double {
        guard let motorcycle = UserProfileManager.shared.profile.selectedMotorcycle else {
            return 300 // Default fallback
        }
        // Assuming average tank size of 15-20L
        let averageTankSize = 18.0
        return (averageTankSize / motorcycle.fuelConsumption) * 100
    }
    
    var numberOfFuelStops: Int {
        Int(ceil(route.distanceKm / fuelRange))
    }
    
    var fuelStopIntervals: [Double] {
        var stops: [Double] = []
        var distance = fuelRange * 0.9 // Stop at 90% of range for safety
        while distance < route.distanceKm {
            stops.append(distance)
            distance += fuelRange * 0.9
        }
        return stops
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image Placeholder
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 200)
                    
                    VStack {
                        Text(route.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(route.country)
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Weather Alerts
                    if !weatherManager.currentWeatherAlerts.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(weatherManager.currentWeatherAlerts.prefix(3)) { alert in
                                WeatherAlertBanner(alert: alert)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Best Departure Time
                    if let bestTime = weatherManager.bestDepartureTime {
                        BestDepartureTimeWidget(bestTime: bestTime)
                            .padding(.horizontal)
                    }
                    
                    // Route Weather Forecast
                    if !weatherManager.routeWeatherForecast.isEmpty {
                        RouteWeatherForecastCard(forecast: weatherManager.routeWeatherForecast)
                            .padding(.horizontal)
                    }
                    
                    // Gear Recommendations
                    if !weatherManager.gearRecommendations.isEmpty {
                        GearRecommendationsView(recommendations: weatherManager.gearRecommendations)
                            .padding(.horizontal)
                    }
                    
                    // Quick Stats
                    HStack(spacing: 20) {
                        StatCard(icon: "road.lanes", title: "Distance", value: "\(Int(route.distanceKm)) km")
                        StatCard(icon: "speedometer", title: "Difficulty", value: route.difficulty.rawValue)
                        StatCard(icon: "fuel.fill", title: "Fuel Cost", value: route.fuelCostFormatted)
                    }
                    
                    // Route Information
                    GroupBox(label: Label("Route Information", systemImage: "info.circle.fill")) {
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(label: "Description", value: route.description)
                            Divider()
                            InfoRow(label: "Start Point", value: route.startPoint)
                            InfoRow(label: "End Point", value: route.endPoint)
                            InfoRow(label: "Best Months", value: route.bestMonths)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Highlights
                    GroupBox(label: Label("Route Highlights", systemImage: "star.fill")) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(route.highlights, id: \.self) { highlight in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(highlight)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Fuel Calculation
                    if let motorcycle = UserProfileManager.shared.profile.selectedMotorcycle {
                        GroupBox(label: Label("Fuel Planning", systemImage: "fuelpump.fill")) {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Your Motorcycle", value: "\(motorcycle.brand) \(motorcycle.model)")
                                InfoRow(label: "Fuel Consumption", value: "\(String(format: "%.1f", motorcycle.fuelConsumption)) L/100km")
                                InfoRow(label: "Estimated Fuel Needed", value: String(format: "%.1f L", (route.distanceKm * motorcycle.fuelConsumption / 100)))
                                InfoRow(label: "Fuel Range", value: "\(Int(fuelRange)) km")
                                InfoRow(label: "Recommended Fuel Stops", value: "\(numberOfFuelStops) stop(s)")
                                
                                if !fuelStopIntervals.isEmpty {
                                    Divider()
                                    Text("Suggested fuel stop locations:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(fuelStopIntervals, id: \.self) { distance in
                                        HStack {
                                            Image(systemName: "fuelpump.circle.fill")
                                                .foregroundColor(.orange)
                                            Text("Around \(Int(distance)) km")
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } else {
                        GroupBox {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Please select a motorcycle in your profile to see fuel calculations")
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Live Tracking Stats (when tracking)
                    if isTracking {
                        GroupBox(label: Label("Live Tracking", systemImage: "location.fill")) {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Distance Ridden", value: String(format: "%.1f km", currentDistance))
                                InfoRow(label: "Current Cost", value: String(format: "%.0f kr", currentCost))
                                InfoRow(label: "Remaining", value: String(format: "%.1f km", max(0, route.distanceKm - currentDistance)))
                                
                                // Fuel warning
                                let nextFuelStop = fuelStopIntervals.first(where: { $0 > currentDistance }) ?? route.distanceKm
                                let distanceToFuelStop = nextFuelStop - currentDistance
                                
                                if distanceToFuelStop < 50 && distanceToFuelStop > 0 {
                                    Divider()
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text("Fuel stop recommended in \(Int(distanceToFuelStop)) km")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Primary Button: Navigate + Track
                        Button(action: {
                            startNavigationAndTracking()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "location.fill.viewfinder")
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Navigate & Track")
                                        .font(.headline)
                                    Text("Apple Maps + GPS Tracking")
                                        .font(.caption)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        
                        HStack(spacing: 12) {
                            // Apple Maps Only
                            Button(action: {
                                openInAppleMaps()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "map.fill")
                                        .font(.title3)
                                    Text("Apple Maps")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                            
                            // View Map
                            Button(action: {
                                showingMap = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "map")
                                        .font(.title3)
                                    Text("View Map")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(10)
                            }
                            
                            // Track Only
                            Button(action: {
                                if isTracking {
                                    stopTracking()
                                } else {
                                    startTracking()
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: isTracking ? "stop.fill" : "play.fill")
                                        .font(.title3)
                                    Text(isTracking ? "Stop" : "Track")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isTracking ? Color.red.opacity(0.15) : Color.purple.opacity(0.15))
                                .foregroundColor(isTracking ? .red : .purple)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingMap) {
            RouteMapView(route: route, locationManager: locationManager, isTracking: $isTracking)
        }
        .onAppear {
            // Keep screen awake when viewing route details
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Start location updates immediately
            locationManager.startLocationUpdates()
            
            // Generate approximate route coordinates for weather
            let geocoder = CLGeocoder()
            Task {
                do {
                    let startPlacemarks = try await geocoder.geocodeAddressString("\(route.startPoint), \(route.country)")
                    let endPlacemarks = try await geocoder.geocodeAddressString("\(route.endPoint), \(route.country)")
                    
                    if let startLocation = startPlacemarks.first?.location,
                       let endLocation = endPlacemarks.first?.location {
                        // Generate approximate path for weather
                        var routePoints: [CLLocationCoordinate2D] = []
                        let steps = 10
                        for i in 0...steps {
                            let ratio = Double(i) / Double(steps)
                            let lat = startLocation.coordinate.latitude + (endLocation.coordinate.latitude - startLocation.coordinate.latitude) * ratio
                            let lon = startLocation.coordinate.longitude + (endLocation.coordinate.longitude - startLocation.coordinate.longitude) * ratio
                            routePoints.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        }
                        
                        await weatherManager.generateRouteForecast(route: routePoints)
                        await weatherManager.checkWeatherAlerts(along: routePoints)
                    }
                } catch {
                    print("Failed to geocode route points for weather: \(error)")
                }
            }
            
            if let location = locationManager.userLocation {
                updateLocationName(for: location)
            }
        }
        .onDisappear {
            // Re-enable sleep when leaving route view (unless navigating)
            if !isNavigating {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    func startTracking() {
        isTracking = true
        locationManager.startTracking()
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopTracking()
    }
    
    func weatherIcon(for condition: String) -> String {
        let lowercased = condition.lowercased()
        if lowercased.contains("sun") || lowercased.contains("clear") {
            return "sun.max.fill"
        } else if lowercased.contains("cloud") {
            return "cloud.fill"
        } else if lowercased.contains("rain") {
            return "cloud.rain.fill"
        } else if lowercased.contains("snow") {
            return "cloud.snow.fill"
        } else if lowercased.contains("storm") || lowercased.contains("thunder") {
            return "cloud.bolt.fill"
        } else if lowercased.contains("fog") || lowercased.contains("mist") {
            return "cloud.fog.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
    
    func updateLocationName(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                currentLocationName = "\(city), \(country)"
            }
        }
    }
    
    func startNavigationAndTracking() {
        // Start GPS tracking first
        startTracking()
        isNavigating = true
        
        // Keep screen awake during navigation
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Open Apple Maps with navigation
        openInAppleMaps()
    }
    
    func openInAppleMaps() {
        isNavigating = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Geocode start and end points
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString("\(route.startPoint), \(route.country)") { startPlacemarks, startError in
            geocoder.geocodeAddressString("\(route.endPoint), \(route.country)") { endPlacemarks, endError in
                
                guard let startLocation = startPlacemarks?.first?.location,
                      let endLocation = endPlacemarks?.first?.location else {
                    print("Failed to geocode route points")
                    return
                }
                
                // Create MKMapItems for the route
                let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: startLocation.coordinate))
                startMapItem.name = route.startPoint
                
                let endMapItem = MKMapItem(placemark: MKPlacemark(coordinate: endLocation.coordinate))
                endMapItem.name = route.endPoint
                
                // Configure launch options with driving directions
                let launchOptions: [String: Any] = [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                    MKLaunchOptionsShowsTrafficKey: true
                ]
                
                // Open Apple Maps with turn-by-turn navigation from current location to start, then to end
                // If we're not at the start point, navigate there first
                if let currentLocation = self.locationManager.userLocation {
                    let currentDistance = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude).distance(from: startLocation)
                    
                    // If more than 1km from start point, navigate to start first
                    if currentDistance > 1000 {
                        // Navigate to start point first
                        MKMapItem.openMaps(
                            with: [startMapItem],
                            launchOptions: launchOptions
                        )
                    } else {
                        // Already at start, navigate the full route
                        MKMapItem.openMaps(
                            with: [endMapItem],
                            launchOptions: launchOptions
                        )
                    }
                } else {
                    // No current location, navigate to start point
                    MKMapItem.openMaps(
                        with: [startMapItem],
                        launchOptions: launchOptions
                    )
                }
            }
        }
    }
    
    func openInGoogleMapsDirectly() {
        // Mark as navigating to keep screen awake
        isNavigating = true
        
        // Keep screen awake during navigation
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Use actual GPS coordinates if available, otherwise use place names
        var origin = "current+location"
        if let location = locationManager.userLocation {
            origin = "\(location.latitude),\(location.longitude)"
        }
        
        // Encode the route points for Google Maps URL
        let destination = "\(route.startPoint),\(route.country)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let waypoint = "\(route.endPoint),\(route.country)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Google Maps URL scheme with waypoints for full route
        let googleMapsURL = "comgooglemaps://?saddr=\(origin)&daddr=\(destination)&waypoints=\(waypoint)&directionsmode=driving"
        
        // Fallback to web URL if app not installed
        let webURL = "https://www.google.com/maps/dir/?api=1&origin=\(origin)&destination=\(destination)&waypoints=\(waypoint)&travelmode=driving"
        
        if let url = URL(string: googleMapsURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // If Google Maps failed, try web
                    if let webUrl = URL(string: webURL) {
                        UIApplication.shared.open(webUrl)
                    }
                }
            }
        } else if let url = URL(string: webURL) {
            UIApplication.shared.open(url)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var unit: String = ""
    var color: Color = .blue
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

// Location Manager for live tracking
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var totalDistance: Double = 0
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        manager.startUpdatingLocation()
    }
    
    func startTracking() {
        manager.startUpdatingLocation()
        totalDistance = 0
        lastLocation = nil
    }
    
    func stopTracking() {
        // Keep location updates running, just stop distance tracking
        totalDistance = 0
        lastLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLocation = location.coordinate
        
        if let last = lastLocation {
            let distance = location.distance(from: last) / 1000.0 // Convert to km
            totalDistance += distance
        }
        
        lastLocation = location
    }
}

// Route Map View with gas stations
struct RouteMapView: View {
    let route: EuropeanRoute
    @ObservedObject var locationManager: LocationManager
    @Binding var isTracking: Bool
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion
    @State private var gasStations: [GasStation] = []
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var startCoordinate: CLLocationCoordinate2D?
    @State private var endCoordinate: CLLocationCoordinate2D?
    
    init(route: EuropeanRoute, locationManager: LocationManager, isTracking: Binding<Bool>) {
        self.route = route
        self.locationManager = locationManager
        self._isTracking = isTracking
        
        // Initialize region based on route country
        let initialRegion = Self.getRegionForCountry(route.country)
        self._region = State(initialValue: initialRegion)
    }
    
    static func getRegionForCountry(_ country: String) -> MKCoordinateRegion {
        // Map center coordinates for different countries
        let countryCoordinates: [String: (lat: Double, lon: Double, span: Double)] = [
            "Norway": (61.0, 8.0, 8.0),
            "Italy": (42.8, 12.5, 6.0),
            "Switzerland": (46.8, 8.2, 2.0),
            "France": (46.2, 2.2, 8.0),
            "Spain": (40.4, -3.7, 8.0),
            "Austria": (47.5, 14.5, 3.0),
            "Germany": (51.1, 10.4, 6.0),
            "Portugal": (39.4, -8.2, 4.0),
            "England": (52.5, -1.5, 4.0),
            "Scotland": (56.5, -4.0, 3.0),
            "Wales": (52.3, -3.7, 2.0),
            "Ireland": (53.4, -7.7, 3.0),
            "Greece": (39.0, 22.0, 5.0),
            "Croatia": (45.1, 15.2, 3.0),
            "Sweden": (60.1, 18.6, 8.0),
            "Denmark": (56.2, 9.5, 3.0),
            "Finland": (61.9, 25.7, 6.0),
            "Iceland": (64.9, -19.0, 4.0),
            "Romania": (45.9, 24.9, 4.0)
        ]
        
        let coords = countryCoordinates[country] ?? (48.8, 2.3, 5.0) // Default to central Europe
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lon),
            span: MKCoordinateSpan(latitudeDelta: coords.span, longitudeDelta: coords.span)
        )
    }
    
    var body: some View {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: gasStations) { station in
                    MapAnnotation(coordinate: station.coordinate) {
                        VStack(spacing: 4) {
                            ZStack {
                                // Pulsing ring for recommended stops
                                if station.isRecommended == true {
                                    Circle()
                                        .stroke(Color.green, lineWidth: 3)
                                        .frame(width: 50, height: 50)
                                        .opacity(0.6)
                                }
                                
                                Image(systemName: (station.isRecommended == true) ? "fuelpump.circle.fill" : "fuelpump.fill")
                                    .foregroundColor(.white)
                                    .font((station.isRecommended == true) ? .title2 : .body)
                                    .padding((station.isRecommended == true) ? 12 : 8)
                                    .background((station.isRecommended == true) ? Color.green : Color.orange)
                                    .clipShape(Circle())
                                    .shadow(radius: (station.isRecommended == true) ? 4 : 2)
                            }
                            
                            VStack(spacing: 2) {
                                Text(station.name)
                                    .font(.caption2)
                                    .fontWeight((station.isRecommended == true) ? .bold : .regular)
                                
                                if station.isRecommended == true, let fuelLevel = station.fuelLevelAtArrival {
                                    Text(String(format: "%.1fL", fuelLevel))
                                        .font(.caption2)
                                        .foregroundColor(fuelLevel < 4 ? .red : .green)
                                }
                                
                                Text(String(format: "%.0fkm", station.distanceFromStart ?? 0))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(6)
                            .shadow(radius: 2)
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Start and End point overlays
                if let start = startCoordinate {
                    VStack {
                        Spacer()
                    }
                    .overlay(alignment: .topLeading) {
                        Text("🏁 \(route.startPoint)")
                            .font(.caption)
                            .padding(8)
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 60)
                            .padding(.leading, 10)
                    }
                }
                
                if let end = endCoordinate {
                    VStack {
                        Spacer()
                    }
                    .overlay(alignment: .topTrailing) {
                        Text("🏁 \(route.endPoint)")
                            .font(.caption)
                            .padding(8)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 60)
                            .padding(.trailing, 10)
                    }
                }
                
                // Fuel Info Panel (top)
                VStack {
                    HStack(spacing: 12) {
                        // Recommended stops indicator
                        HStack(spacing: 6) {
                            Image(systemName: "fuelpump.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recommended")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Based on your fuel")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        Divider()
                            .frame(height: 40)
                        
                        // Regular stations indicator
                        HStack(spacing: 6) {
                            Image(systemName: "fuelpump.fill")
                                .foregroundColor(.orange)
                                .font(.body)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Other Stations")
                                    .font(.caption)
                                Text("Along route")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    .padding(.top, 70)
                    
                    Spacer()
                }
                
                // Stats overlay
                if isTracking {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Distance: \(String(format: "%.1f", locationManager.totalDistance)) km")
                                    .font(.headline)
                                Text("Cost: \(String(format: "%.0f", UserProfileManager.shared.calculateFuelCost(distanceKm: locationManager.totalDistance))) kr")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button("Stop") {
                                isTracking = false
                                locationManager.stopTracking()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                    }
                }
            }
            .navigationTitle("Route Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: loadGasStations) {
                        Label("Gas Stations", systemImage: "fuelpump.fill")
                    }
                }
            }
            .onAppear {
                // Keep screen awake while viewing map
                UIApplication.shared.isIdleTimerDisabled = true
                loadRouteCoordinates()
                loadGasStations()
                // Center map on route after a short delay to allow geocoding
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if let start = startCoordinate, let end = endCoordinate {
                        let centerLat = (start.latitude + end.latitude) / 2
                        let centerLon = (start.longitude + end.longitude) / 2
                        let spanLat = abs(start.latitude - end.latitude) * 1.5
                        let spanLon = abs(start.longitude - end.longitude) * 1.5
                        
                        region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.5), longitudeDelta: max(spanLon, 0.5))
                        )
                    }
                }
            }
            .onDisappear {
                // Re-enable idle timer when map is dismissed (only if not tracking)
                if !isTracking {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
    }
    
    func loadRouteCoordinates() {
        // Geocode start and end points
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString("\(route.startPoint), \(route.country)") { placemarks, error in
            if let location = placemarks?.first?.location {
                self.startCoordinate = location.coordinate
            }
        }
        
        geocoder.geocodeAddressString("\(route.endPoint), \(route.country)") { placemarks, error in
            if let location = placemarks?.first?.location {
                self.endCoordinate = location.coordinate
                
                // Generate route path approximation
                if let start = self.startCoordinate {
                    self.routeCoordinates = self.generateRouteApproximation(from: start, to: location.coordinate)
                }
            }
        }
    }
    
    func loadGasStations() {
        // Simulate loading gas stations along the route
        // In a real app, you'd use MapKit's MKLocalSearch or Google Places API
        gasStations = generateMockGasStations()
    }
    
    func generateMockGasStations() -> [GasStation] {
        var stations: [GasStation] = []
        
        guard let start = startCoordinate, let end = endCoordinate else {
            return stations
        }
        
        // Get user's motorcycle fuel data
        let motorcycle = UserProfileManager.shared.profile.selectedMotorcycle
        let fuelConsumption = motorcycle?.fuelConsumption ?? 5.0 // L/100km
        let tankSize = motorcycle?.tankSize ?? 18.0 // Liters
        
        // Calculate safe refuel range (tank capacity - 2L safety buffer)
        let usableCapacity = tankSize - 2.0
        let safeRange = (usableCapacity / fuelConsumption) * 100.0 // km
        let recommendedRefuelDistance = safeRange * 0.85 // Stop at 85% of max range
        
        // Generate gas stations every 40-60km (realistic spacing)
        let stationSpacing = 50.0 // km
        let numberOfStations = max(Int(route.distanceKm / stationSpacing), 2)
        
        var currentFuel = tankSize // Start with full tank
        var distanceTraveled = 0.0
        
        for i in 0...numberOfStations {
            let distanceFromStart = (Double(i) / Double(numberOfStations)) * route.distanceKm
            let ratio = Double(i) / Double(numberOfStations)
            
            // Interpolate between start and end with some random offset for realism
            let latOffset = Double.random(in: -0.02...0.02)
            let lonOffset = Double.random(in: -0.02...0.02)
            let lat = start.latitude + (end.latitude - start.latitude) * ratio + latOffset
            let lon = start.longitude + (end.longitude - start.longitude) * ratio + lonOffset
            
            // Calculate fuel consumed since last station or start
            let segmentDistance = distanceFromStart - distanceTraveled
            let fuelUsed = (segmentDistance / 100.0) * fuelConsumption
            currentFuel -= fuelUsed
            
            // Determine if this station should be recommended
            let isRecommended = currentFuel <= (tankSize * 0.3) || // Less than 30% fuel remaining
                               (distanceFromStart > 0 && distanceFromStart.truncatingRemainder(dividingBy: recommendedRefuelDistance) < stationSpacing)
            
            // Calculate fuel level at arrival
            let fuelAtArrival = max(0, currentFuel)
            
            stations.append(GasStation(
                id: UUID(),
                name: isRecommended ? "⭐ Recommended Stop" : "Gas Station",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                distance: distanceFromStart,
                brand: "Generic",
                estimatedPrice: nil,
                distanceFromStart: distanceFromStart,
                isRecommended: isRecommended,
                fuelLevelAtArrival: isRecommended ? fuelAtArrival : nil
            ))
            
            // If recommended, assume we refuel here
            if isRecommended {
                currentFuel = tankSize // Full tank after refueling
                distanceTraveled = distanceFromStart
            }
        }
        
        return stations
    }
    
    func generateRouteApproximation(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        // Generate approximate route with some curvature
        let steps = 20
        for i in 0...steps {
            let ratio = Double(i) / Double(steps)
            
            // Add slight curve to make it look more realistic
            let midOffset = sin(ratio * .pi) * 0.3
            
            let lat = start.latitude + (end.latitude - start.latitude) * ratio
            let lon = start.longitude + (end.longitude - start.longitude) * ratio + midOffset
            
            coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        
        return coordinates
    }
}

// Simple polyline overlay for route path visualization
struct MapPolylineOverlay: View {
    let coordinates: [CLLocationCoordinate2D]
    
    var body: some View {
        // This is a simplified version - in production use MKPolyline with MapKit
        EmptyView()
    }
}

// GasStation is defined in FuelStopPlanner.swift
