//
//  ErrorAlertView.swift
//  MCVenture
//

import SwiftUI

enum AppError: Identifiable {
    case networkUnavailable
    case locationPermissionDenied
    case cloudKitSyncFailed(String)
    case dataCorrupted
    case insufficientStorage
    case cameraUnavailable
    case routeLoadFailed
    case exportFailed
    case generic(String)
    
    var id: String {
        switch self {
        case .networkUnavailable: return "network"
        case .locationPermissionDenied: return "location"
        case .cloudKitSyncFailed(let msg): return "cloudkit_\(msg)"
        case .dataCorrupted: return "data"
        case .insufficientStorage: return "storage"
        case .cameraUnavailable: return "camera"
        case .routeLoadFailed: return "route"
        case .exportFailed: return "export"
        case .generic(let msg): return "generic_\(msg)"
        }
    }
    
    var title: String {
        switch self {
        case .networkUnavailable:
            return "No Internet Connection"
        case .locationPermissionDenied:
            return "Location Access Needed"
        case .cloudKitSyncFailed:
            return "Sync Failed"
        case .dataCorrupted:
            return "Data Error"
        case .insufficientStorage:
            return "Storage Full"
        case .cameraUnavailable:
            return "Camera Unavailable"
        case .routeLoadFailed:
            return "Can't Load Route"
        case .exportFailed:
            return "Export Failed"
        case .generic:
            return "Something Went Wrong"
        }
    }
    
    var message: String {
        switch self {
        case .networkUnavailable:
            return "Some features require an internet connection. Your data will sync when you're back online."
        case .locationPermissionDenied:
            return "MCVenture needs location access to track your rides. Enable it in Settings to use all features."
        case .cloudKitSyncFailed(let details):
            return "Failed to sync with iCloud: \(details). Your data is safe locally and will sync when possible."
        case .dataCorrupted:
            return "Some data couldn't be loaded. This might be due to app updates or file corruption."
        case .insufficientStorage:
            return "Your device is running low on storage. Free up space to continue recording trips and photos."
        case .cameraUnavailable:
            return "Can't access the camera right now. Check if another app is using it or enable camera access in Settings."
        case .routeLoadFailed:
            return "This route couldn't be loaded. It may be corrupted or incompatible with this version."
        case .exportFailed:
            return "Failed to export your data. Make sure you have enough storage and try again."
        case .generic(let message):
            return message
        }
    }
    
    var icon: String {
        switch self {
        case .networkUnavailable:
            return "wifi.slash"
        case .locationPermissionDenied:
            return "location.slash.fill"
        case .cloudKitSyncFailed:
            return "icloud.slash.fill"
        case .dataCorrupted:
            return "exclamationmark.triangle.fill"
        case .insufficientStorage:
            return "externaldrive.fill.badge.exclamationmark"
        case .cameraUnavailable:
            return "camera.fill.badge.ellipsis"
        case .routeLoadFailed:
            return "map.fill"
        case .exportFailed:
            return "square.and.arrow.up.trianglebadge.exclamationmark"
        case .generic:
            return "exclamationmark.circle.fill"
        }
    }
    
    var recoveryActions: [RecoveryAction] {
        switch self {
        case .networkUnavailable:
            return [
                RecoveryAction(title: "Continue Offline", style: .default, action: {}),
                RecoveryAction(title: "Open Settings", style: .primary, action: {
                    openSettings()
                })
            ]
        case .locationPermissionDenied:
            return [
                RecoveryAction(title: "Not Now", style: .cancel, action: {}),
                RecoveryAction(title: "Open Settings", style: .primary, action: {
                    openSettings()
                })
            ]
        case .cloudKitSyncFailed:
            return [
                RecoveryAction(title: "Try Again", style: .primary, action: {
                    // Retry sync logic would go here
                })
            ]
        case .dataCorrupted:
            return [
                RecoveryAction(title: "Contact Support", style: .default, action: {
                    openSupport()
                })
            ]
        case .insufficientStorage:
            return [
                RecoveryAction(title: "Open Settings", style: .primary, action: {
                    openSettings()
                })
            ]
        case .cameraUnavailable:
            return [
                RecoveryAction(title: "Try Again", style: .primary, action: {}),
                RecoveryAction(title: "Open Settings", style: .default, action: {
                    openSettings()
                })
            ]
        case .routeLoadFailed:
            return [
                RecoveryAction(title: "Try Again", style: .primary, action: {})
            ]
        case .exportFailed:
            return [
                RecoveryAction(title: "Try Again", style: .primary, action: {})
            ]
        case .generic:
            return [
                RecoveryAction(title: "OK", style: .default, action: {})
            ]
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSupport() {
        if let url = URL(string: "mailto:support@mcventure.com?subject=Data%20Error") {
            UIApplication.shared.open(url)
        }
    }
}

struct RecoveryAction {
    let title: String
    let style: ActionStyle
    let action: () -> Void
    
    enum ActionStyle {
        case primary
        case `default`
        case cancel
        case destructive
    }
}

struct ErrorAlertView: View {
    let error: AppError
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Error icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.red.opacity(0.2), .red.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: error.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(.red)
                }
                
                VStack(spacing: 10) {
                    Text(error.title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(error.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Recovery actions
                VStack(spacing: 10) {
                    ForEach(error.recoveryActions.indices, id: \.self) { index in
                        let action = error.recoveryActions[index]
                        
                        Button(action: {
                            HapticManager.shared.light()
                            action.action()
                            if action.style == .cancel || action.style == .default {
                                onDismiss()
                            }
                        }) {
                            Text(action.title)
                                .font(.headline)
                                .foregroundColor(buttonForegroundColor(for: action.style))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(buttonBackground(for: action.style))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .padding(40)
        }
        .onAppear {
            HapticManager.shared.error()
        }
    }
    
    private func buttonBackground(for style: RecoveryAction.ActionStyle) -> some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .destructive:
            return AnyShapeStyle(Color.red)
        case .default, .cancel:
            return AnyShapeStyle(Color.secondary.opacity(0.2))
        }
    }
    
    private func buttonForegroundColor(for style: RecoveryAction.ActionStyle) -> Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .default, .cancel:
            return .primary
        }
    }
}

// View modifier for easy error handling
struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let error = error {
                ErrorAlertView(error: error) {
                    self.error = nil
                }
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error != nil)
    }
}

extension View {
    func errorAlert(_ error: Binding<AppError?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}

#Preview {
    ErrorAlertView(error: .locationPermissionDenied) { }
}
