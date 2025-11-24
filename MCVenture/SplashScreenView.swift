//
//  SplashScreenView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        if isActive {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                MainMenuView()
            }
        } else {
            ZStack {
                // Motorcycle background image
                Image("MotorcycleLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                
                // Dark overlay for better contrast
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                
                // Speed lines effect
                SpeedLinesView()
                    .opacity(backgroundOpacity * 0.3)
                
                // Logo - responsive sizing
                GeometryReader { geo in
                    let screenWidth = geo.size.width
                    let logoSize = min(300, screenWidth * 0.8)
                    
                    LogoView(size: logoSize)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
            }
            .onAppear {
                // Animate logo entrance
                withAnimation(.easeOut(duration: 1.2)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                    backgroundOpacity = 1.0
                }
                
                // Transition to main app
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

// Speed lines effect to simulate motion
struct SpeedLinesView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<30, id: \.self) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.1), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 1.5, height: 2)
                        .rotationEffect(.degrees(-20))
                        .offset(
                            x: -geometry.size.width * 0.3,
                            y: CGFloat(i) * (geometry.size.height / 30)
                        )
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
