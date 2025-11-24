//
//  ScrapedRoutesView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI
import MapKit

struct ScrapedRoutesView: View {
    @StateObject private var scraperManager = RouteScraperManager.shared
    @State private var selectedRoute: ScrapedRoute?
    @State private var searchText = ""
    @State private var selectedCountry: String = "All"
    @State private var selectedDifficulty: ScrapedRouteDifficulty?
    @State private var selectedTag: String = "All"
    @State private var showFilters = false
    @State private var showScraper = false
    @Environment(\.dismiss) private var dismiss
    
    var filteredRoutes: [ScrapedRoute] {
        var routes = scraperManager.scrapedRoutes
        
        // Apply search
        if !searchText.isEmpty {
            routes = scraperManager.searchRoutes(query: searchText)
        }
        
        // Apply country filter
        if selectedCountry != "All" {
            routes = routes.filter { $0.country == selectedCountry }
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            routes = routes.filter { $0.difficulty == difficulty }
        }
        
        // Apply tag filter
        if selectedTag != "All" {
            routes = routes.filter { $0.tags.contains(selectedTag) }
        }
        
        return routes.sorted { $0.scenicRating > $1.scenicRating }
    }
    
    var routesByCountry: [(country: String, flag: String, routes: [ScrapedRoute])] {
        let routes = filteredRoutes
        let grouped = Dictionary(grouping: routes, by: { $0.country })
        return grouped.map { (country: $0.key, flag: countryFlag(for: $0.key), routes: $0.value.sorted { $0.scenicRating > $1.scenicRating }) }
            .sorted { $0.country < $1.country }
    }
    
    var availableCountries: [String] {
        let countries = Set(scraperManager.scrapedRoutes.map { $0.country })
        return ["All"] + countries.sorted()
    }
    
    var availableTags: [String] {
        let tags = Set(scraperManager.scrapedRoutes.flatMap { $0.tags })
        return ["All"] + tags.sorted()
    }
    
