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
                        .tint(AppColors.inputTint)
                    TextField("Roaster", text: $roaster)
                        .tint(AppColors.inputTint)
                } header: {
                    Text("coffee")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }

                // Industry-standard attributes, pick-from-list instead of free text.
                Section {
                    BeanOptionPicker(title: "Origin", options: CoffeeReference.origins, selection: $origin)
                    BeanOptionPicker(title: "Process", options: CoffeeReference.processes, selection: $process)
                    BeanOptionPicker(title: "Roast Level", options: CoffeeReference.roastLevels, selection: $roastLevel)
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                        .tint(AppColors.inputTint)
                } header: {
                    Text("details")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }

                // Tasting notes with quick-add flavor chips.
                Section {
                    FlavorNotesEditor(notes: $notes)
                } header: {
                    Text("tasting notes")
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
                        .tint(AppColors.inputTint)
                } header: {
                    Text("shelf")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
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
