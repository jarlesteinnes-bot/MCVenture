//
//  SocialFeedView.swift
//  MCVenture
//

import SwiftUI

struct SocialFeedView: View {
    @StateObject private var socialManager = SocialManager.shared
    @State private var showShareSheet = false
    
    var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(socialManager.sharedRoutes) { route in
                        SharedRouteCard(route: route)
                    }
                    
                    if socialManager.sharedRoutes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No shared routes yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Be the first to share a route!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding()
            }
            .navigationTitle("Community Routes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareRouteView()
            }
    }
}

struct SharedRouteCard: View {
    let route: SharedRoute
    @StateObject private var socialManager = SocialManager.shared
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.headline)
                    Text("by \(route.authorName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.1f", route.distance)) km")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    Text(route.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(difficultyColor(route.difficulty).opacity(0.2))
                        .foregroundColor(difficultyColor(route.difficulty))
                        .cornerRadius(8)
                }
            }
            
            Text(route.description)
                .font(.body)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Button(action: {
                    socialManager.likeRoute(route)
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("\(route.likes)")
                    }
                    .foregroundColor(.red)
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    HStack {
                        Image(systemName: "bubble.right.fill")
                        Text("\(route.comments.count)")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    // Download route
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download")
                    }
                    .foregroundColor(.green)
                }
            }
            .font(.subheadline)
            
            if showComments {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(route.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comment.authorName)
                                .font(.caption.bold())
                            Text(comment.text)
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return .green
        case "moderate": return .orange
        case "hard": return .red
        default: return .gray
        }
    }
}

struct ShareRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var socialManager = SocialManager.shared
    @State private var routeName = ""
    @State private var description = ""
    @State private var difficulty = "Moderate"
    let difficulties = ["Easy", "Moderate", "Hard"]
    
    var body: some View {
            Form {
                Section("Route Details") {
                    TextField("Route Name", text: $routeName)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Difficulty") {
                    Picker("Level", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { diff in
                            Text(diff).tag(diff)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Button("Share Route") {
                    socialManager.shareRoute(
                        name: routeName,
                        description: description,
                        authorName: "Current User",
                        distance: 45.5,
                        difficulty: difficulty
                    )
                    dismiss()
                }
                .disabled(routeName.isEmpty || description.isEmpty)
            }
            .navigationTitle("Share Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
    }
}
