//
//  CommunityRoutesView.swift
//  MCVenture
//
//  Discover and share motorcycle routes with the community

import SwiftUI
import MapKit

struct CommunityRoutesView: View {
    @StateObject private var syncManager = CloudKitSyncManager.shared
    @State private var routes: [RouteData] = []
    @State private var isLoading = false
    @State private var error: AppError?
    @State private var selectedRoute: RouteData?
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Loading community routes...")
                        .padding()
                } else if routes.isEmpty {
                    EmptyStateView(
                        icon: "map.circle",
                        title: "No Community Routes Yet",
                        message: "Be the first to share a route with the MCVenture community!",
                        actionTitle: "Share Your Route",
                        action: { showShareSheet = true }
                    )
                } else {
                    List {
                        Section(header: communityHeader) {
                            ForEach(routes, id: \.id) { route in
                                CommunityRouteRowView(route: route)
                                    .onTapGesture {
                                        selectedRoute = route
                                    }
                            }
                        }
                        
                        if syncManager.pendingOperations > 0 {
                            Section {
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                    Text("\(syncManager.pendingOperations) routes syncing...")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Community Routes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: refreshRoutes) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: { showShareSheet = true }) {
                            Label("Share Route", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(action: showSyncStatus) {
                            Label("Sync Status", systemImage: "icloud")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $selectedRoute) { route in
                RouteDetailModalView(route: route)
            }
            .sheet(isPresented: $showShareSheet) {
                CommunityShareRouteView()
            }
            .errorAlert($error)
            .onAppear {
                if routes.isEmpty {
                    loadRoutes()
                }
            }
            .refreshable {
                await refreshRoutesAsync()
            }
        }
    }
    
    private var communityHeader: some View {
        HStack {
            Label("Shared Routes", systemImage: "person.3.fill")
                .font(.headline)
            
            Spacer()
            
            if let lastSync = syncManager.lastSyncDate {
                Text("Updated \(timeAgo(lastSync))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func loadRoutes() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                routes = try await syncManager.fetchRoutes()
                isLoading = false
            } catch {
                isLoading = false
                self.error = .cloudKitSyncFailed(error.localizedDescription)
            }
        }
    }
    
    private func refreshRoutes() {
        HapticManager.shared.light()
        loadRoutes()
    }
    
    private func refreshRoutesAsync() async {
        do {
            routes = try await syncManager.fetchRoutes()
            HapticManager.shared.success()
        } catch {
            self.error = .cloudKitSyncFailed(error.localizedDescription)
        }
    }
    
    private func showSyncStatus() {
        // Show sync status alert
        HapticManager.shared.light()
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Route Row

struct CommunityRouteRowView: View {
    let route: RouteData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Route icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Label(String(format: "%.1f km", route.distance), systemImage: "arrow.left.and.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("Community", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Route Detail Modal

struct RouteDetailModalView: View {
    let route: RouteData
    @Environment(\.dismiss) var dismiss
    @State private var showDownloadSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Map preview placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 200)
                        
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.8))
                            Text("Route Preview")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding()
                    
                    // Route info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label(String(format: "%.1f km", route.distance), systemImage: "arrow.left.and.right")
                            Spacer()
                            Label("Community", systemImage: "icloud")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About This Route")
                                .font(.headline)
                            Text("Shared by the MCVenture community. Download to add this route to your collection.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: downloadRoute) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Download Route")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        Button(action: shareRoute) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Route")
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(route.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .overlay {
            if showDownloadSuccess {
                SuccessAnimationView(
                    icon: "arrow.down.circle.fill",
                    title: "Route Downloaded!",
                    message: "The route has been added to your collection."
                ) {
                    showDownloadSuccess = false
                    dismiss()
                }
            }
        }
    }
    
    private func downloadRoute() {
        HapticManager.shared.success()
        showDownloadSuccess = true
        // TODO: Integrate with your route storage system
    }
    
    private func shareRoute() {
        HapticManager.shared.light()
        // TODO: Implement sharing
    }
}

// MARK: - Share Route View

struct CommunityShareRouteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var routeName = ""
    @State private var isSharing = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Route Details")) {
                    TextField("Route Name", text: $routeName)
                    
                    // TODO: Add route selection picker from user's saved routes
                    Text("Select a route from your collection to share")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: shareRoute) {
                        HStack {
                            Spacer()
                            if isSharing {
                                ProgressView()
                            } else {
                                Text("Share with Community")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(routeName.isEmpty || isSharing)
                }
                
                Section(footer: sharingFooter) {}
            }
            .navigationTitle("Share Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .overlay {
            if showSuccess {
                SuccessAnimationView(
                    icon: "icloud.fill",
                    title: "Route Shared!",
                    message: "Your route is now available to the MCVenture community."
                ) {
                    showSuccess = false
                    dismiss()
                }
            }
        }
    }
    
    private var sharingFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "icloud.fill")
                    .foregroundColor(.blue)
                Text("Shared via iCloud")
                    .font(.caption)
            }
            
            Text("Your route will be visible to all MCVenture users. Only route data is shared - your personal information stays private.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func shareRoute() {
        guard !routeName.isEmpty else { return }
        
        isSharing = true
        HapticManager.shared.light()
        
        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // TODO: Integrate with CloudKitSyncManager.shared.syncRoute()
            isSharing = false
            showSuccess = true
        }
    }
}

#Preview {
    CommunityRoutesView()
}
