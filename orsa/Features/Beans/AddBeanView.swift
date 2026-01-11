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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("coffee info") {
                    TextField("Coffee Name", text: $coffeeName)
                    TextField("Roaster", text: $roaster)
                    DatePicker("Roast Date", selection: $roastDate, displayedComponents: .date)
                }
                
                Section("details") {
                    TextField("Origin", text: $origin)
                    TextField("Process", text: $process)
                    TextField("Roast Level", text: $roastLevel)
                }
                
                Section("notes") {
                    TextField("Tasting Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("add beans")
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
                        saveBean()
                        dismiss()
                    }
                    .disabled(coffeeName.isEmpty || roaster.isEmpty)
                    .tint(coffeeName.isEmpty || roaster.isEmpty ? Color.secondaryText : .accent)
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
            status: BeanStatus.current.rawValue
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
