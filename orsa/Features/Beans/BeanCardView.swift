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
        VStack(alignment: .leading, spacing: 4) {
            Text(bean.coffeeName)
                .font(.oscineHeadline)
                .foregroundColor(.primaryText)
            
            Text(bean.roaster)
                .font(.oscineSubheadline)
                .foregroundColor(.secondaryText)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

#Preview {
    let bean = Bean(coffeeName: "Ethiopian Yirgacheffe", roaster: "Blue Bottle")
    return List {
        BeanCardView(bean: bean)
    }
}
