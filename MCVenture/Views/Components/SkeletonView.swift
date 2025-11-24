//
//  SkeletonView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

// MARK: - Shimmer Effect
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}

// MARK: - Skeleton Views

struct SkeletonRouteRow: View {
    var body: some View {
        HStack(spacing: ResponsiveSpacing.medium) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12.scaled)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100.scaled, height: 80.scaled)
            
            VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
                // Title
                RoundedRectangle(cornerRadius: 4.scaled)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 18.scaled)
                
                // Subtitle
                RoundedRectangle(cornerRadius: 4.scaled)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150.scaled, height: 14.scaled)
                
                // Details
                HStack(spacing: ResponsiveSpacing.small) {
                    RoundedRectangle(cornerRadius: 4.scaled)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60.scaled, height: 12.scaled)
                    
                    RoundedRectangle(cornerRadius: 4.scaled)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60.scaled, height: 12.scaled)
                }
            }
            
            Spacer()
        }
        .padding(ResponsiveSpacing.medium)
        .shimmer()
    }
}

struct SkeletonTripRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ResponsiveSpacing.small) {
            // Title
            RoundedRectangle(cornerRadius: 4.scaled)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 20.scaled)
            
            // Date
            RoundedRectangle(cornerRadius: 4.scaled)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120.scaled, height: 14.scaled)
            
            // Stats
            HStack(spacing: ResponsiveSpacing.medium) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 4.scaled)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70.scaled, height: 12.scaled)
                }
            }
        }
        .padding(ResponsiveSpacing.medium)
        .shimmer()
    }
}

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ResponsiveSpacing.medium) {
            // Header
            HStack {
                RoundedRectangle(cornerRadius: 4.scaled)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150.scaled, height: 20.scaled)
                
                Spacer()
            }
            
            // Content lines
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 4.scaled)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14.scaled)
            }
            
            // Action button
            RoundedRectangle(cornerRadius: 12.scaled)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 44.scaled)
        }
        .padding(ResponsiveSpacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16.scaled)
        .shimmer()
    }
}

struct SkeletonLoadingView: View {
    let style: SkeletonStyle
    
    enum SkeletonStyle {
        case routeList
        case tripList
        case card
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResponsiveSpacing.medium) {
                ForEach(0..<5, id: \.self) { _ in
                    switch style {
                    case .routeList:
                        SkeletonRouteRow()
                    case .tripList:
                        SkeletonTripRow()
                    case .card:
                        SkeletonCard()
                    }
                }
            }
            .padding(ResponsiveSpacing.medium)
        }
    }
}

#Preview("Route List") {
    SkeletonLoadingView(style: .routeList)
}

#Preview("Trip List") {
    SkeletonLoadingView(style: .tripList)
}

#Preview("Card") {
    SkeletonLoadingView(style: .card)
}
