//
//  DataExportManager.swift
//  MCVenture
//

import Foundation
import CoreLocation

class DataExportManager {
    static let shared = DataExportManager()
    
    private init() {}
    
    // MARK: - Export All Data
    
    func exportAllData() -> URL? {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let exportURL = documentsURL.appendingPathComponent("MCVenture_Export_\(timestamp)")
        
        do {
            try fileManager.createDirectory(at: exportURL, withIntermediateDirectories: true)
            
            // Export trips as JSON
            if let tripsJSON = exportTripsJSON() {
                let tripsURL = exportURL.appendingPathComponent("trips.json")
                try tripsJSON.write(to: tripsURL, atomically: true, encoding: .utf8)
            }
            
            // Export routes as JSON
            if let routesJSON = exportRoutesJSON() {
                let routesURL = exportURL.appendingPathComponent("routes.json")
                try routesJSON.write(to: routesURL, atomically: true, encoding: .utf8)
            }
            
            // Export settings
            if let settingsJSON = exportSettingsJSON() {
                let settingsURL = exportURL.appendingPathComponent("settings.json")
                try settingsJSON.write(to: settingsURL, atomically: true, encoding: .utf8)
            }
            
            // Create a zip archive
            return createZipArchive(from: exportURL)
            
        } catch {
            print("Export failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Export Trips
    
    func exportTripsJSON() -> String? {
        // Fetch all trips from persistent storage
        // This is a placeholder - integrate with your actual data model
        let trips: [[String: Any]] = []
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: trips, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to export trips: \(error.localizedDescription)")
            return nil
        }
    }
    
    func exportTripGPX(tripId: String, name: String, coordinates: [CLLocationCoordinate2D], timestamps: [Date]) -> URL? {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let gpxContent = generateGPX(name: name, coordinates: coordinates, timestamps: timestamps)
        let fileName = "\(name.replacingOccurrences(of: " ", with: "_"))_\(tripId).gpx"
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try gpxContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to export GPX: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Export Routes
    
    func exportRoutesJSON() -> String? {
        // Fetch all routes from persistent storage
        let routes: [[String: Any]] = []
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: routes, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to export routes: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Export Settings
    
    func exportSettingsJSON() -> String? {
        let settings: [String: Any] = [
            "simplifiedMode": SimplifiedModeManager.shared.isSimplifiedMode,
            "speedLimitWarning": SpeedLimitManager.shared.isEnabled,
            "speedLimit": SpeedLimitManager.shared.speedLimit,
            "speedOffset": SpeedLimitManager.shared.warningOffset,
            "crashDetectionEnabled": UserDefaults.standard.bool(forKey: "crashDetectionEnabled"),
            "crashThreshold": UserDefaults.standard.double(forKey: "crashDetectionThreshold"),
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: settings, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to export settings: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - GPX Generation
    
    private func generateGPX(name: String, coordinates: [CLLocationCoordinate2D], timestamps: [Date]) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVenture" xmlns="http://www.topografix.com/GPX/1/1">
          <metadata>
            <name>\(name)</name>
            <time>\(ISO8601DateFormatter().string(from: Date()))</time>
          </metadata>
          <trk>
            <name>\(name)</name>
            <trkseg>
        """
        
        for (index, coordinate) in coordinates.enumerated() {
            let timestamp = index < timestamps.count ? timestamps[index] : Date()
            let timeString = ISO8601DateFormatter().string(from: timestamp)
            
            gpx += """
            
                  <trkpt lat="\(coordinate.latitude)" lon="\(coordinate.longitude)">
                    <time>\(timeString)</time>
                  </trkpt>
            """
        }
        
        gpx += """
        
            </trkseg>
          </trk>
        </gpx>
        """
        
        return gpx
    }
    
    // MARK: - Zip Archive
    
    private func createZipArchive(from directory: URL) -> URL? {
        // This is a placeholder - implement actual zip functionality
        // You might want to use a third-party library like ZIPFoundation
        // or use the native compression APIs
        
        let fileManager = FileManager.default
        let zipURL = directory.deletingLastPathComponent().appendingPathComponent("\(directory.lastPathComponent).zip")
        
        // Placeholder: In production, implement actual zip creation
        // For now, just return the directory
        return directory
    }
    
    // MARK: - Share Data
    
    func prepareShareData(for tripId: String) -> [Any] {
        var items: [Any] = []
        
        // Add text summary
        let summary = "Check out my motorcycle ride recorded with MCVenture! 🏍️"
        items.append(summary)
        
        // Add GPX file if available
        // This would integrate with your trip data model
        
        return items
    }
}

// MARK: - Import Data

extension DataExportManager {
    func importFromJSON(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Parse and restore data
            // Integrate with your data model
            
            return true
        } catch {
            print("Import failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func importGPX(url: URL) -> Bool {
        do {
            let gpxString = try String(contentsOf: url, encoding: .utf8)
            
            // Parse GPX and create route/trip
            // Integrate with your data model
            
            return true
        } catch {
            print("GPX import failed: \(error.localizedDescription)")
            return false
        }
    }
}
