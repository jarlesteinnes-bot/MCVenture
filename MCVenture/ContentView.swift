//
//  ContentView.swift
//  MCVenture
//
//  Created by BNTF on 21/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .environmentObject(DataManager.shared)
    }
}

#Preview {
    ContentView()
}
