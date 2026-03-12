//
//  PerformanceOptimizer.swift
//  MCVenture
//

import SwiftUI
import Combine
import UIKit

// MARK: - Lazy Loading Manager
@MainActor
class LazyLoadingManager<T: Identifiable>: ObservableObject {
    @Published var items: [T] = []
    @Published var isLoading = false
    @Published var hasMoreItems = true
    
    private var allItems: [T] = []
    private let pageSize: Int
    private var currentPage = 0
    
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    func configure(with items: [T]) {
        self.allItems = items
        self.currentPage = 0
        self.items = []
        self.hasMoreItems = !items.isEmpty
    }
    
    func loadNextPage() {
        guard !isLoading && hasMoreItems else { return }
        
        isLoading = true
        
        // Simulate network delay for smooth UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let startIndex = self.currentPage * self.pageSize
            let endIndex = min(startIndex + self.pageSize, self.allItems.count)
            
            if startIndex < self.allItems.count {
                let newItems = Array(self.allItems[startIndex..<endIndex])
                self.items.append(contentsOf: newItems)
                self.currentPage += 1
                self.hasMoreItems = endIndex < self.allItems.count
            } else {
                self.hasMoreItems = false
            }
            
            self.isLoading = false
        }
    }
    
    func reset() {
        items = []
        currentPage = 0
        hasMoreItems = !allItems.isEmpty
    }
}

// MARK: - Pagination Helper
struct PaginationHelper<T: Identifiable> {
    static func paginate(_ items: [T], page: Int, pageSize: Int) -> [T] {
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, items.count)
        
        guard startIndex < items.count else { return [] }
        return Array(items[startIndex..<endIndex])
    }
    
    static func hasMorePages(_ items: [T], currentPage: Int, pageSize: Int) -> Bool {
        let nextPageStart = (currentPage + 1) * pageSize
        return nextPageStart < items.count
    }
}

// MARK: - Lazy Loading Scroll View
struct LazyLoadingScrollView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let pageSize: Int
    let loadMore: () -> Void
    let content: (Item) -> Content
    
    @State private var isLoading = false
    
    init(
        items: [Item],
        pageSize: Int = 20,
        loadMore: @escaping () -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.pageSize = pageSize
        self.loadMore = loadMore
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    content(item)
                        .onAppear {
                            // Load more when approaching end
                            if item.id == items.last?.id {
                                loadMore()
                            }
                        }
                }
                
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Image Cache Manager
class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cache.countLimit = 100 // Max 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create cache directory
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func get(forKey key: String) -> UIImage? {
        // Check memory cache
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    func set(_ image: UIImage, forKey key: String) {
        // Save to memory
        cache.setObject(image, forKey: key as NSString)
        
        // Save to disk
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearAll() {
        cache.removeAllObjects()
        
        if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for file in contents {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    func getCacheSize() -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return contents.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(size)
        }
    }
}

// MARK: - Cached Async Image
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        let cacheKey = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? url.lastPathComponent
        
        // Check cache first
        if let cachedImage = ImageCacheManager.shared.get(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadedImage = UIImage(data: data) {
                ImageCacheManager.shared.set(downloadedImage, forKey: cacheKey)
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

// MARK: - Memory Monitor
@MainActor
class MemoryMonitor: ObservableObject {
    static let shared = MemoryMonitor()
    
    @Published var usedMemoryMB: Double = 0
    @Published var isMemoryWarning = false
    
    private var timer: Timer?
    
    private init() {
        startMonitoring()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            usedMemoryMB = Double(info.resident_size) / 1024.0 / 1024.0
            isMemoryWarning = usedMemoryMB > 200 // Warning at 200 MB
        }
    }
    
    private func handleMemoryWarning() {
        isMemoryWarning = true
        
        // Clear image cache
        ImageCacheManager.shared.clearAll()
        
        // Post notification for other components to reduce memory
        NotificationCenter.default.post(name: NSNotification.Name("ReduceMemoryUsage"), object: nil)
        
        print("⚠️ Memory warning - caches cleared")
    }
}

// MARK: - Performance Metrics
struct PerformanceMetrics {
    static func measureExecutionTime(label: String = "Operation", operation: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        operation()
        let end = CFAbsoluteTimeGetCurrent()
        let duration = (end - start) * 1000 // Convert to ms
        print("⏱ \(label) took \(String(format: "%.2f", duration)) ms")
    }
    
    static func measureAsyncExecutionTime(label: String = "Operation", operation: @escaping () async -> Void) async {
        let start = CFAbsoluteTimeGetCurrent()
        await operation()
        let end = CFAbsoluteTimeGetCurrent()
        let duration = (end - start) * 1000
        print("⏱ \(label) took \(String(format: "%.2f", duration)) ms")
    }
}

// MARK: - Debouncer
class Debouncer {
    private var timer: Timer?
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Usage Examples
/*
// Lazy Loading:
@StateObject private var lazyLoader = LazyLoadingManager<Route>()

LazyLoadingScrollView(
    items: lazyLoader.items,
    loadMore: { lazyLoader.loadNextPage() }
) { route in
    RouteCard(route: route)
}
.onAppear {
    lazyLoader.configure(with: allRoutes)
    lazyLoader.loadNextPage()
}

// Cached Images:
CachedAsyncImage(url: URL(string: route.imageURL)) { image in
    image.resizable().aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}

// Memory Monitoring:
@StateObject private var memoryMonitor = MemoryMonitor.shared

Text("Memory: \(memoryMonitor.usedMemoryMB, specifier: "%.1f") MB")
    .foregroundColor(memoryMonitor.isMemoryWarning ? .red : .primary)

// Performance Measurement:
PerformanceMetrics.measureExecutionTime(label: "Route Calculation") {
    calculateOptimalRoute()
}

// Debouncing:
let searchDebouncer = Debouncer(delay: 0.5)

searchDebouncer.debounce {
    performSearch(query: searchText)
}
*/
