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
                ForEach(brews) { brew in
                    BrewCardView(brew: brew) {
                        HapticFeedback.light()
                        brewToShare = brew
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.visible)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteBrew(brew)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
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
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("all brews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewBrew = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
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
