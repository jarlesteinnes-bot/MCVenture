//
//  SocialManager.swift
//  MCVenture
//

import Foundation
import CloudKit
import Combine

struct SharedRoute: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let authorName: String
    let authorId: String
    let distance: Double
    let difficulty: String
    let shareDate: Date
    var likes: Int
    var comments: [RouteComment]
}

struct RouteComment: Identifiable, Codable {
    let id: UUID
    let authorName: String
    let text: String
    let date: Date
}

class SocialManager: ObservableObject {
    static let shared = SocialManager()
    
    @Published var sharedRoutes: [SharedRoute] = []
    @Published var following: [String] = []
    @Published var followers: [String] = []
    
    private init() {}
    
    func shareRoute(name: String, description: String, authorName: String, distance: Double, difficulty: String) {
        let route = SharedRoute(
            id: UUID(),
            name: name,
            description: description,
            authorName: authorName,
            authorId: UUID().uuidString,
            distance: distance,
            difficulty: difficulty,
            shareDate: Date(),
            likes: 0,
            comments: []
        )
        sharedRoutes.append(route)
        // CloudKit sync would go here
    }
    
    func likeRoute(_ route: SharedRoute) {
        if let index = sharedRoutes.firstIndex(where: { $0.id == route.id }) {
            sharedRoutes[index].likes += 1
        }
    }
    
    func addComment(to route: SharedRoute, text: String, authorName: String) {
        if let index = sharedRoutes.firstIndex(where: { $0.id == route.id }) {
            let comment = RouteComment(id: UUID(), authorName: authorName, text: text, date: Date())
            sharedRoutes[index].comments.append(comment)
        }
    }
}
