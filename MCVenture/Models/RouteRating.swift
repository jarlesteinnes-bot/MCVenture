//
//  RouteRating.swift
//  MCVenture
//
//  Route rating and review system
//

import Foundation
import CloudKit

struct RouteRating: Identifiable, Codable {
    let id: UUID
    let routeId: String
    let userId: String
    let userName: String
    var rating: Int // 1-5 stars
    var comment: String
    let date: Date
    var isHelpful: Int // Number of users who found this helpful
    
    init(id: UUID = UUID(), routeId: String, userId: String, userName: String, rating: Int, comment: String = "", date: Date = Date(), isHelpful: Int = 0) {
        self.id = id
        self.routeId = routeId
        self.userId = userId
        self.userName = userName
        self.rating = min(5, max(1, rating)) // Clamp between 1-5
        self.comment = comment
        self.date = date
        self.isHelpful = isHelpful
    }
    
    // CloudKit conversion
    func toCloudKitRecord() -> CKRecord {
        let record = CKRecord(recordType: "RouteRating")
        record["routeId"] = routeId as CKRecordValue
        record["userId"] = userId as CKRecordValue
        record["userName"] = userName as CKRecordValue
        record["rating"] = rating as CKRecordValue
        record["comment"] = comment as CKRecordValue
        record["date"] = date as CKRecordValue
        record["isHelpful"] = isHelpful as CKRecordValue
        return record
    }
    
    static func fromCloudKitRecord(_ record: CKRecord) -> RouteRating? {
        guard let routeId = record["routeId"] as? String,
              let userId = record["userId"] as? String,
              let userName = record["userName"] as? String,
              let rating = record["rating"] as? Int,
              let comment = record["comment"] as? String,
              let date = record["date"] as? Date,
              let isHelpful = record["isHelpful"] as? Int else {
            return nil
        }
        
        return RouteRating(
            routeId: routeId,
            userId: userId,
            userName: userName,
            rating: rating,
            comment: comment,
            date: date,
            isHelpful: isHelpful
        )
    }
}

// Rating statistics for a route
struct RouteRatingStats: Codable {
    let routeId: String
    var averageRating: Double
    var totalRatings: Int
    var ratingDistribution: [Int: Int] // Star count -> number of ratings
    
    init(routeId: String) {
        self.routeId = routeId
        self.averageRating = 0.0
        self.totalRatings = 0
        self.ratingDistribution = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    }
    
    mutating func addRating(_ rating: Int) {
        let oldTotal = Double(totalRatings) * averageRating
        totalRatings += 1
        averageRating = (oldTotal + Double(rating)) / Double(totalRatings)
        ratingDistribution[rating, default: 0] += 1
    }
    
    func getStarPercentage(_ stars: Int) -> Double {
        guard totalRatings > 0 else { return 0.0 }
        let count = ratingDistribution[stars] ?? 0
        return Double(count) / Double(totalRatings) * 100.0
    }
}
