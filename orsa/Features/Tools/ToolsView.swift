//
//  ToolsView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct ToolsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Equipment.dateAdded, order: .reverse) private var equipment: [Equipment]
    @State private var showingAddTool = false
    @State private var selectedEquipment: Equipment?
    
    var sortedEquipment: [Equipment] {
        equipment.sorted { first, second in
            // Primary equipment first
            if first.isPrimary != second.isPrimary {
                return first.isPrimary
            }
            // Then by date added (most recent first)
            return first.dateAdded > second.dateAdded
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedEquipment) { item in
                    EquipmentCardView(equipment: item) {
                        selectedEquipment = item
                        showingAddTool = true
                    }
                    .listRowBackground(AppColors.cardCream)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteEquipment(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                // Settings Section
                Section {
                    SettingsCardView()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                } header: {
                    Text("settings")
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .onAppear {
                print("ToolsView appeared - Equipment count: \(equipment.count)")
                sortedEquipment.forEach { eq in
                    print("  - \(eq.displayName) (\(eq.type)) - id: \(eq.id) - primary: \(eq.isPrimary)")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedEquipment = nil
                        showingAddTool = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .sheet(isPresented: $showingAddTool) {
                AddToolView(existingEquipment: selectedEquipment)
                    .onDisappear {
                        selectedEquipment = nil
                    }
            }
        }
    }
    
    private func deleteEquipment(_ equipment: Equipment) {
        modelContext.delete(equipment)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting equipment: \(error)")
        }
    }
}

#Preview {
    ToolsView()
        .modelContainer(for: [Equipment.self])
}
