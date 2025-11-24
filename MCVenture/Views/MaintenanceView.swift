//
//  MaintenanceView.swift
//  MCVenture
//

import SwiftUI

struct MaintenanceView: View {
    @StateObject private var manager = MaintenanceManager.shared
    @State private var showingAddItem = false
    @State private var currentOdometer = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Odometer Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Odometer")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            TextField("Enter km", text: $currentOdometer)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            
                            Button("Update") {
                                if let km = Double(currentOdometer) {
                                    manager.updateOdometer(km: km)
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // Due Items
                    if !manager.dueItems().isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Due Soon")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                            
                            ForEach(manager.dueItems()) { item in
                                MaintenanceItemRow(item: item, isDue: true)
                            }
                        }
                    }
                    
                    // All Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Maintenance Items")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(manager.items) { item in
                            MaintenanceItemRow(item: item, isDue: false)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddMaintenanceView()
        }
    }
}

struct MaintenanceItemRow: View {
    let item: MaintenanceItem
    let isDue: Bool
    @StateObject private var manager = MaintenanceManager.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.type.rawValue)
                    .font(.headline)
                    .foregroundColor(isDue ? .red : .white)
                
                Text("Last: \(String(format: "%.0f", item.lastServiceKm)) km")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Every \(String(format: "%.0f", item.intervalKm)) km")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            Button(action: {
                manager.completeMaintenanceItem(id: item.id)
            }) {
                Text("Done")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct AddMaintenanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = MaintenanceManager.shared
    @State private var selectedType = MaintenanceType.oilChange
    @State private var intervalKm = "5000"
    
    var body: some View {
            Form {
                Picker("Type", selection: $selectedType) {
                    ForEach(MaintenanceType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                TextField("Interval (km)", text: $intervalKm)
                    .keyboardType(.numberPad)
                
                Button("Add") {
                    if let interval = Double(intervalKm) {
                        manager.addMaintenanceItem(type: selectedType, intervalKm: interval)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
    }
}
