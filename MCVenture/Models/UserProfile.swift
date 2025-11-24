//
//  UserProfile.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import Foundation
import Combine

struct UserProfile: Codable {
    var name: String
    var selectedMotorcycle: Motorcycle?
    var fuelPricePerLiter: Double // User's local fuel price
    
    // Emergency data is stored in EmergencyManager but can be accessed from profile
    var hasEmergencyContacts: Bool {
        !EmergencyManager.shared.emergencyContacts.isEmpty
    }
    
    var hasMedicalInfo: Bool {
        !EmergencyManager.shared.medicalInfo.bloodType.isEmpty
    }
    
    init(name: String = "", selectedMotorcycle: Motorcycle? = nil, fuelPricePerLiter: Double = 2.0) {
        self.name = name
        self.selectedMotorcycle = selectedMotorcycle
        self.fuelPricePerLiter = fuelPricePerLiter
    }
}

class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    private let userDefaultsKey = "userProfile"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func calculateFuelCost(distanceKm: Double) -> Double {
        guard let motorcycle = profile.selectedMotorcycle else { return 0 }
        let litersNeeded = (motorcycle.fuelConsumption / 100.0) * distanceKm
        return litersNeeded * profile.fuelPricePerLiter
    }
    
    func calculateLitersNeeded(distanceKm: Double) -> Double {
        guard let motorcycle = profile.selectedMotorcycle else { return 0 }
        return (motorcycle.fuelConsumption / 100.0) * distanceKm
    }
}
