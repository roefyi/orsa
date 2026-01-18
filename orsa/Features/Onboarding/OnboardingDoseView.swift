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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Text("nice, what's your usual dose?")
                    .font(.oscineLargeTitle)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    TextField("18.0", text: $defaultDose)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary, lineWidth: 2)
                        )
                        .focused($isTextFieldFocused)
                    
                    Text("g")
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Done")
                    .font(.oscineHeadline)
                    .foregroundColor(defaultDose.isEmpty ? .secondary : .buttonText)
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
