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
                    // Custom neutral face (filled style)
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.9))
                            .frame(width: 16, height: 16)
                        // Eyes
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color.primary.colorInvert())
                                .frame(width: 2, height: 2)
                            Circle()
                                .fill(Color.primary.colorInvert())
                                .frame(width: 2, height: 2)
                        }
                        .offset(y: -2)
                        // Mouth (straight line)
                        Rectangle()
                            .fill(Color.primary.colorInvert())
                            .frame(width: 6, height: 1.5)
                            .offset(y: 3)
                    }
                case 4:
                    Image(systemName: "hand.thumbsup.fill")
                case 5:
                    Image(systemName: "heart.fill")
                default:
                    EmptyView()
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.primary)
        }
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(bean?.coffeeName ?? "Unknown Coffee")
                            .font(.oscineHeadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(brew.timestamp, style: .date)
                            .font(.oscineCaption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let roaster = bean?.roaster {
                        Text(roaster)
                            .font(.oscineSubheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(brew.drinkType)
                            .font(.oscineCaption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        ratingIcon
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
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
