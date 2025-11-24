//
//  WeatherManager.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import Foundation
import CoreLocation
import WeatherKit
import Combine

// MARK: - Route Weather Alert
struct RouteWeatherAlert: Identifiable {
    let id = UUID()
    let type: WeatherAlertType
    let severity: AlertSeverity
    let title: String
    let message: String
    let location: CLLocationCoordinate2D
    let timestamp: Date
    
    enum WeatherAlertType {
        case heavyRain
        case strongWind
        case thunderstorm
        case freezing
        case fog
        case snow
        case ice
        case heatWarning
        
        var icon: String {
            switch self {
            case .heavyRain: return "cloud.heavyrain.fill"
            case .strongWind: return "wind"
            case .thunderstorm: return "cloud.bolt.rain.fill"
            case .freezing: return "thermometer.snowflake"
            case .fog: return "cloud.fog.fill"
            case .snow: return "snow"
            case .ice: return "snowflake"
            case .heatWarning: return "thermometer.sun.fill"
            }
        }
    }
    
    enum AlertSeverity {
        case info
        case warning
        case severe
        case extreme
        
        var color: String {
            switch self {
            case .info: return "blue"
            case .warning: return "yellow"
            case .severe: return "orange"
            case .extreme: return "red"
            }
        }
    }
}

// MARK: - Weather Forecast Point
struct WeatherForecastPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let distanceKm: Double
    let estimatedArrivalTime: Date
    let temperature: Double // Celsius
    let condition: String
    let precipitationChance: Double // 0-100
    let windSpeed: Double // km/h
    let visibility: Double // km
    let icon: String
}

// MARK: - Gear Recommendation
struct GearRecommendation: Identifiable {
    let id = UUID()
    let category: String
    let items: [String]
    let reason: String
    let icon: String
}

// MARK: - Weather Manager
class WeatherManager: ObservableObject {
    static let shared = WeatherManager()
    
    private let weatherService = WeatherService.shared
    
    @Published var currentWeatherAlerts: [RouteWeatherAlert] = []
    @Published var routeWeatherForecast: [WeatherForecastPoint] = []
    @Published var gearRecommendations: [GearRecommendation] = []
    @Published var bestDepartureTime: Date?
    
    private var checkTimer: Timer?
    
    init() {}
    
