//
//  EmergencyContactsView.swift
//  MCVenture
//
//  Emergency contacts management
//

import SwiftUI

struct EmergencyContactsView: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    @State private var showingAddContact = false
    @State private var editingContact: EmergencyContact?
    
    var body: some View {
        List {
            Section {
                if emergencyManager.emergencyContacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.badge.gearshape")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("No Emergency Contacts")
                            .font(.headline)
                        
                        Text("Add contacts who will be notified in case of emergency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(emergencyManager.emergencyContacts) { contact in
                        EmergencyContactCardView(contact: contact)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingContact = contact
                            }
                    }
                    .onDelete(perform: deleteContacts)
                }
            } header: {
                Text("Emergency Contacts")
            } footer: {
                Text("These contacts will receive SMS alerts with your location during emergencies")
                    .font(.caption)
            }
            
            Section {
                Button(action: { showingAddContact = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        Text("Add Emergency Contact")
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .navigationTitle("Emergency Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddContact) {
            EmergencyContactEditView(contact: nil)
        }
        .sheet(item: $editingContact) { contact in
            EmergencyContactEditView(contact: contact)
        }
    }
    
    private func deleteContacts(at offsets: IndexSet) {
        offsets.forEach { index in
            emergencyManager.removeEmergencyContact(at: index)
        }
        HapticFeedbackManager.shared.success()
    }
}

// MARK: - Emergency Contact Card View
struct EmergencyContactCardView: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(contact.isPrimary ? Color.red : Color.blue)
                    .frame(width: 50, height: 50)
                
                Image(systemName: contact.isPrimary ? "star.fill" : "person.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                
                Text(contact.relationship)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(contact.phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Call button
            Button(action: {
                if let url = URL(string: "tel://\(contact.phone)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Emergency Contact Edit View
struct EmergencyContactEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var emergencyManager = EmergencyManager.shared
    
    let contact: EmergencyContact?
    
    @State private var name: String
    @State private var relationship: String
    @State private var phone: String
    @State private var isPrimary: Bool
    
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    init(contact: EmergencyContact?) {
        self.contact = contact
        _name = State(initialValue: contact?.name ?? "")
        _relationship = State(initialValue: contact?.relationship ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _isPrimary = State(initialValue: contact?.isPrimary ?? false)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Contact Information")) {
                TextField("Name", text: $name)
                TextField("Relationship (e.g., Spouse, Parent)", text: $relationship)
                TextField("Phone Number", text: $phone)
                    .keyboardType(.phonePad)
            }
            
            Section {
                Toggle("Primary Contact", isOn: $isPrimary)
            } footer: {
                Text("Primary contact will be notified first")
                    .font(.caption)
            }
            
            Section {
                Button(action: saveContact) {
                    Text(contact == nil ? "Add Contact" : "Save Changes")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(contact == nil ? "New Contact" : "Edit Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Validation Error", isPresented: $showingValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }
    
    private func saveContact() {
        // Validate
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter a name"
            showingValidationError = true
            return
        }
        
        guard !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter a phone number"
            showingValidationError = true
            return
        }
        
        // Format phone number (remove spaces, dashes)
        let cleanedPhone = phone.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        if let existingContact = contact {
            // Update existing
            let updated = EmergencyContact(
                id: existingContact.id,
                name: name,
                phone: cleanedPhone,
                relationship: relationship,
                isPrimary: isPrimary
            )
            emergencyManager.updateEmergencyContact(updated)
        } else {
            // Add new
            let newContact = EmergencyContact(
                id: UUID(),
                name: name,
                phone: cleanedPhone,
                relationship: relationship,
                isPrimary: isPrimary
            )
            emergencyManager.addEmergencyContact(newContact)
        }
        
        HapticFeedbackManager.shared.success()
        dismiss()
    }
}
