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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Text("What's your name?")
                    .font(.oscineLargeTitle)
                    .foregroundColor(.primary)
                
                TextField("Enter your name", text: $userName)
                    .font(.oscineRegular(size: 17))
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary, lineWidth: 2)
                    )
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.oscineHeadline)
                    .foregroundColor(userName.isEmpty ? .secondary : .buttonText)
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
        .onTapGesture {
            KeyboardDismissal.dismiss()
        }
    }
}

#Preview {
    OnboardingNameView(userName: .constant(""), onNext: {})
}
