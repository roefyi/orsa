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
                    // Custom neutral face (filled style matching other icons)
                    ZStack {
                        Circle()
                            .fill(Color(.label))
                            .frame(width: 16, height: 16)
                        // Eyes
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 2, height: 2)
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 2, height: 2)
                        }
                        .offset(y: -2)
                        // Mouth (straight line)
                        Rectangle()
                            .fill(Color(.systemBackground))
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
            HStack(spacing: 16) {
                // Square coffee image (Apple Books style)
                if let photoData = bean?.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    // Placeholder with coffee icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .frame(width: 80, height: 80)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Coffee name
                    Text(bean?.coffeeName ?? "Unknown Coffee")
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Roaster
                    if let roaster = bean?.roaster, !roaster.isEmpty {
                        Text(roaster)
                            .font(.oscineSubheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Bottom row: drink type, date, rating
                    HStack(spacing: 8) {
                        Text(brew.drinkType)
                            .font(.oscineCaption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.oscineCaption)
                            .foregroundColor(.secondary)
                        
                        Text(brew.timestamp, style: .date)
                            .font(.oscineCaption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        ratingIcon
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .frame(height: 104)
            .background(Color.clear)
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
