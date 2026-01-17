//
//  AddBeanView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct AddBeanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var coffeeName = ""
    @State private var roaster = ""
    @State private var roastDate = Date()
    @State private var origin = ""
    @State private var process = ""
    @State private var roastLevel = ""
    @State private var notes = ""
    @State private var isPrimary = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Coffee Name", text: $coffeeName)
                    TextField("Roaster", text: $roaster)
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                        .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
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
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground.ignoresSafeArea())
            .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
            .navigationTitle("add beans")
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
                        saveBean()
                        dismiss()
                    }
                    .disabled(coffeeName.isEmpty || roaster.isEmpty)
                    .font(.oscineHeadline)
                }
            }
        }
    }
    
    private func saveBean() {
        let bean = Bean(
            coffeeName: coffeeName,
            roaster: roaster,
            roastDate: roastDate,
            process: process.isEmpty ? nil : process,
            origin: origin.isEmpty ? nil : origin,
            roastLevel: roastLevel.isEmpty ? nil : roastLevel,
            tastingNotes: notes.isEmpty ? nil : notes,
            status: BeanStatus.current.rawValue,
            isPrimary: isPrimary
        )
        modelContext.insert(bean)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving bean: \(error)")
        }
    }
}

#Preview {
    AddBeanView()
        .modelContainer(for: [Bean.self])
}
