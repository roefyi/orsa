//
//  OnboardingDoseView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct OnboardingDoseView: View {
    @Binding var defaultDose: String
    let onComplete: () -> Void
    let onSkip: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("nice, what's your usual dose?")
                    .font(.oscineRegular(size: 28))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 12) {
                    TextField("18.0", text: $defaultDose)
                        .keyboardType(.decimalPad)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($isTextFieldFocused)
                    
                    Text("g")
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            
            Spacer()
            
            OnboardingActionBar(
                isPrimaryEnabled: !defaultDose.isEmpty,
                onPrimary: onComplete,
                onSkip: onSkip
            )
            .onAppear {
                isTextFieldFocused = true
            }
        }
        .background(Color.appBackground)
        .onTapGesture {
            KeyboardDismissal.dismiss()
        }
    }
}

#Preview {
    OnboardingDoseView(defaultDose: .constant("18.0"), onComplete: {}, onSkip: {})
}
