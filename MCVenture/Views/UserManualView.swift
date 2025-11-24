//
//  UserManualView.swift
//  MCVenture
//
//  Created on 24/11/2025.
//

import SwiftUI
import WebKit

struct UserManualView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webViewManager = WebViewManager()
    @State private var isLoading = true
    @State private var loadError: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // WebView
                WebView(
                    url: webViewManager.manualURL,
                    isLoading: $isLoading,
                    loadError: $loadError
                )
                .opacity(isLoading ? 0 : 1)
                
                // Loading State
                if isLoading && loadError == nil {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("manual.loading".localized)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Error State
                if let error = loadError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("manual.error".localized)
                            .font(.headline)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            loadError = nil
                            isLoading = true
                            webViewManager.reload()
                        }) {
                            Label("manual.retry".localized, systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("manual.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { webViewManager.reload() }) {
                            Label("manual.refresh".localized, systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: { webViewManager.openInSafari() }) {
                            Label("manual.openSafari".localized, systemImage: "safari")
                        }
                        
                        Divider()
                        
                        Button(action: { webViewManager.shareManual() }) {
                            Label("manual.share".localized, systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// MARK: - WebView Manager
class WebViewManager: ObservableObject {
    @Published var manualURL: URL
    private var webView: WKWebView?
    
    init() {
        // Get current language from LocalizationManager
        let currentLanguage = LocalizationManager.shared.currentLanguage
        
        // Map language codes to manual paths
        let languageMap: [String: String] = [
            "en": "en",
            "nb": "nb",
            "de": "de",
            "es": "es",
            "fr": "fr",
            "it": "it",
            "sv": "sv",
            "da": "da"
        ]
        
        let languagePath = languageMap[currentLanguage] ?? "en"
        
        // GitHub Pages URL
        let urlString = "https://jarlesteinnes-bot.github.io/mcventure-manual/\(languagePath)/"
        self.manualURL = URL(string: urlString)!
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    func reload() {
        webView?.reload()
    }
    
    func openInSafari() {
        if let url = webView?.url ?? manualURL as URL? {
            UIApplication.shared.open(url)
        }
    }
    
    func shareManual() {
        guard let url = webView?.url ?? manualURL as URL? else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // Find the top-most view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            
            // Present activity view controller
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - WebView UIViewRepresentable
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Load the URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update if needed
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.loadError = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            
            // Check if it's a network error
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    parent.loadError = "No internet connection. Please check your connection and try again."
                case NSURLErrorTimedOut:
                    parent.loadError = "Connection timed out. Please try again."
                case NSURLErrorCannotFindHost:
                    parent.loadError = "Could not connect to the manual server. Please try again later."
                default:
                    parent.loadError = "Could not load manual. Please check your connection."
                }
            } else {
                parent.loadError = error.localizedDescription
            }
        }
    }
}

// MARK: - Preview
struct UserManualView_Previews: PreviewProvider {
    static var previews: some View {
        UserManualView()
    }
}
