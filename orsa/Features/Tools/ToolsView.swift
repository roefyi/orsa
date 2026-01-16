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
    
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(sortedEquipment.enumerated()), id: \.element.id) { index, item in
                    VStack(spacing: 0) {
                        EquipmentCardView(equipment: item) {
                            selectedEquipment = item
                            showingAddTool = true
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
                    }
                }
                
                // Settings Section
                Section {
                    SettingsCardView()
                        .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } header: {
                    Text("settings")
                        .font(.oscineCaption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.leading, 20)
                        .padding(.top, 24)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            selectedEquipment = nil
                            showingAddTool = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showingAddTool) {
                AddToolView(existingEquipment: selectedEquipment)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .onDisappear {
                        selectedEquipment = nil
                    }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    Form {
                        Section {
                            SettingsCardView()
                        }
                    }
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showingSettings = false
                            }
                        }
                    }
                }
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
