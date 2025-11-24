import Foundation
import CoreMotion
import CoreLocation
import Combine
#if os(iOS)
import UIKit
#endif

@MainActor
class SafetyMonitor: ObservableObject {
    @Published var crashDetected = false
    @Published var lowBattery = false
    @Published var sosActivated = false
    @Published var batteryLevel: Float = 1.0
    
    private let motionManager = CMMotionManager()
    private var crashThreshold: Double = 3.0 // G-force threshold
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startMonitoring()
        monitorBattery()
    }
    
    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let acceleration = data?.acceleration else { return }
            
            Task { @MainActor in
                self.checkForCrash(acceleration: acceleration)
            }
        }
    }
    
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func checkForCrash(acceleration: CMAcceleration) {
        let totalAcceleration = sqrt(
            pow(acceleration.x, 2) +
            pow(acceleration.y, 2) +
            pow(acceleration.z, 2)
        )
        
        // Subtract gravity (1G) to get net acceleration
        let netAcceleration = abs(totalAcceleration - 1.0)
        
        if netAcceleration > crashThreshold && !crashDetected {
            crashDetected = true
            handleCrashDetection()
        }
    }
    
    private func handleCrashDetection() {
        // Trigger alert and start countdown for emergency services
        print("⚠️ CRASH DETECTED - Starting emergency protocol")
    }
    
    func activateSOS(location: CLLocation?) {
        sosActivated = true
        
        guard let location = location else {
            print("⚠️ SOS Activated - Location unavailable")
            return
        }
        
        let message = """
        🚨 EMERGENCY SOS
        Location: \(location.coordinate.latitude), \(location.coordinate.longitude)
        Maps: https://maps.apple.com/?q=\(location.coordinate.latitude),\(location.coordinate.longitude)
        Time: \(Date().formatted())
        """
        
        print(message)
        shareLocation(message: message)
    }
    
    func deactivateSOS() {
        sosActivated = false
        crashDetected = false
    }
    
    private func shareLocation(message: String) {
        #if os(iOS)
        // Share via system share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            let activityVC = UIActivityViewController(
                activityItems: [message],
                applicationActivities: nil
            )
            rootViewController.present(activityVC, animated: true)
        }
        #endif
    }
    
    private func monitorBattery() {
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.batteryLevel = UIDevice.current.batteryLevel
                    self.lowBattery = self.batteryLevel < 0.2 && self.batteryLevel > 0
                }
            }
            .store(in: &cancellables)
        #endif
    }
    
    func resetCrashDetection() {
        crashDetected = false
    }
}
