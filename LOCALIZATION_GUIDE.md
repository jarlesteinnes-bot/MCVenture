# MCVenture Localization Guide

## Overview
MCVenture supports multi-language localization with English as the default language. The app is currently set up with 5 languages: English, Norwegian, German, Spanish, and French.

## ✅ Current Setup

### Implemented Features
- ✅ English (Base Language - Default)
- ✅ Norwegian (Bokmål) - Complete translations
- ✅ German, Spanish, French - Ready to add translations
- ✅ Runtime language switching (no app restart needed)
- ✅ Language persistence (saved preference)
- ✅ Easy-to-use language picker in Settings
- ✅ Localized tab bar labels
- ✅ String extension for easy localization (`.localized`)

### Files Created
```
MCVenture/
├── Utilities/
│   └── LocalizationManager.swift       # Language switching manager
├── Views/
│   └── LanguagePickerView.swift        # Language selection UI
├── en.lproj/
│   └── Localizable.strings            # English translations (222 strings)
└── nb.lproj/
    └── Localizable.strings            # Norwegian translations (222 strings)
```

## 🌍 Adding a New Language

### Step 1: Create Language Directory
```bash
mkdir -p MCVenture/xx.lproj
```
Replace `xx` with the ISO 639-1 language code:
- `de` - German
- `es` - Spanish  
- `fr` - French
- `sv` - Swedish
- `da` - Danish
- `it` - Italian

### Step 2: Copy English Template
```bash
cp MCVenture/en.lproj/Localizable.strings MCVenture/xx.lproj/Localizable.strings
```

### Step 3: Translate Strings
Open `xx.lproj/Localizable.strings` and translate the right side of each line:
```
// English
"button.save" = "Save";

// Norwegian
"button.save" = "Lagre";

// German
"button.save" = "Speichern";
```

### Step 4: Add Language to LocalizationManager
Edit `Utilities/LocalizationManager.swift`:

```swift
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case norwegian = "Norsk"
    case german = "Deutsch"
    case newLanguage = "NewLanguageName"  // Add here
    
    var code: String {
        switch self {
        case .english: return "en"
        case .norwegian: return "nb"
        case .german: return "de"
        case .newLanguage: return "xx"  // Add language code
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .norwegian: return "🇳🇴"
        case .german: return "🇩🇪"
        case .newLanguage: return "🇽🇽"  // Add flag emoji
        }
    }
}
```

### Step 5: Add to Xcode Project
1. Open `MCVenture.xcodeproj` in Xcode
2. File → Add Files to "MCVenture"
3. Select the new `xx.lproj` folder
4. Make sure "Create folder references" is selected
5. Click "Add"

## 🎯 Using Localization in Code

### Basic String Localization
```swift
// Old way (hardcoded)
Text("Save")

// New way (localized)
Text("button.save".localized)
```

### With String Formatting
```swift
// With arguments
let message = "trips.distance".localized(with: 42.5, "km")
```

### In Navigation and Labels
```swift
// Tab items
.tabItem {
    Label("tab.routes".localized, systemImage: "map.fill")
}

// Navigation titles
.navigationTitle("nav.settings".localized)

// Buttons
Button("button.save".localized) {
    // Action
}
```

## 📝 String Key Naming Convention

Use dot notation with semantic categories:

| Category | Format | Example |
|----------|--------|---------|
| Tab bar | `tab.xxx` | `tab.routes` |
| Buttons | `button.xxx` | `button.save` |
| Navigation | `nav.xxx` | `nav.settings` |
| Routes | `routes.xxx` | `routes.search` |
| Trips | `trips.xxx` | `trips.active` |
| Profile | `profile.xxx` | `profile.edit` |
| Settings | `settings.xxx` | `settings.language` |
| Errors | `error.xxx` | `error.network` |
| Weather | `weather.xxx` | `weather.forecast` |
| Emergency | `emergency.xxx` | `emergency.sos` |
| Community | `community.xxx` | `community.share` |
| Maintenance | `maintenance.xxx` | `maintenance.schedule` |

## 🔧 Testing Languages

### Change Language in App
1. Open the app
2. Go to Profile → More → Settings
3. Tap "Language"
4. Select desired language
5. UI updates immediately (no restart needed)

