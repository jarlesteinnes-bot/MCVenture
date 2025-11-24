# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

MCVenture is a SwiftUI-based iOS/macOS application for motorcycle and hiking routes. The app provides comprehensive route management with GPS tracking, elevation data, topography maps, and social sharing features.

**Key Features:**
- Route scraping with persistence (data survives app restarts)
- GPS-based tracking with elevation gain/loss calculations
- Topography map integration for routes and spots
- CloudKit-based route sharing between users
- Trail, safety, wildlife, and photo information tied to specific route locations
- Norwegian language support (æ, ø, å keyboard characters)
- Elevation curves and statistics (total km, trip-specific km, height meters)

## Build & Test Commands

### Building
```bash
# Build for macOS
xcodebuild -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=macOS' build

# Build for iOS Simulator
xcodebuild -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean build
xcodebuild -project MCVenture.xcodeproj -scheme MCVenture clean
```

### Testing
```bash
# Run all tests
xcodebuild test -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=macOS'

# Run specific test class
xcodebuild test -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=macOS' -only-testing:MCVentureTests/MCVentureTests

# Run UI tests
xcodebuild test -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=macOS' -only-testing:MCVentureUITests
```

### Running the App
```bash
# Open in Xcode
open MCVenture.xcodeproj

# Run directly (after opening in Xcode, use Cmd+R)
```

## Architecture Guidelines

### Data Persistence
- All scraped routes must persist across app restarts
- Use appropriate storage mechanisms (CoreData, SwiftData, or similar) for route data
- Ensure CloudKit sync maintains data integrity

### CloudKit Integration
- User-added routes are synced via Apple-native CloudKit
- User-added routes should display in a different color on maps to distinguish from scraped/official routes
- Implement proper error handling for network failures during sync

### GPS & Location Services
- GPS integration required for tracking trips and calculating elevation data
- Elevation gain/loss tracking per trip and cumulative totals
- Store trip-specific kilometers and total kilometers ever

### Map Features
- Topography maps must be correctly positioned for each tour and spot route
- Support multiple layers: routes, user-added routes (different color), topography, annotations
- Route data includes trail conditions, safety info, wildlife info, and photos at specific coordinates

### User Interface
- Search functionality must support Norwegian characters: æ, ø, å
- Profile section includes settings functions
- Display elevation curves for routes
- Show loading notifications when comprehensive route database is initializing
- Height meter summary showing total elevation gained

### Route Data Model
Key data associated with routes:
- GPS coordinates and polylines
- Elevation profile data
- Trail conditions
- Safety information
- Wildlife observations
- Photo attachments with geolocation
- User annotations
- Topography map tiles/overlays

## Development Notes

### Language & Framework
- Swift 5.0
- SwiftUI for UI layer
- Target: iOS/macOS (cross-platform)
- Bundle ID: com.mc.no.MCVenture

### Key Technologies
- CloudKit for data sync and sharing
- MapKit for map rendering and route display
- CoreLocation for GPS tracking
- Combine for reactive data flow (likely needed for real-time GPS updates)

### Norwegian Localization
When implementing text input or search:
- Ensure keyboard layouts support æ, ø, å characters
- Consider Norwegian text collation for sorting route names
- Use proper localization for UI strings

### Testing Approach
- Use XCTest framework (already set up)
- Test CloudKit sync with different network conditions
- Mock GPS data for consistent elevation calculation tests
- Test data persistence across app lifecycle events
