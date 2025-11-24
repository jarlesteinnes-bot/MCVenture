//
//  TripPhotoGalleryView.swift
//  MCVenture
//

import SwiftUI
import MapKit

struct TripPhotoGalleryView: View {
    let tripId: UUID
    @StateObject private var photoManager = PhotoCaptureManager.shared
    @State private var selectedPhoto: TripPhoto?
    @State private var showingCamera = false
    
    var photos: [TripPhoto] {
        photoManager.getPhotos(for: tripId)
    }
    
    var body: some View {
        ScrollView {
            if photos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No photos yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Capture memories from your trip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(photos) { photo in
                        PhotoThumbnail(photo: photo)
                            .onTapGesture {
                                selectedPhoto = photo
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Trip Photos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingCamera = true }) {
                    Image(systemName: "camera.fill")
                }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, tripId: tripId)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPlaceholderView(tripId: tripId)
        }
    }
}

struct PhotoThumbnail: View {
    let photo: TripPhoto
    
    var body: some View {
        if let uiImage = UIImage(data: photo.imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipped()
                .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 110, height: 110)
                .cornerRadius(8)
        }
    }
}

struct PhotoDetailView: View {
    let photo: TripPhoto
    let tripId: UUID
    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoManager = PhotoCaptureManager.shared
    @State private var caption: String
    @State private var showMap = false
    
    init(photo: TripPhoto, tripId: UUID) {
        self.photo = photo
        self.tripId = tripId
        _caption = State(initialValue: photo.caption)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            if let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 12) {
                // Caption
                TextField("Add caption...", text: $caption)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: caption) { newValue in
                        photoManager.updateCaption(photoId: photo.id, tripId: tripId, caption: newValue)
                    }
                
                // Location & Time
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                    Text(String(format: "%.4f, %.4f", photo.latitude, photo.longitude))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.green)
                    Text(photo.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(photo.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Show on Map
                Button(action: { showMap.toggle() }) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Show on Map")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .destructive, action: {
                    photoManager.deletePhoto(id: photo.id, from: tripId)
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showMap) {
            PhotoMapView(photo: photo)
        }
    }
}

struct PhotoMapView: View {
    let photo: TripPhoto
    @State private var region: MKCoordinateRegion
    
    init(photo: TripPhoto) {
        self.photo = photo
        _region = State(initialValue: MKCoordinateRegion(
            center: photo.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [photo]) { photo in
            MapPin(coordinate: photo.coordinate, tint: .red)
        }
        .ignoresSafeArea()
    }
}

struct CameraPlaceholderView: View {
    let tripId: UUID
    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoManager = PhotoCaptureManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Camera Integration")
                .font(.title2)
            
            Text("In production, this would open the device camera with GPS tagging enabled")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Simulate Photo Capture") {
                // Simulate photo capture with current location
                let location = CLLocation(latitude: 60.472, longitude: 8.4689)
                if let demoImage = createDemoImage() {
                    photoManager.capturePhoto(for: tripId, image: demoImage, location: location)
                }
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.gray)
        }
    }
    
    private func createDemoImage() -> UIImage? {
        let size = CGSize(width: 400, height: 300)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw gradient background
        let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
        context?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        
        // Add text
        let text = "Demo Photo"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