    // MARK: - Weather Checking for Active Trip
    func startWeatherMonitoring(route: [CLLocationCoordinate2D]) {
        // Stop any existing monitoring
        stopWeatherMonitoring()
        
        // Check weather immediately
        Task {
            await checkWeatherAlerts(along: route)
            await generateRouteForecast(route: route)
        }
        
        // Check every 30 minutes
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            Task {
                await self?.checkWeatherAlerts(along: route)
                await self?.generateRouteForecast(route: route)
            }
        }
    }
    
    func stopWeatherMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
    
    // MARK: - Weather Alerts
    func checkWeatherAlerts(along route: [CLLocationCoordinate2D]) async {
        var alerts: [RouteWeatherAlert] = []
        
        // Sample points along the route (every 50km or so)
        let sampleInterval = max(1, route.count / 10)
        let samplePoints = stride(from: 0, to: route.count, by: sampleInterval).map { route[$0] }
        
        for coordinate in samplePoints {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            do {
                let weather = try await weatherService.weather(for: location)
                
                // Check for severe weather conditions
                let currentCondition = weather.currentWeather
                
                // Heavy rain check (>10mm/hour)
                if let precipitation = weather.hourlyForecast.first?.precipitationAmount.value,
                   precipitation > 10 {
                    alerts.append(RouteWeatherAlert(
                        type: .heavyRain,
                        severity: .warning,
                        title: "Heavy Rain Alert",
                        message: "Heavy rainfall expected (\(Int(precipitation))mm/hour). Reduced visibility and slippery roads.",
                        location: coordinate,
                        timestamp: Date()
                    ))
                }
                
                // Strong wind check (>40 km/h)
                if currentCondition.wind.speed.value * 3.6 > 40 {
                    alerts.append(RouteWeatherAlert(
                        type: .strongWind,
                        severity: .warning,
                        title: "Strong Wind Warning",
                        message: "Wind speed: \(Int(currentCondition.wind.speed.value * 3.6)) km/h. Use caution, especially on open roads.",
                        location: coordinate,
                        timestamp: Date()
                    ))
                }
                
                // Freezing temperature check (<2°C)
                if currentCondition.temperature.value < 2 {
                    alerts.append(RouteWeatherAlert(
                        type: .freezing,
                        severity: .severe,
                        title: "Freezing Conditions",
                        message: "Temperature: \(String(format: "%.1f", currentCondition.temperature.value))°C. Risk of ice on roads.",
                        location: coordinate,
                        timestamp: Date()
                    ))
                }
                
                // High temperature check (>35°C)
                if currentCondition.temperature.value > 35 {
                    alerts.append(RouteWeatherAlert(
                        type: .heatWarning,
                        severity: .warning,
                        title: "Heat Warning",
                        message: "Temperature: \(String(format: "%.1f", currentCondition.temperature.value))°C. Stay hydrated and take breaks.",
                        location: coordinate,
                        timestamp: Date()
                    ))
                }
                
                // Low visibility check (<1km)
                if currentCondition.visibility.value < 1000 {
                    alerts.append(RouteWeatherAlert(
                        type: .fog,
                        severity: .warning,
                        title: "Low Visibility",
                        message: "Visibility: \(Int(currentCondition.visibility.value))m. Fog or mist present.",
                        location: coordinate,
                        timestamp: Date()
                    ))
                }
                
                // Check weather alerts from WeatherKit
                if let weatherAlerts = weather.weatherAlerts {
                    for alert in weatherAlerts {
                        alerts.append(RouteWeatherAlert(
                            type: .thunderstorm,
                            severity: .severe,
                            title: alert.summary,
                            message: alert.detailsURL.absoluteString,
                            location: coordinate,
                            timestamp: Date()
                        ))
                    }
                }
                
            } catch {
                print("Weather fetch error: \(error.localizedDescription)")
            }
        }
        
        DispatchQueue.main.async {
            self.currentWeatherAlerts = alerts
            if !alerts.isEmpty {
                self.generateGearRecommendations(for: alerts)
            }
        }
    }
    
    // MARK: - Route Forecast
    func generateRouteForecast(route: [CLLocationCoordinate2D], averageSpeed: Double = 60) async {
        var forecast: [WeatherForecastPoint] = []
        
        // Sample points along route
        let sampleInterval = max(1, route.count / 20)
        var cumulativeDistance: Double = 0
        var lastCoordinate: CLLocationCoordinate2D?
        
        for i in stride(from: 0, to: route.count, by: sampleInterval) {
            let coordinate = route[i]
            
            // Calculate distance
            if let last = lastCoordinate {
                let loc1 = CLLocation(latitude: last.latitude, longitude: last.longitude)
                let loc2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                cumulativeDistance += loc2.distance(from: loc1) / 1000.0 // km
            }
            
            // Estimate arrival time
            let hoursToArrival = cumulativeDistance / averageSpeed
            let arrivalTime = Date().addingTimeInterval(hoursToArrival * 3600)
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            do {
                let weather = try await weatherService.weather(for: location)
                
                // Find the hourly forecast closest to arrival time
                if let hourlyWeather = weather.hourlyForecast.first(where: { forecast in
                    abs(forecast.date.timeIntervalSince(arrivalTime)) < 1800 // Within 30 minutes
                }) {
                    
                    let point = WeatherForecastPoint(
                        coordinate: coordinate,
                        distanceKm: cumulativeDistance,
                        estimatedArrivalTime: arrivalTime,
                        temperature: hourlyWeather.temperature.value,
                        condition: hourlyWeather.condition.description,
                        precipitationChance: hourlyWeather.precipitationChance * 100,
                        windSpeed: hourlyWeather.wind.speed.value * 3.6,
                        visibility: hourlyWeather.visibility.value / 1000.0,
                        icon: getWeatherIcon(for: hourlyWeather.condition)
                    )
                    
                    forecast.append(point)
                }
            } catch {
                print("Weather forecast error: \(error.localizedDescription)")
            }
            
            lastCoordinate = coordinate
        }
        
        DispatchQueue.main.async {
            self.routeWeatherForecast = forecast
            self.calculateBestDepartureTime(forecast: forecast)
        }
    }
    
    // MARK: - Gear Recommendations
    private func generateGearRecommendations(for alerts: [RouteWeatherAlert]) {
        var recommendations: [GearRecommendation] = []
        
        let hasRain = alerts.contains(where: { $0.type == .heavyRain })
        let hasCold = alerts.contains(where: { $0.type == .freezing })
        let hasHeat = alerts.contains(where: { $0.type == .heatWarning })
        let hasWind = alerts.contains(where: { $0.type == .strongWind })
        let hasFog = alerts.contains(where: { $0.type == .fog })
        
        if hasRain {
            recommendations.append(GearRecommendation(
                category: "Rain Gear",
                items: ["Waterproof jacket", "Rain pants", "Waterproof gloves", "Anti-fog visor"],
                reason: "Heavy rain expected",
                icon: "cloud.rain.fill"
            ))
        }
        
        if hasCold {
            recommendations.append(GearRecommendation(
                category: "Cold Weather",
                items: ["Thermal base layer", "Heated grips/vest", "Winter gloves", "Neck warmer"],
                reason: "Freezing temperatures",
                icon: "snowflake"
            ))
        }
        
        if hasHeat {
            recommendations.append(GearRecommendation(
                category: "Hot Weather",
                items: ["Mesh jacket", "Hydration pack", "Cooling vest", "Sunscreen"],
                reason: "High temperatures",
                icon: "sun.max.fill"
            ))
        }
        
        if hasWind {
            recommendations.append(GearRecommendation(
                category: "Wind Protection",
                items: ["Wind-resistant jacket", "Handlebar wind deflectors", "Ear plugs"],
                reason: "Strong winds expected",
                icon: "wind"
            ))
        }
        
        if hasFog {
            recommendations.append(GearRecommendation(
                category: "Visibility",
                items: ["High-visibility vest", "Helmet lights", "Clear visor", "Reflective tape"],
                reason: "Low visibility conditions",
                icon: "eye.slash.fill"
            ))
        }
        
        self.gearRecommendations = recommendations
    }
    
    // MARK: - Best Departure Time
    private func calculateBestDepartureTime(forecast: [WeatherForecastPoint]) {
        // Find the time window with best weather (least precipitation, good temp, low wind)
        // For now, just suggest current time if weather is OK, otherwise suggest delay
        
        let badWeatherCount = forecast.filter { point in
            point.precipitationChance > 70 ||
            point.windSpeed > 50 ||
            point.temperature < 2 ||
            point.temperature > 35
        }.count
        
        if badWeatherCount > forecast.count / 2 {
            // More than half of route has bad weather, suggest 2-hour delay
            bestDepartureTime = Date().addingTimeInterval(7200)
        } else {
            bestDepartureTime = Date()
        }
    }
    
    // MARK: - Helpers
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .mostlyClear: return "cloud.sun.fill"
        case .mostlyCloudy: return "cloud.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .sleet: return "cloud.sleet.fill"
        case .hail: return "cloud.hail.fill"
        case .thunderstorms: return "cloud.bolt.rain.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .foggy: return "cloud.fog.fill"
        case .windy: return "wind"
        default: return "cloud.fill"
        }
    }
    
    deinit {
        stopWeatherMonitoring()
    }
}
