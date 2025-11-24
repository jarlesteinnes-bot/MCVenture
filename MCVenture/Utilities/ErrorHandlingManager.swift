//
//  ErrorHandlingManager.swift
//  MCVenture
//

import Foundation
import Combine

// MARK: - System Error Types
enum SystemError: LocalizedError {
    case network(NetworkError)
    case storage(StorageError)
    case location(LocationError)
    case validation(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .network(let error): return error.localizedDescription
        case .storage(let error): return error.localizedDescription
        case .location(let error): return error.localizedDescription
        case .validation(let message): return message
        case .unknown(let error): return error.localizedDescription
        }
    }
    
    var recoveryAction: String? {
        switch self {
        case .network(.noConnection): return "Check your internet connection"
        case .network(.timeout): return "Try again in a moment"
        case .location(.permissionDenied): return "Enable location in Settings"
        case .storage(.diskFull): return "Free up storage space"
        default: return "Try again"
        }
    }
}

enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noConnection: return "No internet connection"
        case .timeout: return "Request timed out"
        case .serverError(let code): return "Server error (\(code))"
        case .invalidResponse: return "Invalid server response"
        }
    }
}

enum StorageError: LocalizedError {
    case diskFull
    case writeFailure
    case readFailure
    case corruptedData
    
    var errorDescription: String? {
        switch self {
        case .diskFull: return "Storage is full"
        case .writeFailure: return "Failed to save data"
        case .readFailure: return "Failed to load data"
        case .corruptedData: return "Data is corrupted"
        }
    }
}

enum LocationError: LocalizedError {
    case permissionDenied
    case unavailable
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Location permission denied"
        case .unavailable: return "Location unavailable"
        case .timeout: return "Location request timed out"
        }
    }
}

// MARK: - Retry Manager
class RetryManager {
    static let shared = RetryManager()
    
    private init() {}
    
    /// Retry an operation with exponential backoff
    func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        multiplier: Double = 2.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var delay = initialDelay
        
        while attempt < maxAttempts {
            do {
                return try await operation()
            } catch {
                attempt += 1
                
                if attempt >= maxAttempts {
                    throw error
                }
                
                // Wait before retrying with exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay *= multiplier
            }
        }
        
        fatalError("Unreachable")
    }
    
    /// Retry with custom condition
    func retryWhen<T>(
        maxAttempts: Int = 3,
        shouldRetry: @escaping (Error) -> Bool,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        
        while attempt < maxAttempts {
            do {
                return try await operation()
            } catch {
                attempt += 1
                
                if attempt >= maxAttempts || !shouldRetry(error) {
                    throw error
                }
                
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
        
        fatalError("Unreachable")
    }
}

// MARK: - Error Boundary
@MainActor
class ErrorBoundary: ObservableObject {
    @Published var currentError: SystemError?
    @Published var showError: Bool = false
    
    func handle(_ error: Error, context: String = "") {
        let appError: SystemError
        
        if let existing = error as? SystemError {
            appError = existing
        } else {
            appError = .unknown(error)
        }
        
        currentError = appError
        showError = true
        
        // Log error
        print("❌ Error in \(context): \(appError.localizedDescription)")
        
        // Track analytics
        trackError(appError, context: context)
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
    
    private func trackError(_ error: SystemError, context: String) {
        // Implement analytics tracking here
        // e.g., Firebase Crashlytics, Sentry, etc.
    }
}

// MARK: - Graceful Degradation Helper
struct GracefulDegradation {
    /// Try operation, fallback to default on failure
    static func withFallback<T>(
        operation: () throws -> T,
        fallback: T,
        logError: Bool = true
    ) -> T {
        do {
            return try operation()
        } catch {
            if logError {
                print("⚠️ Operation failed, using fallback: \(error)")
            }
            return fallback
        }
    }
    
    /// Try async operation with fallback
    static func withFallback<T>(
        operation: () async throws -> T,
        fallback: T
    ) async -> T {
        do {
            return try await operation()
        } catch {
            print("⚠️ Async operation failed, using fallback: \(error)")
            return fallback
        }
    }
}

// MARK: - Result Extensions
extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var isFailure: Bool {
        !isSuccess
    }
    
    func onSuccess(_ action: (Success) -> Void) -> Self {
        if case .success(let value) = self {
            action(value)
        }
        return self
    }
    
    func onFailure(_ action: (Failure) -> Void) -> Self {
        if case .failure(let error) = self {
            action(error)
        }
        return self
    }
}

// MARK: - Usage Examples
/*
// Retry with exponential backoff:
let result = try await RetryManager.shared.retry {
    try await fetchRouteData()
}

// Retry only on specific errors:
let data = try await RetryManager.shared.retryWhen(shouldRetry: { error in
    if case NetworkError.timeout = error { return true }
    if case NetworkError.noConnection = error { return true }
    return false
}) {
    try await downloadMap()
}

// Use error boundary in views:
@StateObject private var errorBoundary = ErrorBoundary()

// In body:
.alert("Error", isPresented: $errorBoundary.showError) {
    Button("Retry") {
        // Retry operation
    }
    Button("OK") {
        errorBoundary.clearError()
    }
} message: {
    if let error = errorBoundary.currentError {
        Text(error.localizedDescription)
        if let action = error.recoveryAction {
            Text(action)
        }
    }
}

// Graceful degradation:
let routes = GracefulDegradation.withFallback(
    operation: { try loadRoutes() },
    fallback: []
)
*/
