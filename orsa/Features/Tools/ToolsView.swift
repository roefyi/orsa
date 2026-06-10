//
//  ToolsView.swift
//  orsa
//

import SwiftUI
import SwiftData

struct ToolsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Equipment.dateAdded, order: .reverse) private var equipment: [Equipment]
    @State private var showingAddTool = false
    @State private var equipmentToEdit: Equipment?
    
    private var sortedEquipment: [Equipment] {
        equipment.sorted { first, second in
            if first.isPrimary != second.isPrimary {
                return first.isPrimary
            }
            return first.dateAdded > second.dateAdded
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(sortedEquipment.enumerated()), id: \.element.id) { index, item in
                    OrsaListItem(showsDivider: index < sortedEquipment.count - 1) {
                        EquipmentCardView(equipment: item) {
                            equipmentToEdit = item
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteEquipment(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .overlay {
                if equipment.isEmpty {
                    OrsaEmptyListOverlay(message: "press the + to add tools")
                }
            }
            .navigationTitle("tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OrsaAddToolbarButton { showingAddTool = true }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddTool) {
                EquipmentFormView(mode: .add).orsaLargeSheet()
            }
            .sheet(item: $equipmentToEdit) { equipment in
                EquipmentFormView(mode: .edit(equipment)).orsaLargeSheet()
            }
        }
    }
    
    private func deleteEquipment(_ equipment: Equipment) {
        modelContext.delete(equipment)
        modelContext.saveOrLog("delete equipment")
    }
}

#Preview {
    ToolsView()
        .modelContainer(for: [Equipment.self])
}