    var body: some View {
            VStack(spacing: 0) {
                // Header with stats
                headerView
                
                // Search and filters
                searchFilterBar
                
                // Routes list
                if filteredRoutes.isEmpty {
                    emptyStateView
                } else {
                    routesList
                }
            }
            .navigationTitle("European Routes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showScraper = true }) {
                        Image(systemName: "arrow.down.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showScraper) {
                ScraperControlView()
            }
            .sheet(item: $selectedRoute) { route in
                ScrapedRouteDetailView(route: route)
            }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                ScrapedRouteStatCard(
                    icon: "map",
                    value: "\(scraperManager.scrapedRoutes.count)",
                    label: "Routes"
                )
                
                ScrapedRouteStatCard(
                    icon: "flag",
                    value: "\(Set(scraperManager.scrapedRoutes.map { $0.country }).count)",
                    label: "Countries"
                )
                
                ScrapedRouteStatCard(
                    icon: "road.lanes",
                    value: String(format: "%.0f", scraperManager.scrapedRoutes.map { $0.distanceKm }.reduce(0, +)),
                    label: "Total km"
                )
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
    
    // MARK: - Search and Filter Bar
    private var searchFilterBar: some View {
        VStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search routes, countries, tags...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ScrapedRouteFilterChip(
                        title: "Country: \(selectedCountry)",
                        isSelected: selectedCountry != "All"
                    ) {
                        // Show country picker
                    }
                    
                    ScrapedRouteFilterChip(
                        title: selectedDifficulty?.rawValue ?? "Difficulty",
                        isSelected: selectedDifficulty != nil
                    ) {
                        if selectedDifficulty == nil {
                            selectedDifficulty = .easy
                        } else {
                            selectedDifficulty = nil
                        }
                    }
                    
                    ScrapedRouteFilterChip(
                        title: "Tag: \(selectedTag)",
                        isSelected: selectedTag != "All"
                    ) {
                        // Show tag picker
                    }
                    
                    if selectedCountry != "All" || selectedDifficulty != nil || selectedTag != "All" {
                        Button(action: clearFilters) {
                            HStack(spacing: 4) {
                                Text("Clear")
                                Image(systemName: "xmark")
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Routes List
    private var routesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(routesByCountry, id: \.country) { countryGroup in
                    VStack(alignment: .leading, spacing: 12) {
                        // Country header
                        HStack(spacing: 8) {
                            Text(countryGroup.flag)
                                .font(.largeTitle)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(countryGroup.country)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("\(countryGroup.routes.count) routes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Routes in this country
                        ForEach(countryGroup.routes) { route in
                            RouteCard(route: route)
                                .onTapGesture {
                                    selectedRoute = route
                                }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: scraperManager.scrapedRoutes.isEmpty ? "arrow.down.circle" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(scraperManager.scrapedRoutes.isEmpty ? "No Routes Yet" : "No Routes Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(scraperManager.scrapedRoutes.isEmpty ? 
                 "Tap the download button to scrape European routes" :
                 "Try adjusting your search or filters")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if scraperManager.scrapedRoutes.isEmpty {
                Button(action: { showScraper = true }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Start Scraping")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func clearFilters() {
        selectedCountry = "All"
        selectedDifficulty = nil
        selectedTag = "All"
    }
    
    private func countryFlag(for country: String) -> String {
        if let euCountry = EuropeanCountry.allCases.first(where: { $0.rawValue == country }) {
            return euCountry.flag
        }
        return "🏍️"
    }
}

// MARK: - Stat Card
struct ScrapedRouteStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Filter Chip
struct ScrapedRouteFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

// MARK: - Route Card
struct RouteCard: View {
    let route: ScrapedRoute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Text(countryFlag(for: route.country))
                        Text(route.country)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if let region = route.region {
                            Text("• \(region)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", route.scenicRating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    ScrapedDifficultyBadge(difficulty: route.difficulty)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                ScrapedRouteStatItem(icon: "road.lanes", value: "\(Int(route.distanceKm)) km")
                
                if let elevation = route.maxElevationMeters {
                    ScrapedRouteStatItem(icon: "arrow.up", value: "\(Int(elevation)) m")
                }
                
                if !route.roadTypes.isEmpty {
                    ScrapedRouteStatItem(icon: "signpost.right", value: route.roadTypes.first?.rawValue ?? "")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            // Tags
            if !route.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(route.tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func countryFlag(for country: String) -> String {
        if let euCountry = EuropeanCountry.allCases.first(where: { $0.rawValue == country }) {
            return euCountry.flag
        }
        return "🏍️"
    }
}

// MARK: - Difficulty Badge
struct ScrapedDifficultyBadge: View {
    let difficulty: ScrapedRouteDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(badgeColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15))
            .cornerRadius(4)
    }
    
    private var badgeColor: Color {
        switch difficulty {
        case .easy: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

// MARK: - Stat Item
struct ScrapedRouteStatItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
        }
    }
}

// MARK: - Scraped Route Detail View
struct ScrapedRouteDetailView: View {
    let route: ScrapedRoute
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
    init(route: ScrapedRoute) {
        self.route = route
        _region = State(initialValue: MKCoordinateRegion(
            center: route.startPoint.coordinate.clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        ))
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Map preview
                    Map(coordinateRegion: $region, annotationItems: [route.startPoint, route.endPoint]) { point in
                        MapMarker(coordinate: point.coordinate.clCoordinate, tint: .red)
                    }
                    .frame(height: 250)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and rating
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(route.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 4) {
                                    Text(countryFlag(for: route.country))
                                    Text(route.country)
                                        .foregroundColor(.gray)
                                    if let region = route.region {
                                        Text("• \(region)")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack {
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", route.scenicRating))
                                        .fontWeight(.semibold)
                                }
                                ScrapedDifficultyBadge(difficulty: route.difficulty)
                            }
                        }
                        
                        Divider()
                        
                        // Description
                        Text(route.description)
                            .foregroundColor(.secondary)
                        
                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            DetailStatCard(icon: "road.lanes", label: "Distance", value: "\(Int(route.distanceKm)) km")
                            
                            if let elevation = route.maxElevationMeters {
                                DetailStatCard(icon: "mountain.2", label: "Max Elevation", value: "\(Int(elevation)) m")
                            }
                            
                            if let gain = route.elevationGainMeters {
                                DetailStatCard(icon: "arrow.up", label: "Elevation Gain", value: "\(Int(gain)) m")
                            }
                            
                            DetailStatCard(icon: "car", label: "Traffic", value: route.trafficLevel.rawValue)
                            DetailStatCard(icon: "road.lanes.curved.right", label: "Surface", value: route.surfaceCondition.rawValue)
                            
                            if route.tollRoad {
                                DetailStatCard(icon: "eurosign.circle", label: "Toll Road", value: "Yes")
                            }
                        }
                        
                        // Highlights
                        if !route.highlights.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Highlights")
                                    .font(.headline)
                                ForEach(route.highlights, id: \.self) { highlight in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(highlight)
                                    }
                                }
                            }
                        }
                        
                        // Best months
                        if !route.bestMonths.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Best Months")
                                    .font(.headline)
                                Text(route.bestMonths.joined(separator: ", "))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Tags
                        if !route.tags.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(route.tags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Source
                        Divider()
                        HStack {
                            Text("Source:")
                                .foregroundColor(.gray)
                            Text(route.sourceWebsite)
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                    }
                    .padding()
                }
            }
            .navigationTitle("Route Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
    
    private func countryFlag(for country: String) -> String {
        if let euCountry = EuropeanCountry.allCases.first(where: { $0.rawValue == country }) {
            return euCountry.flag
        }
        return "🏍️"
    }
}

// MARK: - Detail Stat Card
struct DetailStatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}


// MARK: - Scraper Control View
struct ScraperControlView: View {
    @StateObject private var scraperManager = RouteScraperManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            VStack(spacing: 20) {
                if scraperManager.isScraperRunning {
                    VStack(spacing: 20) {
                        ProgressView(value: scraperManager.scrapingProgress)
                            .progressViewStyle(.linear)
                        
                        Text("Scraping: \(scraperManager.currentSource)")
                            .font(.headline)
                        
                        Text("\(scraperManager.routesScrapedCount) routes found")
                            .foregroundColor(.gray)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .padding()
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "globe.europe.africa")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 12) {
                            Text("European Route Scraper")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Scrape motorcycle routes from \(scraperManager.sources.filter { $0.isEnabled }.count) European sources")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 16) {
                            ScraperInfoRow(icon: "map", text: "\(scraperManager.sources.count) sources configured")
                            ScraperInfoRow(icon: "flag", text: "Covers all European countries")
                            ScraperInfoRow(icon: "star", text: "Includes scenic routes, passes, coastal roads")
                        }
                        
                        Button(action: {
                            Task {
                                await scraperManager.startComprehensiveScraping()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Start Scraping")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Route Scraper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct ScraperInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    ScrapedRoutesView()
}
