//
//  AddToolView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct AddToolView: View {
    let existingEquipment: Equipment?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var type: EquipmentType = .machine
    @State private var brand = ""
    @State private var model = ""
    @State private var isPrimary = false
    
    init(existingEquipment: Equipment? = nil) {
        self.existingEquipment = existingEquipment
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("equipment info") {
                    Picker("Type", selection: $type) {
                        ForEach(EquipmentType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $model)
                    Toggle("Set as Primary", isOn: $isPrimary)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground)
            .navigationTitle(existingEquipment != nil ? "edit tool" : "add tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEquipment()
                        dismiss()
                    }
                    .disabled(brand.isEmpty && model.isEmpty)
                    .tint(brand.isEmpty && model.isEmpty ? Color.secondaryText : .accent)
                    .font(.oscineHeadline)
                }
            }
            .onAppear {
                if let equipment = existingEquipment {
                    type = equipment.equipmentType
                    brand = equipment.brand
                    model = equipment.model
                    isPrimary = equipment.isPrimary
                }
            }
        }
    }
    
    private func saveEquipment() {
        if let equipment = existingEquipment {
            // Update existing equipment
            equipment.equipmentType = type
            equipment.brand = brand
            equipment.model = model
            equipment.isPrimary = isPrimary
        } else {
            // Create new equipment
            let equipment = Equipment(
                id: UUID(),
                type: type.rawValue,
                brand: brand,
                model: model,
                isPrimary: isPrimary
            )
            modelContext.insert(equipment)
            print("Inserted new equipment: \(equipment.displayName) with id: \(equipment.id)")
        }
        
        do {
            try modelContext.save()
            print("Successfully saved equipment")
        } catch {
            print("Error saving equipment: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
    }
}

#Preview {
    AddToolView()
        .modelContainer(for: [Equipment.self])
}
