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
    @State private var equipmentToEdit: Equipment?
    
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
                        equipmentToEdit = item
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
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
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } header: {
                    Text("settings")
                        .font(.oscineCaption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTool = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showingAddTool) {
                AddToolView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $equipmentToEdit) { equipment in
                EditToolView(equipment: equipment)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
