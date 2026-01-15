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
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(EquipmentType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    TextField("Brand", text: $brand)
                    TextField("Model", text: $model)
                    Toggle("Set as Primary", isOn: $isPrimary)
                } header: {
                    Text("equipment info")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(existingEquipment != nil ? "edit tool" : "add tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEquipment()
                        dismiss()
                    }
                    .disabled(brand.isEmpty && model.isEmpty)
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
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving equipment: \(error)")
        }
    }
}

#Preview {
    AddToolView()
        .modelContainer(for: [Equipment.self])
}
