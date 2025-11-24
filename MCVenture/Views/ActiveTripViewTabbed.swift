import SwiftUI
import MapKit

struct ActiveTripViewTabbed: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gpsManager = GPSTrackingManager.shared
    @StateObject private var voiceAnnouncer = VoiceAnnouncer()
    @StateObject private var weatherManager = WeatherManager.shared
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedTab = 0
    @State private var showFinishAlert = false
    @State private var selectedMotorcycle: MotorcycleProfile?
    @State private var fuelPricePerLiter: String = ""
    @State private var isPaused = false
    @State private var showWaypointPicker = false
    @State private var showCamera = false
    @State private var showSOSAlert = false
    @State private var showCrashAlert = false
    
    #if os(iOS)
    @StateObject private var photoCaptureManager = PhotoCaptureManager.shared
    #endif
    
    var body: some View {
        mainContentView
            .onAppear {
                loadMotorcycle()
                gpsManager.startTracking()
                voiceAnnouncer.announceStart()
                // Keep screen on during active trip
                UIApplication.shared.isIdleTimerDisabled = true
                // Start weather monitoring
                if let location = gpsManager.currentLocation {
                    let singlePoint = [location.coordinate]
                    weatherManager.startWeatherMonitoring(route: singlePoint)
                }
            }
        .onChange(of: gpsManager.currentLocation) { newLocation in
            // Update weather monitoring with new location
            if let location = newLocation {
                let path = gpsManager.routeCoordinates.isEmpty ? [location.coordinate] : gpsManager.routeCoordinates
                Task {
                    await weatherManager.checkWeatherAlerts(along: path)
                }
            }
        }
        .onChange(of: gpsManager.safetyMonitor.crashDetected) { newValue in
            if newValue {
                showCrashAlert = true
                voiceAnnouncer.announceCrashDetected()
            }
        }
        .alert("Crash Detected!", isPresented: $showCrashAlert) {
            Button("I'm OK") {
                gpsManager.safetyMonitor.resetCrashDetection()
            }
            Button("Call Emergency", role: .destructive) {
                if let location = gpsManager.currentLocation {
                    gpsManager.safetyMonitor.activateSOS(location: location)
                }
            }
        } message: {
            Text("Are you okay? Emergency services can be contacted if needed.")
        }
        .alert("Emergency SOS", isPresented: $showSOSAlert) {
            Button("Cancel", role: .cancel) {
                gpsManager.safetyMonitor.deactivateSOS()
            }
            Button("Activate SOS", role: .destructive) {
                if let location = gpsManager.currentLocation {
                    gpsManager.safetyMonitor.activateSOS(location: location)
                }
            }
        } message: {
            Text("This will share your location and contact emergency services.")
        }
        .alert("Finish Trip?", isPresented: $showFinishAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Finish", role: .destructive) {
                finishTrip()
            }
        } message: {
            Text("Are you sure you want to end this trip?")
        }
        .sheet(isPresented: $showWaypointPicker) {
            waypointPickerSheet
        }
        #if os(iOS)
        .sheet(isPresented: $showCamera) {
            TripCameraView { image in
                if let location = gpsManager.currentLocation, let tripId = gpsManager.currentTripId {
                    photoCaptureManager.capturePhoto(for: tripId, image: image, location: location)
                }
            }
        }
        #endif
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tab Selector
                tabSelector
                
                // Tab Content
                tabContentView
            }
            
            // Floating Action Buttons
            floatingActionButtons
        }
    }
    
    // MARK: - Tab Content
    private var tabContentView: some View {
        TabView(selection: $selectedTab) {
            statsTabView
                .tag(0)
            
            mapTabView
                .tag(1)
            
            detailsTabView
                .tag(2)
            
            if gpsManager.proModeManager.isProModeEnabled {
                proStatsTabView
                    .tag(3)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { showFinishAlert = true }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("TRACKING")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                
                if gpsManager.isPaused {
                    Text("PAUSED")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            Button(action: {
                if isPaused {
                    gpsManager.resumeTracking()
                    voiceAnnouncer.announceResumed()
                } else {
                    gpsManager.pauseTracking()
                    voiceAnnouncer.announcePaused()
                }
                isPaused.toggle()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
            }
        }
        .padding()
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Stats", icon: "chart.bar.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Map", icon: "map.fill", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Details", icon: "info.circle.fill", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            if gpsManager.proModeManager.isProModeEnabled {
                TabButton(title: "Pro", icon: "gauge.high", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Stats Tab
    private var statsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weather Alerts
                if !weatherManager.currentWeatherAlerts.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(weatherManager.currentWeatherAlerts.prefix(2)) { alert in
                            WeatherAlertBanner(alert: alert)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Primary Stats
                TripStatCard(
                    icon: "road.lanes",
                    title: "DISTANCE",
                    value: String(format: "%.2f", gpsManager.tripDistance),
                    unit: "km",
                    color: .orange
                )
                
                TripStatCard(
                    icon: "timer",
                    title: "DURATION",
                    value: formatDuration(gpsManager.tripDuration),
                    unit: "",
                    color: .blue
                )
                
                HStack(spacing: 15) {
                    TripStatCard(
                        icon: "speedometer",
                        title: "CURRENT",
                        value: String(format: "%.0f", gpsManager.currentSpeed),
                        unit: "km/h",
                        color: .green
                    )
                    
                    TripStatCard(
                        icon: "gauge.medium",
                        title: "AVERAGE",
                        value: String(format: "%.0f", gpsManager.averageSpeed),
                        unit: "km/h",
                        color: .purple
                    )
                }
                
                TripStatCard(
                    icon: "bolt.fill",
                    title: "MAX SPEED",
                    value: String(format: "%.0f", gpsManager.maxSpeed),
                    unit: "km/h",
                    color: .red
                )
                
                // Elevation Stats
                HStack(spacing: 15) {
                    TripStatCard(
                        icon: "arrow.up.forward",
                        title: "GAIN",
                        value: String(format: "%.0f", gpsManager.elevationTracker.elevationGain),
                        unit: "m",
                        color: .green
                    )
                    
                    TripStatCard(
                        icon: "arrow.down.forward",
                        title: "LOSS",
                        value: String(format: "%.0f", gpsManager.elevationTracker.elevationLoss),
                        unit: "m",
                        color: .orange
                    )
                }
                
                TripStatCard(
                    icon: "mountain.2.fill",
                    title: "ALTITUDE",
                    value: String(format: "%.0f", gpsManager.elevationTracker.currentAltitude),
                    unit: "m",
                    color: .purple
                )
                
                // Advanced Stats
                HStack(spacing: 15) {
                    TripStatCard(
                        icon: "flame.fill",
                        title: "CALORIES",
                        value: String(format: "%.0f", gpsManager.calories),
                        unit: "kcal",
                        color: .orange
                    )
                    
                    TripStatCard(
                        icon: "leaf.fill",
                        title: "CO₂ SAVED",
                        value: String(format: "%.2f", gpsManager.carbonSaved),
                        unit: "kg",
                        color: .green
                    )
                }
                
                // Fuel Cost (if motorcycle selected)
                if let motorcycle = selectedMotorcycle, !fuelPricePerLiter.isEmpty,
                   let fuelPrice = Double(fuelPricePerLiter) {
                    let fuelUsed = (gpsManager.tripDistance * motorcycle.fuelConsumption) / 100.0
                    let fuelCost = fuelUsed * fuelPrice
                    
                    HStack(spacing: 15) {
                        TripStatCard(
                            icon: "fuelpump.fill",
                            title: "FUEL USED",
                            value: String(format: "%.2f", fuelUsed),
                            unit: "L",
                            color: .yellow
                        )
                        
                        TripStatCard(
                            icon: "creditcard.fill",
                            title: "FUEL COST",
                            value: String(format: "%.0f", fuelCost),
                            unit: "kr",
                            color: .red
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Map Tab
    private var mapTabView: some View {
        LiveMapView(gpsManager: gpsManager)
    }
    
    // MARK: - Pro Stats Tab
    private var proStatsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // G-Force Meter
                if gpsManager.proModeManager.gForceEnabled {
                    GForceMeter(
                        gForce: gpsManager.proModeManager.gForceTracker.currentGForce,
                        maxGForce: gpsManager.proModeManager.gForceTracker.maxGForce
                    )
                }
                
                // Lean Angle Gauge
                if gpsManager.proModeManager.leanAngleEnabled {
                    LeanAngleGauge(
                        currentAngle: gpsManager.proModeManager.leanAngleTracker.currentLeanAngle,
                        maxLeft: gpsManager.proModeManager.leanAngleTracker.maxLeftLean,
                        maxRight: gpsManager.proModeManager.leanAngleTracker.maxRightLean
                    )
                }
                
                // Corner Stats
                if gpsManager.proModeManager.cornerAnalysisEnabled && !gpsManager.proModeManager.cornerAnalyzer.corners.isEmpty {
                    CornerStatsWidget(corners: gpsManager.proModeManager.cornerAnalyzer.corners)
                }
                
                // Lap Timer
                if gpsManager.proModeManager.lapTimingEnabled {
                    LapTimerWidget(lapTimer: gpsManager.proModeManager.lapTimer)
                }
                
                // Surface Quality
                if gpsManager.proModeManager.surfaceDetectionEnabled {
                    SurfaceQualityWidget(
                        quality: gpsManager.proModeManager.surfaceDetector.currentQuality,
                        potholeCount: gpsManager.proModeManager.surfaceDetector.potholeCount
                    )
                }
                
                // AI Insights
                if !gpsManager.proModeManager.cornerAnalyzer.corners.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AI INSIGHTS")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        let style = gpsManager.proModeManager.getRidingStyleAnalysis(
                            avgSpeed: gpsManager.averageSpeed,
                            corners: gpsManager.proModeManager.cornerAnalyzer.corners,
                            maxLean: max(abs(gpsManager.proModeManager.leanAngleTracker.maxLeftLean),
                                       gpsManager.proModeManager.leanAngleTracker.maxRightLean)
                        )
                        
                        Text("Riding Style: \(style.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        let tips = gpsManager.proModeManager.getSkillSuggestions(
                            corners: gpsManager.proModeManager.cornerAnalyzer.corners,
                            gForceData: gpsManager.proModeManager.gForceTracker.gForceHistory
                        )
                        
                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Details Tab
    private var detailsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Waypoints
                if !gpsManager.waypoints.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WAYPOINTS (\(gpsManager.waypoints.count))")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        ForEach(gpsManager.waypoints) { waypoint in
                            WaypointRow(waypoint: waypoint)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
                
                // Photos
                #if os(iOS)
                if let tripId = gpsManager.currentTripId {
                    let tripPhotos = photoCaptureManager.getPhotos(for: tripId)
                    if !tripPhotos.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PHOTOS (\(tripPhotos.count))")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(tripPhotos) { photo in
                                        if let image = UIImage(data: photo.imageData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                }
                #endif
                
                // Speed Zones
                VStack(alignment: .leading, spacing: 10) {
                    Text("TIME IN SPEED ZONES")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    ForEach(["0-30", "30-60", "60-90", "90+"], id: \.self) { zone in
                        HStack {
                            Text(zone + " km/h")
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(formatDuration(gpsManager.speedZones[zone] ?? 0))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)
                
                // Fuel Price Input
                if selectedMotorcycle != nil {
                    VStack(spacing: 10) {
                        Text("FUEL PRICE")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        HStack {
                            TextField("Price per liter", text: $fuelPricePerLiter)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("kr/L")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
                
                // Weather (commented out - using route-based weather)
                /*
                if let weather = weatherManager.currentWeather {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WEATHER")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("\(Int(weather.temperature))°C")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                Text(weather.condition)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Image(systemName: "wind")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(Int(weather.windSpeed)) km/h")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                HStack {
                                    Image(systemName: "humidity")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(Int(weather.humidity))%")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                }
                */
                
                // Battery Warning
                if gpsManager.safetyMonitor.lowBattery {
                    HStack {
                        Image(systemName: "battery.25")
                            .foregroundColor(.red)
                        Text("Low Battery - \(Int(gpsManager.safetyMonitor.batteryLevel * 100))%")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(15)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Floating Action Buttons
    private var floatingActionButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 15) {
                    // Add Waypoint
                    FloatingActionButton(icon: "mappin.and.ellipse", color: .blue) {
                        showWaypointPicker = true
                    }
                    
                    // Take Photo
                    #if os(iOS)
                    FloatingActionButton(icon: "camera.fill", color: .purple) {
                        showCamera = true
                    }
                    #endif
                    
                    // Emergency SOS
                    FloatingActionButton(icon: "exclamationmark.triangle.fill", color: .red) {
                        showSOSAlert = true
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Waypoint Picker Sheet
    private var waypointPickerSheet: some View {
            List {
                ForEach([
                    TripWaypointType.gasStation,
                    .restStop,
                    .photo,
                    .viewpoint,
                    .food,
                    .danger,
                    .custom
                ], id: \.self) { type in
                    Button(action: {
                        gpsManager.addWaypoint(type: type)
                        voiceAnnouncer.announceWaypointAdded(type)
                        showWaypointPicker = false
                    }) {
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundStyle(type.color)
                                .frame(width: 30)
                            Text(type.rawValue.capitalized)
                        }
                    }
                }
            }
            .navigationTitle("Add Waypoint")
            .navigationBarItems(trailing: Button("Cancel") {
                showWaypointPicker = false
            })
    }
    
    // MARK: - Helper Methods
    private func loadMotorcycle() {
        if let motorcycleId = UserDefaults.standard.string(forKey: "selectedMotorcycleId"),
           let id = UUID(uuidString: motorcycleId) {
            selectedMotorcycle = dataManager.motorcycles.first { $0.id == id }
        }
    }
    
    private func finishTrip() {
        guard let summary = gpsManager.stopTracking() else {
            dismiss()
            return
        }
        
        guard summary.distance > 0 else {
            dismiss()
            return
        }
        
        voiceAnnouncer.announceFinish(distance: summary.distance, duration: summary.duration)
        
        let fuelPrice = Double(fuelPricePerLiter) ?? 0.0
        let fuelUsed = selectedMotorcycle != nil ? (summary.distance * selectedMotorcycle!.fuelConsumption) / 100.0 : 0
        let fuelCost = fuelUsed * fuelPrice
        
        let trip = CompletedTrip(
            id: UUID(),
            routeName: "GPS Tracked Trip",
            country: "Unknown",
            date: summary.startTime,
            distanceKm: summary.distance,
            duration: summary.duration,
            fuelCost: fuelCost,
            averageSpeed: summary.averageSpeed,
            photoURLs: [],
            rating: 0,
            notes: "Max: \(Int(summary.maxSpeed)) km/h | Elevation: +\(Int(summary.elevationGain))m/-\(Int(summary.elevationLoss))m | Calories: \(Int(summary.calories)) | CO₂ saved: \(String(format: "%.2f", summary.carbonSaved)) kg",
            weatherCondition: "" // Weather commented out
        )
        
        dataManager.addCompletedTrip(trip)
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .orange : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.orange.opacity(0.2) : Color.clear)
            .cornerRadius(10)
        }
    }
}

struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

struct WaypointRow: View {
    let waypoint: TripWaypoint
    
    var body: some View {
        HStack {
            Image(systemName: waypoint.type.icon)
                .foregroundColor(waypoint.type.color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(waypoint.type.rawValue.capitalized)
                    .foregroundColor(.white)
                Text(waypoint.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}
