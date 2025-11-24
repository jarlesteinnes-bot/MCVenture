//
//  EmptyStateView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: ResponsiveSpacing.large) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120.scaled, height: 120.scaled)
                
                Image(systemName: icon)
                    .font(.system(size: 50.scaled))
                    .foregroundColor(.blue)
            }
            
            // Title
            Text(title)
                .font(Font.scaledTitle())
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(Font.scaledBody())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ResponsiveSpacing.extraLarge)
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
            Button(action: {
                HapticFeedbackManager.shared.lightTap()
                action()
            }) {
                    Text(actionTitle)
                        .font(Font.scaledHeadline())
                        .frame(maxWidth: .infinity)
                        .padding(ResponsiveSpacing.medium)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12.scaled)
                }
                .padding(.horizontal, ResponsiveSpacing.extraLarge)
                .padding(.top, ResponsiveSpacing.medium)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Convenience initializers for common empty states
extension EmptyStateView {
    static func noRoutes(action: @escaping () -> Void) -> some View {
        EmptyStateView(
            icon: "map",
            title: "No Routes Yet",
            message: "Start planning your first motorcycle adventure! Discover scenic routes and create custom paths.",
            actionTitle: "Plan Your First Route",
            action: action
        )
    }
    
    static func noTrips(action: @escaping () -> Void) -> some View {
        EmptyStateView(
            icon: "figure.motorcycling",
            title: "No Trips Recorded",
            message: "Hit the road and start tracking your rides! Every journey begins with a single ride.",
            actionTitle: "Start Your First Trip",
            action: action
        )
    }
    
    static func noPhotos() -> some View {
        EmptyStateView(
            icon: "camera",
            title: "No Photos Yet",
            message: "Capture memories during your rides! Photos will appear here with location data.",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func offline() -> some View {
        EmptyStateView(
            icon: "wifi.slash",
            title: "You're Offline",
            message: "Some features require an internet connection. Your data will sync when you're back online.",
            actionTitle: nil,
            action: nil
        )
    }
    
    static func searchNoResults() -> some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search terms or filters to find what you're looking for.",
            actionTitle: nil,
            action: nil
        )
    }
}

#Preview {
    EmptyStateView.noRoutes { }
}
