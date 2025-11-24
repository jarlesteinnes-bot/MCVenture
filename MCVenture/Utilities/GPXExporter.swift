//
//  GPXExporter.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation

class GPXExporter {
    static let shared = GPXExporter()
    
    private init() {}
    
    // MARK: - Export Route as GPX
    func exportRoute(_ route: ScrapedRoute) -> URL? {
        let gpxString = generateGPX(for: route)
        return saveGPXToFile(gpxString, filename: "\(route.name).gpx")
    }
    
    // MARK: - Export Trip as GPX
    func exportTrip(coordinates: [CLLocationCoordinate2D], 
                   elevationProfile: [ElevationPoint],
                   name: String,
                   startTime: Date,
                   endTime: Date) -> URL? {
        let gpxString = generateGPXFromTrip(
            coordinates: coordinates,
            elevationProfile: elevationProfile,
            name: name,
            startTime: startTime,
            endTime: endTime
        )
        return saveGPXToFile(gpxString, filename: "\(name).gpx")
    }
    
    // MARK: - Generate GPX from ScrapedRoute
    private func generateGPX(for route: ScrapedRoute) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVenture" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
          <metadata>
            <name>\(escapeXML(route.name))</name>
            <desc>\(escapeXML(route.description))</desc>
            <author>
              <name>MCVenture</name>
            </author>
            <time>\(iso8601DateString(route.scrapedDate))</time>
          </metadata>
          <trk>
            <name>\(escapeXML(route.name))</name>
            <desc>\(escapeXML(route.description))</desc>
            <type>\(route.difficulty.rawValue)</type>
            <trkseg>
        
        """
        
        // Add track points
        for coordinate in route.coordinates {
            gpx += "      <trkpt lat=\"\(coordinate.latitude)\" lon=\"\(coordinate.longitude)\">\n"
            if let elevation = coordinate.elevation {
                gpx += "        <ele>\(elevation)</ele>\n"
            }
            gpx += "      </trkpt>\n"
        }
        
        gpx += """
            </trkseg>
          </trk>
        
        """
        
        // Add waypoints (start, end, and POIs)
        gpx += "  <wpt lat=\"\(route.startPoint.coordinate.latitude)\" lon=\"\(route.startPoint.coordinate.longitude)\">\n"
        gpx += "    <name>\(escapeXML(route.startPoint.name))</name>\n"
        gpx += "    <type>start</type>\n"
        gpx += "  </wpt>\n"
        
        gpx += "  <wpt lat=\"\(route.endPoint.coordinate.latitude)\" lon=\"\(route.endPoint.coordinate.longitude)\">\n"
        gpx += "    <name>\(escapeXML(route.endPoint.name))</name>\n"
        gpx += "    <type>end</type>\n"
        gpx += "  </wpt>\n"
        
        // Add POIs
        for poi in route.nearbyPOIs {
            gpx += "  <wpt lat=\"\(poi.coordinate.latitude)\" lon=\"\(poi.coordinate.longitude)\">\n"
            gpx += "    <name>\(escapeXML(poi.name))</name>\n"
            gpx += "    <type>\(escapeXML(poi.type))</type>\n"
            gpx += "  </wpt>\n"
        }
        
        gpx += "</gpx>"
        
        return gpx
    }
    
    // MARK: - Generate GPX from Trip
    private func generateGPXFromTrip(coordinates: [CLLocationCoordinate2D],
                                    elevationProfile: [ElevationPoint],
                                    name: String,
                                    startTime: Date,
                                    endTime: Date) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVenture" xmlns="http://www.topografix.com/GPX/1/1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
          <metadata>
            <name>\(escapeXML(name))</name>
            <desc>GPS tracked trip from MCVenture</desc>
            <author>
              <name>MCVenture</name>
            </author>
            <time>\(iso8601DateString(startTime))</time>
          </metadata>
          <trk>
            <name>\(escapeXML(name))</name>
            <trkseg>
        
        """
        
        // Add track points with elevation
        for (index, coordinate) in coordinates.enumerated() {
            gpx += "      <trkpt lat=\"\(coordinate.latitude)\" lon=\"\(coordinate.longitude)\">\n"
            
            // Add elevation if available
            if index < elevationProfile.count {
                gpx += "        <ele>\(elevationProfile[index].altitude)</ele>\n"
            }
            
            // Calculate timestamp based on distance along route
            let progress = Double(index) / Double(max(1, coordinates.count - 1))
            let timestamp = startTime.addingTimeInterval(endTime.timeIntervalSince(startTime) * progress)
            gpx += "        <time>\(iso8601DateString(timestamp))</time>\n"
            
            gpx += "      </trkpt>\n"
        }
        
        gpx += """
            </trkseg>
          </trk>
        </gpx>
        """
        
        return gpx
    }
    
    // MARK: - Save GPX to File
    private func saveGPXToFile(_ gpxString: String, filename: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try gpxString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving GPX file: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Helpers
    private func escapeXML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
    
    private func iso8601DateString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
