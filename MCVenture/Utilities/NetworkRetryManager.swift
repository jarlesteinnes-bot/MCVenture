//
//  NetworkRetryManager.swift
//  MCVenture
//
//  Handles network requests with automatic retry logic and exponential backoff
//

import Foundation
import Combine

class NetworkRetryManager {
    static let shared = NetworkRetryManager()
    
    private init() {}
    
    /// Performs a network request with automatic retry logic
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts (default: 3)
    ///   - initialDelay: Initial delay in seconds before first retry (default: 1)
    ///   - maxDelay: Maximum delay between retries in seconds (default: 32)
    ///   - request: The async function to execute
    /// - Returns: The result of the request
    func performWithRetry<T>(
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 32.0,
        request: @escaping () async throws -> T
    ) async throws -> T {
        var currentDelay = initialDelay
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                // Attempt the request
                return try await request()
            } catch {
                lastError = error
                
                // Don't retry on final attempt
                if attempt == maxRetries {
                    break
                }
                
                // Check if error is retryable
                guard isRetryable(error: error) else {
                    throw error
                }
                
                // Wait with exponential backoff
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                
                // Increase delay for next retry (exponential backoff)
                currentDelay = min(currentDelay * 2, maxDelay)
                
                print("🔄 Retry attempt \(attempt + 1)/\(maxRetries) after \(currentDelay)s delay")
            }
        }
        
        // All retries exhausted
        throw lastError ?? RetryError.maxRetriesExceeded
    }
    
    /// Determines if an error is retryable
    private func isRetryable(error: Error) -> Bool {
        // Check for network-related errors that should be retried
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut,
                 .cannotConnectToHost,
                 .networkConnectionLost,
                 .notConnectedToInternet,
                 .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        
        // Check for HTTP status codes that should be retried
        if let httpResponse = (error as NSError).userInfo["HTTPResponse"] as? HTTPURLResponse {
            let code = httpResponse.statusCode
            // Retry on 5xx server errors and 429 (rate limiting)
            return code >= 500 || code == 429
        }
        
        return false
    }
}

// MARK: - Retry Errors
enum RetryError: LocalizedError {
    case maxRetriesExceeded
    case invalidResponse
    case noData
    case decodingFailed
    case offline
    
    var errorDescription: String? {
        switch self {
        case .maxRetriesExceeded:
            return "Unable to complete request after multiple attempts. Please check your connection and try again."
        case .invalidResponse:
            return "Received invalid response from server."
        case .noData:
            return "No data received from server."
        case .decodingFailed:
            return "Failed to process server response."
        case .offline:
            return "You're offline. Please check your internet connection."
        }
    }
}

// MARK: - Usage Example
/*
 // Example usage with route scraping
 Task {
     do {
         let routes = try await NetworkRetryManager.shared.performWithRetry {
             try await scrapeRoutes()
         }
         // Handle successful routes
     } catch {
         // Handle error after all retries
         showError(error.localizedDescription)
     }
 }
 */
