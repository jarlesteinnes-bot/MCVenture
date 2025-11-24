# App Store Assets Guide

This document provides guidance for creating and organizing App Store assets for MCVenture.

## Required App Icons

### iOS App Icon Sizes (AppIcon in Assets.xcassets)
- **1024x1024** - App Store (Required, no alpha channel)
- **180x180** - iPhone @3x (iOS 14+)
- **120x120** - iPhone @2x (iOS 14+)
- **167x167** - iPad Pro @2x
- **152x152** - iPad @2x
- **76x76** - iPad @1x
- **60x60** - iPhone @1x (Spotlight)
- **40x40** - iPad, iPhone (Spotlight/Notifications)
- **29x29** - Settings (All devices)

### Design Guidelines
- **Colors**: Use MCVenture brand colors (Blue #007AFF, Orange #FF9500)
- **Symbol**: Motorcycle icon or winding road
- **Style**: Modern, flat design with subtle gradients
- **Background**: Solid color or subtle gradient
- **No text**: Apple guidelines discourage text in app icons

### Icon Concept
```
┌─────────────────┐
│                 │
│    🏍️ + 🗺️     │
│  Motorcycle     │
│   + Route       │
│                 │
└─────────────────┘
```

## Launch Screen (LaunchScreen.storyboard)

### Recommended Design
- MCVenture logo centered
- App name below logo
- Solid background color matching app theme
- Loading indicator (optional)
- Keep it simple and fast

## App Store Screenshots

### Required Sizes
1. **6.7" iPhone 15 Pro Max**: 1290 x 2796 pixels (Required)
2. **6.5" iPhone 14 Plus**: 1284 x 2778 pixels
3. **5.5" iPhone 8 Plus**: 1242 x 2208 pixels
4. **12.9" iPad Pro**: 2048 x 2732 pixels (Optional but recommended)

### Screenshot Content Ideas

#### Screenshot 1: Main Routes View
- Title: "Discover Amazing Routes"
- Show: Route list with beautiful thumbnails
- Highlight: Curated motorcycle routes

#### Screenshot 2: Live GPS Tracking
- Title: "Real-Time GPS Tracking"
- Show: LiveMapView with active route overlay
- Highlight: Live speed, distance, elevation

#### Screenshot 3: Route Details
- Title: "Detailed Route Information"
- Show: RouteDetailView with elevation curve
- Highlight: Distance, difficulty, elevation profile

#### Screenshot 4: Trip History
- Title: "Track Your Adventures"
- Show: Trip history with statistics
- Highlight: Total kilometers, trips completed

#### Screenshot 5: Safety Features
- Title: "Stay Safe on Every Ride"
- Show: Emergency SOS, crash detection
- Highlight: Emergency contacts, automatic alerts

#### Screenshot 6: Social Sharing
- Title: "Share Routes with Friends"
- Show: Route sharing via CloudKit
- Highlight: Community routes, social feed

### Screenshot Design Tips
- Use actual app interface (not mockups)
- Add descriptive text overlays
- Show key features clearly
- Use high-quality images
- Consistent color scheme across all screenshots
- Consider localization (Norwegian + English)

## App Preview Videos (Optional but Recommended)

### Video Specifications
- **Duration**: 15-30 seconds per video
- **Format**: H.264 or HEVC, .mov or .mp4
- **Resolution**: Same as screenshot sizes
- **Aspect Ratio**: Match device screen ratio

### Video Content Ideas
1. **30-second overview**: Show app navigation, route discovery, GPS tracking
2. **Route discovery**: Browse routes, view details, start navigation
3. **Live tracking**: Start a trip, show real-time tracking, finish and save

## App Store Listing Text

### App Name
**MCVenture** (25 character limit)

### Subtitle
**Motorcycle Route Tracker & GPS** (30 character limit)

### Promotional Text (Editable Anytime)
```
🏍️ New: Crash Detection with Emergency SOS
📊 Analytics Dashboard with trip statistics
🎯 Pro Mode with advanced route planning tools
```

### Description (4000 character limit)
```
MCVenture - The Ultimate Motorcycle Route Companion

Discover, track, and share amazing motorcycle routes with MCVenture. 
Whether you're a weekend rider or a seasoned adventurer, MCVenture 
provides everything you need for unforgettable rides.

🗺️ DISCOVER AMAZING ROUTES
• Browse curated motorcycle routes from around the world
• Filter by distance, difficulty, and scenic rating
• View detailed route information with elevation profiles
• Save favorite routes for quick access
• Search routes with Norwegian keyboard support (æ, ø, å)

📍 REAL-TIME GPS TRACKING
• Live GPS tracking with offline maps
• Track speed, distance, and elevation in real-time
• Record your route with waypoints
• Auto-pause detection when you stop
• Voice navigation announcements

📊 COMPREHENSIVE STATISTICS
• Detailed trip analytics and insights
• Track total kilometers and ride time
• Elevation gain/loss tracking
• Speed statistics (average, max, typical)
• Achievement badges and milestones

🛡️ SAFETY FIRST
• Crash detection with countdown alert
• Emergency SOS with automatic contacts notification
• Location sharing with emergency contacts
• Weather warnings and road condition alerts
• Ride planning with gas stations and rest stops

🎯 PRO MODE FEATURES
• Advanced route planning tools
• Custom waypoint management
• Turn-by-turn navigation
• Route optimization algorithms
• Offline map downloads

☁️ SOCIAL FEATURES
• Share routes with the community via CloudKit
• Discover routes shared by other riders
• Social feed with ride photos and updates
• Connect with fellow motorcycle enthusiasts

🔧 MOTORCYCLE MAINTENANCE
• Service reminders and tracking
• Maintenance history logs
• Tire pressure monitoring
• Oil change tracking

✨ ADDITIONAL FEATURES
• Dark mode support
• Multiple map styles (standard, satellite, hybrid)
• Customizable units (km/mi, metric/imperial)
• Export trip data (GPX, KML)
• Photo capture and geotagging
• Accessibility support with VoiceOver

BETTER THAN COMPETITORS
MCVenture offers more features than Calimoto, Rever, and Scenic combined:
• More accurate GPS tracking
• Better route discovery algorithms
• Comprehensive safety features
• Native iOS performance
• Privacy-focused with CloudKit integration

PRIVACY & DATA
• Your data stays on your device
• Optional CloudKit sync for shared routes
• No tracking or advertising
• Full control over location permissions

Perfect for:
✓ Weekend riders exploring local routes
✓ Touring enthusiasts planning long trips
✓ Adventure riders seeking off-road trails
✓ Sport bike riders looking for twisty roads
✓ Cruiser riders enjoying scenic routes

Download MCVenture today and start your next adventure!

SUBSCRIPTION INFORMATION
MCVenture is free with basic features. Pro Mode requires a subscription:
• Monthly: $4.99/month
• Annual: $39.99/year (Save 33%)
• One-time purchase: $99.99 (Lifetime access)

Support: support@mcventure.com
Website: www.mcventure.com
Instagram: @mcventure_app
```

### Keywords (100 character limit, comma-separated)
```
motorcycle,moto,gps,tracker,routes,navigation,ride,touring,adventure,maps
```

### What's New (4000 character limit)
```
Version 1.0 - Initial Release

🏍️ Welcome to MCVenture!

We're excited to launch MCVenture, the ultimate motorcycle route companion. 
This initial release includes:

✨ NEW FEATURES
• Complete route discovery system with 10,000+ curated routes
• Real-time GPS tracking with offline support
• Comprehensive analytics dashboard
• Crash detection with emergency SOS
• Social route sharing via CloudKit
• Pro Mode with advanced planning tools
• Motorcycle maintenance tracking
• Voice announcements for navigation
• Auto-pause detection
• Photo geotagging

🛡️ SAFETY FEATURES
• Automatic crash detection
• 30-second countdown alert
• Emergency contact notifications
• Location sharing
• Weather alerts

📊 ANALYTICS & INSIGHTS
• Trip statistics with charts
• Elevation profiles
• Speed analysis
• Achievement system
• Heat maps of traveled routes

We'd love to hear your feedback! Rate us on the App Store and follow 
@mcventure_app on Instagram.

Happy riding! 🏍️💨
```

## Support URLs

### Marketing URL
```
https://www.mcventure.com
```

### Privacy Policy URL
```
https://www.mcventure.com/privacy
```

### Support URL
```
https://www.mcventure.com/support
```

## Copyright
```
© 2025 MCVenture. All rights reserved.
```

## Age Rating
- **4+** (No objectionable content)

## Categories
- **Primary**: Navigation
- **Secondary**: Travel

## Checklist Before Submission

- [ ] All app icon sizes generated and added to Assets.xcassets
- [ ] Launch screen configured and tested
- [ ] Screenshots for all required device sizes
- [ ] App preview videos (optional)
- [ ] App description written and proofread
- [ ] Keywords optimized for search
- [ ] Privacy policy published online
- [ ] Support website live
- [ ] Contact email active
- [ ] Localizations complete (Norwegian + English)
- [ ] Age rating set appropriately
- [ ] Categories selected
- [ ] Build uploaded to App Store Connect
- [ ] TestFlight beta testing completed
- [ ] All app metadata reviewed
- [ ] Pricing and availability configured
- [ ] In-app purchases configured (Pro Mode)
- [ ] App reviewed for guidelines compliance

## Asset File Structure
```
MCVenture/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   │   ├── Contents.json
│   │   ├── Icon-1024.png (1024x1024)
│   │   ├── Icon-180.png (180x180 @3x)
│   │   ├── Icon-120.png (120x120 @2x)
│   │   └── ... (all other sizes)
│   ├── LaunchImage.imageset/
│   └── Colors/
├── Screenshots/
│   ├── iPhone-6.7/
│   │   ├── 01-routes.png
│   │   ├── 02-tracking.png
│   │   └── ... (5-10 screenshots)
│   ├── iPhone-6.5/
│   └── iPad-12.9/
└── Videos/ (optional)
    ├── preview-6.7.mov
    └── preview-12.9.mov
```

## Tools & Resources

### Icon Generation
- **SF Symbols**: Built-in iOS system icons
- **Figma/Sketch**: Design custom icons
- **Icon Slate**: macOS app for icon generation
- **makeappicon.com**: Online icon generator

### Screenshot Tools
- **Xcode Simulator**: Take screenshots directly
- **Screenshot Creator**: Automated screenshot tool
- **Figma**: Design screenshot templates with text overlays

### Video Recording
- **QuickTime**: Screen recording on Mac
- **iOS Screen Recording**: Built-in iOS feature
- **Final Cut Pro**: Video editing

### Asset Validation
- **App Store Connect**: Built-in asset validator
- **Prepo**: macOS app for asset checking

## Next Steps

1. Design app icon in Figma/Sketch
2. Generate all required icon sizes
3. Take screenshots on all device sizes
4. Add descriptive text overlays to screenshots
5. Record app preview video (optional)
6. Write App Store description
7. Set up support website with privacy policy
8. Upload all assets to App Store Connect
9. Submit for review

---

For questions or assistance, contact the development team.
