//
//  LanguagePickerView.swift
//  MCVenture
//
//  Language selection view for app settings
//

import SwiftUI

struct LanguagePickerView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    private func selectLanguage(_ language: SupportedLanguage) {
        let previousLanguage = localizationManager.currentLanguage
        
        // Haptic feedback
        HapticManager.shared.selection()
        
        // Change language
        localizationManager.changeLanguage(to: language.code)
        
        // Analytics
        AnalyticsManager.shared.languageChanged(from: previousLanguage, to: language.code)
        
        // Success feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.shared.success()
        }
        
        // Dismiss after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(SupportedLanguage.allCases) { language in
                        Button(action: {
                            withAnimation {
                                selectLanguage(language)
                            }
                        }) {
                            HStack {
                                Text(language.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if localizationManager.currentLanguage == language.code {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.body.weight(.semibold))
                                }
                            }
                        }
                    }
                } header: {
                    Text("language.title".localized)
                } footer: {
                    Text("language.current".localized + ": " + currentLanguageName())
                        .font(.footnote)
                }
            }
            .navigationTitle("settings.language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button.done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func currentLanguageName() -> String {
        SupportedLanguage.allCases
            .first { $0.code == localizationManager.currentLanguage }?
            .rawValue ?? "English"
    }
}

#Preview {
    LanguagePickerView()
}
