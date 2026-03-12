import SwiftUI
import UIKit

struct ExportTripView: View {
    let tripSummary: TripSummary
    let tripName: String
    @Environment(\.dismiss) var dismiss
    @State private var selectedFormat: ExportFormat = .gpx
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var showingSuccess = false
    
    enum ExportFormat: String, CaseIterable {
        case gpx = "GPX"
        case kml = "KML"
        case csv = "CSV"
        case racing = "Racing Data"
        
        var icon: String {
            switch self {
            case .gpx: return "map.fill"
            case .kml: return "globe"
            case .csv: return "tablecells"
            case .racing: return "flag.checkered"
            }
        }
        
        var description: String {
            switch self {
            case .gpx: return "Compatible with Strava, Garmin, Komoot"
            case .kml: return "View in Google Earth"
            case .csv: return "Raw data for Excel, Python, R"
            case .racing: return "Professional lap analysis format"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .gpx: return "gpx"
            case .kml: return "kml"
            case .csv: return "csv"
            case .racing: return "csv"
            }
        }
    }
    
    var body: some View {
        // // NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Trip Summary Card
                        VStack(spacing: 12) {
                            Text(tripName)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            HStack(spacing: 30) {
                                VStack {
                                    Text(String(format: "%.2f km", tripSummary.distance))
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text("Distance")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
        // NavigationView closing
                                
                                VStack {
                                    Text(formatDuration(tripSummary.duration))
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Duration")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                VStack {
                                    Text(String(format: "%.0f km/h", tripSummary.maxSpeed))
                                        .font(.headline)
                                        .foregroundColor(.red)
                                    Text("Max Speed")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Format Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("EXPORT FORMAT")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                FormatButton(
                                    format: format,
                                    isSelected: selectedFormat == format
                                ) {
                                    selectedFormat = format
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        
                        // Export Button
                        Button(action: exportData) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                Text("Export \(selectedFormat.rawValue)")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                        }
                        
                        // Pro Tip
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pro Tip")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.blue)
                                Text("GPX files can be imported into Strava, Garmin Connect, and most cycling/motorcycle apps.")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Export Successful", isPresented: $showingSuccess) {
            Button("OK") {
                showingSuccess = false
            }
        } message: {
            Text("Your trip data has been exported successfully!")
        }
    }
    
    private func exportData() {
        let exporter = TelemetryExporter()
        let content: String
        let fileName = "\(tripName.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970)"
        
        switch selectedFormat {
        case .gpx:
            content = exporter.exportToGPX(summary: tripSummary, routeName: tripName)
        case .kml:
            content = exporter.exportToKML(summary: tripSummary, routeName: tripName)
        case .csv:
            content = exporter.exportToCSV(summary: tripSummary)
        case .racing:
            // Convert to lap format if lap data available
            let proManager = ProModeManager.shared
            if !proManager.lapTimer.laps.isEmpty {
                content = exporter.exportToRacingFormat(laps: proManager.lapTimer.laps)
            } else {
                content = exporter.exportToCSV(summary: tripSummary)
            }
        }
        
        if let url = exporter.saveToFile(
            content: content,
            fileName: fileName,
            fileExtension: selectedFormat.fileExtension
        ) {
            exportedFileURL = url
            showingShareSheet = true
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct FormatButton: View {
    let format: ExportTripView.ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: format.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .orange : .white.opacity(0.6))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    Text(format.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                isSelected ? Color.orange.opacity(0.2) : Color.white.opacity(0.05)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct ShareSheet: View {
    let items: [Any]
    var body: some View {
        Text("Sharing not available on macOS")
    }
}
#endif