### Test in Simulator
```bash
# Launch simulator with specific language
xcrun simctl launch booted com.yourcompany.MCVenture -AppleLanguages "(en)"
xcrun simctl launch booted com.yourcompany.MCVenture -AppleLanguages "(nb)"
```

### Verify All Strings Are Localized
```bash
# Find hardcoded strings in SwiftUI views
grep -r 'Text("' MCVenture/Views/ | grep -v '.localized'
grep -r 'Label("' MCVenture/Views/ | grep -v '.localized'
```

## 🌟 App Store Localization

### Adding Localized Metadata
When submitting to App Store Connect, you can provide:

1. **Localized App Name** (optional)
2. **Description** - Full app description in each language
3. **Keywords** - Search keywords in each language
4. **What's New** - Release notes in each language
5. **Screenshots** - Optional localized screenshots

### Supported App Store Languages
- English (required)
- Norwegian (Bokmål)
- German
- Spanish (Spain)
- Spanish (Mexico)
- French (France)
- French (Canada)
- Italian
- Swedish
- Danish
- Dutch
- Portuguese
- And 30+ more...

### Benefits of App Store Localization
- 📈 **128% increase** in downloads per market on average
- 🌍 Reach **26% more users** globally
- ⭐ **Higher ratings** in local markets
- 🎯 Better **App Store search ranking** for local keywords

## 🚀 Quick Start Checklist

- [x] LocalizationManager created
- [x] English base language (222 strings)
- [x] Norwegian translations complete
- [x] Language picker UI created
- [x] MainTabView localized
- [x] Settings updated with language option
- [ ] Add German translations (copy from `en.lproj`, translate to `de.lproj`)
- [ ] Add Spanish translations (copy from `en.lproj`, translate to `es.lproj`)
- [ ] Add French translations (copy from `en.lproj`, translate to `fr.lproj`)
- [ ] Localize remaining views (RoutesView, TripsView, ProfileView, etc.)
- [ ] Test all languages thoroughly
- [ ] Add localized App Store metadata

## 📊 Translation Status

| Language | Code | Strings | Status | Priority |
|----------|------|---------|--------|----------|
| English | en | 222/222 | ✅ Complete | High |
| Norwegian | nb | 222/222 | ✅ Complete | High |
| German | de | 0/222 | ⏳ Pending | Medium |
| Spanish | es | 0/222 | ⏳ Pending | Medium |
| French | fr | 0/222 | ⏳ Pending | Medium |

## 🎨 Market Opportunities

### Nordic Region (High Priority)
- 🇳🇴 Norway - 5.5M people, high motorcycle ownership
- 🇸🇪 Sweden - 10.5M people, strong riding culture
- 🇩🇰 Denmark - 6M people, motorcycle touring popular

### European Market (High Value)
- 🇩🇪 Germany - 83M people, largest motorcycle market in EU
- 🇫🇷 France - 67M people, extensive road network
- 🇪🇸 Spain - 47M people, year-round riding weather
- 🇮🇹 Italy - 60M people, strong motorcycle heritage

## 💡 Pro Tips

1. **Keep keys semantic** - Use `routes.search` not `search_routes_label`
2. **Group by feature** - Makes finding strings easier
3. **Include context** - Add comments for ambiguous strings
4. **Test right-to-left** - If adding Arabic/Hebrew later
5. **Use plural rules** - iOS supports automatic pluralization
6. **Watch string length** - Translations can be 30% longer
7. **Professional translations** - Consider Gengo, One Hour Translation
8. **Community help** - Reddit r/translator, translation Discord servers

## 🔗 Useful Resources

- [Apple Localization Guide](https://developer.apple.com/localization/)
- [NSLocalizedString Documentation](https://developer.apple.com/documentation/foundation/nslocalizedstring)
- [App Store Connect Help](https://help.apple.com/app-store-connect/#/dev997e9a381)
- [ISO 639-1 Language Codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)

---

**Last Updated**: November 24, 2025  
**Total Strings**: 222  
**Languages Supported**: 2 (English, Norwegian)  
**Languages Ready to Add**: 3 (German, Spanish, French)
