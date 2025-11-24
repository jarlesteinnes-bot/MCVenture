//
//  LocalizationManager.swift
//  MCVenture
//
//  Manages app localization and language switching
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            bundle = Bundle.main
        }
    }
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        // Load saved language or use device language
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = savedLanguage
        } else {
            // Default to English if device language not supported
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = SupportedLanguage.allCases
                .first { $0.code == deviceLanguage }?.code ?? "en"
        }
    }
    
    func localizedString(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        // Fallback to English
        return NSLocalizedString(key, comment: "")
    }
    
    func changeLanguage(to language: String) {
        currentLanguage = language
    }
}

// Supported languages enum
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case norwegian = "Norsk"
    case german = "Deutsch"
    case spanish = "Español"
    case french = "Français"
    case italian = "Italiano"
    case swedish = "Svenska"
    case danish = "Dansk"
    
    var id: String { code }
    
    var code: String {
        switch self {
        case .english: return "en"
        case .norwegian: return "nb"
        case .german: return "de"
        case .spanish: return "es"
        case .french: return "fr"
        case .italian: return "it"
        case .swedish: return "sv"
        case .danish: return "da"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .norwegian: return "🇳🇴"
        case .german: return "🇩🇪"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .italian: return "🇮🇹"
        case .swedish: return "🇸🇪"
        case .danish: return "🇩🇰"
        }
    }
    
    var displayName: String {
        return "\(flag) \(rawValue)"
    }
}

// String extension for easy localization
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: LocalizationManager.shared.localizedString(self), arguments: arguments)
    }
}
