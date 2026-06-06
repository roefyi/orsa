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
                    HStack {
                        Text("Brand")
                        TextField("e.g. Lelit", text: $brand)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Model")
                        TextField("e.g. Anna", text: $model)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("Set as Primary", isOn: $isPrimary)
                } header: {
                    Text("equipment info")
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .appFormStyle()
            .scrollContentBackground(.hidden)
            .keyboardDoneToolbar()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("edit tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.oscineHeadline)
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
        modelContext.saveOrLog("edit equipment")
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
