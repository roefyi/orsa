//
//  BeanCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct BeanCardView: View {
    let bean: Bean
    
    var body: some View {
        HStack(spacing: 16) {
            // Square bean image (Apple Books style)
            if let photoData = bean.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                // Placeholder with bean icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.secondary.opacity(0.2))
                    Image("BeansIcon")
                        .renderingMode(.template)
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .frame(width: 80, height: 80)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Coffee name
                Text(bean.coffeeName)
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Roaster
                if !bean.roaster.isEmpty {
                    Text(bean.roaster)
                        .font(.oscineSubheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Bottom row: status and primary indicator
                HStack(spacing: 8) {
                    Text(bean.beanStatus.rawValue.capitalized)
                        .font(.oscineCaption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if bean.isPrimary {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(height: 104)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}

#Preview {
    let bean = Bean(coffeeName: "Ethiopian Yirgacheffe", roaster: "Blue Bottle")
    return List {
        BeanCardView(bean: bean)
    }
}
