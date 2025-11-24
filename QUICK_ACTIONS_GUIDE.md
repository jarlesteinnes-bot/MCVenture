# Quick Actions (Home Screen Shortcuts) Implementation Guide

Quick Actions provide convenient shortcuts from the Home Screen when users 3D Touch or long-press the app icon.

## Implementation Steps

### 1. Add to Info.plist

Add the following to your `Info.plist` (or in Xcode: Target → Info → Custom iOS Target Properties):

```xml
<key>UIApplicationShortcutItems</key>
<array>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.mc.no.MCVenture.startTrip</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Start Trip</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>Begin tracking your ride</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeLocation</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.mc.no.MCVenture.viewLastTrip</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>View Last Trip</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>See your most recent ride</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeTime</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.mc.no.MCVenture.planRoute</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Plan Route</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>Create a new motorcycle route</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeCompose</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>com.mc.no.MCVenture.nearbyRoutes</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Nearby Routes</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>Discover routes near you</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeSearch</string>
    </dict>
</array>
```

### 2. Create QuickActionsManager

Create `QuickActionsManager.swift` in the Managers folder:

```swift
//
//  QuickActionsManager.swift
//  MCVenture
//

import UIKit

enum QuickAction: String {
    case startTrip = "com.mc.no.MCVenture.startTrip"
    case viewLastTrip = "com.mc.no.MCVenture.viewLastTrip"
    case planRoute = "com.mc.no.MCVenture.planRoute"
    case nearbyRoutes = "com.mc.no.MCVenture.nearbyRoutes"
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            return nil
        }
        self = action
    }
}

@MainActor
class QuickActionsManager: ObservableObject {
    static let shared = QuickActionsManager()
    
    @Published var pendingAction: QuickAction?
    
    private init() {}
    
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(shortcutItem: shortcutItem) else {
            return false
        }
        
        pendingAction = action
        HapticManager.shared.light()
        
        return true
    }
    
    func clearPendingAction() {
        pendingAction = nil
    }
    
    // Update dynamic shortcuts based on app state
    func updateDynamicShortcuts(recentTripCount: Int, nearbyRoutesCount: Int) {
        var shortcuts: [UIApplicationShortcutItem] = []
        
        // Always include Start Trip
        shortcuts.append(
            UIApplicationShortcutItem(
                type: QuickAction.startTrip.rawValue,
                localizedTitle: "Start Trip",
                localizedSubtitle: "Begin tracking your ride",
                icon: UIApplicationShortcutIcon(systemImageName: "location.fill")
            )
        )
        
        // Include View Last Trip only if there are trips
        if recentTripCount > 0 {
            shortcuts.append(
                UIApplicationShortcutItem(
                    type: QuickAction.viewLastTrip.rawValue,
                    localizedTitle: "View Last Trip",
                    localizedSubtitle: "\(recentTripCount) trips recorded",
                    icon: UIApplicationShortcutIcon(systemImageName: "clock.fill")
                )
            )
        }
        
        // Include Nearby Routes only if available
        if nearbyRoutesCount > 0 {
            shortcuts.append(
                UIApplicationShortcutItem(
                    type: QuickAction.nearbyRoutes.rawValue,
                    localizedTitle: "Nearby Routes",
                    localizedSubtitle: "\(nearbyRoutesCount) routes nearby",
                    icon: UIApplicationShortcutIcon(systemImageName: "map.fill")
                )
            )
        }
        
        // Always include Plan Route
        shortcuts.append(
            UIApplicationShortcutItem(
                type: QuickAction.planRoute.rawValue,
                localizedTitle: "Plan Route",
                localizedSubtitle: "Create a new route",
                icon: UIApplicationShortcutIcon(systemImageName: "map.circle.fill")
            )
        )
        
        UIApplication.shared.shortcutItems = shortcuts
    }
}
```

### 3. Handle Quick Actions in App Delegate

If using UIKit App Delegate, add this method:

```swift
func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
) {
    let handled = QuickActionsManager.shared.handleShortcutItem(shortcutItem)
    completionHandler(handled)
}
```

### 4. Handle Quick Actions in SwiftUI App

For SwiftUI-only apps, handle in the main App struct:

