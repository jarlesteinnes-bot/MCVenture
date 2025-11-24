import Foundation
import CoreLocation

class TelemetryExporter {
    
    // MARK: - GPX Export
    func exportToGPX(summary: TripSummary, routeName: String) -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="MCVenture" xmlns="http://www.topografix.com/GPX/1/1">
          <metadata>
            <name>\(routeName)</name>
            <time>\(ISO8601DateFormatter().string(from: summary.startTime))</time>
          </metadata>
          <trk>
            <name>\(routeName)</name>
            <type>motorcycle</type>
            <trkseg>
        
        """
        
        for (index, coord) in summary.coordinates.enumerated() {
            let elevation = index < summary.elevationProfile.count ? summary.elevationProfile[index].altitude : 0
            gpx += """
                  <trkpt lat="\(coord.latitude)" lon="\(coord.longitude)">
                    <ele>\(elevation)</ele>
                    <time>\(ISO8601DateFormatter().string(from: summary.startTime.addingTimeInterval(Double(index) * 10)))</time>
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
    
    // MARK: - KML Export
    func exportToKML(summary: TripSummary, routeName: String) -> String {
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(routeName)</name>
            <description>Distance: \(String(format: "%.2f", summary.distance))km, Duration: \(formatDuration(summary.duration))</description>
            <Style id="motorcycleRoute">
              <LineStyle>
                <color>ff0000ff</color>
                <width>4</width>
              </LineStyle>
            </Style>
            <Placemark>
              <name>\(routeName)</name>
              <styleUrl>#motorcycleRoute</styleUrl>
              <LineString>
                <coordinates>
        
        """
        
        for coord in summary.coordinates {
            kml += "          \(coord.longitude),\(coord.latitude),0\n"
        }
        
        kml += """
                </coordinates>
              </LineString>
            </Placemark>
        
        """
        
        // Add waypoints
        for waypoint in summary.waypoints {
            kml += """
              <Placemark>
                <name>\(waypoint.type.rawValue)</name>
                <Point>
                  <coordinates>\(waypoint.longitude),\(waypoint.latitude),0</coordinates>
                </Point>
              </Placemark>
            
            """
        }
        
        kml += """
          </Document>
        </kml>
        """
        
        return kml
    }
    
    // MARK: - CSV Export
    func exportToCSV(summary: TripSummary) -> String {
        var csv = "Timestamp,Latitude,Longitude,Elevation,Speed,Distance\n"
        
        for (index, coord) in summary.coordinates.enumerated() {
            let elevation = index < summary.elevationProfile.count ? summary.elevationProfile[index].altitude : 0
            let timestamp = summary.startTime.addingTimeInterval(Double(index) * 10)
            let distance = (Double(index) / Double(summary.coordinates.count)) * summary.distance
            
            csv += "\(ISO8601DateFormatter().string(from: timestamp)),"
            csv += "\(coord.latitude),"
            csv += "\(coord.longitude),"
            csv += "\(elevation),"
            csv += "\(summary.averageSpeed),"
            csv += "\(distance)\n"
        }
        
        return csv
    }
    
    // MARK: - Racing Lap Data Format
    func exportToRacingFormat(laps: [Lap]) -> String {
        var data = "Lap,Time,MaxSpeed,AvgSpeed,Distance,Sector1,Sector2,Sector3\n"
        
        for lap in laps {
            data += "\(lap.number),"
            data += "\(formatTime(lap.time)),"
            data += "\(String(format: "%.1f", lap.maxSpeed)),"
            data += "\(String(format: "%.1f", lap.avgSpeed)),"
            data += "\(String(format: "%.2f", lap.distance)),"
            
            for (index, sectorTime) in lap.sectorTimes.enumerated() {
                data += formatTime(sectorTime)
                if index < lap.sectorTimes.count - 1 {
                    data += ","
                }
            }
            data += "\n"
        }
        
        return data
    }
    
    // MARK: - Video Sync Markers
    func generateVideoSyncMarkers(waypoints: [TripWaypoint], startTime: Date) -> String {
        var markers = "# MCVenture Video Sync Markers\n"
        markers += "# Format: Timestamp, Type, Location, Notes\n\n"
        
        for waypoint in waypoints {
            let timestamp = waypoint.timestamp.timeIntervalSince(startTime)
            markers += "\(formatTime(timestamp)),"
            markers += "\(waypoint.type.rawValue),"
            markers += "\(waypoint.latitude),\(waypoint.longitude),"
            markers += "\(waypoint.note)\n"
        }
        
        return markers
    }
    
    // MARK: - Helper Functions
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    // MARK: - Save to File
    func saveToFile(content: String, fileName: String, fileExtension: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("\(fileName).\(fileExtension)")
        
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}
