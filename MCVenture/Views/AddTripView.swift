//
//  AddTripView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var routeName = ""
    @State private var country = ""
    @State private var date = Date()
    @State private var distanceKm = ""
    @State private var durationHours = ""
    @State private var durationMinutes = ""
    @State private var fuelCost = ""
    @State private var rating = 0
    @State private var notes = ""
    @State private var weatherCondition = ""
    
    var body: some View {
        // // NavigationView {
            Form {
                Section(header: Text("Route Information")) {
                    TextField("Route Name", text: $routeName)
                    TextField("Country", text: $country)
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
        // NavigationView closing
                
                Section(header: Text("Trip Details")) {
                    TextField("Distance (km)", text: $distanceKm)
                        .keyboardType(.decimalPad)
                    
                    HStack {
                        TextField("Hours", text: $durationHours)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        Text("h")
                        
                        TextField("Minutes", text: $durationMinutes)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        Text("m")
                    }
                    
                    TextField("Fuel Cost (€)", text: $fuelCost)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Rating")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }
                
                Section(header: Text("Additional Info")) {
                    TextField("Weather Condition", text: $weatherCondition)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTrip()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !routeName.isEmpty && !country.isEmpty && !distanceKm.isEmpty
    }
    
    private func saveTrip() {
        guard let distance = Double(distanceKm) else { return }
        
        let hours = Double(durationHours) ?? 0
        let minutes = Double(durationMinutes) ?? 0
        let duration = (hours * 3600) + (minutes * 60)
        
        let fuel = Double(fuelCost) ?? 0
        let avgSpeed = duration > 0 ? (distance / (duration / 3600)) : 0
        
        let trip = CompletedTrip(
            routeName: routeName,
            country: country,
            date: date,
            distanceKm: distance,
            duration: duration,
            fuelCost: fuel,
            averageSpeed: avgSpeed,
            rating: rating,
            notes: notes,
            weatherCondition: weatherCondition
        )
        
        dataManager.addCompletedTrip(trip)
        dismiss()
    }
}

#Preview {
    AddTripView()
        .environmentObject(DataManager.shared)
}
