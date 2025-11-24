//
//  TermsOfServiceView.swift
//  MCVenture
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle.bold())
                    .padding(.bottom)
                
                Group {
                    SectionHeader(title: "1. Acceptance of Terms")
                    SectionText(text: "By using MCVenture, you agree to these Terms of Service. If you do not agree, please do not use the app.")
                    
                    SectionHeader(title: "2. Use of the App")
                    SectionText(text: "MCVenture is intended for motorcycle riders to track rides, plan routes, and access safety features. You agree to use the app responsibly and in compliance with all applicable laws.")
                    
                    SectionHeader(title: "3. Safety Disclaimer")
                    SectionText(text: "⚠️ IMPORTANT: MCVenture's crash detection and emergency features are supplementary tools only. They should NOT be your sole reliance for safety. Always ride safely, wear proper gear, and follow traffic laws.")
                    
                    SectionHeader(title: "4. Emergency Services")
                    SectionText(text: "The SOS feature is designed to assist in emergencies but does not automatically contact emergency services. You must manually activate it. Response times and availability are not guaranteed.")
                    
                    SectionHeader(title: "5. Location Data")
                    SectionText(text: "MCVenture collects location data to provide tracking and navigation features. Location data is stored on your device and optionally synced via iCloud if you enable route sharing.")
                    
                    SectionHeader(title: "6. Route Sharing & CloudKit")
                    SectionText(text: "When you share routes with other users, the data is stored in Apple's CloudKit. Shared routes are visible to other MCVenture users who have access. You are responsible for the content you share.")
                    
                    SectionHeader(title: "7. Data Privacy")
                    SectionText(text: "We respect your privacy. Your trip data, photos, and analytics are stored locally on your device. We do not collect or sell your personal data. See our Privacy Policy for details.")
                    
                    SectionHeader(title: "8. Prohibited Activities")
                    SectionText(text: "You may not:\n• Share routes that encourage illegal activities\n• Use the app while operating a vehicle in a distracting manner\n• Attempt to circumvent safety features\n• Share offensive or inappropriate content")
                    
                    SectionHeader(title: "9. Liability Limitations")
                    SectionText(text: "MCVenture and its developers are not liable for:\n• Accidents or injuries while using the app\n• Inaccurate GPS data or route information\n• Device battery drain or performance issues\n• Loss of data or iCloud sync failures")
                    
                    SectionHeader(title: "10. No Warranty")
                    SectionText(text: "The app is provided \"as is\" without warranties of any kind. We do not guarantee uninterrupted service, accuracy of data, or fitness for a particular purpose.")
                    
                    SectionHeader(title: "11. Changes to Terms")
                    SectionText(text: "We may update these Terms at any time. Continued use of the app constitutes acceptance of updated Terms.")
                    
                    SectionHeader(title: "12. Governing Law")
                    SectionText(text: "These Terms are governed by Norwegian law. Any disputes shall be resolved in Norwegian courts.")
                    
                    SectionHeader(title: "13. Contact")
                    SectionText(text: "For questions about these Terms, please contact us through the app's support section.")
                }
                
                Text("Last Updated: November 2025")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                Button(action: { dismiss() }) {
                    Text("I Accept")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.orange)
            .padding(.top, 8)
    }
}

struct SectionText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.primary)
    }
}

#Preview {
    SwiftUI.NavigationView {
        TermsOfServiceView()
    }
}
