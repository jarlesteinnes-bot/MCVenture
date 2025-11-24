//
//  RoutePlanningManager.swift
//  MCVenture
//

import Foundation
import CoreLocation
import MapKit
import Combine

class RoutePlanningManager: ObservableObject {
    static let shared = RoutePlanningManager()
    
    @Published var plannedWaypoints: [CLLocationCoordinate2D] = []
    @Published var avoidHighways = false
    @Published var maximizeCurves = false
    @Published var preferScenicRoutes = true
    
    private init() {}
    
    func addWaypoint(_ coordinate: CLLocationCoordinate2D) {
        plannedWaypoints.append(coordinate)
    }
    
    func removeWaypoint(at index: Int) {
        guard index < plannedWaypoints.count else { return }
        plannedWaypoints.remove(at: index)
    }
    
    func clearWaypoints() {
        plannedWaypoints.removeAll()
    }
    
    func calculateOptimalRoute(completion: @escaping ([CLLocationCoordinate2D]?) -> Void) {
        guard plannedWaypoints.count >= 2 else {
            completion(nil)
            return
        }
        
        var routePoints: [CLLocationCoordinate2D] = []
        let group = DispatchGroup()
        
        for i in 0..<(plannedWaypoints.count - 1) {
            group.enter()
            calculateSegment(from: plannedWaypoints[i], to: plannedWaypoints[i + 1]) { points in
                if let points = points {
                    routePoints.append(contentsOf: points)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(routePoints.isEmpty ? nil : routePoints)
        }
    }
    
    private func calculateSegment(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping ([CLLocationCoordinate2D]?) -> Void) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        if avoidHighways {
            request.transportType = .walking // Approximation for avoiding highways
        }
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                completion(nil)
                return
            }
            
            let coordinates = route.polyline.points()
            let count = route.polyline.pointCount
            var coords: [CLLocationCoordinate2D] = []
            
            for i in 0..<count {
                let point = coordinates[i]
                coords.append(point.coordinate)
            }
            
            completion(coords)
        }
    }
    
    func importGPX(url: URL) -> [CLLocationCoordinate2D]? {
        guard let locations = GPXExportManager.shared.importFromGPX(url: url) else {
            return nil
        }
        return locations.map { $0.coordinate }
    }
}
