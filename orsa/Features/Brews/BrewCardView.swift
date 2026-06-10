//
//  BrewCardView.swift
//  orsa
//

import SwiftUI

struct BrewCardView: View {
    let brew: Brew
    let bean: Bean?
    let onTap: () -> Void
    
    @ViewBuilder
    private var ratingIcon: some View {
        if let rating = brew.rating {
            BrewRatingListIcon(rating: rating)
        }
    }
    
    var body: some View {
        Button {
            HapticFeedback.light()
            onTap()
        } label: {
            HStack(spacing: 16) {
                if let photoData = bean?.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .frame(width: 80, height: 80)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(bean?.coffeeName ?? "Unknown Coffee")
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let roaster = bean?.roaster, !roaster.isEmpty {
                        Text(roaster)
                            .font(.oscineSubheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
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
    let brew = Brew(timestamp: Date(), drinkType: "Espresso")
    List {
        BrewCardView(brew: brew, bean: nil, onTap: {})
    }
}
