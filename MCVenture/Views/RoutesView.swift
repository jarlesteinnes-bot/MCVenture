//
//  RoutesView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct RoutesView: View {
    @State private var searchText = ""
    @State private var selectedCountry: String?
    @State private var selectedDifficulty: EuropeanRoute.Difficulty?
    @State private var showFavoritesOnly = false
    @State private var importedRoutes: [EuropeanRoute] = []
    @State private var showingImporter = false
    @State private var autoOpenInMaps = false
    @State private var showScraper = false
    @State private var isRefreshing = false
    @AppStorage("autoOpenMaps") private var savedAutoOpenMaps = false
    @AppStorage("lastSelectedCountry") private var lastSelectedCountry: String?
    @AppStorage("lastSelectedDifficulty") private var lastSelectedDifficultyRaw: String?
    
    var database = EuropeanRoutesDatabase.shared
    @StateObject private var scraperManager = RouteScraperManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var dataManager = DataManager.shared
    
    private var isLoading: Bool {
        scraperManager.isScraperRunning
    }
    
    var allRoutes: [RouteDisplayItem] {
        // Combine existing routes with scraped routes
        var displayItems: [RouteDisplayItem] = []
        
        // Add existing EuropeanRoute items
        displayItems += (database.routes + importedRoutes).map { RouteDisplayItem(europeanRoute: $0) }
        
        // Add scraped routes
        displayItems += scraperManager.scrapedRoutes.map { RouteDisplayItem(scrapedRoute: $0) }
        
        return displayItems
    }
    
    var filteredRoutes: [RouteDisplayItem] {
        var routes = allRoutes
        
        // Apply favorites filter
        if showFavoritesOnly {
            routes = routes.filter { dataManager.isFavorite(routeId: $0.id) }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            routes = routes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply country filter
        if let country = selectedCountry {
            routes = routes.filter { $0.country == country }
        }
        
        // Apply difficulty filter based on difficulty string matching
        if let difficulty = selectedDifficulty {
            routes = routes.filter { $0.difficultyString == difficulty.rawValue }
        }
        
        return routes
    }
    
    var groupedRoutes: [(String, [RouteDisplayItem])] {
        let grouped = Dictionary(grouping: filteredRoutes) { $0.country }
        return grouped.sorted { $0.key < $1.key }.map { ($0, $1.sorted { $0.name < $1.name }) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            offlineBanner
            statsHeader
            filtersBar
            
            routesScrollView
        }
        .navigationTitle("My Routes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showScraper) { ScraperControlView() }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url): importRoutes(from: url)
            case .failure: break
            }
        }
        .onAppear { restoreFilters() }
        .onChange(of: selectedCountry) { _ in saveFilters() }
        .onChange(of: selectedDifficulty) { _ in saveFilters() }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var offlineBanner: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash").foregroundColor(.white)
                Text("Offline - Some features unavailable")
                    .font(.subheadline).foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal).padding(.vertical, 12)
            .background(Color.orange)
        }
    }
    
    @ViewBuilder
    private var statsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(filteredRoutes.count) Routes")
                    .font(.title).fontWeight(.bold)
                let scrapedCount = scraperManager.scrapedRoutes.count
                if scrapedCount > 0 {
                    Text("\(groupedRoutes.count) countries • \(scrapedCount) scraped")
                        .font(.subheadline).foregroundColor(.secondary)
                } else {
                    Text("\(groupedRoutes.count) countries")
                        .font(.subheadline).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding().background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var filtersBar: some View {
        if selectedCountry != nil || selectedDifficulty != nil || showFavoritesOnly {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill").foregroundColor(.blue)
                    Text("Filters active").font(.subheadline).fontWeight(.medium)
                    if showFavoritesOnly {
                        Image(systemName: "heart.fill").font(.caption).foregroundColor(.red)
                    }
                }
                Spacer()
                Button(action: clearFilters) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear")
                    }
                    .font(.subheadline).foregroundColor(.red)
                }
            }
            .padding(.horizontal).padding(.vertical, 10)
            .background(Color.blue.opacity(0.1))
        }
        
        if !groupedRoutes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                        // Favorites button
                        Button(action: {
                            HapticFeedbackManager.shared.lightTap()
                            showFavoritesOnly.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.subheadline)
                                Text("Favorites")
                                    .font(.subheadline)
                                    .fontWeight(showFavoritesOnly ? .semibold : .regular)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(showFavoritesOnly ? Color.red : Color.gray.opacity(0.2))
                            .foregroundColor(showFavoritesOnly ? .white : .primary)
                            .cornerRadius(20)
                        }
                        
                        // All Countries button
                        Button(action: { 
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            selectedCountry = nil 
                        }) {
                            HStack(spacing: 6) {
                                Text("🌍")
                                    .font(.body)
                                Text("All")
                                    .font(.subheadline)
                                    .fontWeight(selectedCountry == nil ? .semibold : .regular)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCountry == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCountry == nil ? .white : .primary)
                            .cornerRadius(20)
                        }
                        
                        // Individual country buttons
                        ForEach(groupedRoutes.map { $0.0 }.sorted(), id: \.self) { country in
                            Button(action: { 
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                if selectedCountry == country {
                                    selectedCountry = nil
                                } else {
                                    selectedCountry = country
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Text(countryFlag(for: country))
                                        .font(.body)
                                    Text(country)
                                        .font(.subheadline)
                                        .fontWeight(selectedCountry == country ? .semibold : .regular)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCountry == country ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCountry == country ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground).opacity(0.95))
        }
    }
    
    @ViewBuilder
    private var routesScrollView: some View {
        ScrollView {
                // Loading indicator (when scraping AND no routes exist yet)
                if scraperManager.isLoading && filteredRoutes.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading routes...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !scraperManager.currentSource.isEmpty {
                            Text(scraperManager.currentSource)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                }
                // Empty state (not loading, no routes)
                else if filteredRoutes.isEmpty {
                    EmptyRoutesView(onRefresh: refreshRoutes)
                        .padding(.top, 50)
                }
                // Routes list (show routes even while loading new ones)
                else {
                    // Loading banner at top if currently scraping
                    if scraperManager.isScraperRunning {
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.9)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Checking for new routes...")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if !scraperManager.currentSource.isEmpty {
                                    Text(scraperManager.currentSource)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(scraperManager.routesScrapedCount) new")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedRoutes, id: \.0) { country, routes in
                            Section {
                            VStack(spacing: 12) {
                                ForEach(routes) { routeItem in
                                    if let europeanRoute = routeItem.europeanRoute {
                                        NavigationLink(destination: RouteDetailView(route: europeanRoute)) {
                                            ImprovedRouteCard(europeanRoute: europeanRoute)
                                        }
                                        .buttonStyle(.plain)
                                    } else if let scrapedRoute = routeItem.scrapedRoute {
                                        NavigationLink(destination: ScrapedRouteDetailView(route: scrapedRoute)) {
                                            ImprovedScrapedRouteCard(scrapedRoute: scrapedRoute)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } header: {
                            HStack {
                                Text(countryFlag(for: country))
                                    .font(.title)
                                Text(country)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(routes.count)")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground).opacity(0.95))
                        }
                        }
                    }
                    .padding(.top, 8)
                }
        }
        .refreshable {
            await scraperManager.refreshRoutes()
        }
        .searchable(text: $searchText, prompt: "Search routes...")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: { showScraper = true }) {
                    Label("Scrape Routes", systemImage: "arrow.down.circle")
                }
                Divider()
                Toggle(isOn: $savedAutoOpenMaps) {
                    Label("Auto-open in Google Maps", systemImage: "map.circle")
                }
                Divider()
                Button(action: { showingImporter = true }) {
                    Label("Import JSON", systemImage: "square.and.arrow.down")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    func importRoutes(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let newRoutes = try JSONDecoder().decode([EuropeanRoute].self, from: data)
            // Deduplicate by name+country
            let existingKeys = Set((database.routes + importedRoutes).map { "\($0.name)|\($0.country)" })
            let unique = newRoutes.filter { !existingKeys.contains("\($0.name)|\($0.country)") }
            importedRoutes.append(contentsOf: unique)
        } catch {
            print("Import failed: \(error)")
        }
    }
    
    private func countryFlag(for country: String) -> String {
        if let euCountry = EuropeanCountry.allCases.first(where: { $0.rawValue == country }) {
            return euCountry.flag
        }
        return "🏍️"
    }
    
    private func refreshRoutes() {
        Task {
            await scraperManager.startComprehensiveScraping()
        }
    }
    
    private func clearFilters() {
        HapticFeedbackManager.shared.mediumImpact()
        selectedCountry = nil
        selectedDifficulty = nil
        showFavoritesOnly = false
        lastSelectedCountry = nil
        lastSelectedDifficultyRaw = nil
    }
    
    private func saveFilters() {
        lastSelectedCountry = selectedCountry
        lastSelectedDifficultyRaw = selectedDifficulty?.rawValue
    }
    
    private func restoreFilters() {
        if let country = lastSelectedCountry {
            selectedCountry = country
        }
        if let difficultyRaw = lastSelectedDifficultyRaw,
           let difficulty = EuropeanRoute.Difficulty(rawValue: difficultyRaw) {
            selectedDifficulty = difficulty
        }
    }
}

// MARK: - Empty Routes View
struct EmptyRoutesView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "map.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Text("No Routes Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Discover amazing motorcycle routes across Europe. Tap the button below to load routes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onRefresh) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Load Routes")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - RouteDisplayItem wrapper
struct RouteDisplayItem: Identifiable {
    let id: UUID
    let name: String
    let country: String
    let description: String
    let difficultyString: String
    let europeanRoute: EuropeanRoute?
    let scrapedRoute: ScrapedRoute?
    
    init(europeanRoute: EuropeanRoute) {
        self.id = europeanRoute.id
        self.name = europeanRoute.name
        self.country = europeanRoute.country
        self.description = europeanRoute.description
        self.difficultyString = europeanRoute.difficulty.rawValue
        self.europeanRoute = europeanRoute
        self.scrapedRoute = nil
    }
    
    init(scrapedRoute: ScrapedRoute) {
        self.id = scrapedRoute.id
        self.name = scrapedRoute.name
        self.country = scrapedRoute.country
        self.description = scrapedRoute.description
        self.difficultyString = scrapedRoute.difficulty.rawValue
        self.europeanRoute = nil
        self.scrapedRoute = scrapedRoute
    }
}

// MARK: - ScrapedRouteRowView
struct ScrapedRouteRowView: View {
    let route: ScrapedRoute
    
    var body: some View {
        HStack(spacing: 12) {
            // Country flag
            Text(countryFlag(for: route.country))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", route.scenicRating))
                            .font(.caption)
                    }
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("\(Int(route.distanceKm)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !route.tags.isEmpty {
                        Text("•")
                            .foregroundColor(.gray)
                        Text(route.tags.first ?? "")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func countryFlag(for country: String) -> String {
        if let euCountry = EuropeanCountry.allCases.first(where: { $0.rawValue == country }) {
            return euCountry.flag
        }
        return "🏍️"
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct CountryHeader: View {
    let country: String
    let routeCount: Int
    
    var body: some View {
        HStack {
            Text(country)
                .font(.headline)
            Spacer()
            Text("\(routeCount) routes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RouteRowView: View {
    let route: EuropeanRoute
    
    var difficultyColor: Color {
        switch route.difficulty {
        case .easy: return .green
        case .moderate: return .blue
        case .challenging: return .orange
        case .expert: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.name)
                    .font(.headline)
                Spacer()
                Text(route.difficulty.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor.opacity(0.2))
                    .foregroundColor(difficultyColor)
                    .cornerRadius(8)
            }
            
            Text(route.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                Label("\(Int(route.distanceKm)) km", systemImage: "road.lanes")
                    .font(.caption)
                Label(route.fuelCostFormatted, systemImage: "fuelpump.fill")
                    .font(.caption)
                Label(route.bestMonths, systemImage: "calendar")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            // Quick highlights
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(route.highlights.prefix(3), id: \.self) { highlight in
                        Text(highlight)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Improved Card Views
struct ImprovedScrapedRouteCard: View {
    let scrapedRoute: ScrapedRoute
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(scrapedRoute.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", scrapedRoute.scenicRating))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "road.lanes")
                                .font(.subheadline)
                            Text("\(Int(scrapedRoute.distanceKm)) km")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        
                        if let region = scrapedRoute.region {
                            Text(region)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        dataManager.toggleFavorite(routeId: scrapedRoute.id)
                    }) {
                        Image(systemName: dataManager.isFavorite(routeId: scrapedRoute.id) ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(dataManager.isFavorite(routeId: scrapedRoute.id) ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            
            if !scrapedRoute.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(scrapedRoute.tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
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

struct ImprovedRouteCard: View {
    let europeanRoute: EuropeanRoute
    @StateObject private var dataManager = DataManager.shared
    
    var difficultyColor: Color {
        switch europeanRoute.difficulty {
        case .easy: return .green
        case .moderate: return .blue
        case .challenging: return .orange
        case .expert: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(europeanRoute.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "road.lanes")
                                .font(.subheadline)
                            Text("\(Int(europeanRoute.distanceKm)) km")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        
                        Text(europeanRoute.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(difficultyColor.opacity(0.2))
                            .foregroundColor(difficultyColor)
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        dataManager.toggleFavorite(routeId: europeanRoute.id)
                    }) {
                        Image(systemName: dataManager.isFavorite(routeId: europeanRoute.id) ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(dataManager.isFavorite(routeId: europeanRoute.id) ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            
            if !europeanRoute.highlights.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(europeanRoute.highlights.prefix(4), id: \.self) { highlight in
                            Text(highlight)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(8)
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
