//
//  EditProfileView.swift
//  MCVenture
//
//  Created by BNTF on 23/11/2025.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userName") private var userName = ""
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("userAddress") private var userAddress = ""
    @AppStorage("userCity") private var userCity = ""
    @AppStorage("userCountry") private var userCountry = ""
    @AppStorage("userBio") private var userBio = ""
    @AppStorage("userDateOfBirth") private var userDateOfBirth = ""
    @AppStorage("userLicenseNumber") private var userLicenseNumber = ""
    @AppStorage("userEmergencyContact") private var userEmergencyContact = ""
    @AppStorage("userEmergencyPhone") private var userEmergencyPhone = ""
    
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        // // NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Full Name", text: $userName)
        // NavigationView closing
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Email", text: $userEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Phone Number", text: $userPhone)
                            .keyboardType(.phonePad)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        Button(action: { showingDatePicker.toggle() }) {
                            HStack {
                                Text(userDateOfBirth.isEmpty ? "Date of Birth" : userDateOfBirth)
                                    .foregroundColor(userDateOfBirth.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if showingDatePicker {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .onChange(of: selectedDate) { newDate in
                                let formatter = DateFormatter()
                                formatter.dateStyle = .long
                                userDateOfBirth = formatter.string(from: newDate)
                            }
                    }
                }
                
                Section(header: Text("Address")) {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Street Address", text: $userAddress)
                    }
                    
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("City", text: $userCity)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Country", text: $userCountry)
                    }
                }
                
                Section(header: Text("Motorcycle License")) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("License Number", text: $userLicenseNumber)
                    }
                }
                
                Section(header: Text("Emergency Contact")) {
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        TextField("Contact Name", text: $userEmergencyContact)
                    }
                    
                    HStack {
                        Image(systemName: "phone.badge.checkmark.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        TextField("Emergency Phone", text: $userEmergencyPhone)
                            .keyboardType(.phonePad)
                    }
                }
                
                Section(header: Text("About Me")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            Text("Bio")
                                .foregroundColor(.secondary)
                        }
                        
                        TextEditor(text: $userBio)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                Section {
                    Button(action: {
                        // Save and dismiss
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Profile")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
