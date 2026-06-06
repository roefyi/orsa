//
//  OnboardingIntroView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct OnboardingIntroView: View {
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 40) {
                Text("Hey fellow coffee drinker. Thanks for downloading.")
                Text("My job is simple: log your coffee, then get out of the way. I'm just here to help you get the most out of those beautiful little beans.")
                Text("Now lets get you set up.")
            }
            .font(.oscineRegular(size: 20))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            
            Spacer()
            
            OnboardingActionBar(onPrimary: onNext, onSkip: onSkip)
        }
        .background(Color.appBackground)
    }
}

#Preview {
    OnboardingIntroView(onNext: {}, onSkip: {})
}
