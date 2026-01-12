//
//  EditBrewParametersView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct EditBrewParametersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    
    // Bindings to update parent view
    @Binding var selectedBean: Bean?
    @Binding var selectedMachine: Equipment?
    @Binding var selectedGrinder: Equipment?
    @Binding var temperature: String
    @Binding var grindSetting: String
    @Binding var drinkType: String
    @Binding var milkType: String
    @Binding var dose: Double
    
    // Local state for drink type picker
    @State private var drinkTypeOptions = ["Single Shot", "Double Shot", "Cappuccino", "Latte", "Americano", "Macchiato", "Flat White", "Cortado"]
    @State private var milkTypeOptions = ["None", "Whole", "Oat", "Almond", "Soy", "Coconut", "2%", "Skim"]
    
    init(
        selectedBean: Binding<Bean?>,
        selectedMachine: Binding<Equipment?>,
        selectedGrinder: Binding<Equipment?>,
        temperature: Binding<String>,
        grindSetting: Binding<String>,
        drinkType: Binding<String>,
        milkType: Binding<String>,
        dose: Binding<Double>
    ) {
        self._selectedBean = selectedBean
        self._selectedMachine = selectedMachine
        self._selectedGrinder = selectedGrinder
        self._temperature = temperature
        self._grindSetting = grindSetting
        self._drinkType = drinkType
        self._milkType = milkType
        self._dose = dose
    }
    
    var machines: [Equipment] {
        equipment.filter { $0.equipmentType == .machine }
    }
    
    var grinders: [Equipment] {
        equipment.filter { $0.equipmentType == .grinder }
    }
    
    var primaryMachine: Equipment? {
        machines.first { $0.isPrimary }
    }
    
    var primaryGrinder: Equipment? {
        grinders.first { $0.isPrimary }
    }
    
    // Helper to create bean display string
    func beanDisplayName(_ bean: Bean) -> String {
        if bean.roaster.isEmpty {
            return bean.coffeeName
        } else {
            return "\(bean.coffeeName) by \(bean.roaster)"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Beans Dropdown
                Picker("Beans", selection: Binding(
                    get: { selectedBean?.id.uuidString ?? "none" },
                    set: { newValue in
                        if newValue == "none" {
                            selectedBean = nil
                        } else if let uuid = UUID(uuidString: newValue) {
                            selectedBean = beans.first { $0.id == uuid }
                        }
                    }
                )) {
                    Text("None").tag("none")
                    ForEach(beans) { bean in
                        Text(beanDisplayName(bean)).tag(bean.id.uuidString)
                    }
                }
                
                // Machine Dropdown
                Picker("Machine", selection: Binding(
                    get: { selectedMachine?.id.uuidString ?? primaryMachine?.id.uuidString ?? "" },
                    set: { newValue in
                        if let uuid = UUID(uuidString: newValue) {
                            selectedMachine = machines.first { $0.id == uuid }
                        }
                    }
                )) {
                    ForEach(machines) { machine in
                        Text(machine.displayName).tag(machine.id.uuidString)
                    }
                }
                
                // Grinder Dropdown
                Picker("Grinder", selection: Binding(
                    get: { selectedGrinder?.id.uuidString ?? primaryGrinder?.id.uuidString ?? "" },
                    set: { newValue in
                        if let uuid = UUID(uuidString: newValue) {
                            selectedGrinder = grinders.first { $0.id == uuid }
                        }
                    }
                )) {
                    ForEach(grinders) { grinder in
                        Text(grinder.displayName).tag(grinder.id.uuidString)
                    }
                }
                
                // Dose
                TextField("Dose", value: $dose, format: .number)
                    .keyboardType(.decimalPad)
                
                // Temperature
                TextField("Temperature", text: $temperature)
                    .keyboardType(.decimalPad)
                
                // Grind Size
                TextField("Grind Size", text: $grindSetting)
                
                // Drink Type
                Picker("Drink Type", selection: $drinkType) {
                    ForEach(drinkTypeOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                
                // Milk Type
                Picker("Milk Type", selection: $milkType) {
                    ForEach(milkTypeOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("parameters")
            .onAppear {
                // Set defaults to primary equipment if not already set
                if selectedMachine == nil, let primary = primaryMachine {
                    selectedMachine = primary
                }
                if selectedGrinder == nil, let primary = primaryGrinder {
                    selectedGrinder = primary
                }
            }
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
                        dismiss()
                    }
                    .tint(.accent)
                    .font(.oscineHeadline)
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedBean: Bean? = Bean(coffeeName: "Test Bean", roaster: "Test Roaster")
        @State private var selectedMachine: Equipment? = nil
        @State private var selectedGrinder: Equipment? = nil
        @State private var temperature = "200"
        @State private var grindSetting = "5"
        @State private var drinkType = "Single Shot"
        @State private var milkType = "None"
        @State private var dose: Double = 18.0
        
        var body: some View {
            EditBrewParametersView(
                selectedBean: $selectedBean,
                selectedMachine: $selectedMachine,
                selectedGrinder: $selectedGrinder,
                temperature: $temperature,
                grindSetting: $grindSetting,
                drinkType: $drinkType,
                milkType: $milkType,
                dose: $dose
            )
        }
    }
    
    return PreviewWrapper()
        .modelContainer(for: [Bean.self, Equipment.self])
}
