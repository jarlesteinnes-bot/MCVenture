//
//  RoutePlannerView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import MapKit

struct RoutePlannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var plannerManager = RoutePlannerManager.shared
    @State private var currentRoute: RoutePlan
    @State private var showingAddWaypoint = false
    @State private var showingPreferences = false
    @State private var showingDirections = false
    @State private var showingExport = false
    @State private var showingAISuggestions = false
    @State private var showingTemplates = false
    @State private var showingTutorial = false
    @State private var selectedWaypoint: RouteWaypoint?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    @State private var selectedTab = 0
    @State private var viewMode: ViewMode = .guided
    @AppStorage("hasSeenRoutePlannerTutorial") private var hasSeenTutorial = false
    
    enum ViewMode: String, CaseIterable {
        case guided = "Guided"
        case advanced = "Advanced"
        
        var icon: String {
            switch self {
            case .guided: return "hand.raised.fill"
            case .advanced: return "gearshape.2.fill"
            }
        }
        
        var description: String {
            switch self {
            case .guided: return "Step-by-step route creation for new riders"
            case .advanced: return "Full control for experienced riders"
            }
        }
    }
    
    init(route: RoutePlan? = nil) {
        _currentRoute = State(initialValue: route ?? RoutePlan(name: "New Route"))
    }
    
    var body: some View {
            ZStack {
                if viewMode == .guided {
                    guidedModeView
                } else {
                    advancedModeView
                }
                
                // Loading Overlay
                if plannerManager.isCalculating {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16.scaled) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Calculating route...")
                            .font(Font.scaledHeadline())
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle(currentRoute.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12.scaled) {
                        // Mode Toggle
                        Button(action: {
                            withAnimation(.spring()) {
                                viewMode = viewMode == .guided ? .advanced : .guided
                            }
                        }) {
                            Image(systemName: viewMode == .guided ? "gearshape.2" : "hand.raised")
                                .font(.system(size: 18.scaled))
                        }
                        
                        // More Menu
                        Menu {
                            Button(action: { showingTemplates = true }) {
                                Label("Route Templates", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: { showingTutorial = true }) {
                                Label("Quick Tutorial", systemImage: "questionmark.circle")
                            }
                            
                            Divider()
                            
                            Button(action: { showingPreferences = true }) {
                                Label("Route Preferences", systemImage: "slider.horizontal.3")
                            }
                            
                            Button(action: { showingExport = true }) {
                                Label("Export Route", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: saveRoute) {
                                Label("Save Route", systemImage: "folder.fill.badge.plus")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive, action: { dismiss() }) {
                                Label("Discard", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18.scaled))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddWaypoint) {
                AddWaypointView(route: $currentRoute)
            }
            .sheet(isPresented: $showingPreferences) {
                RoutePreferencesView(route: $currentRoute)
            }
            .sheet(isPresented: $showingExport) {
                RouteExportView(route: currentRoute)
            }
            .sheet(isPresented: $showingTemplates) {
                RouteTemplatesView(onSelectTemplate: { template in
                    currentRoute = template
                    recalculateRoute()
                })
            }
            .sheet(isPresented: $showingTutorial) {
                RoutePlannerTutorialView()
            }
            .onAppear {
                if !hasSeenTutorial && currentRoute.waypoints.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingTutorial = true
                        hasSeenTutorial = true
                    }
                }
            }
    }
    
    // MARK: - Guided Mode View
    
    private var guidedModeView: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            guidedModeProgress
            
            ScrollView {
                VStack(spacing: ResponsiveSpacing.large) {
                    // Step 1: Choose Starting Point
                    if currentRoute.waypoints.isEmpty {
                        GuidedStepCard(
                            stepNumber: 1,
                            title: "Choose Your Starting Point",
                            description: "Where will your adventure begin?",
                            icon: "flag.fill",
                            color: .green,
                            isComplete: false
                        ) {
                            Button(action: { showingAddWaypoint = true }) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Set Start Location")
                                }
                                .font(Font.scaledHeadline())
                                .frame(maxWidth: .infinity)
                                .padding(ResponsiveSpacing.medium)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12.scaled)
                            }
                        }
                    }
                    
                    // Step 2: Choose Template or Add Waypoints
                    if currentRoute.waypoints.count >= 1 {
                        GuidedStepCard(
                            stepNumber: 2,
                            title: "Plan Your Route",
                            description: "Add stops along the way or choose a template",
                            icon: "map.fill",
                            color: .blue,
                            isComplete: currentRoute.waypoints.count >= 2
                        ) {
                            VStack(spacing: ResponsiveSpacing.medium) {
                                Button(action: { showingTemplates = true }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("Use Template")
                                    }
                                    .font(Font.scaled(15))
                                    .frame(maxWidth: .infinity)
                                    .padding(ResponsiveSpacing.medium)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10.scaled)
                                }
                                
                                Text("or")
                                    .font(Font.scaledCaption())
                                    .foregroundColor(.secondary)
                                
                                Button(action: { showingAddWaypoint = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Waypoint Manually")
                                    }
                                    .font(Font.scaled(15))
                                    .frame(maxWidth: .infinity)
                                    .padding(ResponsiveSpacing.medium)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10.scaled)
                                }
                            }
                        }
                    }
                    
                    // Current Waypoints
                    if !currentRoute.waypoints.isEmpty {
                        VStack(alignment: .leading, spacing: ResponsiveSpacing.medium) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.blue)
                                Text("Your Route (\(currentRoute.waypoints.count) stops)")
                                    .font(Font.scaledHeadline())
                                Spacer()
                            }
                            .padding(.horizontal, ResponsiveSpacing.medium)
                            
                            ForEach(Array(currentRoute.waypoints.enumerated()), id: \.element.id) { index, waypoint in
                                RoutePlanWaypointRow(waypoint: waypoint, index: index)
                                    .padding(.horizontal, ResponsiveSpacing.medium)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeWaypoint(at: index)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Step 3: Choose Route Type
                    if currentRoute.waypoints.count >= 2 {
                        GuidedStepCard(
                            stepNumber: 3,
                            title: "Choose Route Style",
                            description: "What kind of ride do you prefer?",
                            icon: "road.lanes",
                            color: .orange,
                            isComplete: true
                        ) {
                            VStack(spacing: ResponsiveSpacing.small) {
                                ForEach(RouteOptimization.allCases, id: \.self) { opt in
                                    RouteOptimizationButton(
                                        optimization: opt,
                                        isSelected: currentRoute.optimization == opt
                                    ) {
                                        currentRoute.optimization = opt
                                        recalculateRoute()
                                    }
                                }
                            }
                        }
                    }
                    
                    // Step 4: Review & Calculate
                    if currentRoute.waypoints.count >= 2 {
                        GuidedStepCard(
                            stepNumber: 4,
                            title: "Calculate Your Route",
                            description: "Get distance, time, and elevation details",
                            icon: "arrow.triangle.2.circlepath",
                            color: .purple,
                            isComplete: currentRoute.totalDistance > 0
                        ) {
                            VStack(spacing: ResponsiveSpacing.medium) {
                                if currentRoute.totalDistance > 0 {
                                    // Route Stats
                                    CompactRouteStats(route: currentRoute)
                                } else {
                                    Button(action: calculateRoute) {
                                        HStack {
                                            Image(systemName: "wand.and.stars")
                                            Text("Calculate Route")
                                        }
                                        .font(Font.scaledHeadline())
                                        .frame(maxWidth: .infinity)
                                        .padding(ResponsiveSpacing.medium)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(12.scaled)
                                    }
                                }
                            }
                        }
                    }
                    
                    // AI Suggestions
                    if !plannerManager.aiSuggestions.isEmpty && currentRoute.waypoints.isEmpty {
                        VStack(alignment: .leading, spacing: ResponsiveSpacing.medium) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("Suggested Routes")
                                    .font(Font.scaledHeadline())
                                Spacer()
                            }
                            .padding(.horizontal, ResponsiveSpacing.medium)
                            
                            ForEach(plannerManager.aiSuggestions.prefix(3)) { suggestion in
                                AISuggestionCard(suggestion: suggestion) {
                                    currentRoute = suggestion.route
                                    recalculateRoute()
                                }
                                .padding(.horizontal, ResponsiveSpacing.medium)
                            }
                        }
                    }
                }
                .padding(.vertical, ResponsiveSpacing.medium)
            }
            
            // Bottom Actions
            if currentRoute.totalDistance > 0 {
                HStack(spacing: ResponsiveSpacing.medium) {
                    Button(action: { showingDirections = true }) {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                            .font(Font.scaled(15))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: saveRoute) {
                        Label("Save Route", systemImage: "checkmark.circle.fill")
                            .font(Font.scaledHeadline())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .responsivePadding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, y: -2)
            }
        }
    }
    
    private var guidedModeProgress: some View {
        HStack(spacing: 8.scaled) {
            ForEach(1...4, id: \.self) { step in
                Circle()
                    .fill(progressColor(for: step))
                    .frame(width: 8.scaled, height: 8.scaled)
                    .overlay(
                        Circle()
                            .stroke(progressColor(for: step), lineWidth: 2.scaled)
                            .frame(width: 12.scaled, height: 12.scaled)
                            .opacity(isCurrentStep(step) ? 1 : 0)
                    )
            }
        }
        .padding(.vertical, ResponsiveSpacing.small)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
    }
    
    private func progressColor(for step: Int) -> Color {
        let currentStep = min(4, currentRoute.waypoints.isEmpty ? 1 : (currentRoute.waypoints.count == 1 ? 2 : (currentRoute.totalDistance > 0 ? 4 : 3)))
        return step <= currentStep ? .blue : .gray.opacity(0.3)
    }
    
    private func isCurrentStep(_ step: Int) -> Bool {
        let currentStep = min(4, currentRoute.waypoints.isEmpty ? 1 : (currentRoute.waypoints.count == 1 ? 2 : (currentRoute.totalDistance > 0 ? 4 : 3)))
        return step == currentStep
    }
    
    // MARK: - Advanced Mode View
    
    private var advancedModeView: some View {
        VStack(spacing: 0) {
            // Top Bar with Route Stats
            routeStatsHeader
            
            // Tabbed Content
            TabView(selection: $selectedTab) {
                // Tab 1: Map & Waypoints
                mapAndWaypointsTab
                    .tag(0)
                
                // Tab 2: Elevation & Analytics
                elevationAndAnalyticsTab
                    .tag(1)
                
                // Tab 3: Directions
                directionsTab
                    .tag(2)
                
                // Tab 4: AI Suggestions
                aiSuggestionsTab
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Bottom Action Bar
            bottomActionBar
        }
    }
    
    // MARK: - Route Stats Header
    
    private var routeStatsHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                StatBadge(icon: "arrow.left.and.right", value: String(format: "%.1f", currentRoute.totalDistance), unit: "km", color: .blue)
                StatBadge(icon: "clock", value: formatDuration(currentRoute.estimatedDuration), unit: "", color: .green)
                StatBadge(icon: "arrow.up", value: String(format: "%.0f", currentRoute.elevationGain), unit: "m", color: .orange)
                StatBadge(icon: "star.fill", value: String(format: "%.1f", currentRoute.difficultyRating), unit: "/10", color: .yellow)
            }
            .padding(.horizontal)
            
            // Optimization Picker
            Picker("Optimization", selection: Binding(
                get: { currentRoute.optimization },
                set: { newValue in
                    currentRoute.optimization = newValue
                    recalculateRoute()
                }
            )) {
                ForEach(RouteOptimization.allCases, id: \.self) { opt in
                    Label(opt.rawValue, systemImage: opt.icon).tag(opt)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
    }
    
    // MARK: - Map & Waypoints Tab
    
    private var mapAndWaypointsTab: some View {
        VStack(spacing: 0) {
            // Map View
            Map(coordinateRegion: $region, annotationItems: currentRoute.waypoints) { waypoint in
                MapAnnotation(coordinate: waypoint.coordinate) {
                    RoutePlanWaypointMarker(waypoint: waypoint)
                        .onTapGesture {
                            selectedWaypoint = waypoint
                        }
                }
            }
            .frame(height: 300)
            
            // Waypoints List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(currentRoute.waypoints.enumerated()), id: \.element.id) { index, waypoint in
                        RoutePlanWaypointRow(waypoint: waypoint, index: index)
                            .onTapGesture {
                                selectedWaypoint = waypoint
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    removeWaypoint(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onMove { from, to in
                        currentRoute.waypoints.move(fromOffsets: from, toOffset: to)
                        recalculateRoute()
                    }
                    
                    // Add Waypoint Button
                    Button(action: { showingAddWaypoint = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Waypoint")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Elevation & Analytics Tab
    
    private var elevationAndAnalyticsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Elevation Profile Chart
                GroupBox(label: Label("Elevation Profile", systemImage: "chart.line.uptrend.xyaxis")) {
                    ElevationProfileChart(points: plannerManager.elevationProfile)
                        .frame(height: 200)
                        .padding(.vertical)
                }
                
                // Route Scores
                GroupBox(label: Label("Route Characteristics", systemImage: "chart.bar.fill")) {
                    VStack(spacing: 15) {
                        ScoreBar(label: "Difficulty", score: currentRoute.difficultyRating, color: .red)
                        ScoreBar(label: "Twistiness", score: currentRoute.twistinessScore, color: .blue)
                        ScoreBar(label: "Scenic Value", score: currentRoute.scenicScore, color: .green)
                    }
                    .padding(.vertical, 8)
                }
                
                // Suggested Stops
                if !currentRoute.suggestedFuelStops.isEmpty {
                    GroupBox(label: Label("Fuel Stops", systemImage: "fuelpump.fill")) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(currentRoute.suggestedFuelStops.prefix(3)) { stop in
                                HStack {
                                    Image(systemName: "fuelpump.circle.fill")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading) {
                                        Text(stop.name)
                                            .font(.subheadline)
                                        if let address = stop.address {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        var updatedStop = stop
                                        updatedStop.type = .waypoint
                                        currentRoute.waypoints.append(updatedStop)
                                        recalculateRoute()
                                    }) {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if !currentRoute.suggestedRestStops.isEmpty {
                    GroupBox(label: Label("Rest Stops", systemImage: "bed.double.fill")) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(currentRoute.suggestedRestStops.prefix(3)) { stop in
                                HStack {
                                    Image(systemName: "bed.double.circle.fill")
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text(stop.name)
                                            .font(.subheadline)
                                        if let address = stop.address {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        var updatedStop = stop
                                        updatedStop.type = .waypoint
                                        currentRoute.waypoints.append(updatedStop)
                                        recalculateRoute()
                                    }) {
                                        Image(systemName: "plus.circle")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Weather Forecast
                if let weather = currentRoute.weatherForecast {
                    GroupBox(label: Label("Weather Forecast", systemImage: "cloud.sun.fill")) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(weather.condition)
                                        .font(.headline)
                                    Text("\(Int(weather.temperature))°C")
                                        .font(.title2)
                                        .bold()
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Rain: \(Int(weather.precipitationChance))%")
                                        .font(.caption)
                                    Text("Wind: \(Int(weather.windSpeed)) km/h")
                                        .font(.caption)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(weather.recommendation.color)
                                Text("Riding Conditions: \(weather.recommendation.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(weather.recommendation.color)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Directions Tab
    
    private var directionsTab: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(currentRoute.directions.enumerated()), id: \.element.id) { index, direction in
                    DirectionRow(direction: direction, step: index + 1)
                }
            }
            .padding()
        }
    }
    
    // MARK: - AI Suggestions Tab
    
    private var aiSuggestionsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(plannerManager.aiSuggestions) { suggestion in
                    AISuggestionCard(suggestion: suggestion) {
                        currentRoute = suggestion.route
                        recalculateRoute()
                        selectedTab = 0
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        HStack(spacing: 15) {
            Button(action: { showingAddWaypoint = true }) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Button(action: { calculateRoute() }) {
                Label("Calculate", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: saveRoute) {
                Label("Save", systemImage: "folder.badge.plus")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: -2)
    }
    
    // MARK: - Helper Functions
    
    private func recalculateRoute() {
        plannerManager.calculateRoute(&currentRoute) {
            updateMapRegion()
        }
    }
    
    private func calculateRoute() {
        plannerManager.calculateRoute(&currentRoute) {
            updateMapRegion()
        }
    }
    
    private func saveRoute() {
        plannerManager.saveRoute(currentRoute)
        dismiss()
    }
    
    private func removeWaypoint(at index: Int) {
        currentRoute.waypoints.remove(at: index)
        recalculateRoute()
    }
    
    private func updateMapRegion() {
        guard let first = currentRoute.waypoints.first else { return }
        
        var minLat = first.coordinate.latitude
        var maxLat = first.coordinate.latitude
        var minLon = first.coordinate.longitude
        var maxLon = first.coordinate.longitude
        
        for waypoint in currentRoute.waypoints {
            minLat = min(minLat, waypoint.coordinate.latitude)
            maxLat = max(maxLat, waypoint.coordinate.latitude)
            minLon = min(minLon, waypoint.coordinate.longitude)
            maxLon = max(maxLon, waypoint.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.1, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.1, (maxLon - minLon) * 1.5)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct RoutePlanWaypointMarker: View {
    let waypoint: RouteWaypoint
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(waypoint.type.color)
                    .frame(width: 30, height: 30)
                Image(systemName: waypoint.type.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            .shadow(radius: 3)
            
            Text(waypoint.name)
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.white)
                .cornerRadius(4)
                .shadow(radius: 2)
        }
    }
}

struct RoutePlanWaypointRow: View {
    let waypoint: RouteWaypoint
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(waypoint.type.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: waypoint.type.icon)
                    .foregroundColor(waypoint.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(waypoint.name)
                    .font(.headline)
                if let address = waypoint.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("#\(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ScoreBar: View {
    let label: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f/10", score))
                    .font(.subheadline)
                    .bold()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (score / 10), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct DirectionRow: View {
    let direction: RouteDirection
    let step: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: direction.maneuverType.icon)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(step)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(direction.instruction)
                    .font(.subheadline)
                HStack(spacing: 12) {
                    Label(String(format: "%.1f km", direction.distance), systemImage: "arrow.left.and.right")
                    Label(formatDuration(direction.duration), systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct AISuggestionCard: View {
    let suggestion: AIRouteSuggestion
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suggestion.suggestionType.icon)
                    .foregroundColor(suggestion.suggestionType.color)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(suggestion.title)
                        .font(.headline)
                    Text(suggestion.suggestionType.rawValue)
                        .font(.caption)
                        .foregroundColor(suggestion.suggestionType.color)
                }
                
                Spacer()
                
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 15) {
                Label("\(Int(suggestion.route.totalDistance)) km", systemImage: "arrow.left.and.right")
                Label(formatDuration(suggestion.route.estimatedDuration), systemImage: "clock")
                Label("\(Int(suggestion.route.elevationGain)) m", systemImage: "arrow.up")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: onSelect) {
                Text("Use This Route")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

struct ElevationProfileChart: View {
    let points: [RouteElevationPoint]
    
    var body: some View {
        GeometryReader { geometry in
            if points.isEmpty {
                VStack {
                    Spacer()
                    Text("No elevation data")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                let maxElevation = points.map { $0.elevation }.max() ?? 1000
                let minElevation = points.map { $0.elevation }.min() ?? 0
                let elevationRange = maxElevation - minElevation
                
                Path { path in
                    for (index, point) in points.enumerated() {
                        let x = (point.distance / (points.last?.distance ?? 1)) * geometry.size.width
                        let y = geometry.size.height - ((point.elevation - minElevation) / elevationRange) * geometry.size.height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Fill area under curve
                Path { path in
                    for (index, point) in points.enumerated() {
                        let x = (point.distance / (points.last?.distance ?? 1)) * geometry.size.width
                        let y = geometry.size.height - ((point.elevation - minElevation) / elevationRange) * geometry.size.height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)], startPoint: .top, endPoint: .bottom))
            }
        }
    }
}

// MARK: - Guided Mode Supporting Views

struct GuidedStepCard<Content: View>: View {
    let stepNumber: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isComplete: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResponsiveSpacing.medium) {
            HStack(spacing: ResponsiveSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 48.scaled, height: 48.scaled)
                    
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20.scaled, weight: .bold))
                            .foregroundColor(color)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 20.scaled))
                            .foregroundColor(color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4.scaled) {
                    HStack {
                        Text("Step \(stepNumber)")
                            .font(Font.scaledCaption())
                            .foregroundColor(.secondary)
                        
                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .font(Font.scaledCaption())
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(title)
                        .font(Font.scaledHeadline())
                    
                    Text(description)
                        .font(Font.scaled(15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            content
        }
        .padding(ResponsiveSpacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16.scaled)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal, ResponsiveSpacing.medium)
    }
}

struct CompactRouteStats: View {
    let route: RoutePlan
    
    var body: some View {
        VStack(spacing: ResponsiveSpacing.small) {
            HStack(spacing: ResponsiveSpacing.medium) {
                RouteStatItem(icon: "arrow.left.and.right", label: "Distance", value: String(format: "%.1f km", route.totalDistance), color: .blue)
                Divider().frame(height: 40.scaled)
                RouteStatItem(icon: "clock", label: "Time", value: formatDuration(route.estimatedDuration), color: .green)
            }
            
            Divider()
            
            HStack(spacing: ResponsiveSpacing.medium) {
                RouteStatItem(icon: "arrow.up", label: "Elevation", value: String(format: "%.0f m", route.elevationGain), color: .orange)
                Divider().frame(height: 40.scaled)
                RouteStatItem(icon: "star.fill", label: "Difficulty", value: String(format: "%.1f/10", route.difficultyRating), color: .yellow)
            }
        }
        .padding(ResponsiveSpacing.medium)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12.scaled)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

struct RouteStatItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4.scaled) {
            Image(systemName: icon)
                .font(.system(size: 20.scaled))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16.scaled, weight: .bold))
            
            Text(label)
                .font(Font.scaledCaption())
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RouteOptimizationButton: View {
    let optimization: RouteOptimization
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResponsiveSpacing.medium) {
                Image(systemName: optimization.icon)
                    .font(.system(size: 20.scaled))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 32.scaled)
                
                VStack(alignment: .leading, spacing: 2.scaled) {
                    Text(optimization.rawValue)
                        .font(Font.scaled(15, weight: .medium))
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(optimization.description)
                        .font(Font.scaledCaption())
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(ResponsiveSpacing.medium)
            .background(isSelected ? Color.blue : Color(.tertiarySystemBackground))
            .cornerRadius(12.scaled)
        }
    }
}

// MARK: - Tutorial View

struct RoutePlannerTutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    let pages = [
        TutorialPage(
            icon: "hand.raised.fill",
            title: "Welcome to Route Planner",
            description: "Create perfect motorcycle routes in just a few taps. Choose between Guided mode for beginners or Advanced mode for pros.",
            color: .blue
        ),
        TutorialPage(
            icon: "map.fill",
            title: "Add Waypoints",
            description: "Set your start and end points, then add stops along the way. Tap and hold on the map or search for locations.",
            color: .green
        ),
        TutorialPage(
            icon: "road.lanes",
            title: "Choose Your Style",
            description: "Select route optimization: Fastest, Most Scenic, Twisty Roads, or Balanced. Each gives you a different riding experience.",
            color: .orange
        ),
        TutorialPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "View Route Details",
            description: "See elevation profiles, fuel stops, weather forecasts, and turn-by-turn directions before you ride.",
            color: .purple
        )
    ]
    
    var body: some View {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(Font.scaledHeadline())
                        .frame(maxWidth: .infinity)
                        .padding(ResponsiveSpacing.medium)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12.scaled)
                }
                .responsivePadding()
            }
            .navigationTitle("Quick Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
    }
}

struct TutorialPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: ResponsiveSpacing.large) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 120.scaled, height: 120.scaled)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50.scaled))
                    .foregroundColor(page.color)
            }
            
            VStack(spacing: ResponsiveSpacing.small) {
                Text(page.title)
                    .font(Font.scaledTitle())
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(Font.scaledBody())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ResponsiveSpacing.extraLarge)
            }
            
            Spacer()
        }
        .padding(ResponsiveSpacing.medium)
    }
}

