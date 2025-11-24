//
//  MedicalInfoView.swift
//  MCVenture
//
//  Medical information form for emergencies
//

import SwiftUI

struct MedicalInfoView: View {
    @StateObject private var emergencyManager = EmergencyManager.shared
    @State private var bloodType: String
    @State private var allergies: [String]
    @State private var medications: [String]
    @State private var medicalConditions: [String]
    @State private var insuranceProvider: String
    @State private var insurancePolicyNumber: String
    @State private var doctorName: String
    @State private var doctorPhone: String
    
    @State private var newAllergyText = ""
    @State private var newMedicationText = ""
    @State private var newConditionText = ""
    
    @State private var showingSaveConfirmation = false
    
    init() {
        let medicalInfo = EmergencyManager.shared.medicalInfo
        _bloodType = State(initialValue: medicalInfo.bloodType)
        _allergies = State(initialValue: medicalInfo.allergies)
        _medications = State(initialValue: medicalInfo.medications)
        _medicalConditions = State(initialValue: medicalInfo.medicalConditions)
        _insuranceProvider = State(initialValue: medicalInfo.insuranceProvider)
        _insurancePolicyNumber = State(initialValue: medicalInfo.insurancePolicyNumber)
        _doctorName = State(initialValue: medicalInfo.doctorName)
        _doctorPhone = State(initialValue: medicalInfo.doctorPhone)
    }
    
    var body: some View {
        Form {
            // Blood Type
            Section {
                Picker("Blood Type", selection: $bloodType) {
                    Text("Unknown").tag("")
                    Text("A+").tag("A+")
                    Text("A-").tag("A-")
                    Text("B+").tag("B+")
                    Text("B-").tag("B-")
                    Text("AB+").tag("AB+")
                    Text("AB-").tag("AB-")
                    Text("O+").tag("O+")
                    Text("O-").tag("O-")
                }
                .pickerStyle(.menu)
            } header: {
                Text("Blood Type")
            } footer: {
                Text("Your blood type is critical information for emergency responders")
                    .font(.caption)
            }
            
            // Allergies
            Section {
                ForEach(allergies, id: \.self) { allergy in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(allergy)
                        Spacer()
                        Button(action: {
                            removeAllergy(allergy)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    TextField("Add allergy...", text: $newAllergyText)
                    Button(action: addAllergy) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newAllergyText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Allergies")
            } footer: {
                Text("List any drug or food allergies (e.g., Penicillin, Peanuts)")
                    .font(.caption)
            }
            
            // Medications
            Section {
                ForEach(medications, id: \.self) { medication in
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.blue)
                        Text(medication)
                        Spacer()
                        Button(action: {
                            removeMedication(medication)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    TextField("Add medication...", text: $newMedicationText)
                    Button(action: addMedication) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newMedicationText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Current Medications")
            } footer: {
                Text("List medications you take regularly")
                    .font(.caption)
            }
            
            // Medical Conditions
            Section {
                ForEach(medicalConditions, id: \.self) { condition in
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(.red)
                        Text(condition)
                        Spacer()
                        Button(action: {
                            removeCondition(condition)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                HStack {
                    TextField("Add condition...", text: $newConditionText)
                    Button(action: addCondition) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .disabled(newConditionText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Medical Conditions")
            } footer: {
                Text("List any chronic conditions (e.g., Diabetes, Asthma)")
                    .font(.caption)
            }
            
            // Insurance
            Section {
                TextField("Insurance Provider", text: $insuranceProvider)
                TextField("Policy Number", text: $insurancePolicyNumber)
            } header: {
                Text("Insurance Information")
            }
            
            // Doctor
            Section {
                TextField("Doctor's Name", text: $doctorName)
                TextField("Doctor's Phone", text: $doctorPhone)
                    .keyboardType(.phonePad)
            } header: {
                Text("Doctor Information")
            }
            
            // Save Button
            Section {
                Button(action: saveMedicalInfo) {
                    HStack {
                        Spacer()
                        Text("Save Medical Information")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Medical Information")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your medical information has been saved securely")
        }
    }
    
    // MARK: - Allergies
    private func addAllergy() {
        let trimmed = newAllergyText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !allergies.contains(trimmed) else { return }
        allergies.append(trimmed)
        newAllergyText = ""
        HapticFeedbackManager.shared.lightTap()
    }
    
    private func removeAllergy(_ allergy: String) {
        allergies.removeAll { $0 == allergy }
        HapticFeedbackManager.shared.lightTap()
    }
    
    // MARK: - Medications
    private func addMedication() {
        let trimmed = newMedicationText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !medications.contains(trimmed) else { return }
        medications.append(trimmed)
        newMedicationText = ""
        HapticFeedbackManager.shared.lightTap()
    }
    
    private func removeMedication(_ medication: String) {
        medications.removeAll { $0 == medication }
        HapticFeedbackManager.shared.lightTap()
    }
    
    // MARK: - Conditions
    private func addCondition() {
        let trimmed = newConditionText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !medicalConditions.contains(trimmed) else { return }
        medicalConditions.append(trimmed)
        newConditionText = ""
        HapticFeedbackManager.shared.lightTap()
    }
    
    private func removeCondition(_ condition: String) {
        medicalConditions.removeAll { $0 == condition }
        HapticFeedbackManager.shared.lightTap()
    }
    
    // MARK: - Save
    private func saveMedicalInfo() {
        emergencyManager.medicalInfo = MedicalInfo(
            bloodType: bloodType,
            allergies: allergies,
            medications: medications,
            medicalConditions: medicalConditions,
            insuranceProvider: insuranceProvider,
            insurancePolicyNumber: insurancePolicyNumber,
            doctorName: doctorName,
            doctorPhone: doctorPhone
        )
        emergencyManager.saveEmergencyData()
        
        HapticFeedbackManager.shared.success()
        showingSaveConfirmation = true
    }
}

// MARK: - Preview Helper
// // #Preview {
//     // NavigationView {
//         MedicalInfoView()
//     }
// }
