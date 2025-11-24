// InputValidator.swift - Prevent crashes from bad input

import Foundation

struct InputValidator {
    
    // MARK: - Text Validation
    static func validateText(_ text: String, minLength: Int = 0, maxLength: Int = 500, allowEmpty: Bool = false) -> ValidationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !allowEmpty && trimmed.isEmpty {
            return .invalid("This field cannot be empty")
        }
        
        if trimmed.count < minLength {
            return .invalid("Minimum \(minLength) characters required")
        }
        
        if trimmed.count > maxLength {
            return .invalid("Maximum \(maxLength) characters allowed")
        }
        
        return .valid
    }
    
    // MARK: - Motorcycle Name
    static func validateMotorcycleName(_ name: String) -> ValidationResult {
        let result = validateText(name, maxLength: 100, allowEmpty: false)
        guard case .valid = result else { return result }
        
        // Check for invalid characters
        let allowedChars = CharacterSet.alphanumerics.union(.whitespaces).union(CharacterSet(charactersIn: "-_."))
        if name.rangeOfCharacter(from: allowedChars.inverted) != nil {
            return .invalid("Only letters, numbers, spaces, and -_. allowed")
        }
        
        return .valid
    }
    
    // MARK: - Numeric Validation
    static func validateNumber(_ value: String, min: Double = 0, max: Double = 999999) -> ValidationResult {
        guard let number = Double(value) else {
            return .invalid("Please enter a valid number")
        }
        
        if number < min {
            return .invalid("Value must be at least \(min)")
        }
        
        if number > max {
            return .invalid("Value cannot exceed \(max)")
        }
        
        return .valid
    }
    
    // MARK: - Email Validation
    static func validateEmail(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if !predicate.evaluate(with: email) {
            return .invalid("Please enter a valid email address")
        }
        
        return .valid
    }
    
    // MARK: - Phone Validation
    static func validatePhone(_ phone: String) -> ValidationResult {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.count < 8 || cleaned.count > 15 {
            return .invalid("Please enter a valid phone number")
        }
        
        return .valid
    }
    
    // MARK: - Sanitization
    static func sanitize(_ text: String) -> String {
        var sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove potential SQL injection attempts
        let dangerousChars = ["<", ">", "script", "javascript:", "onerror", "onclick"]
        for char in dangerousChars {
            sanitized = sanitized.replacingOccurrences(of: char, with: "", options: .caseInsensitive)
        }
        
        return sanitized
    }
}

enum ValidationResult: Equatable {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
}