// MARK: - Templates View

struct RouteTemplatesView: View {
    @Environment(\.dismiss) var dismiss
    let onSelectTemplate: (RoutePlan) -> Void
    
    let templates = [
        RouteTemplate(
            name: "Weekend Getaway",
            description: "2-day scenic route with overnight stop",
            icon: "moon.stars.fill",
            distance: 450,
            duration: 6 * 3600,
            optimization: .scenic,
            color: .purple
        ),
        RouteTemplate(
            name: "Canyon Carver",
            description: "Twisty mountain roads for spirited riding",
            icon: "point.3.connected.trianglepath.dotted",
            distance: 200,
            duration: 4 * 3600,
            optimization: .twisty,
            color: .orange
        ),
        RouteTemplate(
            name: "Coastal Cruise",
            description: "Relaxing seaside route with photo stops",
            icon: "water.waves",
            distance: 300,
            duration: 5 * 3600,
            optimization: .scenic,
            color: .blue
        ),
        RouteTemplate(
            name: "Quick Commute",
            description: "Fast route to get there efficiently",
            icon: "bolt.fill",
            distance: 80,
            duration: 1 * 3600,
            optimization: .fastest,
            color: .green
        ),
        RouteTemplate(
            name: "Mountain Explorer",
            description: "High elevation routes with challenging terrain",
            icon: "mountain.2.fill",
            distance: 350,
            duration: 7 * 3600,
            optimization: .twisty,
            color: .indigo
        ),
        RouteTemplate(
            name: "Historic Tour",
            description: "Cultural stops and historic landmarks",
            icon: "building.columns.fill",
            distance: 250,
            duration: 6 * 3600,
            optimization: .balanced,
            color: .brown
        )
    ]
    
