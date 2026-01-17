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
    
    // Sort beans with primary/current bean at the top
    var sortedBeans: [Bean] {
        beans.sorted { bean1, bean2 in
            // Primary bean always comes first
            if bean1.isPrimary && !bean2.isPrimary {
                return true
            } else if !bean1.isPrimary && bean2.isPrimary {
                return false
            }
            // If both or neither are primary, sort by date added (newest first)
            return bean1.dateAdded > bean2.dateAdded
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(sortedBeans.enumerated()), id: \.element.id) { index, bean in
                    VStack(spacing: 0) {
                        Button(action: {
                            HapticFeedback.light()
                            selectedBean = bean
                            showingBeanDetail = true
                        }) {
                            BeanCardView(bean: bean)
                        }
                        .buttonStyle(.plain)
                        
                        // Divider spanning full width (except for last item)
                        if index < sortedBeans.count - 1 {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("beans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBeans = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
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