```swift
@main
struct MCVentureApp: App {
    @StateObject private var quickActionsManager = QuickActionsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handle URL schemes
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    // Handle universal links
                }
                .environmentObject(quickActionsManager)
        }
    }
}

// In your main/root view:
struct MainMenuView: View {
    @EnvironmentObject var quickActionsManager: QuickActionsManager
    @State private var showTrackMyRide = false
    @State private var showRoutePlanner = false
    @State private var showLastTrip = false
    @State private var showNearbyRoutes = false
    
    var body: some View {
        // Your main menu UI...
        
        .onChange(of: quickActionsManager.pendingAction) { _, action in
            guard let action = action else { return }
            
            switch action {
            case .startTrip:
                showTrackMyRide = true
            case .viewLastTrip:
                showLastTrip = true
            case .planRoute:
                showRoutePlanner = true
            case .nearbyRoutes:
                showNearbyRoutes = true
            }
            
            quickActionsManager.clearPendingAction()
        }
        .sheet(isPresented: $showTrackMyRide) {
            // Your Track My Ride view
        }
        .sheet(isPresented: $showRoutePlanner) {
            // Your Route Planner view
        }
        // etc.
    }
}
```

### 5. Update Dynamic Shortcuts

Call this when app state changes:

```swift
// In your app initialization or when data changes:
func updateShortcuts() {
    let tripCount = /* fetch trip count */
    let nearbyRoutesCount = /* fetch nearby routes count */
    
    QuickActionsManager.shared.updateDynamicShortcuts(
        recentTripCount: tripCount,
        nearbyRoutesCount: nearbyRoutesCount
    )
}
```

## Available System Icons

For `UIApplicationShortcutIconType`:
- `UIApplicationShortcutIconTypeCompose`
- `UIApplicationShortcutIconTypePlay`
- `UIApplicationShortcutIconTypePause`
- `UIApplicationShortcutIconTypeAdd`
- `UIApplicationShortcutIconTypeLocation`
- `UIApplicationShortcutIconTypeSearch`
- `UIApplicationShortcutIconTypeShare`
- `UIApplicationShortcutIconTypeFavorite`
- `UIApplicationShortcutIconTypeLove`
- `UIApplicationShortcutIconTypeTime`
- `UIApplicationShortcutIconTypeCapturePhoto`
- `UIApplicationShortcutIconTypeUpdate`

For SF Symbols (iOS 13+):
```swift
UIApplicationShortcutIcon(systemImageName: "figure.motorcycling")
```

## Custom Icons

To use custom icons:

1. Add 35x35 pt (@2x = 70x70px, @3x = 105x105px) template images to Assets
2. Use single color, transparent background
3. Reference in code:

```swift
UIApplicationShortcutIcon(templateImageName: "CustomIcon")
```

## Best Practices

1. **Limit to 4 shortcuts** - iOS displays max 4 at once
2. **Use dynamic shortcuts** - Update based on user behavior
3. **Clear descriptions** - Use concise, actionable titles
4. **Appropriate icons** - Choose recognizable SF Symbols
5. **Handle cold launch** - Quick actions work even when app is closed
6. **Test thoroughly** - Test on device, not just simulator
7. **Localization** - Use NSLocalizedString for multi-language support

## Testing

1. Build and run on a physical device (doesn't work reliably in simulator)
2. Go to Home Screen
3. Long-press the MCVenture app icon
4. Tap a quick action
5. Verify the app opens to the correct screen

## Localization

For localized shortcuts, use `NSLocalizedString`:

```swift
UIApplicationShortcutItem(
    type: QuickAction.startTrip.rawValue,
    localizedTitle: NSLocalizedString("quick_action.start_trip.title", comment: ""),
    localizedSubtitle: NSLocalizedString("quick_action.start_trip.subtitle", comment: ""),
    icon: UIApplicationShortcutIcon(systemImageName: "location.fill")
)
```

## Analytics

Track quick action usage:

```swift
func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
    guard let action = QuickAction(shortcutItem: shortcutItem) else {
        return false
    }
    
    // Track analytics
    // Analytics.log("quick_action_used", parameters: ["action": action.rawValue])
    
    pendingAction = action
    return true
}
```

This helps you understand which shortcuts users prefer and optimize accordingly.
