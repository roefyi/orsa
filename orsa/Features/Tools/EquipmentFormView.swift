//
//  EquipmentFormView.swift
//  orsa
//

import SwiftUI
import SwiftData

struct EquipmentFormView: View {
    enum Mode {
        case add
        case edit(Equipment)
    }
    
    let mode: Mode
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var type: EquipmentType
    @State private var brand: String
    @State private var model: String
    @State private var isPrimary: Bool
    
    private var navigationTitle: String {
        switch mode {
        case .add: "add tool"
        case .edit: "edit tool"
        }
    }
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            _type = State(initialValue: .machine)
            _brand = State(initialValue: "")
            _model = State(initialValue: "")
            _isPrimary = State(initialValue: false)
        case .edit(let equipment):
            _type = State(initialValue: equipment.equipmentType)
            _brand = State(initialValue: equipment.brand)
            _model = State(initialValue: equipment.model)
            _isPrimary = State(initialValue: equipment.isPrimary)
        }
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
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(brand.isEmpty && model.isEmpty)
                    .font(.oscineHeadline)
                }
            }
        }
    }
    
    private func save() {
        switch mode {
        case .add:
            modelContext.insert(Equipment(
                id: UUID(),
                type: type.rawValue,
                brand: brand,
                model: model,
                isPrimary: isPrimary
            ))
            modelContext.saveOrLog("add equipment")
        case .edit(let equipment):
            equipment.equipmentType = type
            equipment.brand = brand
            equipment.model = model
            equipment.isPrimary = isPrimary
            modelContext.saveOrLog("edit equipment")
        }
    }
}

#Preview("Add") {
    EquipmentFormView(mode: .add)
        .modelContainer(for: [Equipment.self])
}

#Preview("Edit") {
    EquipmentFormView(mode: .edit(Equipment(
        id: UUID(),
        type: EquipmentType.machine.rawValue,
        brand: "Lelit",
        model: "Anna",
        isPrimary: true
    )))
    .modelContainer(for: [Equipment.self])
}
