//
//  OnboardingNameView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct OnboardingNameView: View {
    @Binding var userName: String
    let onNext: () -> Void
    let onSkip: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("What's your name?")
                    .font(.oscineRegular(size: 34))
                    .foregroundColor(.primary)
                
                TextField("Enter your name", text: $userName)
                    .font(.oscineRegular(size: 17))
                    .foregroundColor(.primary)
                    .appInputFieldStyle()
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            
            Spacer()
            
            OnboardingActionBar(
                isPrimaryEnabled: !userName.isEmpty,
                onPrimary: onNext,
                onSkip: onSkip
            )
        }
        .background(Color.appBackground)
        .onTapGesture {
            KeyboardDismissal.dismiss()
        }
    }
}

#Preview {
    OnboardingNameView(userName: .constant(""), onNext: {}, onSkip: {})
}
