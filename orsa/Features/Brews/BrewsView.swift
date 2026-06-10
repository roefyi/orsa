//
//  BrewsView.swift
//  orsa
//

import SwiftUI
import SwiftData

struct BrewsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Brew.timestamp, order: .reverse) private var brews: [Brew]
    @Query private var beans: [Bean]
    @State private var showingNewBrew = false
    @State private var brewToEdit: Brew?
    @State private var brewToShare: Brew?
    
    private var beansByID: [UUID: Bean] {
        Dictionary(uniqueKeysWithValues: beans.map { ($0.id, $0) })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(brews.enumerated()), id: \.element.id) { index, brew in
                    OrsaListItem(showsDivider: index < brews.count - 1) {
                        BrewCardView(
                            brew: brew,
                            bean: brew.beanID.flatMap { beansByID[$0] }
                        ) {
                            brewToShare = brew
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteBrew(brew)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        
                        Button {
                            brewToEdit = brew
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .overlay {
                if brews.isEmpty {
                    OrsaEmptyListOverlay(message: "press the + to add brew")
                }
            }
            .navigationTitle("all brews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OrsaAddToolbarButton { showingNewBrew = true }
                }
            }
            .fullScreenCover(isPresented: $showingNewBrew) {
                NewBrewView()
            }
            .fullScreenCover(item: $brewToEdit) { brew in
                EditBrewView(brew: brew)
            }
            .fullScreenCover(item: $brewToShare) { brew in
                BrewShareCardView(brew: brew)
            }
        }
    }
    
    private func deleteBrew(_ brew: Brew) {
        modelContext.delete(brew)
        modelContext.saveOrLog("delete brew")
    }
}

#Preview {
    BrewsView()
        .modelContainer(for: [Brew.self, Bean.self, Equipment.self])
}
