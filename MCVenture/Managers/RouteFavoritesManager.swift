//
//  RouteFavoritesManager.swift
//  MCVenture
//

import Foundation
import Combine

class RouteFavoritesManager: ObservableObject {
    static let shared = RouteFavoritesManager()
    
    @Published var favoriteRouteIds: Set<UUID> = []
    @Published var routeCollections: [RouteCollection] = []
    
    private let favoritesKey = "favoriteRoutes"
    private let collectionsKey = "routeCollections"
    
    private init() {
        loadFavorites()
        loadCollections()
    }
    
    // MARK: - Favorites
    func toggleFavorite(routeId: UUID) {
        if favoriteRouteIds.contains(routeId) {
            favoriteRouteIds.remove(routeId)
        } else {
            favoriteRouteIds.insert(routeId)
        }
        saveFavorites()
    }
    
    func isFavorite(routeId: UUID) -> Bool {
        favoriteRouteIds.contains(routeId)
    }
    
    func getFavoriteRoutes<T: Identifiable>(from routes: [T]) -> [T] where T.ID == UUID {
        routes.filter { route in
            favoriteRouteIds.contains(route.id)
        }
    }
    
    // MARK: - Collections
    func createCollection(name: String, description: String = "") {
        let collection = RouteCollection(
            id: UUID(),
            name: name,
            description: description,
            routeIds: [],
            createdDate: Date()
        )
        routeCollections.append(collection)
        saveCollections()
    }
    
    func deleteCollection(_ collection: RouteCollection) {
        routeCollections.removeAll { $0.id == collection.id }
        saveCollections()
    }
    
    func addRouteToCollection(routeId: UUID, collectionId: UUID) {
        if let index = routeCollections.firstIndex(where: { $0.id == collectionId }) {
            if !routeCollections[index].routeIds.contains(routeId) {
                routeCollections[index].routeIds.append(routeId)
                saveCollections()
            }
        }
    }
    
    func removeRouteFromCollection(routeId: UUID, collectionId: UUID) {
        if let index = routeCollections.firstIndex(where: { $0.id == collectionId }) {
            routeCollections[index].routeIds.removeAll { $0 == routeId }
            saveCollections()
        }
    }
    
    func getCollectionsContaining(routeId: UUID) -> [RouteCollection] {
        routeCollections.filter { collection in
            collection.routeIds.contains(routeId)
        }
    }
    
    // MARK: - Persistence
    private func saveFavorites() {
        let array = Array(favoriteRouteIds)
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let array = try? JSONDecoder().decode([UUID].self, from: data) {
            favoriteRouteIds = Set(array)
        }
    }
    
    private func saveCollections() {
        if let data = try? JSONEncoder().encode(routeCollections) {
            UserDefaults.standard.set(data, forKey: collectionsKey)
        }
    }
    
    private func loadCollections() {
        if let data = UserDefaults.standard.data(forKey: collectionsKey),
           let collections = try? JSONDecoder().decode([RouteCollection].self, from: data) {
            routeCollections = collections
        }
    }
}

// MARK: - Route Collection Model
struct RouteCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var routeIds: [UUID]
    let createdDate: Date
    
    var routeCount: Int {
        routeIds.count
    }
}
