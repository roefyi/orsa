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
    @State private var selectedBean: Bean?
    @State private var showingBeanDetail = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(beans) { bean in
                    Button(action: {
                        HapticFeedback.light()
                        selectedBean = bean
                        showingBeanDetail = true
                    }) {
                        BeanCardView(bean: bean)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("beans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBeans = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showingAddBeans) {
                AddBeanView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(item: $selectedBean) { bean in
                BeanDetailView(bean: bean)
            }
        }
    }
}

#Preview {
    BeansView()
        .modelContainer(for: [Bean.self])
}
