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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(equipment) { item in
                    EquipmentCardView(equipment: item) {
                        selectedEquipment = item
                        showingAddTool = true
                    }
                    .listRowBackground(AppColors.cardCream)
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
                    }
                }
            }
            .sheet(isPresented: $showingAddTool) {
                AddToolView(existingEquipment: selectedEquipment)
            }
        }
    }
}

#Preview {
    ToolsView()
        .modelContainer(for: [Equipment.self])
}