    var body: some View {
            ScrollView {
                LazyVStack(spacing: ResponsiveSpacing.medium) {
                    ForEach(templates, id: \.name) { template in
                        RouteTemplateCard(template: template) {
                            let route = createRouteFromTemplate(template)
                            onSelectTemplate(route)
                            dismiss()
                        }
                    }
                }
                .responsivePadding()
            }
            .navigationTitle("Route Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
    }
    
    private func createRouteFromTemplate(_ template: RouteTemplate) -> RoutePlan {
        // Create sample waypoints based on template
        let start = RouteWaypoint(
            name: "Start",
            coordinate: CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522),
            type: .start
        )
        
        let end = RouteWaypoint(
            name: "Destination",
            coordinate: CLLocationCoordinate2D(latitude: 60.3913, longitude: 11.0760),
            type: .end
        )
        
        var route = RoutePlan(name: template.name, waypoints: [start, end], optimization: template.optimization)
        route.totalDistance = template.distance
        route.estimatedDuration = template.duration
        
        return route
    }
}

struct RouteTemplate {
    let name: String
    let description: String
    let icon: String
    let distance: Double
    let duration: TimeInterval
    let optimization: RouteOptimization
    let color: Color
}

struct RouteTemplateCard: View {
    let template: RouteTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: ResponsiveSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(template.color.opacity(0.2))
                        .frame(width: 56.scaled, height: 56.scaled)
                    
                    Image(systemName: template.icon)
                        .font(.system(size: 24.scaled))
                        .foregroundColor(template.color)
                }
                
                VStack(alignment: .leading, spacing: 4.scaled) {
                    Text(template.name)
                        .font(Font.scaledHeadline())
                        .foregroundColor(.primary)
                    
                    Text(template.description)
                        .font(Font.scaled(15))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: ResponsiveSpacing.small) {
                        Label("\(Int(template.distance)) km", systemImage: "arrow.left.and.right")
                        Label(formatDuration(template.duration), systemImage: "clock")
                    }
                    .font(Font.scaledCaption())
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(ResponsiveSpacing.medium)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16.scaled)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}

#Preview {
    RoutePlannerView()
}
