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
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(bean.coffeeName)
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                
                Text(bean.roaster)
                    .font(.oscineSubheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if bean.isPrimary {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
    }
}

#Preview {
    let bean = Bean(coffeeName: "Ethiopian Yirgacheffe", roaster: "Blue Bottle")
    return List {
        BeanCardView(bean: bean)
    }
}
