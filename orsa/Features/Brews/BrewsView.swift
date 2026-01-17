//
//  BrewsView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct BrewsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Brew.timestamp, order: .reverse) private var brews: [Brew]
    @State private var showingNewBrew = false
    @State private var brewToEdit: Brew?
    @State private var brewToShare: Brew?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(brews.enumerated()), id: \.element.id) { index, brew in
                    VStack(spacing: 0) {
                        BrewCardView(brew: brew) {
                            HapticFeedback.light()
                            brewToShare = brew
                        }
                        
                        // Divider spanning full width (except for last item)
                        if index < brews.count - 1 {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
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
            .navigationTitle("all brews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewBrew = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
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
        do {
            try modelContext.save()
        } catch {
            print("Error deleting brew: \(error)")
        }
    }
}

#Preview {
    BrewsView()
        .modelContainer(for: [Brew.self, Bean.self, Equipment.self])
}
