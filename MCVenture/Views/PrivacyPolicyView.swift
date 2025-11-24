//
//  PrivacyPolicyView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: ResponsiveSpacing.large) {
                    Group {
                        Text("Privacy Policy")
                            .font(Font.scaledLargeTitle())
                            .fontWeight(.bold)
                        
                        Text("Last updated: November 23, 2025")
                            .font(Font.scaledCaption())
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Section {
                            Text("Introduction")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("MCVenture (\"we\", \"our\", or \"us\") respects your privacy and is committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our motorcycle route planning and tracking application.")
                                .font(Font.scaledBody())
                        }
                        
                        Divider()
                        
                        Section {
                            Text("Information We Collect")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("**Location Data**")
                                .font(Font.scaledHeadline())
                                .padding(.top)
                            
                            Text("We collect and process your location data when you:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Track a trip using GPS")
                                BulletPoint(text: "View routes on the map")
                                BulletPoint(text: "Search for nearby points of interest")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                            
                            Text("Location data is stored locally on your device and is only used to provide route tracking and navigation features. We do not share your location data with third parties.")
                                .font(Font.scaledBody())
                                .padding(.top, ResponsiveSpacing.small)
                        }
                    }
                    
                    Group {
                        Divider()
                        
                        Section {
                            Text("**User Profile Data**")
                                .font(Font.scaledHeadline())
                            
                            Text("We store the following information locally:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Motorcycle profiles and specifications")
                                BulletPoint(text: "Trip history and statistics")
                                BulletPoint(text: "Saved routes and favorites")
                                BulletPoint(text: "User preferences and settings")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                        }
                        
                        Divider()
                        
                        Section {
                            Text("Cloud Synchronization (iCloud)")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("If you enable iCloud sync, your data is synchronized across your devices using Apple's CloudKit service. This data is:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Encrypted in transit and at rest")
                                BulletPoint(text: "Stored in your personal iCloud account")
                                BulletPoint(text: "Never accessible by us")
                                BulletPoint(text: "Controlled by your iCloud settings")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                        }
                        
                        Divider()
                        
                        Section {
                            Text("Data Usage")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("We use your data exclusively to:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Provide GPS tracking and navigation")
                                BulletPoint(text: "Calculate trip statistics and fuel consumption")
                                BulletPoint(text: "Display route information and maps")
                                BulletPoint(text: "Synchronize data across your devices")
                                BulletPoint(text: "Improve app performance and user experience")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                        }
                    }
                    
                    Group {
                        Divider()
                        
                        Section {
                            Text("Data Sharing")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("We do NOT:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Sell your personal data")
                                BulletPoint(text: "Share your location with third parties")
                                BulletPoint(text: "Use your data for advertising")
                                BulletPoint(text: "Track you across other apps or websites")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                        }
                        
                        Divider()
                        
                        Section {
                            Text("Your Rights")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("You have the right to:")
                                .font(Font.scaledBody())
                            
                            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                                BulletPoint(text: "Access your personal data")
                                BulletPoint(text: "Delete your data at any time")
                                BulletPoint(text: "Disable location services")
                                BulletPoint(text: "Export your trip data")
                                BulletPoint(text: "Opt out of iCloud synchronization")
                            }
                            .padding(.leading, ResponsiveSpacing.medium)
                        }
                        
                        Divider()
                        
                        Section {
                            Text("Contact Us")
                                .font(Font.scaledTitle())
                                .fontWeight(.semibold)
                            
                            Text("If you have questions about this privacy policy, please contact us at:")
                                .font(Font.scaledBody())
                            
                            Text("support@mcventure.app")
                                .font(Font.scaledBody())
                                .foregroundColor(.blue)
                                .padding(.top, ResponsiveSpacing.small)
                        }
                    }
                }
                .padding(ResponsiveSpacing.large)
            }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ResponsiveSpacing.small) {
            Text("•")
                .font(Font.scaledBody())
            Text(text)
                .font(Font.scaledBody())
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
