//
//  BeansView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct BeansView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bean.dateAdded, order: .reverse) private var beans: [Bean]
    @State private var showingAddBeans = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(beans) { bean in
                    NavigationLink {
                        BeanDetailView(bean: bean)
                    } label: {
                        BeanCardView(bean: bean)
                    }
                    .listRowBackground(AppColors.cardCream)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("beans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBeans = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBeans) {
                AddBeanView()
            }
        }
    }
}

#Preview {
    BeansView()
        .modelContainer(for: [Bean.self])
}
