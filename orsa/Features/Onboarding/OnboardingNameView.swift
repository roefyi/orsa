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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("What's your name?")
                    .font(.oscineLargeTitle)
                    .padding(.horizontal, 32)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .font(.oscineBody)
                    .padding(.horizontal, 32)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.oscineHeadline)
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userName.isEmpty ? Color.secondaryText.opacity(0.3) : AppColors.buttonYellow)
                    .cornerRadius(12)
            }
            .disabled(userName.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.appBackground)
    }
}

#Preview {
    OnboardingNameView(userName: .constant(""), onNext: {})
}
