//
//  MaintenanceManager.swift
//  MCVenture
//

import Foundation
import Combine

struct MaintenanceItem: Identifiable, Codable {
    let id: UUID
    let type: MaintenanceType
    var lastServiceDate: Date
    var lastServiceKm: Double
    var intervalKm: Double
    var intervalMonths: Int
    var notes: String
    
    enum MaintenanceType: String, Codable, CaseIterable {
        case oilChange = "Oil Change"
        case tireReplacement = "Tire Replacement"
        case brakeService = "Brake Service"
        case chainLube = "Chain Lube"
        case airFilter = "Air Filter"
        case sparkPlugs = "Spark Plugs"
        case coolant = "Coolant"
        case brakeFluid = "Brake Fluid"
        case general = "General Service"
        
        var icon: String {
            switch self {
            case .oilChange: return "drop.fill"
            case .tireReplacement: return "circle.dotted"
            case .brakeService: return "brake.signal"
            case .chainLube: return "link"
            case .airFilter: return "wind"
            case .sparkPlugs: return "bolt.fill"
            case .coolant: return "thermometer"
            case .brakeFluid: return "drop.triangle"
            case .general: return "wrench.and.screwdriver.fill"
            }
        }
    }
    
    func isDue(currentKm: Double) -> Bool {
        let kmSince = currentKm - lastServiceKm
        let monthsSince = Calendar.current.dateComponents([.month], from: lastServiceDate, to: Date()).month ?? 0
        return kmSince >= intervalKm || monthsSince >= intervalMonths
    }
    
    func daysUntilDue(currentKm: Double) -> Int? {
        let monthsSince = Calendar.current.dateComponents([.month], from: lastServiceDate, to: Date()).month ?? 0
        let monthsRemaining = intervalMonths - monthsSince
        if monthsRemaining <= 0 { return 0 }
        return monthsRemaining * 30
    }
}

typealias MaintenanceType = MaintenanceItem.MaintenanceType

class MaintenanceManager: ObservableObject {
    static let shared = MaintenanceManager()
    
    @Published var items: [MaintenanceItem] = []
    @Published var maintenanceItems: [MaintenanceItem] = []
    @Published var currentOdometer: Double = 0
    
    private init() {
        loadMaintenanceItems()
        loadOdometer()
    }
    
    func addMaintenanceItem(type: MaintenanceType, intervalKm: Double, intervalMonths: Int = 12, notes: String = "") {
        let item = MaintenanceItem(
            id: UUID(),
            type: type,
            lastServiceDate: Date(),
            lastServiceKm: currentOdometer,
            intervalKm: intervalKm,
            intervalMonths: intervalMonths,
            notes: notes
        )
        maintenanceItems.append(item)
        items = maintenanceItems
        saveMaintenanceItems()
    }
    
    func addMaintenanceItem(_ item: MaintenanceItem) {
        maintenanceItems.append(item)
        items = maintenanceItems
        saveMaintenanceItems()
    }
    
    func updateMaintenanceItem(_ item: MaintenanceItem) {
        if let index = maintenanceItems.firstIndex(where: { $0.id == item.id }) {
            maintenanceItems[index] = item
            saveMaintenanceItems()
        }
    }
    
    func deleteMaintenanceItem(_ item: MaintenanceItem) {
        maintenanceItems.removeAll { $0.id == item.id }
        saveMaintenanceItems()
    }
    
    func dueItems() -> [MaintenanceItem] {
        maintenanceItems.filter { $0.isDue(currentKm: currentOdometer) }
    }
    
    func getDueItems() -> [MaintenanceItem] {
        maintenanceItems.filter { $0.isDue(currentKm: currentOdometer) }
    }
    
    func completeMaintenanceItem(id: UUID) {
        if let index = maintenanceItems.firstIndex(where: { $0.id == id }) {
            maintenanceItems[index].lastServiceDate = Date()
            maintenanceItems[index].lastServiceKm = currentOdometer
            items = maintenanceItems
            saveMaintenanceItems()
        }
    }
    
    func updateOdometer(km: Double) {
        currentOdometer = km
        UserDefaults.standard.set(km, forKey: "currentOdometer")
    }
    
    func updateOdometer(_ km: Double) {
        currentOdometer = km
        UserDefaults.standard.set(km, forKey: "currentOdometer")
    }
    
    private func saveMaintenanceItems() {
        if let data = try? JSONEncoder().encode(maintenanceItems) {
            UserDefaults.standard.set(data, forKey: "maintenanceItems")
        }
    }
    
    private func loadMaintenanceItems() {
        if let data = UserDefaults.standard.data(forKey: "maintenanceItems"),
           let loadedItems = try? JSONDecoder().decode([MaintenanceItem].self, from: data) {
            maintenanceItems = loadedItems
            items = loadedItems
        }
    }
    
    private func loadOdometer() {
        currentOdometer = UserDefaults.standard.double(forKey: "currentOdometer")
    }
}
