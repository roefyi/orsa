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
                    BeanCardView(bean: bean)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedBean = bean
                            showingBeanDetail = true
                        }
                        .listRowBackground(AppColors.cardCream)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
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
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .sheet(isPresented: $showingAddBeans) {
                AddBeanView()
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
