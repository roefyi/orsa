//
//  EditToolView.swift
//  orsa
//
//  Created by Rome on 1/16/26.
//

import SwiftUI
import SwiftData

struct EditToolView: View {
    let equipment: Equipment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var type: EquipmentType
    @State private var brand: String
    @State private var model: String
    @State private var isPrimary: Bool
    
    init(equipment: Equipment) {
        self.equipment = equipment
        
        // Initialize state from equipment object
        _type = State(initialValue: equipment.equipmentType)
        _brand = State(initialValue: equipment.brand)
        _model = State(initialValue: equipment.model)
        _isPrimary = State(initialValue: equipment.isPrimary)
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
                        .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
                } header: {
                    Text("equipment info")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("edit tool")
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
        }
    }
    
    private func saveEquipment() {
        // Update existing equipment
        equipment.equipmentType = type
        equipment.brand = brand
        equipment.model = model
        equipment.isPrimary = isPrimary
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving equipment: \(error)")
        }
    }
}

#Preview {
    let equipment = Equipment(
        id: UUID(),
        type: EquipmentType.machine.rawValue,
        brand: "Lelit",
        model: "Anna",
        isPrimary: true
    )
    return EditToolView(equipment: equipment)
        .modelContainer(for: [Equipment.self])
}
