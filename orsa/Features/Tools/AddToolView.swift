//
//  AddToolView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct AddToolView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var type: EquipmentType = .machine
    @State private var brand = ""
    @State private var model = ""
    @State private var isPrimary = false
    
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
            .navigationTitle("add tool")
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
        // Create new equipment
        let equipment = Equipment(
            id: UUID(),
            type: type.rawValue,
            brand: brand,
            model: model,
            isPrimary: isPrimary
        )
        modelContext.insert(equipment)
        modelContext.saveOrLog("add equipment")
    }
}

#Preview {
    AddToolView()
        .modelContainer(for: [Equipment.self])
}
