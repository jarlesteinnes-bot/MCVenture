//
//  MoreView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI
import CoreLocation
import Combine
import UIKit

struct MoreView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            Section(header: Text("Safety")) {
                NavigationLink(destination: SOSView()) {
                    Label("Emergency SOS", systemImage: "sos.circle.fill")
                        .foregroundColor(.red)
                }
                
                NavigationLink(destination: Text("Nearby Hospitals (TODO)")) {
                    Label("Nearby Hospitals", systemImage: "cross.circle.fill")
                }
            }
            
            Section(header: Text("Trip Planning")) {
                NavigationLink(destination: PackingListsView()) {
                    Label("Packing Lists", systemImage: "list.bullet.clipboard")
                }
                
                NavigationLink(destination: Text("Custom Routes (TODO)")) {
                    Label("Create Custom Route", systemImage: "pencil.and.outline")
                }
                
                NavigationLink(destination: Text("Offline Maps (TODO)")) {
                    Label("Offline Maps", systemImage: "map")
                }
            }
            
            Section(header: Text("Weather")) {
                NavigationLink(destination: Text("Extended Weather (TODO)")) {
                    Label("7-Day Forecast", systemImage: "cloud.sun.fill")
                }
                
                NavigationLink(destination: Text("Rain Radar (TODO)")) {
                    Label("Rain Radar", systemImage: "cloud.rain.fill")
                }
            }
            
            Section(header: Text("Points of Interest")) {
                NavigationLink(destination: Text("POI Finder (TODO)")) {
                    Label("Find POIs", systemImage: "mappin.and.ellipse")
                }
            }
            
            Section(header: Text("Settings")) {
                NavigationLink(destination: BasicSettingsView()) {
                    Label("App Settings", systemImage: "gearshape.fill")
                }
                
                NavigationLink(destination: Text("About (TODO)")) {
                    Label("About MCVenture", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("More")
    }
}

// MARK: - SOS View
struct SOSView: View {
    @State private var showingEmergencyAlert = false
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var locationManager = SOSLocationManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Emergency Button
                VStack(spacing: 20) {
                    Image(systemName: "sos.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.red)
                    
                    Text("Emergency SOS")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Press and hold to activate emergency alert")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showingEmergencyAlert = true
                    }) {
                        Text("ACTIVATE SOS")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                // Current Location
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Current Location")
                        .font(.headline)
                    
                    if let location = locationManager.currentLocation, let placemark = locationManager.currentPlacemark {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                Text("\(placemark.locality ?? "Unknown"), \(placemark.country ?? "")")
                            }
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.gray)
                                Text("Lat: \(location.coordinate.latitude, specifier: "%.6f"), Lon: \(location.coordinate.longitude, specifier: "%.6f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Text("Location unavailable")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Emergency Contacts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Emergency Contacts")
                        .font(.headline)
                    
                    if dataManager.emergencyContacts.isEmpty {
                        Text("No emergency contacts added")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dataManager.emergencyContacts.filter { $0.isPrimary }) { contact in
                            Button(action: {
                                if let url = URL(string: "tel://\(contact.phone)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading) {
                                        Text(contact.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(contact.phone)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quick Actions")
                        .font(.headline)
                    
                    Button(action: {
                        if let url = URL(string: "tel://112") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call 112 (European Emergency)")
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Share location
                        shareLocation()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Share My Location")
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // European Emergency Numbers
                NavigationLink(destination: EuropeanEmergencyNumbersView()) {
                    HStack {
                        Image(systemName: "globe.europe.africa.fill")
                            .foregroundColor(.orange)
                        Text("Emergency Numbers by Country")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Emergency SOS")
        .alert("Emergency SOS", isPresented: $showingEmergencyAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Call Emergency", role: .destructive) {
                if let url = URL(string: "tel://112") {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("This will call emergency services (112) and alert your emergency contacts.")
        }
    }
    
    private func shareLocation() {
        guard let location = locationManager.currentLocation else { return }
        
        let coordinate = location.coordinate
        let message = "I need help! My location is: https://maps.google.com/?q=\(coordinate.latitude),\(coordinate.longitude)"
        
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Packing Lists View
struct PackingListsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddList = false
    
    var body: some View {
        List {
            ForEach(dataManager.packingLists) { list in
                NavigationLink(destination: PackingListDetailView(list: list)) {
                    PackingListRow(list: list)
                }
            }
        }
        .navigationTitle("Packing Lists")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddList = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddList) {
            Text("Create Packing List (TODO)")
        }
    }
}

struct PackingListRow: View {
    let list: PackingList
    
    var packedCount: Int {
        list.items.filter { $0.isPacked }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(list.name)
                .font(.headline)
            
            HStack {
                Text(list.tripType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(packedCount)/\(list.items.count) packed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(packedCount), total: Double(list.items.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding(.vertical, 5)
    }
}

struct PackingListDetailView: View {
    let list: PackingList
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            ForEach(list.items) { item in
                HStack {
                    Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isPacked ? .green : .gray)
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if item.isEssential {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .onTapGesture {
                    togglePacked(item: item)
                }
            }
        }
        .navigationTitle(list.name)
    }
    
    private func togglePacked(item: PackingItem) {
        var updatedList = list
        if let index = updatedList.items.firstIndex(where: { $0.id == item.id }) {
            updatedList.items[index].isPacked.toggle()
            dataManager.updatePackingList(updatedList)
        }
    }
}

// MARK: - Basic Settings View
struct BasicSettingsView: View {
    @AppStorage("autoOpenGoogleMaps") private var autoOpenGoogleMaps = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("preferredUnits") private var preferredUnits = "Metric"
    
    var body: some View {
        Form {
            Section(header: Text("User Profile")) {
                TextField("Name", text: $userName)
            }
            
            Section(header: Text("Navigation")) {
                Toggle("Auto-open Google Maps", isOn: $autoOpenGoogleMaps)
            }
            
            Section(header: Text("Units")) {
                Picker("Preferred Units", selection: $preferredUnits) {
                    Text("Metric (km)").tag("Metric")
                    Text("Imperial (miles)").tag("Imperial")
                }
            }
            
            Section(header: Text("Data")) {
                Button("Export Trip Data") {
                    // TODO: Export functionality
                }
                
                Button("Clear Cache") {
                    // TODO: Clear cache
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - European Emergency Numbers
struct EuropeanEmergencyNumbersView: View {
    @State private var searchText = ""
    
    var filteredCountries: [EmergencyCountry] {
        if searchText.isEmpty {
            return emergencyNumbers
        }
        return emergencyNumbers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            Section(header: Text("Universal European Number")) {
                EmergencyNumberRow(
                    icon: "🇪🇺",
                    title: "112",
                    subtitle: "All European Countries",
                    description: "General Emergency (Police, Fire, Ambulance)",
                    number: "112",
                    isPrimary: true
                )
            }
            
            ForEach(filteredCountries) { country in
                Section(header: HStack {
                    Text(country.flag)
                    Text(country.name)
                }) {
                    ForEach(country.numbers) { emergency in
                        EmergencyNumberRow(
                            icon: country.flag,
                            title: emergency.number,
                            subtitle: emergency.service,
                            description: emergency.description,
                            number: emergency.number,
                            isPrimary: emergency.number == "112"
                        )
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search country")
        .navigationTitle("Emergency Numbers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmergencyNumberRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let number: String
    let isPrimary: Bool
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel://\(number)") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 15) {
                Text(icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isPrimary ? .red : .primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isPrimary ? .red : .green)
            }
            .padding(.vertical, 8)
        }
    }
}

struct EmergencyNumber: Identifiable {
    let id = UUID()
    let number: String
    let service: String
    let description: String
}

struct EmergencyCountry: Identifiable {
    let id = UUID()
    let name: String
    let flag: String
    let numbers: [EmergencyNumber]
}

let emergencyNumbers: [EmergencyCountry] = [
    EmergencyCountry(name: "Austria", flag: "🇦🇹", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "133", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "122", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "144", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Belgium", flag: "🇧🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "101", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "100", service: "Fire & Ambulance", description: "Fire and medical emergency")
    ]),
    EmergencyCountry(name: "Croatia", flag: "🇭🇷", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "192", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "193", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "194", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Czech Republic", flag: "🇨🇿", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "158", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "150", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "155", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Denmark", flag: "🇩🇰", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Finland", flag: "🇫🇮", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "France", flag: "🇫🇷", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "17", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "18", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "15", service: "SAMU (Ambulance)", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Germany", flag: "🇩🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "110", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "Greece", flag: "🇬🇷", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "100", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "199", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "166", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Hungary", flag: "🇭🇺", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "107", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "105", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "104", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Ireland", flag: "🇮🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "999", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Italy", flag: "🇮🇹", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "113", service: "Police", description: "State police"),
        EmergencyNumber(number: "115", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "118", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Netherlands", flag: "🇳🇱", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Norway", flag: "🇳🇴", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "110", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "113", service: "Medical Emergency", description: "Ambulance")
    ]),
    EmergencyCountry(name: "Poland", flag: "🇵🇱", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "997", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "998", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "999", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Portugal", flag: "🇵🇹", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Romania", flag: "🇷🇴", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Slovakia", flag: "🇸🇰", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "158", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "150", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "155", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Slovenia", flag: "🇸🇮", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "113", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "Spain", flag: "🇪🇸", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "091", service: "Police", description: "National police"),
        EmergencyNumber(number: "080", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "061", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Sweden", flag: "🇸🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Switzerland", flag: "🇨🇭", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "117", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "118", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "144", service: "Ambulance", description: "Medical emergency"),
        EmergencyNumber(number: "1414", service: "REGA", description: "Air rescue")
    ]),
    EmergencyCountry(name: "United Kingdom", flag: "🇬🇧", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "999", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Iceland", flag: "🇮🇸", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Estonia", flag: "🇪🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Latvia", flag: "🇱🇻", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Lithuania", flag: "🇱🇹", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Luxembourg", flag: "🇱🇺", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "113", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "Malta", flag: "🇲🇹", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Cyprus", flag: "🇨🇾", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "199", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "199", service: "Fire Brigade", description: "Fire emergency")
    ]),
    EmergencyCountry(name: "Bulgaria", flag: "🇧🇬", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "166", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "160", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "150", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Serbia", flag: "🇷🇸", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "192", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "193", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "194", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Montenegro", flag: "🇲🇪", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "122", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "Bosnia & Herzegovina", flag: "🇧🇦", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "122", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "123", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "124", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Albania", flag: "🇦🇱", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "129", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "North Macedonia", flag: "🇲🇰", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "192", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "193", service: "Fire Brigade", description: "Fire emergency"),
        EmergencyNumber(number: "194", service: "Ambulance", description: "Medical emergency")
    ]),
    EmergencyCountry(name: "Andorra", flag: "🇦🇩", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance")
    ]),
    EmergencyCountry(name: "Monaco", flag: "🇲🇨", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "17", service: "Police", description: "Direct police line"),
        EmergencyNumber(number: "18", service: "Fire Brigade", description: "Fire emergency")
    ]),
    EmergencyCountry(name: "Liechtenstein", flag: "🇱🇮", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "117", service: "Police", description: "Direct police line")
    ]),
    EmergencyCountry(name: "San Marino", flag: "🇸🇲", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "113", service: "Police", description: "State police")
    ]),
    EmergencyCountry(name: "Vatican City", flag: "🇻🇦", numbers: [
        EmergencyNumber(number: "112", service: "General Emergency", description: "Police, Fire, Ambulance"),
        EmergencyNumber(number: "113", service: "Vatican Police", description: "Gendarmerie")
    ])
]

// MARK: - SOS Location Manager
class SOSLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // Reverse geocode to get placemark
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                self?.currentPlacemark = placemark
            }
        }
    }
}

// // #Preview {
//     // NavigationView {
//         MoreView()
//             .environmentObject(DataManager.shared)
//     }
// }
