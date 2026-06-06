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
                ForEach(Array(sortedEquipment.enumerated()), id: \.element.id) { index, item in
                    VStack(spacing: 0) {
                        EquipmentCardView(equipment: item) {
                            equipmentToEdit = item
                        }

                        // Divider spanning full width (except for last item)
                        if index < sortedEquipment.count - 1 {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
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
                    Text("press the + to add tools")
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTool = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
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
        modelContext.saveOrLog("delete equipment")
    }
}

#Preview {
    ToolsView()
        .modelContainer(for: [Equipment.self])
}
