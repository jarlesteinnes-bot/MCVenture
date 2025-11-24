//
//  OfflineMapsManager.swift
//  MCVenture
//
//  Created by BNTF on 24/11/2025.
//

import Foundation
import MapKit
import CoreLocation
import Combine

struct OfflineRegion: Identifiable, Codable {
    let id: UUID
    let name: String
    let center: CodableCoordinate
    let radius: Double // km
    let downloadDate: Date
    var lastUsed: Date
    var sizeBytes: Int64
    
    struct CodableCoordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

class OfflineMapsManager: ObservableObject {
    static let shared = OfflineMapsManager()
    
    @Published var downloadedRegions: [OfflineRegion] = []
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var currentDownload: String?
    
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 500_000_000 // 500 MB
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("OfflineMaps")
        
        // Create cache directory
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        loadDownloadedRegions()
    }
    
    // MARK: - Download Region
    func downloadRegion(name: String, center: CLLocationCoordinate2D, radius: Double) {
        isDownloading = true
        currentDownload = name
        downloadProgress = 0
        
        // Simulate download (in production, use MapKit snapshot API)
        Task {
            for i in 0...100 {
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                await MainActor.run {
                    downloadProgress = Double(i) / 100.0
                }
            }
            
            await MainActor.run {
                let region = OfflineRegion(
                    id: UUID(),
                    name: name,
                    center: OfflineRegion.CodableCoordinate(latitude: center.latitude, longitude: center.longitude),
                    radius: radius,
                    downloadDate: Date(),
                    lastUsed: Date(),
                    sizeBytes: Int64.random(in: 10_000_000...50_000_000)
                )
                
                downloadedRegions.append(region)
                saveDownloadedRegions()
                
                isDownloading = false
                currentDownload = nil
                downloadProgress = 0
            }
        }
    }
    
    // MARK: - Delete Region
    func deleteRegion(_ region: OfflineRegion) {
        downloadedRegions.removeAll { $0.id == region.id }
        saveDownloadedRegions()
        
        // Delete cached files
        let regionPath = cacheDirectory.appendingPathComponent(region.id.uuidString)
        try? FileManager.default.removeItem(at: regionPath)
    }
    
    // MARK: - Check if Location is Cached
    func isLocationCached(_ coordinate: CLLocationCoordinate2D) -> Bool {
        for region in downloadedRegions {
            let regionLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            let pointLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = regionLocation.distance(from: pointLocation) / 1000.0 // km
            
            if distance <= region.radius {
                // Update last used
                if let index = downloadedRegions.firstIndex(where: { $0.id == region.id }) {
                    downloadedRegions[index].lastUsed = Date()
                }
                return true
            }
        }
        return false
    }
    
    // MARK: - Get Total Cache Size
    func getTotalCacheSize() -> Int64 {
        return downloadedRegions.reduce(0) { $0 + $1.sizeBytes }
    }
    
    // MARK: - Clean Old Cache
    func cleanOldCache() {
        let totalSize = getTotalCacheSize()
        if totalSize > maxCacheSize {
            // Remove oldest regions
            let sorted = downloadedRegions.sorted { $0.lastUsed < $1.lastUsed }
            var sizeToRemove = totalSize - maxCacheSize
            
            for region in sorted {
                if sizeToRemove <= 0 { break }
                deleteRegion(region)
                sizeToRemove -= region.sizeBytes
            }
        }
    }
    
    // MARK: - Persistence
    private func saveDownloadedRegions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(downloadedRegions) {
            UserDefaults.standard.set(data, forKey: "offlineRegions")
        }
    }
    
    private func loadDownloadedRegions() {
        if let data = UserDefaults.standard.data(forKey: "offlineRegions"),
           let regions = try? JSONDecoder().decode([OfflineRegion].self, from: data) {
            downloadedRegions = regions
        }
    }
}
