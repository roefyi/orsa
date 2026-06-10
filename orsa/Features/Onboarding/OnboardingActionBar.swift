//
//  OnboardingActionBar.swift
//  orsa
//
//  Created by Rome on 6/5/26.
//

import SwiftUI

struct OnboardingActionBar: View {
    var primaryIcon: String = "arrow.right"
    var isPrimaryEnabled: Bool = true
    var isSkipEnabled: Bool = true
    var showsSkip: Bool = true
    var isBackEnabled: Bool = true
    let onPrimary: () -> Void
    let onSkip: () -> Void
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(isBackEnabled ? .primary : .secondary)
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isBackEnabled)
                }
                
                Button(action: onPrimary) {
                    Image(systemName: primaryIcon)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(isPrimaryEnabled ? .buttonText : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isPrimaryEnabled ? AppColors.buttonYellow : Color.secondaryText.opacity(0.3))
                        .cornerRadius(12)
                }
                .disabled(!isPrimaryEnabled)
            }
            
            if showsSkip {
                Button(action: onSkip) {
                    Image(systemName: "forward.end")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(isSkipEnabled ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
                .disabled(!isSkipEnabled)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
}

#Preview {
    VStack {
        Spacer()
        OnboardingActionBar(onPrimary: {}, onSkip: {}, onBack: {})
    }
    .background(Color.appBackground)
}
