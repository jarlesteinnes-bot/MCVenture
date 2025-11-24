# MCVenture App Store Submission Guide

## Required Assets

### App Icon
Create app icons in all required sizes. Use the SF Symbols `figure.motorcycling` with an orange/red gradient and road/map elements.

**Required Sizes:**
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro @2x)
- 152x152 (iPad @2x)
- 76x76 (iPad)
- 40x40 (Spotlight @2x)
- 29x29 (Settings @1x)

**Design Guidelines:**
- Use MCVenture brand colors: Orange (#FF6B35) to Red (#D32F2F) gradient
- Include motorcycle silhouette or helmet icon
- Add subtle map/road elements in background
- Ensure icon is recognizable at small sizes
- No transparency
- Rounded corners will be applied automatically

### Screenshots

**iPhone (Required)**
- 6.7" (iPhone 14 Pro Max) - 1290 x 2796
- 6.5" (iPhone 11 Pro Max) - 1242 x 2688
- 5.5" (iPhone 8 Plus) - 1242 x 2208

**iPad (If supporting iPad)**
- 12.9" (iPad Pro) - 2048 x 2732
- 11" (iPad Pro) - 1668 x 2388

**Screenshot Content Ideas:**
1. **Main Menu** - Show beautiful gradient background with clear action buttons
2. **Track My Ride** - Active trip with real-time stats and map
3. **Route Planning** - Map view with custom route
4. **Trip Summary** - Completed trip with elevation curve and photos
5. **Profile Stats** - Achievements, total distance, leaderboard

**Screenshot Design Tips:**
- Add descriptive text overlays
- Use device frames for context
- Show app in action with real data
- Highlight unique features (crash detection, elevation tracking)
- Use consistent branding and colors

### App Preview Videos (Optional but Recommended)

**Video Specs:**
- 15-30 seconds max
- Portrait orientation
- 1080 x 1920 resolution
- MP4 or MOV format
- Show app in action

**Video Content Ideas:**
1. Quick tour of main features
2. Starting and completing a trip
3. Route planning workflow
4. Social sharing capabilities

## App Store Listing

### App Name
**MCVenture** (8 characters)

### Subtitle (30 characters max)
Options:
- "Motorcycle GPS & Route Tracker"
- "Track Your Motorcycle Rides"
- "GPS Tracker for Bikers"

### Description (4000 characters max)

```
Transform every ride into an adventure with MCVenture – the ultimate motorcycle tracking app for riders who demand precision and passion.

🏍️ TRACK YOUR RIDES
• Real-time GPS tracking with pinpoint accuracy
• Automatic elevation gain/loss calculation
• Speed, distance, and duration monitoring
• Detailed elevation curves for every route
• Pro mode with lean angle, g-force, and corner analysis

🗺️ PLAN YOUR ROUTES
• Custom route planning with topography maps
• Discover scenic routes and hidden gems
• Add waypoints, stops, and points of interest
• Norwegian keyboard support (æ, ø, å)
• Share routes with the rider community

📸 CAPTURE MEMORIES
• Snap photos during your ride with GPS tagging
• Add trail conditions and wildlife sightings
• Safety notes and hazard warnings
• Build your personal riding journal

⚡ SAFETY FIRST
• Intelligent crash detection with emergency alerts
• Speed limit warnings (customizable)
• Offline mode – no internet required
• All data stored locally and synced to iCloud

🏆 TRACK YOUR PROGRESS
• Lifetime statistics and achievements
• Trip history with detailed analytics
• Export data as GPX or JSON
• Share your best rides on social media

🎯 FOR EVERY RIDER
• Simplified mode for casual riders
• Pro mode with advanced telemetry
• Beginner-friendly with guided tutorials
• Professional-grade tracking for enthusiasts

📱 FEATURES
✓ Background GPS tracking
✓ Haptic feedback for key events
✓ Dark mode support
✓ VoiceOver accessibility
✓ CloudKit sync across devices
✓ Privacy-focused – your data stays yours

Whether you're a weekend warrior or a daily commuter, MCVenture is your perfect riding companion. Every mile matters. Every turn counts. Every ride is an adventure.

Download MCVenture today and start tracking your motorcycle journeys!

---

PRIVACY & PERMISSIONS
• Location: Required for GPS tracking
• Motion: For crash detection and lean angle
• Camera: To capture ride photos
• iCloud: Optional sync across devices

All data is stored securely and never shared without your consent.
```

### Keywords (100 characters max, comma-separated)
```
motorcycle,gps,tracker,ride,route,biker,motorbike,navigation,touring,adventure
```

### Promotional Text (170 characters max)
```
New: Intelligent crash detection, enhanced elevation tracking, and community route sharing. Download the update and ride safer, smarter, and more connected!
```

### Support URL
```
https://mcventure.com/support
```
(Create a simple landing page or use GitHub Pages)

### Marketing URL
```
https://mcventure.com
```

### Privacy Policy URL
```
https://mcventure.com/privacy
```
(Required - create based on TermsOfServiceView.swift)

## Categories

**Primary Category:** Navigation
**Secondary Category:** Health & Fitness or Travel

## Age Rating

- **Age Rating:** 4+
- **Unrestricted Web Access:** No
- **Gambling:** No
- **Contests:** No
- **Mature/Suggestive Themes:** No
- **Horror/Fear Themes:** No
- **Medical/Treatment Information:** No
- **Profanity or Crude Humor:** No
- **Realistic Violence:** No
- **Sexual Content or Nudity:** No
- **Alcohol, Tobacco, or Drug Use:** No

## App Information

### Copyright
```
© 2024 MCVenture. All rights reserved.
```

### Trade Representative Contact
Your name and email (required in some regions)

### App Review Information

**Contact Information:**
- First Name: [Your Name]
- Last Name: [Your Last Name]
- Phone: [Your Phone]
- Email: [Your Email]

**Demo Account (if needed):**
- Username: demo@mcventure.com
- Password: DemoPass123

**Notes:**
```
MCVenture is a motorcycle GPS tracking app that requires location permissions to function properly.

To test the app:
1. Allow location permissions when prompted
2. Tap "Track My Ride" to start recording
3. The app works best when moving, but can be tested while stationary
4. Crash detection requires motion permissions
5. iCloud sync is optional

All features work offline except CloudKit sharing.
```

## Localization

**Primary Language:** English (U.S.)

**Planned Localizations:**
- Norwegian (Bokmål)
- Norwegian (Nynorsk)
- Swedish
- Danish
- German
- French
- Spanish

## Pricing

**Free** with optional in-app purchases (if implementing):
- Pro Mode: $4.99/month or $39.99/year
- Lifetime Pro: $99.99
- Route Packs: $2.99 each

## App Store Connect Checklist

- [ ] Create App Store Connect listing
- [ ] Upload all app icons
- [ ] Upload screenshots for all device sizes
- [ ] Upload app preview video (optional)
- [ ] Complete app description and metadata
- [ ] Add keywords
- [ ] Set pricing and availability
- [ ] Configure in-app purchases (if any)
- [ ] Provide privacy policy URL
- [ ] Complete age rating questionnaire
- [ ] Add app review contact information
- [ ] Upload build via Xcode or Transporter
- [ ] Submit for review

## Pre-Submission Testing

- [ ] Test on multiple iPhone models
- [ ] Test on iPad (if supporting)
- [ ] Verify all permissions work correctly
- [ ] Test offline functionality
- [ ] Test CloudKit sync
- [ ] Verify crash detection
- [ ] Test data export
- [ ] Check VoiceOver accessibility
- [ ] Test in different languages
- [ ] Verify app doesn't crash on launch
- [ ] Test Terms of Service acceptance flow
- [ ] Test onboarding for new users

## Common Rejection Reasons to Avoid

1. **Crash on Launch** - Thoroughly test before submission
2. **Missing Functionality** - Ensure all described features work
3. **Poor Performance** - Optimize before submission
4. **Privacy Policy** - Must be accessible and accurate
5. **Permissions** - Clearly explain why each permission is needed
6. **Incomplete Information** - Fill out all required fields
7. **Misleading Screenshots** - Show actual app functionality
8. **3rd Party Trademarks** - Don't use motorcycle brand names without permission

## Launch Strategy

### Soft Launch
1. Release in Norway first (smaller market, Norwegian support)
2. Gather initial reviews and feedback
3. Fix any critical issues
4. Expand to neighboring countries

### Marketing
1. Create landing page with email signup
2. Social media presence (Instagram, Facebook groups)
3. Reach out to motorcycle communities
4. Submit to app review sites
5. Create demo videos for YouTube
6. Partner with motorcycle clubs
7. Submit to Product Hunt

### Post-Launch
1. Monitor crash reports and reviews
2. Respond to user feedback
3. Release updates regularly
4. Build community features
5. Consider partnership with motorcycle brands
