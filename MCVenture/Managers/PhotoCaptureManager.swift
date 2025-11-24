//
//  PhotoCaptureManager.swift
//  MCVenture
//

import Foundation
import SwiftUI
import CoreLocation
import Photos
import Combine

struct TripPhoto: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    let imageData: Data
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    var caption: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class PhotoCaptureManager: ObservableObject {
    static let shared = PhotoCaptureManager()
    
    @Published var tripPhotos: [UUID: [TripPhoto]] = [:] // tripId -> photos
    
    private init() {
        loadPhotos()
    }
    
    func capturePhoto(for tripId: UUID, image: UIImage, location: CLLocation, caption: String = "") {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let photo = TripPhoto(
            id: UUID(),
            tripId: tripId,
            imageData: imageData,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date(),
            caption: caption
        )
        
        if tripPhotos[tripId] == nil {
            tripPhotos[tripId] = []
        }
        tripPhotos[tripId]?.append(photo)
        savePhotos()
    }
    
    func getPhotos(for tripId: UUID) -> [TripPhoto] {
        return tripPhotos[tripId] ?? []
    }
    
    func deletePhoto(id: UUID, from tripId: UUID) {
        tripPhotos[tripId]?.removeAll { $0.id == id }
        savePhotos()
    }
    
    func updateCaption(photoId: UUID, tripId: UUID, caption: String) {
        if let index = tripPhotos[tripId]?.firstIndex(where: { $0.id == photoId }) {
            tripPhotos[tripId]?[index].caption = caption
            savePhotos()
        }
    }
    
    private func savePhotos() {
        // Save to UserDefaults or FileManager
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tripPhotos) {
            UserDefaults.standard.set(data, forKey: "tripPhotos")
        }
    }
    
    private func loadPhotos() {
        if let data = UserDefaults.standard.data(forKey: "tripPhotos"),
           let decoded = try? JSONDecoder().decode([UUID: [TripPhoto]].self, from: data) {
            tripPhotos = decoded
        }
    }
}
