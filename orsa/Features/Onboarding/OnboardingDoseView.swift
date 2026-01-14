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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("nice, what's your usual dose?")
                    .font(.oscineLargeTitle)
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 32)
                
                HStack(spacing: 12) {
                    TextField("18.0", text: $defaultDose)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primaryText)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryText, lineWidth: 2)
                        )
                        .focused($isTextFieldFocused)
                    
                    Text("g")
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primaryText.opacity(0.7))
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Done")
                    .font(.oscineHeadline)
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(defaultDose.isEmpty ? Color.secondaryText.opacity(0.3) : AppColors.buttonYellow)
                    .cornerRadius(12)
            }
            .disabled(defaultDose.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
            .onAppear {
                isTextFieldFocused = true
            }
        }
        .background(Color.appBackground)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

#Preview {
    OnboardingDoseView(defaultDose: .constant("18.0"), onComplete: {})
}
