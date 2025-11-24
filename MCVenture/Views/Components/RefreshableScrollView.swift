//
//  RefreshableScrollView.swift
//  MCVenture
//

import SwiftUI

// Pull-to-refresh wrapper for ScrollView
struct RefreshableScrollView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ScrollView {
                content
            }
            .refreshable {
                await onRefresh()
            }
        } else {
            ScrollView {
                content
            }
        }
    }
}

// Usage example:
// RefreshableScrollView {
//     ForEach(items) { item in
//         ItemView(item: item)
//     }
// } onRefresh: {
//     await fetchNewData()
// }
