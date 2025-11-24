//
//  Motorcycle.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import Foundation

struct Motorcycle: Identifiable, Codable, Hashable {
    let id: UUID
    let brand: String
    let model: String
    let year: Int
    let fuelConsumption: Double // Liters per 100km
    let engineSize: Int // CC
    let tankSize: Double // Liters
    
    init(id: UUID = UUID(), brand: String, model: String, year: Int, fuelConsumption: Double, engineSize: Int, tankSize: Double) {
        self.id = id
        self.brand = brand
        self.model = model
        self.year = year
        self.fuelConsumption = fuelConsumption
        self.engineSize = engineSize
        self.tankSize = tankSize
    }
    
    var displayName: String {
        "\(brand) \(model) (\(year))"
    }
}

class MotorcycleDatabase {
    static let shared = MotorcycleDatabase()
    
    let motorcycles: [Motorcycle] = [
        // Harley-Davidson
        Motorcycle(brand: "Harley-Davidson", model: "Model 1", year: 1903, fuelConsumption: 2.5, engineSize: 405, tankSize: 7.5),
        Motorcycle(brand: "Harley-Davidson", model: "Model J", year: 1915, fuelConsumption: 3.0, engineSize: 1000, tankSize: 10.0),
        Motorcycle(brand: "Harley-Davidson", model: "WLA", year: 1942, fuelConsumption: 4.5, engineSize: 750, tankSize: 11.0),
        Motorcycle(brand: "Harley-Davidson", model: "Knucklehead EL", year: 1947, fuelConsumption: 5.0, engineSize: 1000, tankSize: 12.5),
        Motorcycle(brand: "Harley-Davidson", model: "Panhead FL", year: 1955, fuelConsumption: 5.2, engineSize: 1200, tankSize: 13.0),
        Motorcycle(brand: "Harley-Davidson", model: "Sportster XL", year: 1957, fuelConsumption: 4.8, engineSize: 883, tankSize: 12.5),
        Motorcycle(brand: "Harley-Davidson", model: "Electra Glide", year: 1965, fuelConsumption: 5.5, engineSize: 1200, tankSize: 15.0),
        Motorcycle(brand: "Harley-Davidson", model: "Shovelhead FLH", year: 1970, fuelConsumption: 5.8, engineSize: 1200, tankSize: 15.5),
        Motorcycle(brand: "Harley-Davidson", model: "XLCR Cafe Racer", year: 1977, fuelConsumption: 5.0, engineSize: 1000, tankSize: 13.0),
        Motorcycle(brand: "Harley-Davidson", model: "FXR Super Glide", year: 1982, fuelConsumption: 5.5, engineSize: 1340, tankSize: 16.0),
        Motorcycle(brand: "Harley-Davidson", model: "Evolution Softail", year: 1984, fuelConsumption: 5.2, engineSize: 1340, tankSize: 17.0),
        Motorcycle(brand: "Harley-Davidson", model: "Fat Boy", year: 1990, fuelConsumption: 5.8, engineSize: 1340, tankSize: 18.9),
        Motorcycle(brand: "Harley-Davidson", model: "Road King", year: 1994, fuelConsumption: 6.0, engineSize: 1340, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "V-Rod", year: 2002, fuelConsumption: 5.5, engineSize: 1130, tankSize: 18.9),
        Motorcycle(brand: "Harley-Davidson", model: "Street 500", year: 2024, fuelConsumption: 4.2, engineSize: 494, tankSize: 13.1),
        Motorcycle(brand: "Harley-Davidson", model: "Street 750", year: 2024, fuelConsumption: 4.5, engineSize: 750, tankSize: 13.1),
        Motorcycle(brand: "Harley-Davidson", model: "Iron 883", year: 2024, fuelConsumption: 5.0, engineSize: 883, tankSize: 12.5),
        Motorcycle(brand: "Harley-Davidson", model: "Iron 1200", year: 2024, fuelConsumption: 5.3, engineSize: 1202, tankSize: 12.5),
        Motorcycle(brand: "Harley-Davidson", model: "Forty-Eight", year: 2024, fuelConsumption: 5.1, engineSize: 1202, tankSize: 7.9),
        Motorcycle(brand: "Harley-Davidson", model: "Sportster S", year: 2024, fuelConsumption: 5.2, engineSize: 1252, tankSize: 11.8),
        Motorcycle(brand: "Harley-Davidson", model: "Nightster", year: 2024, fuelConsumption: 4.9, engineSize: 975, tankSize: 11.7),
        Motorcycle(brand: "Harley-Davidson", model: "Low Rider S", year: 2024, fuelConsumption: 5.6, engineSize: 1868, tankSize: 18.9),
        Motorcycle(brand: "Harley-Davidson", model: "Fat Bob", year: 2024, fuelConsumption: 5.7, engineSize: 1868, tankSize: 13.6),
        Motorcycle(brand: "Harley-Davidson", model: "Fat Boy", year: 2024, fuelConsumption: 5.8, engineSize: 1868, tankSize: 18.9),
        Motorcycle(brand: "Harley-Davidson", model: "Softail Standard", year: 2024, fuelConsumption: 5.5, engineSize: 1868, tankSize: 13.2),
        Motorcycle(brand: "Harley-Davidson", model: "Heritage Classic", year: 2024, fuelConsumption: 5.9, engineSize: 1868, tankSize: 18.9),
        Motorcycle(brand: "Harley-Davidson", model: "Street Glide", year: 2024, fuelConsumption: 6.0, engineSize: 1868, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "Road Glide", year: 2024, fuelConsumption: 6.0, engineSize: 1868, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "Road King", year: 2024, fuelConsumption: 6.1, engineSize: 1868, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "Electra Glide", year: 2024, fuelConsumption: 6.2, engineSize: 1868, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "Ultra Limited", year: 2024, fuelConsumption: 6.3, engineSize: 1868, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "CVO Street Glide", year: 2024, fuelConsumption: 6.5, engineSize: 1923, tankSize: 22.7),
        Motorcycle(brand: "Harley-Davidson", model: "Pan America 1250", year: 2024, fuelConsumption: 5.4, engineSize: 1252, tankSize: 21.2),
        Motorcycle(brand: "Harley-Davidson", model: "LiveWire", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        
        // Honda
        Motorcycle(brand: "Honda", model: "Dream D", year: 1949, fuelConsumption: 1.8, engineSize: 98, tankSize: 8.3),
        Motorcycle(brand: "Honda", model: "Super Cub C100", year: 1958, fuelConsumption: 1.5, engineSize: 50, tankSize: 6.7),
        Motorcycle(brand: "Honda", model: "CB92 Benly", year: 1959, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Honda", model: "CB72 Hawk", year: 1961, fuelConsumption: 3.0, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Honda", model: "CB77 Super Hawk", year: 1963, fuelConsumption: 3.2, engineSize: 305, tankSize: 12.2),
        Motorcycle(brand: "Honda", model: "CB450 Black Bomber", year: 1965, fuelConsumption: 3.8, engineSize: 444, tankSize: 14.2),
        Motorcycle(brand: "Honda", model: "CB750 Four", year: 1969, fuelConsumption: 4.5, engineSize: 736, tankSize: 17.8),
        Motorcycle(brand: "Honda", model: "CB500 Four", year: 1971, fuelConsumption: 4.0, engineSize: 498, tankSize: 15.0),
        Motorcycle(brand: "Honda", model: "CB400F Super Sport", year: 1975, fuelConsumption: 3.8, engineSize: 408, tankSize: 13.7),
        Motorcycle(brand: "Honda", model: "CBX 1000", year: 1978, fuelConsumption: 5.5, engineSize: 1047, tankSize: 22.3),
        Motorcycle(brand: "Honda", model: "CB900F", year: 1981, fuelConsumption: 5.0, engineSize: 901, tankSize: 19.7),
        Motorcycle(brand: "Honda", model: "VF750F Interceptor", year: 1983, fuelConsumption: 4.8, engineSize: 748, tankSize: 18.0),
        Motorcycle(brand: "Honda", model: "VFR750F", year: 1986, fuelConsumption: 5.0, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Honda", model: "CBR900RR Fireblade", year: 1992, fuelConsumption: 5.5, engineSize: 893, tankSize: 19.5),
        Motorcycle(brand: "Honda", model: "CB1300", year: 2003, fuelConsumption: 5.2, engineSize: 1284, tankSize: 20.7),
        Motorcycle(brand: "Honda", model: "Grom", year: 2024, fuelConsumption: 2.1, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Honda", model: "Monkey", year: 2024, fuelConsumption: 2.2, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Honda", model: "CB300R", year: 2024, fuelConsumption: 3.0, engineSize: 286, tankSize: 11.9),
        Motorcycle(brand: "Honda", model: "CBR300R", year: 2024, fuelConsumption: 3.1, engineSize: 286, tankSize: 11.9),
        Motorcycle(brand: "Honda", model: "Rebel 300", year: 2024, fuelConsumption: 3.2, engineSize: 286, tankSize: 11.9),
        Motorcycle(brand: "Honda", model: "CB500F", year: 2024, fuelConsumption: 3.5, engineSize: 471, tankSize: 14.6),
        Motorcycle(brand: "Honda", model: "CB500X", year: 2024, fuelConsumption: 3.6, engineSize: 471, tankSize: 14.6),
        Motorcycle(brand: "Honda", model: "CBR500R", year: 2024, fuelConsumption: 3.7, engineSize: 471, tankSize: 14.6),
        Motorcycle(brand: "Honda", model: "Rebel 500", year: 2024, fuelConsumption: 3.6, engineSize: 471, tankSize: 14.6),
        Motorcycle(brand: "Honda", model: "CB650R", year: 2024, fuelConsumption: 4.2, engineSize: 649, tankSize: 16.8),
        Motorcycle(brand: "Honda", model: "CBR650R", year: 2024, fuelConsumption: 4.4, engineSize: 649, tankSize: 16.8),
        Motorcycle(brand: "Honda", model: "NC750X", year: 2024, fuelConsumption: 3.8, engineSize: 745, tankSize: 17.9),
        Motorcycle(brand: "Honda", model: "CB1000R", year: 2024, fuelConsumption: 5.0, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Honda", model: "CBR1000RR", year: 2024, fuelConsumption: 5.5, engineSize: 999, tankSize: 21.4),
        Motorcycle(brand: "Honda", model: "Africa Twin", year: 2024, fuelConsumption: 4.8, engineSize: 1084, tankSize: 22.9),
        Motorcycle(brand: "Honda", model: "Africa Twin Adventure Sports", year: 2024, fuelConsumption: 5.0, engineSize: 1084, tankSize: 22.9),
        Motorcycle(brand: "Honda", model: "Rebel 1100", year: 2024, fuelConsumption: 4.5, engineSize: 1084, tankSize: 22.9),
        Motorcycle(brand: "Honda", model: "NT1100", year: 2024, fuelConsumption: 4.7, engineSize: 1084, tankSize: 22.9),
        Motorcycle(brand: "Honda", model: "Gold Wing", year: 2024, fuelConsumption: 6.5, engineSize: 1833, tankSize: 22.2),
        Motorcycle(brand: "Honda", model: "Gold Wing Tour", year: 2024, fuelConsumption: 6.7, engineSize: 1833, tankSize: 22.2),
        
        // Yamaha
        Motorcycle(brand: "Yamaha", model: "YA-1", year: 1955, fuelConsumption: 2.0, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Yamaha", model: "YD-1", year: 1957, fuelConsumption: 2.5, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Yamaha", model: "YDS-1", year: 1959, fuelConsumption: 3.0, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Yamaha", model: "TD1", year: 1962, fuelConsumption: 3.5, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Yamaha", model: "XS650", year: 1970, fuelConsumption: 4.5, engineSize: 653, tankSize: 16.8),
        Motorcycle(brand: "Yamaha", model: "RD350", year: 1973, fuelConsumption: 4.0, engineSize: 347, tankSize: 12.8),
        Motorcycle(brand: "Yamaha", model: "XS750", year: 1976, fuelConsumption: 5.0, engineSize: 747, tankSize: 18.0),
        Motorcycle(brand: "Yamaha", model: "XS1100", year: 1978, fuelConsumption: 5.5, engineSize: 1101, tankSize: 23.2),
        Motorcycle(brand: "Yamaha", model: "RD500LC", year: 1984, fuelConsumption: 4.8, engineSize: 499, tankSize: 15.0),
        Motorcycle(brand: "Yamaha", model: "FZR1000", year: 1987, fuelConsumption: 5.5, engineSize: 1002, tankSize: 21.5),
        Motorcycle(brand: "Yamaha", model: "YZF750R", year: 1993, fuelConsumption: 5.2, engineSize: 749, tankSize: 18.0),
        Motorcycle(brand: "Yamaha", model: "YZF-R1", year: 1998, fuelConsumption: 5.8, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Yamaha", model: "YZF-R125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Yamaha", model: "MT-125", year: 2024, fuelConsumption: 2.6, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Yamaha", model: "XSR125", year: 2024, fuelConsumption: 2.7, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Yamaha", model: "YZF-R3", year: 2024, fuelConsumption: 3.3, engineSize: 321, tankSize: 12.4),
        Motorcycle(brand: "Yamaha", model: "MT-03", year: 2024, fuelConsumption: 3.4, engineSize: 321, tankSize: 12.4),
        Motorcycle(brand: "Yamaha", model: "YZF-R7", year: 2024, fuelConsumption: 4.1, engineSize: 689, tankSize: 17.3),
        Motorcycle(brand: "Yamaha", model: "MT-07", year: 2024, fuelConsumption: 3.8, engineSize: 689, tankSize: 17.3),
        Motorcycle(brand: "Yamaha", model: "XSR700", year: 2024, fuelConsumption: 3.9, engineSize: 689, tankSize: 17.3),
        Motorcycle(brand: "Yamaha", model: "Ténéré 700", year: 2024, fuelConsumption: 3.9, engineSize: 689, tankSize: 17.3),
        Motorcycle(brand: "Yamaha", model: "MT-09", year: 2024, fuelConsumption: 4.5, engineSize: 890, tankSize: 19.5),
        Motorcycle(brand: "Yamaha", model: "XSR900", year: 2024, fuelConsumption: 4.6, engineSize: 890, tankSize: 19.5),
        Motorcycle(brand: "Yamaha", model: "Tracer 9", year: 2024, fuelConsumption: 4.7, engineSize: 890, tankSize: 19.5),
        Motorcycle(brand: "Yamaha", model: "Tracer 9 GT", year: 2024, fuelConsumption: 4.8, engineSize: 890, tankSize: 19.5),
        Motorcycle(brand: "Yamaha", model: "MT-10", year: 2024, fuelConsumption: 5.5, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Yamaha", model: "YZF-R1", year: 2024, fuelConsumption: 5.8, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Yamaha", model: "YZF-R1M", year: 2024, fuelConsumption: 5.9, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Yamaha", model: "Super Ténéré", year: 2024, fuelConsumption: 5.3, engineSize: 1199, tankSize: 25.0),
        Motorcycle(brand: "Yamaha", model: "VMAX", year: 2024, fuelConsumption: 7.2, engineSize: 1679, tankSize: 24.0),
        
        // Kawasaki
        Motorcycle(brand: "Kawasaki", model: "B8", year: 1962, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Kawasaki", model: "W1", year: 1966, fuelConsumption: 4.0, engineSize: 624, tankSize: 16.5),
        Motorcycle(brand: "Kawasaki", model: "H1 Mach III", year: 1969, fuelConsumption: 5.0, engineSize: 498, tankSize: 15.0),
        Motorcycle(brand: "Kawasaki", model: "Z1", year: 1972, fuelConsumption: 5.5, engineSize: 903, tankSize: 19.7),
        Motorcycle(brand: "Kawasaki", model: "Z1-R", year: 1978, fuelConsumption: 5.8, engineSize: 1015, tankSize: 21.7),
        Motorcycle(brand: "Kawasaki", model: "GPZ900R Ninja", year: 1984, fuelConsumption: 5.5, engineSize: 908, tankSize: 19.8),
        Motorcycle(brand: "Kawasaki", model: "ZX-10", year: 1988, fuelConsumption: 6.0, engineSize: 997, tankSize: 21.4),
        Motorcycle(brand: "Kawasaki", model: "ZZR1100", year: 1990, fuelConsumption: 6.2, engineSize: 1052, tankSize: 22.4),
        Motorcycle(brand: "Kawasaki", model: "ZX-7R", year: 1996, fuelConsumption: 5.8, engineSize: 748, tankSize: 18.0),
        Motorcycle(brand: "Kawasaki", model: "Z1000", year: 2003, fuelConsumption: 5.5, engineSize: 953, tankSize: 20.6),
        Motorcycle(brand: "Kawasaki", model: "Ninja 400", year: 2024, fuelConsumption: 3.7, engineSize: 399, tankSize: 13.6),
        Motorcycle(brand: "Kawasaki", model: "Z650", year: 2024, fuelConsumption: 4.0, engineSize: 649, tankSize: 16.8),
        Motorcycle(brand: "Kawasaki", model: "Ninja ZX-6R", year: 2024, fuelConsumption: 5.2, engineSize: 636, tankSize: 16.6),
        Motorcycle(brand: "Kawasaki", model: "Z900", year: 2024, fuelConsumption: 4.8, engineSize: 948, tankSize: 20.5),
        Motorcycle(brand: "Kawasaki", model: "Ninja ZX-10R", year: 2024, fuelConsumption: 6.0, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Kawasaki", model: "Versys 650", year: 2024, fuelConsumption: 4.3, engineSize: 649, tankSize: 16.8),
        
        // Suzuki
        Motorcycle(brand: "Suzuki", model: "Colleda", year: 1954, fuelConsumption: 2.0, engineSize: 90, tankSize: 8.0),
        Motorcycle(brand: "Suzuki", model: "T10", year: 1963, fuelConsumption: 2.5, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Suzuki", model: "T500 Titan", year: 1968, fuelConsumption: 4.0, engineSize: 492, tankSize: 14.9),
        Motorcycle(brand: "Suzuki", model: "GT750", year: 1971, fuelConsumption: 5.5, engineSize: 738, tankSize: 17.9),
        Motorcycle(brand: "Suzuki", model: "GT550", year: 1972, fuelConsumption: 4.5, engineSize: 543, tankSize: 15.5),
        Motorcycle(brand: "Suzuki", model: "GS750", year: 1977, fuelConsumption: 5.0, engineSize: 748, tankSize: 18.0),
        Motorcycle(brand: "Suzuki", model: "GSX1100", year: 1980, fuelConsumption: 5.8, engineSize: 1075, tankSize: 22.8),
        Motorcycle(brand: "Suzuki", model: "GSX-R750", year: 1985, fuelConsumption: 5.5, engineSize: 749, tankSize: 18.0),
        Motorcycle(brand: "Suzuki", model: "GSX-R1100", year: 1986, fuelConsumption: 6.0, engineSize: 1127, tankSize: 23.7),
        Motorcycle(brand: "Suzuki", model: "Bandit 1200", year: 1995, fuelConsumption: 5.5, engineSize: 1157, tankSize: 24.2),
        Motorcycle(brand: "Suzuki", model: "TL1000S", year: 1997, fuelConsumption: 5.8, engineSize: 996, tankSize: 21.4),
        Motorcycle(brand: "Suzuki", model: "SV650", year: 2024, fuelConsumption: 4.0, engineSize: 645, tankSize: 16.7),
        Motorcycle(brand: "Suzuki", model: "GSX-R750", year: 2024, fuelConsumption: 5.5, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Suzuki", model: "GSX-S1000", year: 2024, fuelConsumption: 5.2, engineSize: 999, tankSize: 21.4),
        Motorcycle(brand: "Suzuki", model: "V-Strom 650", year: 2024, fuelConsumption: 4.5, engineSize: 645, tankSize: 16.7),
        Motorcycle(brand: "Suzuki", model: "Hayabusa", year: 2024, fuelConsumption: 6.5, engineSize: 1340, tankSize: 21.2),
        
        // BMW
        Motorcycle(brand: "BMW", model: "R32", year: 1923, fuelConsumption: 3.5, engineSize: 494, tankSize: 14.9),
        Motorcycle(brand: "BMW", model: "R51", year: 1938, fuelConsumption: 4.0, engineSize: 494, tankSize: 14.9),
        Motorcycle(brand: "BMW", model: "R50", year: 1955, fuelConsumption: 4.2, engineSize: 494, tankSize: 14.9),
        Motorcycle(brand: "BMW", model: "R69S", year: 1960, fuelConsumption: 4.5, engineSize: 594, tankSize: 16.1),
        Motorcycle(brand: "BMW", model: "R60/5", year: 1969, fuelConsumption: 4.8, engineSize: 599, tankSize: 16.2),
        Motorcycle(brand: "BMW", model: "R90S", year: 1973, fuelConsumption: 5.0, engineSize: 898, tankSize: 19.6),
        Motorcycle(brand: "BMW", model: "R100RS", year: 1976, fuelConsumption: 5.2, engineSize: 980, tankSize: 21.1),
        Motorcycle(brand: "BMW", model: "K100", year: 1983, fuelConsumption: 5.0, engineSize: 987, tankSize: 21.2),
        Motorcycle(brand: "BMW", model: "R1100GS", year: 1993, fuelConsumption: 5.2, engineSize: 1085, tankSize: 23.0),
        Motorcycle(brand: "BMW", model: "R1200C", year: 1997, fuelConsumption: 5.5, engineSize: 1170, tankSize: 24.5),
        Motorcycle(brand: "BMW", model: "G 310 R", year: 2024, fuelConsumption: 3.2, engineSize: 313, tankSize: 12.3),
        Motorcycle(brand: "BMW", model: "F 900 R", year: 2024, fuelConsumption: 4.4, engineSize: 895, tankSize: 19.6),
        Motorcycle(brand: "BMW", model: "S 1000 RR", year: 2024, fuelConsumption: 5.9, engineSize: 999, tankSize: 21.4),
        Motorcycle(brand: "BMW", model: "R 1250 GS", year: 2024, fuelConsumption: 5.0, engineSize: 1254, tankSize: 20.4),
        Motorcycle(brand: "BMW", model: "R 18", year: 2024, fuelConsumption: 5.5, engineSize: 1802, tankSize: 22.0),
        
        // Ducati
        Motorcycle(brand: "Ducati", model: "98 Sport", year: 1952, fuelConsumption: 2.2, engineSize: 98, tankSize: 8.3),
        Motorcycle(brand: "Ducati", model: "125 Gran Sport", year: 1955, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Ducati", model: "Diana", year: 1961, fuelConsumption: 3.0, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Ducati", model: "350 Sebring", year: 1966, fuelConsumption: 3.5, engineSize: 346, tankSize: 12.8),
        Motorcycle(brand: "Ducati", model: "750 GT", year: 1971, fuelConsumption: 4.5, engineSize: 748, tankSize: 18.0),
        Motorcycle(brand: "Ducati", model: "750 Super Sport", year: 1974, fuelConsumption: 5.0, engineSize: 748, tankSize: 18.0),
        Motorcycle(brand: "Ducati", model: "900SS", year: 1975, fuelConsumption: 5.5, engineSize: 864, tankSize: 19.0),
        Motorcycle(brand: "Ducati", model: "Pantah 500", year: 1980, fuelConsumption: 4.0, engineSize: 499, tankSize: 15.0),
        Motorcycle(brand: "Ducati", model: "851", year: 1988, fuelConsumption: 5.8, engineSize: 851, tankSize: 18.8),
        Motorcycle(brand: "Ducati", model: "Monster 900", year: 1993, fuelConsumption: 5.0, engineSize: 904, tankSize: 19.7),
        Motorcycle(brand: "Ducati", model: "916", year: 1994, fuelConsumption: 5.5, engineSize: 916, tankSize: 20.0),
        Motorcycle(brand: "Ducati", model: "996", year: 1999, fuelConsumption: 5.8, engineSize: 996, tankSize: 21.4),
        Motorcycle(brand: "Ducati", model: "Monster", year: 2024, fuelConsumption: 4.8, engineSize: 937, tankSize: 20.3),
        Motorcycle(brand: "Ducati", model: "Panigale V2", year: 2024, fuelConsumption: 5.5, engineSize: 955, tankSize: 20.6),
        Motorcycle(brand: "Ducati", model: "Panigale V4", year: 2024, fuelConsumption: 6.2, engineSize: 1103, tankSize: 23.3),
        Motorcycle(brand: "Ducati", model: "Multistrada V4", year: 2024, fuelConsumption: 5.3, engineSize: 1158, tankSize: 24.3),
        Motorcycle(brand: "Ducati", model: "Scrambler", year: 2024, fuelConsumption: 4.5, engineSize: 803, tankSize: 17.9),
        
        // Triumph
        Motorcycle(brand: "Triumph", model: "Model H", year: 1915, fuelConsumption: 3.0, engineSize: 550, tankSize: 15.6),
        Motorcycle(brand: "Triumph", model: "Speed Twin", year: 1938, fuelConsumption: 3.5, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Triumph", model: "Thunderbird", year: 1950, fuelConsumption: 4.0, engineSize: 650, tankSize: 16.8),
        Motorcycle(brand: "Triumph", model: "TR6 Trophy", year: 1956, fuelConsumption: 3.8, engineSize: 650, tankSize: 16.8),
        Motorcycle(brand: "Triumph", model: "Bonneville T120", year: 1959, fuelConsumption: 4.2, engineSize: 650, tankSize: 16.8),
        Motorcycle(brand: "Triumph", model: "Trident T150", year: 1968, fuelConsumption: 4.5, engineSize: 740, tankSize: 17.9),
        Motorcycle(brand: "Triumph", model: "Bonneville T140", year: 1973, fuelConsumption: 4.5, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Triumph", model: "Daytona 900", year: 1992, fuelConsumption: 5.0, engineSize: 885, tankSize: 19.4),
        Motorcycle(brand: "Triumph", model: "Speed Triple", year: 1994, fuelConsumption: 5.2, engineSize: 885, tankSize: 19.4),
        Motorcycle(brand: "Triumph", model: "Bonneville T100", year: 2001, fuelConsumption: 4.3, engineSize: 790, tankSize: 17.7),
        Motorcycle(brand: "Triumph", model: "Street Triple", year: 2024, fuelConsumption: 4.5, engineSize: 765, tankSize: 17.3),
        Motorcycle(brand: "Triumph", model: "Speed Triple", year: 2024, fuelConsumption: 5.0, engineSize: 1160, tankSize: 24.3),
        Motorcycle(brand: "Triumph", model: "Tiger 900", year: 2024, fuelConsumption: 4.7, engineSize: 888, tankSize: 19.5),
        Motorcycle(brand: "Triumph", model: "Bonneville T120", year: 2024, fuelConsumption: 4.3, engineSize: 1200, tankSize: 25.0),
        Motorcycle(brand: "Triumph", model: "Rocket 3", year: 2024, fuelConsumption: 6.8, engineSize: 2458, tankSize: 25.0),
        
        // KTM
        Motorcycle(brand: "KTM", model: "390 Duke", year: 2024, fuelConsumption: 3.4, engineSize: 373, tankSize: 13.2),
        Motorcycle(brand: "KTM", model: "890 Duke", year: 2024, fuelConsumption: 4.6, engineSize: 889, tankSize: 19.5),
        Motorcycle(brand: "KTM", model: "1290 Super Duke R", year: 2024, fuelConsumption: 5.8, engineSize: 1301, tankSize: 20.8),
        Motorcycle(brand: "KTM", model: "790 Adventure", year: 2024, fuelConsumption: 4.5, engineSize: 799, tankSize: 17.9),
        
        // Aprilia
        Motorcycle(brand: "Aprilia", model: "RS 660", year: 2024, fuelConsumption: 4.8, engineSize: 659, tankSize: 16.9),
        Motorcycle(brand: "Aprilia", model: "Tuono V4", year: 2024, fuelConsumption: 5.9, engineSize: 1077, tankSize: 22.8),
        Motorcycle(brand: "Aprilia", model: "RSV4", year: 2024, fuelConsumption: 6.3, engineSize: 1099, tankSize: 23.2),
        Motorcycle(brand: "Aprilia", model: "Tuareg 660", year: 2024, fuelConsumption: 4.6, engineSize: 659, tankSize: 16.9),
        Motorcycle(brand: "Aprilia", model: "RS 125", year: 2024, fuelConsumption: 2.5, engineSize: 124, tankSize: 9.1),
        
        // Indian
        Motorcycle(brand: "Indian", model: "Single", year: 1901, fuelConsumption: 2.0, engineSize: 213, tankSize: 10.9),
        Motorcycle(brand: "Indian", model: "Big Twin", year: 1907, fuelConsumption: 2.5, engineSize: 633, tankSize: 16.6),
        Motorcycle(brand: "Indian", model: "Powerplus", year: 1916, fuelConsumption: 3.5, engineSize: 1000, tankSize: 21.4),
        Motorcycle(brand: "Indian", model: "Scout", year: 1920, fuelConsumption: 3.8, engineSize: 606, tankSize: 16.3),
        Motorcycle(brand: "Indian", model: "Chief", year: 1922, fuelConsumption: 4.5, engineSize: 1000, tankSize: 21.4),
        Motorcycle(brand: "Indian", model: "Four", year: 1928, fuelConsumption: 5.0, engineSize: 1265, tankSize: 20.5),
        Motorcycle(brand: "Indian", model: "Sport Scout", year: 1940, fuelConsumption: 4.0, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Indian", model: "Chief Roadmaster", year: 1950, fuelConsumption: 5.5, engineSize: 1200, tankSize: 25.0),
        Motorcycle(brand: "Indian", model: "Scout", year: 2024, fuelConsumption: 5.2, engineSize: 1133, tankSize: 23.8),
        Motorcycle(brand: "Indian", model: "Scout Bobber", year: 2024, fuelConsumption: 5.3, engineSize: 1133, tankSize: 23.8),
        Motorcycle(brand: "Indian", model: "Scout Rogue", year: 2024, fuelConsumption: 5.2, engineSize: 1133, tankSize: 23.8),
        Motorcycle(brand: "Indian", model: "Chief", year: 2024, fuelConsumption: 6.0, engineSize: 1890, tankSize: 22.5),
        Motorcycle(brand: "Indian", model: "Chieftain", year: 2024, fuelConsumption: 6.4, engineSize: 1890, tankSize: 22.5),
        Motorcycle(brand: "Indian", model: "Roadmaster", year: 2024, fuelConsumption: 6.8, engineSize: 1890, tankSize: 22.5),
        Motorcycle(brand: "Indian", model: "Springfield", year: 2024, fuelConsumption: 6.3, engineSize: 1890, tankSize: 22.5),
        Motorcycle(brand: "Indian", model: "Challenger", year: 2024, fuelConsumption: 6.5, engineSize: 1768, tankSize: 24.7),
        Motorcycle(brand: "Indian", model: "FTR", year: 2024, fuelConsumption: 5.5, engineSize: 1203, tankSize: 20.0),
        
        // Moto Guzzi
        Motorcycle(brand: "Moto Guzzi", model: "V7 Stone", year: 2024, fuelConsumption: 4.2, engineSize: 850, tankSize: 18.8),
        Motorcycle(brand: "Moto Guzzi", model: "V9 Bobber", year: 2024, fuelConsumption: 4.5, engineSize: 853, tankSize: 18.8),
        Motorcycle(brand: "Moto Guzzi", model: "V85 TT", year: 2024, fuelConsumption: 4.8, engineSize: 853, tankSize: 18.8),
        Motorcycle(brand: "Moto Guzzi", model: "V100 Mandello", year: 2024, fuelConsumption: 5.0, engineSize: 1042, tankSize: 22.2),
        
        // Royal Enfield
        Motorcycle(brand: "Royal Enfield", model: "Meteor 350", year: 2024, fuelConsumption: 3.0, engineSize: 349, tankSize: 12.8),
        Motorcycle(brand: "Royal Enfield", model: "Classic 350", year: 2024, fuelConsumption: 3.1, engineSize: 349, tankSize: 12.8),
        Motorcycle(brand: "Royal Enfield", model: "Hunter 350", year: 2024, fuelConsumption: 3.0, engineSize: 349, tankSize: 12.8),
        Motorcycle(brand: "Royal Enfield", model: "Himalayan", year: 2024, fuelConsumption: 3.6, engineSize: 411, tankSize: 13.7),
        Motorcycle(brand: "Royal Enfield", model: "Interceptor 650", year: 2024, fuelConsumption: 4.1, engineSize: 648, tankSize: 16.8),
        Motorcycle(brand: "Royal Enfield", model: "Continental GT 650", year: 2024, fuelConsumption: 4.0, engineSize: 648, tankSize: 16.8),
        Motorcycle(brand: "Royal Enfield", model: "Super Meteor 650", year: 2024, fuelConsumption: 4.2, engineSize: 648, tankSize: 16.8),
        
        // MV Agusta
        Motorcycle(brand: "MV Agusta", model: "Brutale 800", year: 2024, fuelConsumption: 5.2, engineSize: 798, tankSize: 17.9),
        Motorcycle(brand: "MV Agusta", model: "Brutale 1000", year: 2024, fuelConsumption: 6.5, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "MV Agusta", model: "F3 800", year: 2024, fuelConsumption: 5.3, engineSize: 798, tankSize: 17.9),
        Motorcycle(brand: "MV Agusta", model: "F4", year: 2024, fuelConsumption: 6.2, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "MV Agusta", model: "Superveloce 800", year: 2024, fuelConsumption: 5.5, engineSize: 798, tankSize: 17.9),
        
        // Husqvarna
        Motorcycle(brand: "Husqvarna", model: "Vitpilen 401", year: 2024, fuelConsumption: 3.5, engineSize: 373, tankSize: 13.2),
        Motorcycle(brand: "Husqvarna", model: "Svartpilen 401", year: 2024, fuelConsumption: 3.6, engineSize: 373, tankSize: 13.2),
        Motorcycle(brand: "Husqvarna", model: "Norden 901", year: 2024, fuelConsumption: 4.7, engineSize: 889, tankSize: 19.5),
        Motorcycle(brand: "Husqvarna", model: "Vitpilen 250", year: 2024, fuelConsumption: 3.0, engineSize: 248, tankSize: 11.4),
        
        // Benelli
        Motorcycle(brand: "Benelli", model: "TRK 502", year: 2024, fuelConsumption: 4.6, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Benelli", model: "Leoncino 500", year: 2024, fuelConsumption: 4.4, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Benelli", model: "TNT 300", year: 2024, fuelConsumption: 3.9, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Benelli", model: "302S", year: 2024, fuelConsumption: 3.8, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Benelli", model: "TRK 251", year: 2024, fuelConsumption: 3.2, engineSize: 250, tankSize: 11.4),
        
        // CFMoto
        Motorcycle(brand: "CFMoto", model: "300NK", year: 2024, fuelConsumption: 3.5, engineSize: 292, tankSize: 12.0),
        Motorcycle(brand: "CFMoto", model: "650NK", year: 2024, fuelConsumption: 4.5, engineSize: 649, tankSize: 16.8),
        Motorcycle(brand: "CFMoto", model: "650MT", year: 2024, fuelConsumption: 4.7, engineSize: 649, tankSize: 16.8),
        Motorcycle(brand: "CFMoto", model: "700CL-X", year: 2024, fuelConsumption: 4.8, engineSize: 693, tankSize: 17.3),
        Motorcycle(brand: "CFMoto", model: "800MT", year: 2024, fuelConsumption: 5.2, engineSize: 799, tankSize: 17.9),
        
        // GAS GAS
        Motorcycle(brand: "GAS GAS", model: "EC 250", year: 2024, fuelConsumption: 3.5, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "GAS GAS", model: "EC 300", year: 2024, fuelConsumption: 3.8, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "GAS GAS", model: "MC 250", year: 2024, fuelConsumption: 3.6, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "GAS GAS", model: "EX 250", year: 2024, fuelConsumption: 3.4, engineSize: 250, tankSize: 11.4),
        
        // Beta
        Motorcycle(brand: "Beta", model: "RR 200", year: 2024, fuelConsumption: 2.8, engineSize: 200, tankSize: 10.7),
        Motorcycle(brand: "Beta", model: "RR 300", year: 2024, fuelConsumption: 3.5, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Beta", model: "RR 430", year: 2024, fuelConsumption: 4.0, engineSize: 430, tankSize: 14.0),
        Motorcycle(brand: "Beta", model: "Xtrainer 300", year: 2024, fuelConsumption: 3.3, engineSize: 300, tankSize: 12.1),
        
        // Sherco
        Motorcycle(brand: "Sherco", model: "SE 250", year: 2024, fuelConsumption: 3.2, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Sherco", model: "SE 300", year: 2024, fuelConsumption: 3.6, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Sherco", model: "SEF 450", year: 2024, fuelConsumption: 4.1, engineSize: 450, tankSize: 14.3),
        
        // Ural
        Motorcycle(brand: "Ural", model: "Gear Up", year: 2024, fuelConsumption: 6.5, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Ural", model: "cT", year: 2024, fuelConsumption: 6.4, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Ural", model: "Patrol", year: 2024, fuelConsumption: 6.6, engineSize: 750, tankSize: 18.0),
        
        // Can-Am
        Motorcycle(brand: "Can-Am", model: "Ryker 600", year: 2024, fuelConsumption: 5.0, engineSize: 600, tankSize: 16.2),
        Motorcycle(brand: "Can-Am", model: "Ryker 900", year: 2024, fuelConsumption: 5.8, engineSize: 900, tankSize: 19.7),
        Motorcycle(brand: "Can-Am", model: "Spyder F3", year: 2024, fuelConsumption: 6.2, engineSize: 1330, tankSize: 21.1),
        Motorcycle(brand: "Can-Am", model: "Spyder RT", year: 2024, fuelConsumption: 6.5, engineSize: 1330, tankSize: 21.1),
        
        // Norton
        Motorcycle(brand: "Norton", model: "16H", year: 1921, fuelConsumption: 3.0, engineSize: 490, tankSize: 14.9),
        Motorcycle(brand: "Norton", model: "Model 18", year: 1930, fuelConsumption: 3.2, engineSize: 490, tankSize: 14.9),
        Motorcycle(brand: "Norton", model: "International", year: 1935, fuelConsumption: 3.5, engineSize: 490, tankSize: 14.9),
        Motorcycle(brand: "Norton", model: "Manx", year: 1950, fuelConsumption: 4.0, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Norton", model: "Dominator 99", year: 1956, fuelConsumption: 4.2, engineSize: 600, tankSize: 16.2),
        Motorcycle(brand: "Norton", model: "Atlas", year: 1962, fuelConsumption: 4.5, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Norton", model: "Commando 750", year: 1968, fuelConsumption: 4.8, engineSize: 750, tankSize: 18.0),
        Motorcycle(brand: "Norton", model: "Commando 850", year: 1973, fuelConsumption: 5.0, engineSize: 828, tankSize: 18.4),
        Motorcycle(brand: "Norton", model: "Commando 961", year: 2024, fuelConsumption: 5.0, engineSize: 961, tankSize: 20.8),
        Motorcycle(brand: "Norton", model: "V4 SV", year: 2024, fuelConsumption: 6.0, engineSize: 1200, tankSize: 25.0),
        Motorcycle(brand: "Norton", model: "V4 RR", year: 2024, fuelConsumption: 6.2, engineSize: 1200, tankSize: 25.0),
        
        // Bimota
        Motorcycle(brand: "Bimota", model: "Tesi H2", year: 2024, fuelConsumption: 6.5, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Bimota", model: "KB4", year: 2024, fuelConsumption: 5.8, engineSize: 1043, tankSize: 22.2),
        
        // SWM
        Motorcycle(brand: "SWM", model: "Gran Milano 440", year: 2024, fuelConsumption: 3.8, engineSize: 445, tankSize: 14.2),
        Motorcycle(brand: "SWM", model: "Gran Turismo 440", year: 2024, fuelConsumption: 3.9, engineSize: 445, tankSize: 14.2),
        Motorcycle(brand: "SWM", model: "SuperDual X", year: 2024, fuelConsumption: 3.7, engineSize: 600, tankSize: 16.2),
        
        // Fantic
        Motorcycle(brand: "Fantic", model: "Caballero 500", year: 2024, fuelConsumption: 4.0, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Fantic", model: "XEF 250", year: 2024, fuelConsumption: 3.2, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Fantic", model: "XMF 250", year: 2024, fuelConsumption: 3.3, engineSize: 250, tankSize: 11.4),
        
        // Jawa
        Motorcycle(brand: "Jawa", model: "42", year: 2024, fuelConsumption: 3.5, engineSize: 293, tankSize: 12.0),
        Motorcycle(brand: "Jawa", model: "Perak", year: 2024, fuelConsumption: 3.8, engineSize: 334, tankSize: 12.6),
        Motorcycle(brand: "Jawa", model: "300", year: 2024, fuelConsumption: 3.6, engineSize: 293, tankSize: 12.0),
        
        // Keeway
        Motorcycle(brand: "Keeway", model: "K-Light 125", year: 2024, fuelConsumption: 2.2, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Keeway", model: "RKR 165", year: 2024, fuelConsumption: 2.8, engineSize: 165, tankSize: 10.2),
        Motorcycle(brand: "Keeway", model: "V-Cruise 250", year: 2024, fuelConsumption: 3.4, engineSize: 250, tankSize: 11.4),
        
        // Kymco
        Motorcycle(brand: "Kymco", model: "AK 550", year: 2024, fuelConsumption: 4.2, engineSize: 550, tankSize: 15.6),
        Motorcycle(brand: "Kymco", model: "CV3", year: 2024, fuelConsumption: 3.5, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Kymco", model: "Visar 125", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        
        // SYM
        Motorcycle(brand: "SYM", model: "Cruisym 300", year: 2024, fuelConsumption: 3.6, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "SYM", model: "Maxsym TL", year: 2024, fuelConsumption: 4.8, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "SYM", model: "NH T", year: 2024, fuelConsumption: 3.2, engineSize: 125, tankSize: 9.2),
        
        // Brixton
        Motorcycle(brand: "Brixton", model: "Cromwell 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Brixton", model: "Felsberg 125", year: 2024, fuelConsumption: 2.6, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Brixton", model: "Crossfire 500", year: 2024, fuelConsumption: 4.0, engineSize: 500, tankSize: 15.0),
        
        // Zontes
        Motorcycle(brand: "Zontes", model: "310 R", year: 2024, fuelConsumption: 3.4, engineSize: 312, tankSize: 12.3),
        Motorcycle(brand: "Zontes", model: "350 T", year: 2024, fuelConsumption: 3.7, engineSize: 348, tankSize: 12.8),
        Motorcycle(brand: "Zontes", model: "ZT125 U", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        
        // Voge
        Motorcycle(brand: "Voge", model: "300 AC", year: 2024, fuelConsumption: 3.5, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "Voge", model: "500 R", year: 2024, fuelConsumption: 4.2, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "Voge", model: "650 DS", year: 2024, fuelConsumption: 4.6, engineSize: 650, tankSize: 16.8),
        
        // QJMotor
        Motorcycle(brand: "QJMotor", model: "SRK 400", year: 2024, fuelConsumption: 3.9, engineSize: 400, tankSize: 13.6),
        Motorcycle(brand: "QJMotor", model: "SRV 300", year: 2024, fuelConsumption: 3.6, engineSize: 300, tankSize: 12.1),
        Motorcycle(brand: "QJMotor", model: "SRT 500", year: 2024, fuelConsumption: 4.3, engineSize: 500, tankSize: 15.0),
        
        // Zero (Electric)
        Motorcycle(brand: "Zero", model: "SR/F", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Zero", model: "SR/S", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Zero", model: "DSR/X", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Zero", model: "FXE", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        
        // Energica (Electric)
        Motorcycle(brand: "Energica", model: "Ego", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Energica", model: "Eva Ribelle", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Energica", model: "Experia", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        
        // Lightning (Electric)
        Motorcycle(brand: "Lightning", model: "LS-218", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        Motorcycle(brand: "Lightning", model: "Strike", year: 2024, fuelConsumption: 0.0, engineSize: 0, tankSize: 0.0),
        
        // Piaggio
        Motorcycle(brand: "Piaggio", model: "Liberty 150", year: 2024, fuelConsumption: 2.3, engineSize: 150, tankSize: 10.0),
        Motorcycle(brand: "Piaggio", model: "Medley 125", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Piaggio", model: "MP3 500", year: 2024, fuelConsumption: 4.1, engineSize: 493, tankSize: 14.9),
        
        // Vespa
        Motorcycle(brand: "Vespa", model: "Primavera 125", year: 2024, fuelConsumption: 2.2, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Vespa", model: "GTS 300", year: 2024, fuelConsumption: 3.5, engineSize: 278, tankSize: 11.8),
        Motorcycle(brand: "Vespa", model: "GTS Super 300", year: 2024, fuelConsumption: 3.6, engineSize: 278, tankSize: 11.8),
        
        // Peugeot
        Motorcycle(brand: "Peugeot", model: "Django 125", year: 2024, fuelConsumption: 2.3, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Peugeot", model: "Metropolis 400", year: 2024, fuelConsumption: 4.0, engineSize: 400, tankSize: 13.6),
        
        // Lambretta
        Motorcycle(brand: "Lambretta", model: "V125 Special", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Lambretta", model: "V200 Special", year: 2024, fuelConsumption: 3.0, engineSize: 200, tankSize: 10.7),
        
        // Gilera
        Motorcycle(brand: "Gilera", model: "Runner 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // TM Racing
        Motorcycle(brand: "TM Racing", model: "EN 250", year: 2024, fuelConsumption: 3.3, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "TM Racing", model: "EN 300", year: 2024, fuelConsumption: 3.6, engineSize: 300, tankSize: 12.1),
        
        // Malaguti
        Motorcycle(brand: "Malaguti", model: "Dune 125", year: 2024, fuelConsumption: 2.6, engineSize: 125, tankSize: 9.2),
        
        // Derbi
        Motorcycle(brand: "Derbi", model: "Senda DRD X-Treme", year: 2024, fuelConsumption: 2.3, engineSize: 50, tankSize: 6.7),
        
        // Rieju
        Motorcycle(brand: "Rieju", model: "MRT 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Hyosung
        Motorcycle(brand: "Hyosung", model: "GV 250", year: 2024, fuelConsumption: 3.4, engineSize: 250, tankSize: 11.4),
        Motorcycle(brand: "Hyosung", model: "GT 650", year: 2024, fuelConsumption: 4.5, engineSize: 650, tankSize: 16.8),
        
        // SWM (Additional models)
        Motorcycle(brand: "SWM", model: "RS 125", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        
        // Lifan
        Motorcycle(brand: "Lifan", model: "KP 150", year: 2024, fuelConsumption: 2.7, engineSize: 150, tankSize: 10.0),
        Motorcycle(brand: "Lifan", model: "KPR 200", year: 2024, fuelConsumption: 3.2, engineSize: 200, tankSize: 10.7),
        
        // Sachs
        Motorcycle(brand: "Sachs", model: "Madass 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Bullit
        Motorcycle(brand: "Bullit", model: "Hero 125", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Bullit", model: "Spirit 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Mutt Motorcycles
        Motorcycle(brand: "Mutt", model: "Mongrel 125", year: 2024, fuelConsumption: 2.6, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Mutt", model: "FSR 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Sinnis
        Motorcycle(brand: "Sinnis", model: "Retrostar 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Lexmoto
        Motorcycle(brand: "Lexmoto", model: "Valiant 125", year: 2024, fuelConsumption: 2.4, engineSize: 125, tankSize: 9.2),
        Motorcycle(brand: "Lexmoto", model: "Assault 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // Herald Motor
        Motorcycle(brand: "Herald", model: "Classic 125", year: 2024, fuelConsumption: 2.5, engineSize: 125, tankSize: 9.2),
        
        // CSC Motorcycles
        Motorcycle(brand: "CSC", model: "TT250", year: 2024, fuelConsumption: 3.2, engineSize: 250, tankSize: 11.4),
        
        // Cleveland CycleWerks
        Motorcycle(brand: "Cleveland CycleWerks", model: "Misfit", year: 2024, fuelConsumption: 2.8, engineSize: 250, tankSize: 11.4),
        
        // Arch Motorcycle
        Motorcycle(brand: "Arch", model: "KRGT-1", year: 2024, fuelConsumption: 5.8, engineSize: 2032, tankSize: 23.4),
        
        // Confederate
        Motorcycle(brand: "Confederate", model: "P51 Combat Fighter", year: 2024, fuelConsumption: 6.5, engineSize: 2163, tankSize: 24.2),
        
        // Erik Buell Racing
        Motorcycle(brand: "Erik Buell Racing", model: "1190RX", year: 2024, fuelConsumption: 5.5, engineSize: 1190, tankSize: 24.8),
        
        // Horex
        Motorcycle(brand: "Horex", model: "VR6", year: 2024, fuelConsumption: 5.2, engineSize: 1218, tankSize: 20.1),
        
        // Vyrus
        Motorcycle(brand: "Vyrus", model: "Alyen 988", year: 2024, fuelConsumption: 5.8, engineSize: 988, tankSize: 21.2),
        
        // CCM Motorcycles
        Motorcycle(brand: "CCM", model: "Spitfire 600", year: 2024, fuelConsumption: 4.2, engineSize: 600, tankSize: 16.2),
        
        // Vertemati
        Motorcycle(brand: "Vertemati", model: "SR 450", year: 2024, fuelConsumption: 4.0, engineSize: 450, tankSize: 14.3),
        
        // BSA
        Motorcycle(brand: "BSA", model: "Model E", year: 1919, fuelConsumption: 2.8, engineSize: 557, tankSize: 15.7),
        Motorcycle(brand: "BSA", model: "Empire Star", year: 1936, fuelConsumption: 3.5, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "BSA", model: "M20", year: 1940, fuelConsumption: 3.8, engineSize: 496, tankSize: 14.9),
        Motorcycle(brand: "BSA", model: "Gold Star DBD34", year: 1956, fuelConsumption: 4.0, engineSize: 500, tankSize: 15.0),
        Motorcycle(brand: "BSA", model: "A10 Golden Flash", year: 1950, fuelConsumption: 4.2, engineSize: 646, tankSize: 16.8),
        Motorcycle(brand: "BSA", model: "A65 Thunderbolt", year: 1965, fuelConsumption: 4.5, engineSize: 654, tankSize: 16.8),
        Motorcycle(brand: "BSA", model: "Rocket 3", year: 1968, fuelConsumption: 5.0, engineSize: 740, tankSize: 17.9),
        
        // Vincent
        Motorcycle(brand: "Vincent", model: "Rapide Series A", year: 1937, fuelConsumption: 4.0, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Vincent", model: "Rapide Series C", year: 1948, fuelConsumption: 4.5, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Vincent", model: "Black Shadow", year: 1948, fuelConsumption: 5.0, engineSize: 998, tankSize: 21.4),
        Motorcycle(brand: "Vincent", model: "Black Knight", year: 1954, fuelConsumption: 5.2, engineSize: 998, tankSize: 21.4),
        
        // Matchless
        Motorcycle(brand: "Matchless", model: "G3", year: 1940, fuelConsumption: 3.5, engineSize: 347, tankSize: 12.8),
        Motorcycle(brand: "Matchless", model: "G80", year: 1946, fuelConsumption: 4.0, engineSize: 497, tankSize: 15.0),
        Motorcycle(brand: "Matchless", model: "G12", year: 1958, fuelConsumption: 4.5, engineSize: 646, tankSize: 16.8),
        
        // Velocette
        Motorcycle(brand: "Velocette", model: "KSS", year: 1936, fuelConsumption: 3.2, engineSize: 348, tankSize: 12.8),
        Motorcycle(brand: "Velocette", model: "MAC", year: 1939, fuelConsumption: 3.5, engineSize: 349, tankSize: 12.8),
        Motorcycle(brand: "Velocette", model: "Venom", year: 1956, fuelConsumption: 4.0, engineSize: 499, tankSize: 15.0),
        Motorcycle(brand: "Velocette", model: "Thruxton", year: 1965, fuelConsumption: 4.2, engineSize: 499, tankSize: 15.0),
    ]
    
    var brands: [String] {
        Array(Set(motorcycles.map { $0.brand })).sorted()
    }
    
    func models(for brand: String) -> [Motorcycle] {
        motorcycles.filter { $0.brand == brand }.sorted { $0.model < $1.model }
    }
    
    func models(for brand: String, model: String) -> [Motorcycle] {
        motorcycles.filter { $0.brand == brand && $0.model == model }.sorted { $0.year > $1.year }
    }
    
    func search(query: String) -> [Motorcycle] {
        if query.isEmpty {
            return motorcycles
        }
        return motorcycles.filter {
            $0.brand.localizedCaseInsensitiveContains(query) ||
            $0.model.localizedCaseInsensitiveContains(query)
        }
    }
}
