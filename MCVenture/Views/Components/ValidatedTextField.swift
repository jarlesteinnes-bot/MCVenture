//
//  ValidatedTextField.swift
//  MCVenture
//

import SwiftUI
import UIKit

/// TextField with built-in validation using InputValidator
struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    let validation: InputValidator.ValidationType
    let placeholder: String
    let keyboardType: UIKeyboardType
    
    @State private var validationResult: ValidationResult = .valid
    @State private var showValidation: Bool = false
    
    init(
        _ title: String,
        text: Binding<String>,
        validation: InputValidator.ValidationType = .text(minLength: 1, maxLength: 100),
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.validation = validation
        self.placeholder = placeholder
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(borderColor, lineWidth: showValidation ? 2 : 0)
                )
                .onChange(of: text) { newValue in
                    validateInput(newValue)
                }
                .onSubmit {
                    showValidation = true
                }
            
            if showValidation, case .invalid(let message) = validationResult {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .transition(.opacity)
            }
        }
    }
    
    private var borderColor: Color {
        if !showValidation { return .clear }
        return validationResult.isValid ? .green : .red
    }
    
    private func validateInput(_ value: String) {
        switch validation {
        case .text(let min, let max):
            validationResult = InputValidator.validateText(value, minLength: min, maxLength: max)
        case .email:
            validationResult = InputValidator.validateEmail(value)
        case .phone:
            validationResult = InputValidator.validatePhone(value)
        case .number(let min, let max):
            validationResult = InputValidator.validateNumber(value, min: min ?? 0, max: max ?? 999999)
        }
    }
    
    func showValidationOnAppear() -> some View {
        self.onAppear {
            showValidation = !text.isEmpty
            validateInput(text)
        }
    }
}

// MARK: - Validation Types
extension InputValidator {
    enum ValidationType {
        case text(minLength: Int, maxLength: Int)
        case email
        case phone
        case number(min: Double?, max: Double?)
    }
}

// MARK: - SecureField Variant
struct ValidatedSecureField: View {
    let title: String
    @Binding var text: String
    let minLength: Int
    
    @State private var validationResult: ValidationResult = .valid
    @State private var showValidation: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SecureField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(borderColor, lineWidth: showValidation ? 2 : 0)
                )
                .onChange(of: text) { newValue in
                    validationResult = InputValidator.validateText(newValue, minLength: minLength, maxLength: 100)
                }
                .onSubmit {
                    showValidation = true
                }
            
            if showValidation, case .invalid(let message) = validationResult {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
    
    private var borderColor: Color {
        if !showValidation { return .clear }
        return validationResult.isValid ? .green : .red
    }
}

// MARK: - Usage Examples
/*
// Basic text validation:
ValidatedTextField(
    "Username",
    text: $username,
    validation: .text(minLength: 3, maxLength: 20)
)

// Email validation:
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email,
    keyboardType: .emailAddress
)

// Phone validation:
ValidatedTextField(
    "Phone",
    text: $phone,
    validation: .phone,
    keyboardType: .phonePad
)

// Number validation:
ValidatedTextField(
    "Distance (km)",
    text: $distance,
    validation: .number(min: 0, max: 1000),
    keyboardType: .decimalPad
)

// Password:
ValidatedSecureField(
    "Password",
    text: $password,
    minLength: 8
)

// With custom placeholder:
ValidatedTextField(
    "Name",
    text: $name,
    validation: .text(minLength: 2, maxLength: 50),
    placeholder: "Enter your name"
)

// Show validation immediately:
ValidatedTextField("Email", text: $email, validation: .email)
    .showValidationOnAppear()
*/
