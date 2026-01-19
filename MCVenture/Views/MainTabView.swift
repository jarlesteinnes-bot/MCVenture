//
//  MainTabView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    @State private var showingBackAlert = false
    
    init() {
        // Make TabView background transparent
        UITabBar.appearance().backgroundColor = .clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }
    
    var body: some View {
        ZStack {
            // Background image
            Image("MotorcycleLogo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Tab 1: Routes
                RoutesView()
                    .background(Color.clear)
                    .tabItem {
                        Label("tab.routes".localized, systemImage: "map.fill")
                    }
                    .tag(0)
                
                // Tab 2: My Trips
                TripsView()
                    .tabItem {
                        Label("tab.myTrips".localized, systemImage: "road.lanes")
                    }
                    .tag(1)
                
                // Tab 3: Profile
                EnhancedProfileView()
                    .tabItem {
                        Label("tab.profile".localized, systemImage: "person.circle.fill")
                    }
                    .tag(2)
                
                // Tab 4: More
                MoreView()
                    .tabItem {
                        Label("tab.more".localized, systemImage: "ellipsis.circle.fill")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
        }
        .environmentObject(dataManager)
    }
}

#Preview {
    MainTabView()
}
