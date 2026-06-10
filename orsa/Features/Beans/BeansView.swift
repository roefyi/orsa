//
//  BeansView.swift
//  orsa
//

import SwiftUI
import SwiftData

struct BeansView: View {
    @Query(sort: \Bean.dateAdded, order: .reverse) private var beans: [Bean]
    @State private var showingAddBeans = false
    @State private var selectedBean: Bean?
    
    private var sortedBeans: [Bean] {
        beans.sorted { bean1, bean2 in
            if bean1.isPrimary != bean2.isPrimary {
                return bean1.isPrimary
            }
            return bean1.dateAdded > bean2.dateAdded
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(sortedBeans.enumerated()), id: \.element.id) { index, bean in
                    OrsaListItem(showsDivider: index < sortedBeans.count - 1) {
                        Button {
                            HapticFeedback.light()
                            selectedBean = bean
                        } label: {
                            BeanCardView(bean: bean)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .overlay {
                if beans.isEmpty {
                    OrsaEmptyListOverlay(message: "press the + to add beans")
                }
            }
            .navigationTitle("beans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OrsaAddToolbarButton { showingAddBeans = true }
                }
            }
            .sheet(isPresented: $showingAddBeans) {
                AddBeanView().orsaLargeSheet()
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
