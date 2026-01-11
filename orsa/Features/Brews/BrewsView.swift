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
    @State private var selectedBrew: Brew?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(brews) { brew in
                    BrewCardView(brew: brew) {
                        selectedBrew = brew
                    }
                    .listRowBackground(AppColors.cardCream)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("all brews")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedBrew = nil
                        showingNewBrew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewBrew) {
                NewBrewView(existingBrew: selectedBrew)
            }
            .onChange(of: selectedBrew) { oldValue, newValue in
                if newValue != nil && !showingNewBrew {
                    showingNewBrew = true
                }
            }
        }
    }
}

#Preview {
    BrewsView()
        .modelContainer(for: [Brew.self, Bean.self, Equipment.self])
}
