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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bean.coffeeName)
                    .font(.oscineHeadline)
                    .foregroundColor(.cardText)
                
                Text(bean.roaster)
                    .font(.oscineSubheadline)
                    .foregroundColor(.cardText.opacity(0.7))
            }
            Spacer()
            if bean.isPrimary {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.cardText)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

#Preview {
    let bean = Bean(coffeeName: "Ethiopian Yirgacheffe", roaster: "Blue Bottle")
    return List {
        BeanCardView(bean: bean)
    }
}
