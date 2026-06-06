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
    @State private var status: BeanStatus = .current

    private var canSave: Bool {
        !coffeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !roaster.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // The essentials — only name + roaster are required.
                Section {
                    TextField("Coffee Name", text: $coffeeName)
                    TextField("Roaster", text: $roaster)
                } header: {
                    Text("coffee")
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }

                // Industry-standard attributes; origin is free text.
                Section {
                    TextField("Origin", text: $origin)
                    BeanOptionPicker(title: "Process", options: CoffeeReference.processes, selection: $process)
                    BeanOptionPicker(title: "Roast Level", options: CoffeeReference.roastLevels, selection: $roastLevel)
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                } header: {
                    Text("details")
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }

                // Tasting notes with quick-add flavor chips.
                Section {
                    FlavorNotesEditor(notes: $notes)
                } header: {
                    Text("tasting notes")
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }

                Section {
                    Picker("Status", selection: $status) {
                        ForEach(BeanStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    Toggle("Set as Primary", isOn: $isPrimary)
                } header: {
                    Text("shelf")
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .appFormStyle()
            .scrollContentBackground(.hidden)
            .keyboardDoneToolbar()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("add beans")
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
                        saveBean()
                        dismiss()
                    }
                    .disabled(!canSave)
                    .font(.oscineHeadline)
                }
            }
        }
    }

    private func saveBean() {
        let bean = Bean(
            coffeeName: coffeeName.trimmingCharacters(in: .whitespacesAndNewlines),
            roaster: roaster.trimmingCharacters(in: .whitespacesAndNewlines),
            roastDate: roastDate,
            process: process.isEmpty ? nil : process,
            origin: origin.isEmpty ? nil : origin,
            roastLevel: roastLevel.isEmpty ? nil : roastLevel,
            tastingNotes: notes.isEmpty ? nil : notes,
            status: status.rawValue,
            isPrimary: isPrimary
        )
        modelContext.insert(bean)
        modelContext.saveOrLog("add bean")
    }
}

#Preview {
    AddBeanView()
        .modelContainer(for: [Bean.self])
}
