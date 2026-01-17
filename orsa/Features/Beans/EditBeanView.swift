//
//  EditBeanView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct EditBeanView: View {
    let existingBean: Bean?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bean.dateAdded, order: .reverse) private var beans: [Bean]
    
    @State private var selectedBeanID: UUID?
    @State private var coffeeName = ""
    @State private var roaster = ""
    @State private var roastDate = Date()
    @State private var origin = ""
    @State private var process = ""
    @State private var roastLevel = ""
    @State private var notes = ""
    @State private var isPrimary = false
    @State private var status: BeanStatus = .current
    @State private var temperature = ""
    @State private var grindSetting = ""
    
    init(existingBean: Bean? = nil) {
        self.existingBean = existingBean
    }
    
    var currentBean: Bean? {
        if let existing = existingBean {
            return existing
        }
        if let selectedID = selectedBeanID {
            return beans.first { $0.id == selectedID }
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if existingBean == nil {
                    Section {
                        Picker("Bean", selection: $selectedBeanID) {
                            Text("Select a bean").tag(nil as UUID?)
                            ForEach(beans) { bean in
                                Text(bean.coffeeName).tag(bean.id as UUID?)
                            }
                        }
                        .onChange(of: selectedBeanID) { oldValue, newValue in
                            loadBeanData()
                        }
                    } header: {
                        Text("select bean")
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                    }
                }
                
                Section {
                    TextField("Coffee Name", text: $coffeeName)
                    TextField("Roaster", text: $roaster)
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                        .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
                    Picker("Status", selection: $status) {
                        ForEach(BeanStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    Toggle("Set as Primary", isOn: $isPrimary)
                        .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
                } header: {
                    Text("coffee info")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
                
                Section {
                    TextField("Origin", text: $origin)
                    TextField("Process", text: $process)
                    TextField("Roast Level", text: $roastLevel)
                } header: {
                    Text("details")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
                
                Section {
                    TextField("Tasting Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("notes")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
                
                Section {
                    TextField("Temperature", text: $temperature)
                    TextField("Grind Setting", text: $grindSetting)
                } header: {
                    Text("settings")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground)
            .navigationTitle("edit beans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBean()
                        dismiss()
                    }
                    .disabled(currentBean == nil || coffeeName.isEmpty || roaster.isEmpty)
                    .tint((currentBean == nil || coffeeName.isEmpty || roaster.isEmpty) ? Color.secondaryText : .accent)
                    .font(.oscineHeadline)
                }
            }
            .onAppear {
                loadBeanData()
            }
        }
    }
    
    private func loadBeanData() {
        if let bean = currentBean {
            coffeeName = bean.coffeeName
            roaster = bean.roaster
            roastDate = bean.roastDate ?? Date()
            origin = bean.origin ?? ""
            process = bean.process ?? ""
            roastLevel = bean.roastLevel ?? ""
            notes = bean.tastingNotes ?? ""
            isPrimary = bean.isPrimary
            status = bean.beanStatus
            temperature = bean.temperature ?? ""
            grindSetting = bean.grindSetting ?? ""
        } else if existingBean == nil {
            // Reset fields if no bean selected
            coffeeName = ""
            roaster = ""
            roastDate = Date()
            origin = ""
            process = ""
            roastLevel = ""
            notes = ""
            isPrimary = false
            status = .current
            temperature = ""
            grindSetting = ""
        }
    }
    
    private func saveBean() {
        guard let bean = currentBean else { return }
        
        // Update existing bean
        bean.coffeeName = coffeeName
        bean.roaster = roaster
        bean.roastDate = roastDate
        bean.process = process.isEmpty ? nil : process
        bean.origin = origin.isEmpty ? nil : origin
        bean.roastLevel = roastLevel.isEmpty ? nil : roastLevel
        bean.tastingNotes = notes.isEmpty ? nil : notes
        bean.isPrimary = isPrimary
        bean.status = status.rawValue
        bean.temperature = temperature.isEmpty ? nil : temperature
        bean.grindSetting = grindSetting.isEmpty ? nil : grindSetting
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving bean: \(error)")
        }
    }
}

#Preview {
    EditBeanView()
        .modelContainer(for: [Bean.self])
}
