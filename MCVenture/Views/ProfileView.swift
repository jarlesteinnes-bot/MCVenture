//
//  ProfileView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var profileManager = UserProfileManager.shared
    @State private var name: String = ""
    @State private var fuelPrice: String = ""
    @State private var showingMotorcycleSelector = false
    @State private var searchText = ""
    
    var body: some View {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        Text("Your Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Selected Motorcycle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Motorcycle")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                showingMotorcycleSelector = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let motorcycle = profileManager.profile.selectedMotorcycle {
                                            Text(motorcycle.displayName)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            
                                            Text("\(motorcycle.engineSize)cc • \(String(format: "%.1f", motorcycle.fuelConsumption))L/100km")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("Select your motorcycle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Fuel Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fuel Price (per liter)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                TextField("2.00", text: $fuelPrice)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(10)
                                
                                Text("kr")
                                    .foregroundColor(.white)
                                    .padding(.trailing)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Social & Features Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Community & Tools")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Social Feed
                            NavigationLink(destination: SocialFeedView()) {
                                HStack {
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Community Routes")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Share and discover routes")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Achievements
                            NavigationLink(destination: AchievementsView()) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.yellow)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Achievements")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Track your riding goals")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Route Planning
                            NavigationLink(destination: RoutePlanningView()) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Plan Route")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Create custom routes")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Maintenance
                            NavigationLink(destination: MaintenanceView()) {
                                HStack {
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Maintenance")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Track bike service")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Pro Mode Stats
                            NavigationLink(destination: ProModeStatsView()) {
                                HStack {
                                    Image(systemName: "gauge.high")
                                        .foregroundColor(.purple)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Pro Mode Stats")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Lean angle, G-forces, performance")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Emergency Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emergency")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Emergency Contacts
                            NavigationLink(destination: EmergencyContactsView()) {
                                HStack {
                                    Image(systemName: "person.2.badge.gearshape.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Emergency Contacts")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Who to notify in emergencies")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Medical Info
                            NavigationLink(destination: MedicalInfoView()) {
                                HStack {
                                    Image(systemName: "cross.case.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Medical Information")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                        
                                        Text("Blood type, allergies, medications")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            Text("Save Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingMotorcycleSelector) {
                MotorcycleSelectorView(selectedMotorcycle: $profileManager.profile.selectedMotorcycle)
            }
            .onAppear {
                name = profileManager.profile.name
                fuelPrice = String(format: "%.2f", profileManager.profile.fuelPricePerLiter)
            }
    }
    
    private func saveProfile() {
        profileManager.profile.name = name
        if let price = Double(fuelPrice) {
            profileManager.profile.fuelPricePerLiter = price
        }
        dismiss()
    }
}

struct MotorcycleSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMotorcycle: Motorcycle?
    @State private var searchText = ""
    @State private var selectedBrand: String? = nil
    
    private let database = MotorcycleDatabase.shared
    
    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search brand or model...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    if searchText.isEmpty {
                        // Show brands
                        List {
                            ForEach(database.brands, id: \.self) { brand in
                                Button(action: {
                                    selectedBrand = brand
                                }) {
                                    HStack {
                                        Text(brand)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .listRowBackground(Color.white.opacity(0.05))
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        // Show search results
                        List {
                            ForEach(database.search(query: searchText)) { motorcycle in
                                MotorcycleRow(motorcycle: motorcycle, isSelected: selectedMotorcycle?.id == motorcycle.id)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedMotorcycle = motorcycle
                                        dismiss()
                                    }
                                    .listRowBackground(Color.white.opacity(0.05))
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Select Motorcycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(item: $selectedBrand) { brand in
                BrandModelsView(brand: brand, selectedMotorcycle: $selectedMotorcycle, dismiss: dismiss)
            }
    }
}

struct BrandModelsView: View {
    let brand: String
    @Binding var selectedMotorcycle: Motorcycle?
    let dismiss: DismissAction
    @Environment(\.dismiss) var dismissSheet
    
    private let database = MotorcycleDatabase.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            List {
                ForEach(database.models(for: brand)) { motorcycle in
                    MotorcycleRow(motorcycle: motorcycle, isSelected: selectedMotorcycle?.id == motorcycle.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMotorcycle = motorcycle
                            dismissSheet()
                            dismiss()
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(brand)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MotorcycleRow: View {
    let motorcycle: Motorcycle
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(motorcycle.brand) \(motorcycle.model)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 15) {
                    Label("\(motorcycle.engineSize)cc", systemImage: "engine.combustion")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("\(String(format: "%.1f", motorcycle.fuelConsumption))L/100km", systemImage: "fuelpump")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    ProfileView()
}
