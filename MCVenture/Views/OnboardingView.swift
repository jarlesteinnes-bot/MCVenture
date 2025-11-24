// OnboardingView.swift - Welcome & Feature Tour

import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isPresented: Bool
    @State private var locationManager = CLLocationManager()
    
    let pages = [
        OnboardingPage(icon: "map.fill", title: "Discover Routes", description: "Explore thousands of motorcycle routes across Europe", color: .blue),
        OnboardingPage(icon: "location.fill", title: "Track Your Rides", description: "GPS tracking with elevation, speed, and performance stats", color: .green),
        OnboardingPage(icon: "exclamationmark.shield.fill", title: "Stay Safe", description: "Crash detection, emergency SOS, and weather alerts", color: .red),
        OnboardingPage(icon: "trophy.fill", title: "Earn Achievements", description: "Complete challenges and track your riding progress", color: .orange),
        OnboardingPage(icon: "location.circle.fill", title: "Location Permission", description: "We need location access to track rides and provide navigation", color: .orange, isPermissionPage: true)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                if currentPage == pages.count - 1 {
                    VStack(spacing: 16) {
                        Button(action: {
                            // Request location permission
                            locationManager.requestWhenInUseAuthorization()
                            // Mark onboarding complete
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            isPresented = false
                        }) {
                            Text("Grant Location Access")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(15)
                        }
                        .padding(.horizontal, 40)
                        
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            isPresented = false
                        }) {
                            Text("Maybe Later")
                                .foregroundColor(.gray)
                        }
                    }
                    .transition(.scale)
                } else if currentPage == pages.count - 2 {
                    Button(action: { currentPage += 1 }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                } else {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        isPresented = false
                    }) {
                        Text("Skip")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isPermissionPage: Bool = false
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(page.color)
            Text(page.title)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            Text(page.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
