//
//  SearchManager.swift
//  MCVenture
//

import Foundation
import Combine

class SearchManager: ObservableObject {
    static let shared = SearchManager()
    
    @Published var searchHistory: [SearchHistoryItem] = []
    @Published var searchFilters: SearchFilters = SearchFilters()
    
    private let historyKey = "searchHistory"
    private let maxHistoryItems = 50
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Search History
    func addToHistory(query: String, resultCount: Int = 0) {
        // Don't add empty queries
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Remove existing instance of this query
        searchHistory.removeAll { $0.query.lowercased() == query.lowercased() }
        
        // Add to front
        let item = SearchHistoryItem(query: query, timestamp: Date(), resultCount: resultCount)
        searchHistory.insert(item, at: 0)
        
        // Limit history size
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        searchHistory.removeAll()
        saveHistory()
    }
    
    func deleteHistoryItem(_ item: SearchHistoryItem) {
        searchHistory.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    // MARK: - Autocomplete
    func getAutocompleteSuggestions(for query: String, limit: Int = 5) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercasedQuery = query.lowercased()
        
        // Get suggestions from history
        let historySuggestions = searchHistory
            .filter { $0.query.lowercased().contains(lowercasedQuery) }
            .map { $0.query }
            .prefix(limit)
        
        // Add common motorcycle route search terms
        let commonTerms = [
            "scenic routes",
            "mountain passes",
            "coastal roads",
            "twisty roads",
            "Alps routes",
            "Norway fjords",
            "Italian passes",
            "Swiss Alps",
            "German autobahn alternatives",
            "French mountain roads"
        ]
        
        let commonSuggestions = commonTerms
            .filter { $0.lowercased().contains(lowercasedQuery) }
            .prefix(limit - historySuggestions.count)
        
        return Array(historySuggestions) + Array(commonSuggestions)
    }
    
    // MARK: - Filters
    func applyFilters<T>(to routes: [T], filter: (T) -> Bool) -> [T] {
        routes.filter(filter)
    }
    
    // MARK: - Persistence
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([SearchHistoryItem].self, from: data) {
            searchHistory = history
        }
    }
}

// MARK: - Models
struct SearchHistoryItem: Identifiable, Codable {
    let id: UUID
    let query: String
    let timestamp: Date
    let resultCount: Int
    
    init(id: UUID = UUID(), query: String, timestamp: Date, resultCount: Int) {
        self.id = id
        self.query = query
        self.timestamp = timestamp
        self.resultCount = resultCount
    }
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let mins = Int(interval / 60)
            return "\(mins) minute\(mins == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

struct SearchFilters: Codable {
    var minDistance: Double? = nil  // km
    var maxDistance: Double? = nil  // km
    var difficulty: [SearchRouteDifficulty] = []
    var countries: Set<String> = []
    var roadTypes: Set<RoadType> = []
    var sortBy: SortOption = .relevance
    
    enum SortOption: String, Codable, CaseIterable {
        case relevance = "Relevance"
        case distance = "Distance"
        case difficulty = "Difficulty"
        case rating = "Rating"
        case newest = "Newest"
        
        var icon: String {
            switch self {
            case .relevance: return "star.fill"
            case .distance: return "arrow.left.and.right"
            case .difficulty: return "mountain.2.fill"
            case .rating: return "heart.fill"
            case .newest: return "clock.fill"
            }
        }
    }
    
    enum RoadType: String, Codable, CaseIterable {
        case mountain = "Mountain"
        case coastal = "Coastal"
        case forest = "Forest"
        case scenic = "Scenic"
        case twisty = "Twisty"
        
        var icon: String {
            switch self {
            case .mountain: return "mountain.2.fill"
            case .coastal: return "water.waves"
            case .forest: return "tree.fill"
            case .scenic: return "camera.fill"
            case .twisty: return "arrow.triangle.turn.up.right.circle.fill"
            }
        }
    }
    
    var isActive: Bool {
        minDistance != nil || maxDistance != nil || !difficulty.isEmpty ||
        !countries.isEmpty || !roadTypes.isEmpty || sortBy != .relevance
    }
    
    mutating func reset() {
        minDistance = nil
        maxDistance = nil
        difficulty.removeAll()
        countries.removeAll()
        roadTypes.removeAll()
        sortBy = .relevance
    }
}

enum SearchRouteDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case moderate = "Moderate"
    case challenging = "Challenging"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .moderate: return "yellow"
        case .challenging: return "orange"
        case .expert: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .moderate: return "figure.walk"
        case .challenging: return "figure.run"
        case .expert: return "flame.fill"
        }
    }
}
