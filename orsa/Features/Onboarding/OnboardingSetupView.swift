//
//  OnboardingSetupView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct OnboardingSetupView: View {
    @Binding var machineName: String
    @Binding var grinderName: String
    let userName: String
    let onNext: () -> Void
    let onSkip: () -> Void
    @FocusState private var focusedField: Field?
    
    enum Field {
        case machine, grinder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 30) {
                Text("glad you're here \(userName)")
                    .font(.oscineRegular(size: 34))
                    .foregroundColor(.primary)
                
                Text("what's your main setup?")
                    .font(.oscineRegular(size: 20))
                    .foregroundColor(.secondaryText)
                
                VStack(spacing: 16) {
                    TextField("Machine", text: $machineName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($focusedField, equals: .machine)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .grinder
                        }
                    
                    TextField("Grinder", text: $grinderName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primary)
                        .appInputFieldStyle()
                        .focused($focusedField, equals: .grinder)
                        .submitLabel(.next)
                        .onSubmit {
                            if !machineName.isEmpty && !grinderName.isEmpty {
                                onNext()
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            
            Spacer()
            
            OnboardingActionBar(
                isPrimaryEnabled: !machineName.isEmpty && !grinderName.isEmpty,
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
    OnboardingSetupView(
        machineName: .constant(""),
        grinderName: .constant(""),
        userName: "Rome",
        onNext: {},
        onSkip: {}
    )
}
