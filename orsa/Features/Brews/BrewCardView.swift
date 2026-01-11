//
//  BrewCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct BrewCardView: View {
    let brew: Brew
    let onTap: () -> Void
    
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    
    var bean: Bean? {
        guard let beanID = brew.beanID else { return nil }
        return beans.first { $0.id == beanID }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(bean?.coffeeName ?? "Unknown Coffee")
                        .font(.oscineHeadline)
                        .foregroundColor(.primaryText)
                    Spacer()
                    Text(brew.timestamp, style: .date)
                        .font(.oscineCaption)
                        .foregroundColor(.secondaryText)
                }
                
                if let roaster = bean?.roaster {
                    Text(roaster)
                        .font(.oscineSubheadline)
                        .foregroundColor(.secondaryText)
                }
                
                Text(brew.drinkType)
                    .font(.oscineCaption)
                    .foregroundColor(.secondaryText)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Brew.self, Bean.self, configurations: config)
    let brew = Brew(timestamp: Date(), drinkType: "Espresso")
    
    List {
        BrewCardView(brew: brew, onTap: {})
    }
    .modelContainer(container)
}
