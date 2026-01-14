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
    @FocusState private var focusedField: Field?
    
    enum Field {
        case machine, grinder
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 30) {
                Text("glad you're here \(userName)")
                    .font(.oscineLargeTitle)
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 32)
                
                Text("what's your main setup?")
                    .font(.oscineTitle3)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 32)
                
                VStack(spacing: 16) {
                    TextField("Machine", text: $machineName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primaryText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryText, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .machine)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .grinder
                        }
                    
                    TextField("Grinder", text: $grinderName)
                        .font(.oscineRegular(size: 17))
                        .foregroundColor(.primaryText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryText, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .grinder)
                        .submitLabel(.next)
                        .onSubmit {
                            if !machineName.isEmpty && !grinderName.isEmpty {
                                onNext()
                            }
                        }
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.oscineHeadline)
                    .foregroundColor((machineName.isEmpty || grinderName.isEmpty) ? .primaryText : .buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(machineName.isEmpty || grinderName.isEmpty ? Color.secondaryText.opacity(0.3) : AppColors.buttonYellow)
                    .cornerRadius(12)
            }
            .disabled(machineName.isEmpty || grinderName.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.appBackground)
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    OnboardingSetupView(
        machineName: .constant(""),
        grinderName: .constant(""),
        userName: "Rome",
        onNext: {}
    )
}
