//
//  OrsaListComponents.swift
//  orsa
//

import SwiftUI

struct OrsaListItem<Content: View>: View {
    let showsDivider: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            content()
            if showsDivider {
                Divider().padding(.horizontal, 20)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

struct OrsaEmptyListOverlay: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.oscineRegular(size: 17))
            .foregroundColor(.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OrsaAddToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

extension View {
    func orsaLargeSheet() -> some View {
        presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}
