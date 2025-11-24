//
//  AddMotorcycleView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct AddMotorcycleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var selectedBrand: String = ""
    @State private var selectedModel: String = ""
    @State private var selectedMotorcycle: Motorcycle?
    @State private var currentMileage: String = ""
    @State private var searchText: String = ""
    @State private var useCustomBike = false
    @State private var customBrand: String = ""
    @State private var customModel: String = ""
    @State private var customYear: String = ""
    @State private var customFuelConsumption: String = ""
    @State private var customEngineSize: String = ""
    
    private let database = MotorcycleDatabase.shared
    
    var filteredBrands: [String] {
        if searchText.isEmpty {
            return database.brands
        }
        return database.brands.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var availableModelNames: [String] {
        if selectedBrand.isEmpty {
            return []
        }
        // Get unique model names for selected brand
        let models = database.models(for: selectedBrand)
        return Array(Set(models.map { $0.model })).sorted()
    }
    
    var availableYears: [Motorcycle] {
        if selectedBrand.isEmpty || selectedModel.isEmpty {
            return []
        }
        // Get all year variants for selected brand and model
        return database.models(for: selectedBrand, model: selectedModel).sorted { $0.year > $1.year }
    }
    
    var isValid: Bool {
        if useCustomBike {
            return !customBrand.isEmpty && !customModel.isEmpty && !customYear.isEmpty &&
                   !customFuelConsumption.isEmpty &&
                   Int(customYear) != nil && Double(customFuelConsumption) != nil &&
                   Int(customEngineSize ?? "0") != nil
        } else {
            return selectedMotorcycle != nil
        }
    }
    
    var body: some View {
        // // NavigationView {
            Form {
                Section {
                    Toggle("Add Custom Motorcycle", isOn: $useCustomBike)
                        .tint(.orange)
        // NavigationView closing
                
                if useCustomBike {
                    Section(header: Text("Custom Motorcycle Details")) {
                        TextField("Brand", text: $customBrand)
                        TextField("Model", text: $customModel)
                        TextField("Year (e.g. 1985)", text: $customYear)
                            .keyboardType(.numberPad)
                        TextField("Fuel Consumption (L/100km)", text: $customFuelConsumption)
                            .keyboardType(.decimalPad)
                        TextField("Engine Size (cc) - Optional", text: $customEngineSize)
                            .keyboardType(.numberPad)
                    }
                } else {
                    Section(header: Text("Select Motorcycle")) {
                    // Brand selection
                    Picker("Brand", selection: $selectedBrand) {
                        Text("Select Brand").tag("")
                        ForEach(database.brands, id: \.self) { brand in
                            Text(brand).tag(brand)
                        }
                    }
                    .onChange(of: selectedBrand) { _ in
                        selectedModel = ""
                        selectedMotorcycle = nil
                    }
                    
                    // Model selection (only shown when brand is selected)
                    if !selectedBrand.isEmpty {
                        Picker("Model", selection: $selectedModel) {
                            Text("Select Model").tag("")
                            ForEach(availableModelNames, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .onChange(of: selectedModel) { _ in
                            selectedMotorcycle = nil
                        }
                    }
                    
                    // Year selection (only shown when model is selected)
                    if !selectedBrand.isEmpty && !selectedModel.isEmpty {
                        Picker("Year", selection: $selectedMotorcycle) {
                            Text("Select Year").tag(nil as Motorcycle?)
                            ForEach(availableYears, id: \.id) { motorcycle in
                                Text("\(motorcycle.year)").tag(motorcycle as Motorcycle?)
                            }
                        }
                    }
                    
                    // Show selected motorcycle details
                    if let motorcycle = selectedMotorcycle {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "figure.motorcycling")
                                    .foregroundColor(.orange)
                                Text(motorcycle.displayName)
                                    .font(.headline)
                            }
                            
                            HStack {
                                Image(systemName: "engine.combustion")
                                    .foregroundColor(.orange)
                                Text("\(motorcycle.engineSize) cc")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "fuelpump")
                                    .foregroundColor(.orange)
                                Text("\(String(format: "%.1f", motorcycle.fuelConsumption)) L/100km")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    }
                }
                
                Section(header: Text("Current Mileage (Optional)")) {
                    TextField("Current Mileage (km)", text: $currentMileage)
                        .keyboardType(.decimalPad)
                }
                
                if let motorcycle = selectedMotorcycle {
                    Section(header: Text("Route Cost Calculation")) {
                        HStack {
                            Text("Fuel Consumption:")
                            Spacer()
                            Text("\(String(format: "%.1f", motorcycle.fuelConsumption)) L/100km")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("This will be used to calculate fuel costs for your selected routes based on current fuel prices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if useCustomBike && !customFuelConsumption.isEmpty, let consumption = Double(customFuelConsumption) {
                    Section(header: Text("Route Cost Calculation")) {
                        HStack {
                            Text("Fuel Consumption:")
                            Spacer()
                            Text("\(String(format: "%.1f", consumption)) L/100km")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("This will be used to calculate fuel costs for your selected routes based on current fuel prices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Motorcycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMotorcycle()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func addMotorcycle() {
        let mileage = Double(currentMileage) ?? 0.0
        
        let profile: MotorcycleProfile
        
        if useCustomBike {
            guard let year = Int(customYear),
                  let fuelConsumption = Double(customFuelConsumption) else { return }
            
            let engineSize = Int(customEngineSize) ?? 0
            
            profile = MotorcycleProfile(
                id: UUID(),
                brand: customBrand,
                model: customModel,
                year: year,
                nickname: "",
                currentMileage: mileage,
                fuelConsumption: fuelConsumption,
                tankSize: 15.0,
                tireSize: "Unknown",
                oilType: "10W-40",
                maintenanceRecords: [],
                nextServiceDue: mileage + 5000,
                photoURL: nil
            )
        } else {
            guard let motorcycle = selectedMotorcycle else { return }
            
            profile = MotorcycleProfile(
                id: UUID(),
                brand: motorcycle.brand,
                model: motorcycle.model,
                year: motorcycle.year,
                nickname: "",
                currentMileage: mileage,
                fuelConsumption: motorcycle.fuelConsumption,
                tankSize: 15.0,
                tireSize: "120/70 R17 / 180/55 R17",
                oilType: "10W-40",
                maintenanceRecords: [],
                nextServiceDue: mileage + 5000,
                photoURL: nil
            )
        }
        
        dataManager.motorcycles.append(profile)
        dismiss()
    }
}

#Preview {
    AddMotorcycleView()
        .environmentObject(DataManager.shared)
}
