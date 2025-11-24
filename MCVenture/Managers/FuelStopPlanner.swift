//
//  FuelStopPlanner.swift
//  MCVenture
//

import Foundation
import CoreLocation
import MapKit
import Combine

struct GasStation: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let distance: Double // km from current location
    let brand: String
    var estimatedPrice: Double?
    var distanceFromStart: Double? // for route planning
    var isRecommended: Bool? // for fuel planning
    var fuelLevelAtArrival: Double? // liters remaining when arriving at station
    
    init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D, distance: Double, brand: String, estimatedPrice: Double? = nil, distanceFromStart: Double? = nil, isRecommended: Bool? = nil, fuelLevelAtArrival: Double? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.distance = distance
        self.brand = brand
        self.estimatedPrice = estimatedPrice
        self.distanceFromStart = distanceFromStart
        self.isRecommended = isRecommended
        self.fuelLevelAtArrival = fuelLevelAtArrival
    }
}

class FuelStopPlanner: ObservableObject {
    static let shared = FuelStopPlanner()
    
    @Published var nearbyStations: [GasStation] = []
    @Published var fuelLevel: Double = 100.0 // percentage
    @Published var fuelRange: Double = 0 // km remaining
    @Published var showLowFuelWarning = false
    
    private var tankCapacity: Double = 15.0 // liters
    private var fuelConsumption: Double = 5.0 // L/100km
    private var currentLocation: CLLocation?
    
    private init() {}
    
    func updateFuelStatus(currentKm: Double, tankCapacityLiters: Double, consumptionPer100km: Double) {
        self.tankCapacity = tankCapacityLiters
        self.fuelConsumption = consumptionPer100km
        
        // Calculate range
        fuelRange = (tankCapacity * (fuelLevel / 100.0)) / fuelConsumption * 100.0
        
        // Show warning if under 20% or less than 50km range
        showLowFuelWarning = fuelLevel < 20.0 || fuelRange < 50.0
    }
    
    func findNearbyGasStations(from location: CLLocation, completion: @escaping ([GasStation]) -> Void) {
        currentLocation = location
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gas station"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 50000, // 50km radius
            longitudinalMeters: 50000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                completion([])
                return
            }
            
            let stations = response.mapItems.map { item -> GasStation in
                let stationLocation = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                let distance = location.distance(from: stationLocation) / 1000.0 // to km
                
                return GasStation(
                    name: item.name ?? "Gas Station",
                    coordinate: item.placemark.coordinate,
                    distance: distance,
                    brand: self.extractBrand(from: item.name ?? ""),
                    estimatedPrice: nil
                )
            }
            .sorted { $0.distance < $1.distance }
            .prefix(20)
            .map { $0 }
            
            DispatchQueue.main.async {
                self.nearbyStations = stations
                completion(stations)
            }
        }
    }
    
    func getStationsOnRoute(route: [CLLocationCoordinate2D], completion: @escaping ([GasStation]) -> Void) {
        guard !route.isEmpty else {
            completion([])
            return
        }
        
        // Sample points along route
        let samplePoints = stride(from: 0, to: route.count, by: max(1, route.count / 10)).map { route[$0] }
        var allStations: [GasStation] = []
        let group = DispatchGroup()
        
        for coordinate in samplePoints {
            group.enter()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            findNearbyGasStations(from: location) { stations in
                allStations.append(contentsOf: stations)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Remove duplicates and sort by distance
            let uniqueStations = Dictionary(grouping: allStations, by: { $0.name + "\($0.coordinate.latitude)" })
                .compactMap { $0.value.first }
                .sorted { $0.distance < $1.distance }
            completion(Array(uniqueStations.prefix(30)))
        }
    }
    
    func simulateFuelConsumption(distanceTraveled: Double) {
        let litersUsed = (distanceTraveled / 100.0) * fuelConsumption
        let percentageUsed = (litersUsed / tankCapacity) * 100.0
        fuelLevel = max(0, fuelLevel - percentageUsed)
        updateFuelStatus(currentKm: 0, tankCapacityLiters: tankCapacity, consumptionPer100km: fuelConsumption)
    }
    
    func refuel(amount: Double) {
        let percentageAdded = (amount / tankCapacity) * 100.0
        fuelLevel = min(100.0, fuelLevel + percentageAdded)
        updateFuelStatus(currentKm: 0, tankCapacityLiters: tankCapacity, consumptionPer100km: fuelConsumption)
    }
    
    private func extractBrand(from name: String) -> String {
        let brands = ["Shell", "BP", "Esso", "Total", "Circle K", "7-Eleven", "Statoil", "YX"]
        for brand in brands {
            if name.contains(brand) {
                return brand
            }
        }
        return "Generic"
    }
}
