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
                    .padding(.horizontal, 32)
                
                HStack {
                    TextField("18.0", text: $defaultDose)
                        .textFieldStyle(.roundedBorder)
                        .font(.oscineBody)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                    
                    Text("g")
                        .foregroundColor(.secondary)
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
    }
}

#Preview {
    OnboardingDoseView(defaultDose: .constant("18.0"), onComplete: {})
}
