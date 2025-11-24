//
//  MainMenuView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct MainMenuView: View {
    @State private var selectedOption: MenuOption?
    @State private var showContent = false
    @State private var animateButtons = false
    
    var body: some View {
        ZStack {
            // Background image
            GeometryReader { geometry in
                Image("MotorcycleLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // Overlay gradient for better readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Logo section - using same logo as splash screen
                    LogoView(size: 240)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    
                    // Menu buttons
                    VStack(spacing: 16) {
                        MenuButton(
                            title: "TRACK RIDE",
                            icon: "play.circle.fill",
                            delay: 0.1
                        ) {
                            selectedOption = .startRiding
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .offset(x: animateButtons ? 0 : -50)
                        
                        MenuButton(
                            title: "PLAN ROUTE",
                            icon: "map.circle.fill",
                            delay: 0.2
                        ) {
                            selectedOption = .planRoute
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .offset(x: animateButtons ? 0 : -50)
                        
                    MenuButton(
                        title: "MY ROUTES",
                        icon: "map.fill",
                        delay: 0.3
                    ) {
                        selectedOption = .myRoutes
                    }
                    .opacity(animateButtons ? 1 : 0)
                    .offset(x: animateButtons ? 0 : -50)
                    
                    MenuButton(
                        title: "PROFILE",
                        icon: "person.circle.fill",
                        delay: 0.4
                    ) {
                        selectedOption = .myBikes
                    }
                    .opacity(animateButtons ? 1 : 0)
                    .offset(x: animateButtons ? 0 : -50)
                        
                        MenuButton(
                            title: "SETTINGS",
                            icon: "gearshape.fill",
                            delay: 0.5
                        ) {
                            selectedOption = .settings
                        }
                        .opacity(animateButtons ? 1 : 0)
                        .offset(x: animateButtons ? 0 : -50)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateButtons = true
            }
        }
        .fullScreenCover(item: $selectedOption) { option in
            destinationView(for: option)
        }
    }
    
    @ViewBuilder
    private func destinationView(for option: MenuOption) -> some View {
        switch option {
        case .startRiding:
            ActiveTripViewTabbed(route: nil)
                .environmentObject(DataManager.shared)
        case .planRoute:
            SwiftUI.NavigationView {
                RoutePlannerView()
            }
        case .myBikes:
            SwiftUI.NavigationView {
                EnhancedProfileView()
                    .environmentObject(DataManager.shared)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { selectedOption = nil }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
        case .myRoutes:
            SwiftUI.NavigationView {
                ContentView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { selectedOption = nil }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
        case .settings:
            SwiftUI.NavigationView {
                SettingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { selectedOption = nil }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
        }
    }
}

// Menu option enum
enum MenuOption: Identifiable {
    case startRiding
    case planRoute
    case myRoutes
    case myBikes
    case settings
    
    var id: String {
        switch self {
        case .startRiding: return "start"
        case .planRoute: return "plan"
        case .myRoutes: return "routes"
        case .myBikes: return "bikes"
        case .settings: return "settings"
        }
    }
}

// Fancy menu button
struct MenuButton: View {
    let title: String
    let icon: String
    let delay: Double
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 35)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Orange gradient fade from left 1/3 only
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            // Left 1/3 with orange gradient
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.5),
                                            Color.red.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.33)
                            
                            Spacer()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Glass morphism effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.15))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .orange.opacity(0.8),
                                            .red.opacity(0.5),
                                            .white.opacity(0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    // Subtle inner glow from left 1/3
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.25),
                                            Color.red.opacity(0.15),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.33)
                            
                            Spacer()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            )
            .shadow(color: .orange.opacity(0.6), radius: 12, x: -5, y: 0)
            .shadow(color: .red.opacity(0.4), radius: 8, x: -3, y: 0)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .overlay(
                // Shine effect on press
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(isPressed ? 0.3 : 0), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.easeOut(duration: 0.6).delay(delay), value: isPressed)
    }
}

// Scale button style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Speed background effect
struct SpeedBackgroundView: View {
    @State private var animateLines = false
    
    var body: some View {
        ZStack {
            // Base dark background
            Color.black
            
            // Motion blur lines
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<40, id: \.self) { index in
                        SpeedLine(
                            width: geometry.size.width,
                            yPosition: CGFloat(index) * (geometry.size.height / 40),
                            delay: Double(index) * 0.02,
                            animate: animateLines
                        )
                    }
                }
            }
            
            // Vignette effect
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.8)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            
            // Center bright spot
            RadialGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
        }
        .onAppear {
            animateLines = true
        }
    }
}

// Individual speed line
struct SpeedLine: View {
    let width: CGFloat
    let yPosition: CGFloat
    let delay: Double
    let animate: Bool
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(Double.random(in: 0.05...0.15)),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width * 1.5, height: CGFloat.random(in: 1...3))
            .rotationEffect(.degrees(-15))
            .offset(x: offset, y: yPosition)
            .onAppear {
                if animate {
                    withAnimation(
                        .linear(duration: Double.random(in: 1.5...3.0))
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                    ) {
                        offset = width * 2
                    }
                }
            }
    }
}

#Preview {
    MainMenuView()
}
