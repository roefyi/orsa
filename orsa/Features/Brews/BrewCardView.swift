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
    
    @ViewBuilder
    private var ratingIcon: some View {
        if let rating = brew.rating {
            Group {
                switch rating {
                case 1:
                    Image(systemName: "hand.thumbsdown.fill")
                case 3:
                    Image(systemName: "face.smiling.fill")
                case 4:
                    Image(systemName: "hand.thumbsup.fill")
                case 5:
                    Image(systemName: "heart.fill")
                default:
                    EmptyView()
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.cardText)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(bean?.coffeeName ?? "Unknown Coffee")
                            .font(.oscineHeadline)
                            .foregroundColor(.cardText)
                        Spacer()
                        Text(brew.timestamp, style: .date)
                            .font(.oscineCaption)
                            .foregroundColor(.cardText.opacity(0.7))
                    }
                    
                    if let roaster = bean?.roaster {
                        Text(roaster)
                            .font(.oscineSubheadline)
                            .foregroundColor(.cardText.opacity(0.7))
                    }
                    
                    Text(brew.drinkType)
                        .font(.oscineCaption)
                        .foregroundColor(.cardText.opacity(0.7))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                
                ratingIcon
                    .padding(.trailing, 4)
                    .padding(.bottom, 4)
            }
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
