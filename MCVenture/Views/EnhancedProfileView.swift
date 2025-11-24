//
//  EnhancedProfileView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct EnhancedProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Fancy profile header
                ProfileHeaderView()
                    .environmentObject(dataManager)
                
                // Segmented picker
                Picker("View", selection: $selectedTab) {
                    Text("Motorcycles").tag(0)
                    Text("Maintenance").tag(1)
                    Text("Emergency").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    MotorcyclesContentView()
                } else if selectedTab == 1 {
                    MaintenanceContentView()
                } else {
                    EmergencyContactsContentView()
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Menu")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Motorcycles Content View
struct MotorcyclesContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddMotorcycle = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("My Motorcycles")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { showingAddMotorcycle = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            if dataManager.motorcycles.isEmpty {
                motorcycleEmptyState
            } else {
                motorcycleList
            }
        }
        .sheet(isPresented: $showingAddMotorcycle) {
            AddMotorcycleView()
                .environmentObject(dataManager)
        }
    }
    
    var motorcycleEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.motorcycling")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No motorcycles added")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Add your bike to track maintenance!")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .padding(.bottom, 100)
    }
    
    var motorcycleList: some View {
        VStack(spacing: 12) {
            ForEach(dataManager.motorcycles) { motorcycle in
                NavigationLink(destination: MotorcycleDetailView(motorcycle: motorcycle)) {
                    MotorcycleProfileRow(motorcycle: motorcycle)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct MotorcycleProfileRow: View {
    let motorcycle: MotorcycleProfile
    
    var body: some View {
        GeometryReader { geometry in
            let isSmallScreen = geometry.size.width < 375
            makeContent(isSmallScreen: isSmallScreen)
        }
        .frame(height: 100)
    }
    
    @ViewBuilder
    private func makeContent(isSmallScreen: Bool) -> some View {
        HStack(spacing: isSmallScreen ? 12 : 15) {
            ZStack {
                let iconSize: CGFloat = isSmallScreen ? 50 : 60
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: iconSize, height: iconSize)
                Image(systemName: "figure.motorcycling")
                    .font(.system(size: isSmallScreen ? 24 : 28, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: isSmallScreen ? 4 : 5) {
                Text(motorcycle.nickname.isEmpty ? "\(motorcycle.brand) \(motorcycle.model)" : motorcycle.nickname)
                    .font(isSmallScreen ? .subheadline : .headline)
                    .fontWeight(isSmallScreen ? .semibold : .regular)
                
                Text("\(motorcycle.brand) \(motorcycle.model) (\(motorcycle.year))")
                    .font(isSmallScreen ? .caption : .subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: isSmallScreen ? 10 : 15) {
                    HStack(spacing: isSmallScreen ? 3 : 5) {
                        Image(systemName: "speedometer")
                            .font(isSmallScreen ? .caption2 : .caption)
                        Text("\(Int(motorcycle.currentMileage)) km")
                            .font(isSmallScreen ? .caption2 : .caption)
                    }
                    
                    if motorcycle.nextServiceDue > motorcycle.currentMileage {
                        HStack(spacing: isSmallScreen ? 3 : 5) {
                            Image(systemName: "wrench.fill")
                                .font(isSmallScreen ? .caption2 : .caption)
                            Text("Service in \(Int(motorcycle.nextServiceDue - motorcycle.currentMileage)) km")
                                .font(isSmallScreen ? .caption2 : .caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundColor(.orange)
                    } else if motorcycle.nextServiceDue > 0 {
                        HStack(spacing: isSmallScreen ? 3 : 5) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(isSmallScreen ? .caption2 : .caption)
                            Text("Service overdue!")
                                .font(isSmallScreen ? .caption2 : .caption)
                        }
                        .foregroundColor(.red)
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(isSmallScreen ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Maintenance Content View
struct MaintenanceContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddRecord = false
    
    var sortedRecords: [MaintenanceRecord] {
        dataManager.maintenanceRecords.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Maintenance Records")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { showingAddRecord = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            if sortedRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No maintenance records")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Track your bike's service history!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
                .padding(.bottom, 100)
            } else {
                VStack(spacing: 12) {
                    ForEach(sortedRecords) { record in
                        MaintenanceRow(record: record)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            Text("Add Maintenance Record (TODO)")
        }
    }
}

struct MaintenanceRow: View {
    let record: MaintenanceRecord
    @EnvironmentObject var dataManager: DataManager
    
    var motorcycleName: String {
        if let bike = dataManager.motorcycles.first(where: { $0.id == record.motorcycleId }) {
            return bike.nickname.isEmpty ? "\(bike.brand) \(bike.model)" : bike.nickname
        }
        return "Unknown Motorcycle"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "wrench.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(record.type.rawValue)
                    .font(.headline)
                Spacer()
                Text("€\(Int(record.cost))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(motorcycleName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                Text(record.date, style: .date)
                
                Text("•")
                
                Image(systemName: "speedometer")
                Text("\(Int(record.mileage)) km")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !record.description.isEmpty {
                Text(record.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Emergency Contacts Content View
struct EmergencyContactsContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddContact = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Emergency Contacts")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { showingAddContact = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            if dataManager.emergencyContacts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No emergency contacts")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Add contacts for safety!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
                .padding(.bottom, 100)
            } else {
                VStack(spacing: 12) {
                    ForEach(dataManager.emergencyContacts) { contact in
                        EmergencyContactRow(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddContact) {
            Text("Add Emergency Contact (TODO)")
        }
    }
    
    private func deleteContacts(at offsets: IndexSet) {
        offsets.forEach { index in
            let contact = dataManager.emergencyContacts[index]
            dataManager.deleteEmergencyContact(contact)
        }
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        contact.isPrimary
                        ? LinearGradient(
                            colors: [.red.opacity(0.3), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                Image(systemName: contact.isPrimary ? "star.fill" : "person.fill")
                    .foregroundStyle(
                        contact.isPrimary
                        ? LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                Text(contact.relationship)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.caption)
                    Text(contact.phone)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if let url = URL(string: "tel://\(contact.phone)") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #endif
                }
            }) {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

struct MotorcycleDetailView: View {
    let motorcycle: MotorcycleProfile
    
    var body: some View {
        Text("Motorcycle details for \(motorcycle.brand) \(motorcycle.model)")
            .navigationTitle(motorcycle.nickname.isEmpty ? "\(motorcycle.brand) \(motorcycle.model)" : motorcycle.nickname)
    }
}

// // #Preview {
//     // NavigationView {
//         EnhancedProfileView()
//             .environmentObject(DataManager.shared)
//     }
// }
