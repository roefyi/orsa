//
//  BeanDetailView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct BeanDetailView: View {
    let bean: Bean
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Photo placeholder
                Rectangle()
                    .fill(AppColors.cardCream)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.oscineLargeTitle)
                            .foregroundColor(.secondaryText)
                    )
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(bean.coffeeName)
                        .font(.oscineLargeTitle)
                        .foregroundColor(.primaryText)
                    
                    if let roastDate = bean.roastDate {
                        Text("Roast date: \(roastDate, style: .date)")
                            .font(.oscineSubheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Text(bean.roaster)
                        .font(.oscineTitle3)
                        .foregroundColor(.secondaryText)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    if !(bean.origin?.isEmpty ?? true) {
                        Label(bean.origin ?? "", systemImage: "globe")
                    }
                    
                    if !(bean.process?.isEmpty ?? true) {
                        Label(bean.process ?? "", systemImage: "leaf")
                    }
                }
                
                if !(bean.tastingNotes?.isEmpty ?? true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.oscineHeadline)
                            .foregroundColor(.primaryText)
                        Text(bean.tastingNotes ?? "")
                            .font(.oscineBody)
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Edit action
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview {
    let bean = Bean(
        coffeeName: "Ethiopian Yirgacheffe",
        roaster: "Blue Bottle",
        roastDate: Date(),
        process: "Washed",
        origin: "Ethiopia"
    )
    NavigationStack {
        BeanDetailView(bean: bean)
    }
}
