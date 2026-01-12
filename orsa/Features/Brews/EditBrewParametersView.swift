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
    @Binding var wdt: Bool
    @Binding var rdt: Bool
    
    // Local state for drink type picker
    @State private var drinkTypeOptions = ["Espresso", "Cappuccino", "Latte", "Americano", "Macchiato", "Flat White", "Cortado"]
    @State private var milkTypeOptions = ["None", "Whole", "Oat", "Almond", "Soy", "Coconut", "2%", "Skim"]
    
    init(
        selectedBean: Binding<Bean?>,
        selectedMachine: Binding<Equipment?>,
        selectedGrinder: Binding<Equipment?>,
        temperature: Binding<String>,
        grindSetting: Binding<String>,
        drinkType: Binding<String>,
        milkType: Binding<String>,
        wdt: Binding<Bool>,
        rdt: Binding<Bool>
    ) {
        self._selectedBean = selectedBean
        self._selectedMachine = selectedMachine
        self._selectedGrinder = selectedGrinder
        self._temperature = temperature
        self._grindSetting = grindSetting
        self._drinkType = drinkType
        self._milkType = milkType
        self._wdt = wdt
        self._rdt = rdt
    }
    
    var machines: [Equipment] {
        equipment.filter { $0.equipmentType == .machine }
    }
    
    var grinders: [Equipment] {
        equipment.filter { $0.equipmentType == .grinder }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Beans Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("beans")
                            .font(.oscineHeadline)
                            .foregroundColor(.primaryText)
                            .textCase(.lowercase)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            ForEach(beans) { bean in
                                Button {
                                    selectedBean = (selectedBean?.id == bean.id) ? nil : bean
                                } label: {
                                    HStack {
                                        BeanCardView(bean: bean)
                                        Spacer()
                                        if selectedBean?.id == bean.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accent)
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Tools Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("tools")
                            .font(.oscineHeadline)
                            .foregroundColor(.primaryText)
                            .textCase(.lowercase)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            // Machine Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("machine")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                VStack(spacing: 8) {
                                    // None option
                                    Button {
                                        selectedMachine = nil
                                    } label: {
                                        HStack {
                                            Text("None")
                                                .font(.oscineBody)
                                                .foregroundColor(.primaryText)
                                            Spacer()
                                            if selectedMachine == nil {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.accent)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    ForEach(machines) { machine in
                                        Button {
                                            selectedMachine = (selectedMachine?.id == machine.id) ? nil : machine
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(machine.displayName)
                                                        .font(.oscineHeadline)
                                                        .foregroundColor(.primaryText)
                                                    Text("espresso machine")
                                                        .font(.oscineCaption)
                                                        .foregroundColor(.secondaryText)
                                                }
                                                Spacer()
                                                if selectedMachine?.id == machine.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.accent)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .padding()
                                            .background(Color.cardBackground)
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            
                            // Grinder Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("grinder")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                VStack(spacing: 8) {
                                    // None option
                                    Button {
                                        selectedGrinder = nil
                                    } label: {
                                        HStack {
                                            Text("None")
                                                .font(.oscineBody)
                                                .foregroundColor(.primaryText)
                                            Spacer()
                                            if selectedGrinder == nil {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.accent)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    ForEach(grinders) { grinder in
                                        Button {
                                            selectedGrinder = (selectedGrinder?.id == grinder.id) ? nil : grinder
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(grinder.displayName)
                                                        .font(.oscineHeadline)
                                                        .foregroundColor(.primaryText)
                                                    Text("grinder")
                                                        .font(.oscineCaption)
                                                        .foregroundColor(.secondaryText)
                                                }
                                                Spacer()
                                                if selectedGrinder?.id == grinder.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.accent)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .padding()
                                            .background(Color.cardBackground)
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Process Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("process")
                            .font(.oscineHeadline)
                            .foregroundColor(.primaryText)
                            .textCase(.lowercase)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            // Temperature
                            VStack(alignment: .leading, spacing: 8) {
                                Text("temperature")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                TextField("Temperature", text: $temperature)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                            }
                            
                            // Grind Size
                            VStack(alignment: .leading, spacing: 8) {
                                Text("grind size")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                TextField("Grind Size", text: $grindSetting)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(8)
                            }
                            
                            // Drink Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("drink type")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                Picker("Drink Type", selection: $drinkType) {
                                    ForEach(drinkTypeOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                            }
                            
                            // Milk Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("milk type")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                Picker("Milk Type", selection: $milkType) {
                                    ForEach(milkTypeOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(8)
                            }
                            
                            // Prep Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("prep")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.primaryText)
                                    .textCase(.lowercase)
                                
                                VStack(spacing: 12) {
                                    Toggle("WDT", isOn: $wdt)
                                        .font(.oscineBody)
                                        .foregroundColor(.primaryText)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(8)
                                    
                                    Toggle("RDT", isOn: $rdt)
                                        .font(.oscineBody)
                                        .foregroundColor(.primaryText)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("edit parameters")
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
        @State private var drinkType = "Espresso"
        @State private var milkType = "None"
        @State private var wdt = false
        @State private var rdt = false
        
        var body: some View {
            EditBrewParametersView(
                selectedBean: $selectedBean,
                selectedMachine: $selectedMachine,
                selectedGrinder: $selectedGrinder,
                temperature: $temperature,
                grindSetting: $grindSetting,
                drinkType: $drinkType,
                milkType: $milkType,
                wdt: $wdt,
                rdt: $rdt
            )
        }
    }
    
    return PreviewWrapper()
        .modelContainer(for: [Bean.self, Equipment.self])
}
