//
//  OnboardingIntroView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct OnboardingIntroView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Text("this is Orsa")
                    .font(.oscineLargeTitle)
                    .foregroundColor(.primary)
                
                Text("the simple coffee journal")
                    .font(.oscineTitle2)
                    .foregroundColor(.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Get Started")
                    .font(.oscineHeadline)
                    .foregroundColor(.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.buttonYellow)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.appBackground)
    }
}

#Preview {
    OnboardingIntroView(onNext: {})
}
