//
//  CloudKitSyncManager.swift
//  MCVenture
//

import Foundation
import CloudKit
import Combine
import UIKit

class CloudKitSyncManager: ObservableObject {
    static let shared = CloudKitSyncManager()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var pendingOperations: Int = 0
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    private let retryManager = RetryManager.shared
    private let offlineQueue = OperationQueue()
    private var cancellables = Set<AnyCancellable>()
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case failed(String)
        case offline
    }
    
    private init() {
        database = container.publicCloudDatabase
        offlineQueue.maxConcurrentOperationCount = 1
        
        // Listen for network changes
        OfflineModeManager.shared.$connectionType
            .sink { [weak self] connectionType in
                if connectionType != .none {
                    self?.processPendingOperations()
                } else {
                    self?.syncStatus = .offline
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync Operations
    
    /// Sync a route to CloudKit with automatic retry
    func syncRoute(_ route: RouteData) async throws {
        guard OfflineModeManager.shared.connectionType != .none else {
            queueForLater(.syncRoute(route))
            throw SyncError.offline
        }
        
        isSyncing = true
        syncStatus = .syncing
        
        do {
            try await retryManager.retry(maxAttempts: 3, initialDelay: 2.0) {
                try await self.uploadRoute(route)
            }
            
            syncStatus = .success
            lastSyncDate = Date()
        } catch {
            syncStatus = .failed(error.localizedDescription)
            
            // Queue for retry if network error
            if isNetworkError(error) {
                queueForLater(.syncRoute(route))
            }
            
            throw error
        }
        
        isSyncing = false
    }
    
    /// Download routes from CloudKit
    func fetchRoutes() async throws -> [RouteData] {
        guard OfflineModeManager.shared.connectionType != .none else {
            throw SyncError.offline
        }
        
        isSyncing = true
        syncStatus = .syncing
        
        do {
            let routes = try await retryManager.retry(maxAttempts: 3) {
                try await self.downloadRoutes()
            }
            
            syncStatus = .success
            lastSyncDate = Date()
            isSyncing = false
            
            return routes
        } catch {
            syncStatus = .failed(error.localizedDescription)
            isSyncing = false
            throw error
        }
    }
    
    /// Delete route from CloudKit
    func deleteRoute(recordID: CKRecord.ID) async throws {
        guard OfflineModeManager.shared.connectionType != .none else {
            queueForLater(.deleteRoute(recordID.recordName))
            throw SyncError.offline
        }
        
        try await retryManager.retry(maxAttempts: 3) {
            try await self.database.deleteRecord(withID: recordID)
        }
    }
    
    // MARK: - Offline Queue
    
    private func queueForLater(_ operation: PendingOperation) {
        pendingOperations += 1
        
        // Save to persistent storage
        var queue = loadOfflineQueue()
        queue.append(operation)
        saveOfflineQueue(queue)
    }
    
    private func processPendingOperations() {
        let queue = loadOfflineQueue()
        guard !queue.isEmpty else { return }
        
        Task {
            for operation in queue {
                do {
                    try await processOperation(operation)
                    removeFromQueue(operation)
                    pendingOperations -= 1
                } catch {
                    print("Failed to process queued operation: \(error)")
                }
            }
        }
    }
    
    private func processOperation(_ operation: PendingOperation) async throws {
        switch operation {
        case .syncRoute(let route):
            try await syncRoute(route)
        case .deleteRoute(let recordIDString):
            let recordID = CKRecord.ID(recordName: recordIDString)
            try await deleteRoute(recordID: recordID)
        }
    }
    
    // MARK: - CloudKit Operations
    
    private func uploadRoute(_ route: RouteData) async throws {
        let record = CKRecord(recordType: "Route")
        record["name"] = route.name as CKRecordValue
        record["coordinates"] = route.coordinates as CKRecordValue
        record["distance"] = route.distance as CKRecordValue
        record["createdBy"] = UIDevice.current.name as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        try await database.save(record)
    }
    
    private func downloadRoutes() async throws -> [RouteData] {
        let query = CKQuery(recordType: "Route", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await database.records(matching: query, desiredKeys: nil)
        
        return results.compactMap { _, result in
            guard case .success(let record) = result else { return nil }
            return RouteData(from: record)
        }
    }
    
    // MARK: - Persistence
    
    private func loadOfflineQueue() -> [PendingOperation] {
        guard let data = UserDefaults.standard.data(forKey: "offlineQueue"),
              let queue = try? JSONDecoder().decode([PendingOperation].self, from: data) else {
            return []
        }
        return queue
    }
    
    private func saveOfflineQueue(_ queue: [PendingOperation]) {
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: "offlineQueue")
        }
    }
    
    private func removeFromQueue(_ operation: PendingOperation) {
        var queue = loadOfflineQueue()
        queue.removeAll { $0.id == operation.id }
        saveOfflineQueue(queue)
    }
    
    // MARK: - Helpers
    
    private func isNetworkError(_ error: Error) -> Bool {
        if let ckError = error as? CKError {
            return [.networkUnavailable, .networkFailure, .requestRateLimited].contains(ckError.code)
        }
        return false
    }
}

// MARK: - Models

enum SyncError: LocalizedError {
    case offline
    case networkUnavailable
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return "You're offline. Changes will sync when connection is restored."
        case .networkUnavailable:
            return "Network unavailable. Please try again."
        case .unauthorized:
            return "iCloud access denied. Enable in Settings."
        }
    }
}

enum PendingOperation: Codable {
    case syncRoute(RouteData)
    case deleteRoute(String) // Record ID as string
    
    var id: String {
        switch self {
        case .syncRoute(let route):
            return "sync_\(route.id)"
        case .deleteRoute(let id):
            return "delete_\(id)"
        }
    }
}

struct RouteData: Codable, Identifiable {
    let id: String
    let name: String
    let coordinates: String // JSON encoded
    let distance: Double
    
    init(from record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"] as? String ?? ""
        self.coordinates = record["coordinates"] as? String ?? ""
        self.distance = record["distance"] as? Double ?? 0.0
    }
}
