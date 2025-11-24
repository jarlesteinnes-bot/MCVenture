# MCVenture Pre-Launch Checklist

## ⚠️ BLOCKING ISSUES (Must Fix Before Submit)

### [ ] 1. Build Errors
- [ ] Fix NavigationView compiler issues
- [ ] Resolve all type conflicts
- [ ] Clean build with ZERO errors
- [ ] Test on device (not just simulator)

### [ ] 2. App Store Assets
- [ ] App icon 1024x1024 (App Store)
- [ ] App icon 180x180 (iPhone)
- [ ] App icon 120x120 (iPhone)
- [ ] App icon 87x87 (notifications)
- [ ] Launch screen storyboard
- [ ] 6.5" screenshots (iPhone 14 Pro Max) - 6 required
- [ ] 5.5" screenshots (iPhone 8 Plus) - 6 required

### [ ] 3. Legal Requirements
- [ ] Privacy Policy URL (create webpage)
- [ ] Terms of Service URL
- [ ] Age rating questionnaire completed
- [ ] Export compliance information

### [ ] 4. Crash Prevention
- [ ] All text fields validated (max length, invalid chars)
- [ ] GPS permission denied handled gracefully
- [ ] Network errors don't crash app
- [ ] CloudKit errors handled
- [ ] Test with airplane mode
- [ ] Test with location services off
- [ ] Test with full storage

### [ ] 5. Core Features Testing
- [ ] Route scraping works
- [ ] GPS tracking accurate
- [ ] Trip saving persists
- [ ] SOS button doesn't trigger accidentally
- [ ] Settings save correctly
- [ ] Onboarding shows on first launch only

## ✅ STRONGLY RECOMMENDED

### [ ] 6. Accessibility
- [ ] VoiceOver on all buttons/images
- [ ] Labels for icons
- [ ] Color contrast sufficient
- [ ] Works with Dynamic Type

### [ ] 7. Performance
- [ ] Route list loads < 3 seconds
- [ ] No memory leaks during long trips
- [ ] Battery drain reasonable
- [ ] App doesn't overheat device

### [ ] 8. User Experience
- [ ] All loading states present
- [ ] Error messages are helpful
- [ ] Empty states look good
- [ ] Haptic feedback feels right

## 📱 DEVICE TESTING

Test on:
- [ ] iPhone SE (smallest screen)
- [ ] iPhone 14/15 (standard)
- [ ] iPhone 14 Pro Max (largest)
- [ ] iOS 15.0 (minimum supported)
- [ ] iOS 17.x (latest)

## 📝 APP STORE LISTING

### [ ] Metadata
- [ ] App name: "MCVenture"
- [ ] Subtitle (30 chars): "Motorcycle Route Tracker"
- [ ] Keywords: motorcycle, routes, GPS, tracking, navigation, touring, adventure
- [ ] Description (4000 chars max)
- [ ] What's New text for v1.0
- [ ] Support URL
- [ ] Marketing URL (optional)

### [ ] Pricing
- [ ] Select price tier
- [ ] Select territories
- [ ] Decide: free vs paid vs freemium

### [ ] App Review Information
- [ ] Demo account (if needed)
- [ ] Notes for reviewer
- [ ] Contact information

## 🔍 FINAL CHECKS

- [ ] Test complete user journey: Install → Onboarding → Route Discovery → Trip → Review
- [ ] Verify no placeholder text ("TODO", "Lorem ipsum")
- [ ] Check all images load
- [ ] Verify no console errors
- [ ] Test offline mode
- [ ] Test SOS system (without actually calling 112!)
- [ ] Verify CloudKit works
- [ ] Check memory usage doesn't grow unbounded

## 🚀 SUBMISSION STEPS

1. [ ] Xcode: Product → Archive
2. [ ] Validate app (catches common issues)
3. [ ] Upload to App Store Connect
4. [ ] Fill out all metadata in App Store Connect
5. [ ] Submit for review
6. [ ] Wait 1-3 days for review
7. [ ] Launch! 🎉

## ⏱️ TIME ESTIMATE

- Build fixes: 2-4 hours
- App Store assets: 3-6 hours
- Privacy policy: 1-2 hours
- Testing: 4-8 hours
- **Total: 10-20 hours** to launch-ready

## 🎯 PRIORITY ORDER

1. Fix build errors (BLOCKING)
2. Create app icons (REQUIRED)
3. Create privacy policy (REQUIRED)
4. Crash prevention (CRITICAL)
5. Device testing (IMPORTANT)
6. Screenshots & metadata (REQUIRED)
7. Submit!
