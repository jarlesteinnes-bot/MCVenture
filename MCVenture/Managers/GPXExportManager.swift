//
//  GPXExportManager.swift
//  MCVenture
//
//  Created by BNTF on 24/11/2025.
//

import Foundation
import CoreLocation

class GPXExportManager {
    static let shared = GPXExportManager()
    
    private init() {}
    
    // MARK: - Export to GPX
    func exportToGPX(route: [CLLocation], name: String, description: String? = nil) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVenture" xmlns="http://www.topografix.com/GPX/1/1">
          <metadata>
            <name>\(name.xmlEscaped)</name>
        """
        
        if let desc = description {
            gpx += "\n    <desc>\(desc.xmlEscaped)</desc>"
        }
        
        gpx += """
        
            <time>\(ISO8601DateFormatter().string(from: Date()))</time>
          </metadata>
          <trk>
            <name>\(name.xmlEscaped)</name>
            <trkseg>
        
        """
        
        for location in route {
            gpx += "      <trkpt lat=\"\(location.coordinate.latitude)\" lon=\"\(location.coordinate.longitude)\">\n"
            gpx += "        <ele>\(location.altitude)</ele>\n"
            gpx += "        <time>\(ISO8601DateFormatter().string(from: location.timestamp))</time>\n"
            gpx += "      </trkpt>\n"
        }
        
        gpx += """
            </trkseg>
          </trk>
        </gpx>
        """
        
        return gpx
    }
    
    // MARK: - Export to KML
    func exportToKML(route: [CLLocation], name: String, description: String? = nil) -> String {
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(name.xmlEscaped)</name>
        """
        
        if let desc = description {
            kml += "\n    <description>\(desc.xmlEscaped)</description>"
        }
        
        kml += """
        
            <Style id="routeStyle">
              <LineStyle>
                <color>ff0000ff</color>
                <width>4</width>
              </LineStyle>
            </Style>
            <Placemark>
              <name>\(name.xmlEscaped)</name>
              <styleUrl>#routeStyle</styleUrl>
              <LineString>
                <coordinates>
        
        """
        
        for location in route {
            kml += "          \(location.coordinate.longitude),\(location.coordinate.latitude),\(location.altitude)\n"
        }
        
        kml += """
                </coordinates>
              </LineString>
            </Placemark>
          </Document>
        </kml>
        """
        
        return kml
    }
    
    // MARK: - Save to File
    func saveToFile(content: String, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save file: \(error)")
            return nil
        }
    }
    
    // MARK: - Import from GPX
    func importFromGPX(url: URL) -> [CLLocation]? {
        guard let data = try? Data(contentsOf: url),
              let xmlString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        var locations: [CLLocation] = []
        let parser = SimpleGPXParser(xmlString: xmlString)
        
        if let trackpoints = parser.parse() {
            for point in trackpoints {
                let location = CLLocation(
                    coordinate: CLLocationCoordinate2D(latitude: point.lat, longitude: point.lon),
                    altitude: point.ele ?? 0,
                    horizontalAccuracy: 10,
                    verticalAccuracy: 10,
                    timestamp: point.time ?? Date()
                )
                locations.append(location)
            }
        }
        
        return locations.isEmpty ? nil : locations
    }
}

// MARK: - XML Escaping
extension String {
    var xmlEscaped: String {
        return self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

// MARK: - Simple GPX Parser
struct GPXTrackpoint {
    let lat: Double
    let lon: Double
    let ele: Double?
    let time: Date?
}

class SimpleGPXParser {
    private let xmlString: String
    
    init(xmlString: String) {
        self.xmlString = xmlString
    }
    
    func parse() -> [GPXTrackpoint]? {
        var trackpoints: [GPXTrackpoint] = []
        
        // Simple regex-based parsing for trackpoints
        let pattern = #"<trkpt\s+lat="([^"]+)"\s+lon="([^"]+)"[^>]*>(.*?)</trkpt>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return nil
        }
        
        let nsString = xmlString as NSString
        let matches = regex.matches(in: xmlString, range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            guard match.numberOfRanges >= 4 else { continue }
            
            let latString = nsString.substring(with: match.range(at: 1))
            let lonString = nsString.substring(with: match.range(at: 2))
            let content = nsString.substring(with: match.range(at: 3))
            
            guard let lat = Double(latString), let lon = Double(lonString) else { continue }
            
            // Parse elevation
            var ele: Double? = nil
            if let eleMatch = content.range(of: #"<ele>([^<]+)</ele>"#, options: .regularExpression) {
                let eleString = String(content[eleMatch]).replacingOccurrences(of: "<ele>", with: "").replacingOccurrences(of: "</ele>", with: "")
                ele = Double(eleString)
            }
            
            // Parse time
            var time: Date? = nil
            if let timeMatch = content.range(of: #"<time>([^<]+)</time>"#, options: .regularExpression) {
                let timeString = String(content[timeMatch]).replacingOccurrences(of: "<time>", with: "").replacingOccurrences(of: "</time>", with: "")
                time = ISO8601DateFormatter().date(from: timeString)
            }
            
            trackpoints.append(GPXTrackpoint(lat: lat, lon: lon, ele: ele, time: time))
        }
        
        return trackpoints.isEmpty ? nil : trackpoints
    }
}
