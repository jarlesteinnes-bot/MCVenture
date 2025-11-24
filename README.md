# MCVenture 🏍️

**Your Ultimate Motorcycle Adventure Companion**

A comprehensive iOS app for motorcycle enthusiasts to discover routes, track trips, and connect with the riding community.

[![Platform](https://img.shields.io/badge/platform-iOS%2016.0%2B-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🌍 Supported Languages

MCVenture is available in **8 languages** covering the major European motorcycle markets:

| Language | Code | Market Size | Status |
|----------|------|-------------|--------|
| 🇬🇧 English | `en` | Global (default) | ✅ Complete |
| 🇳🇴 Norwegian (Bokmål) | `nb` | 5.5M | ✅ Complete |
| 🇩🇪 German (Deutsch) | `de` | 83M | ✅ Complete |
| 🇪🇸 Spanish (Español) | `es` | 47M | ✅ Complete |
| 🇫🇷 French (Français) | `fr` | 67M | ✅ Complete |
| 🇮🇹 Italian (Italiano) | `it` | 60M | ✅ Complete |
| 🇸🇪 Swedish (Svenska) | `sv` | 10.5M | ✅ Complete |
| 🇩🇰 Danish (Dansk) | `da` | 6M | ✅ Complete |

**Total Market Coverage**: ~280M European users

### Language Features
- 🔄 **Runtime language switching** - No app restart required
- 💾 **Persistent preference** - Language choice saved
- 🌐 **Auto-detection** - Automatically detects device language on first launch
- 🔙 **Fallback support** - Defaults to English if translation missing
- 📱 **Native UI** - All interface elements fully localized

Users can switch language anytime via **Settings → Language**

## ✨ Features

### 🗺️ Route Discovery
- Browse curated motorcycle routes
- Search by location, difficulty, or distance
- View topography maps for each route
- Save favorite routes for offline access
- Filter by scenic roads, mountain passes, coastal routes

### 📍 GPS Trip Tracking
- Real-time GPS tracking with elevation data
- Automatic trip statistics (distance, speed, elevation gain)
- Route playback and analysis
- Photo capture with geolocation
- Trip history and analytics

### 🚨 Safety Features
- Crash detection with automatic alerts
- Emergency SOS with location sharing
- Emergency contact management
- Medical information storage
- Offline mode for remote areas

### 👥 Community
- Share routes with other riders
- Discover community-created routes
- CloudKit-based social features
- User profiles and achievements
- Route ratings and reviews

### 🔧 Maintenance Tracking
- Service schedule reminders
- Maintenance history log
- Mileage tracking
- Tire and oil change reminders

### ☁️ Weather Integration
- Real-time weather conditions
- Route-specific weather forecasts
- Wind and visibility data
- Multi-day forecasts

## 🚀 Technical Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Minimum iOS**: 16.0+
- **Architecture**: MVVM with Combine
- **Persistence**: SwiftData / CoreData
- **Networking**: URLSession with retry logic
- **Maps**: MapKit with custom overlays
- **Cloud**: CloudKit for sync and sharing
- **Analytics**: Built-in analytics framework

## 📱 Requirements

- iOS 16.0 or later
- iPhone (optimized for all screen sizes)
- Location Services (for GPS tracking)
- Camera (optional, for photo capture)
- iCloud account (optional, for sync and sharing)

## 🏗️ Project Structure

```
MCVenture/
├── MCVenture/
│   ├── Models/              # Data models
│   ├── Views/               # SwiftUI views
│   ├── Managers/            # Business logic managers
│   ├── Utilities/           # Helper utilities
│   ├── Assets.xcassets/     # Images and app icons
│   ├── en.lproj/            # English translations
│   ├── nb.lproj/            # Norwegian translations
│   ├── de.lproj/            # German translations
│   ├── es.lproj/            # Spanish translations
│   ├── fr.lproj/            # French translations
│   ├── it.lproj/            # Italian translations
│   ├── sv.lproj/            # Swedish translations
│   └── da.lproj/            # Danish translations
├── MCVentureTests/          # Unit tests
└── MCVentureUITests/        # UI tests
```

## 🔧 Key Managers

### LocalizationManager
Handles runtime language switching and string localization.

### GPSTrackingManager
Manages GPS tracking, elevation data, and trip recording.

### CloudKitSyncManager
Handles data synchronization and route sharing via CloudKit.

### RouteScraperManager
Scrapes and imports routes from external sources.

### EmergencyManager
Manages crash detection and emergency features.

### NetworkRetryManager
Provides robust network calls with automatic retry logic.

### AnalyticsManager
Tracks events, errors, and performance metrics.

## 🌐 Localization

All user-facing strings are localized using the `.localized` extension:

```swift
// Before
Text("Save")

// After
Text("button.save".localized)
```

### Adding a New Language

1. Create language folder: `mkdir MCVenture/xx.lproj`
2. Copy English strings: `cp MCVenture/en.lproj/Localizable.strings MCVenture/xx.lproj/`
3. Translate strings in the new file
4. Add language to `LocalizationManager.swift`
5. Add folder to Xcode project

See `LOCALIZATION_GUIDE.md` for detailed instructions.

## 🔐 Privacy & Legal

- **Privacy Policy**: https://jarlesteinnes-bot.github.io/mcventure-legal/privacy-policy.html
- **Terms of Service**: https://jarlesteinnes-bot.github.io/mcventure-legal/terms-of-service.html
- **Support**: https://jarlesteinnes-bot.github.io/mcventure-legal/

All legal documents are:
- ✅ GDPR compliant
- ✅ CCPA compliant
- ✅ COPPA compliant
- ✅ Mobile-responsive
- ✅ Multi-language ready

## 📊 App Store

### Screenshots
Available for all device sizes:
- 6.7-inch (iPhone 14/15/16 Pro Max)
- 6.5-inch (iPhone 11 Pro Max, XS Max)
- 5.5-inch (iPhone 8 Plus, 7 Plus)

### App Icons
13 validated and Apple-compliant app icons included.

### Keywords
Motorcycle, route, GPS, trip tracker, navigation, adventure, touring, riding, biker, moto

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ SDK
- Apple Developer Account (for device testing)

### Building the App

```bash
# Clone the repository
git clone <repository-url>
cd MCVenture

# Open in Xcode
open MCVenture.xcodeproj

# Build and run
# Press Cmd+R in Xcode
```

### Running Tests

```bash
# Unit tests
xcodebuild test -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -project MCVenture.xcodeproj -scheme MCVenture -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MCVentureUITests
```

## 📝 Documentation

- `LOCALIZATION_GUIDE.md` - Complete localization documentation
- `PRE_LAUNCH_REVIEW.md` - Pre-launch checklist and recommendations
- `WARP.md` - Project guidelines and development info

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Areas for Contribution
- 🌍 Additional language translations
- 🗺️ More route sources
- 🎨 UI/UX improvements
- 🐛 Bug fixes
- 📝 Documentation improvements

## 📈 Roadmap

### Version 1.1
- [ ] Additional language support (Portuguese, Dutch, Polish)
- [ ] Advanced route filtering
- [ ] Social features expansion
- [ ] Weather alerts
- [ ] Route recommendations AI

### Version 1.2
- [ ] Apple Watch companion app
- [ ] CarPlay support
- [ ] Route import from GPX files
- [ ] Export trip data
- [ ] Custom route creation

### Version 2.0
- [ ] AR navigation features
- [ ] Community challenges
- [ ] Leaderboards
- [ ] Premium subscription features
- [ ] Professional route planning tools

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**BNTF**
- Bundle ID: `com.mc.no.MCVenture`

## 🙏 Acknowledgments

- Apple MapKit for mapping functionality
- CloudKit for seamless data sync
- The motorcycle community for inspiration and feedback

## 📧 Support

For support, email: [Your support email]
Or visit: https://jarlesteinnes-bot.github.io/mcventure-legal/

## 🌟 Show Your Support

If you like this app, please give it a ⭐ on GitHub!

---

**Built with ❤️ for the motorcycle community**

*Last Updated: November 24, 2025*
*Version: 1.0*
*Market Coverage: 280M European users across 8 languages*
