//
//  ButtonStyles.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct YellowButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.oscineHeadline)
            .foregroundColor(isDisabled ? .primaryText : .buttonText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.secondaryText.opacity(0.3) : AppColors.buttonYellow)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

extension ButtonStyle where Self == YellowButtonStyle {
    static func yellow(isDisabled: Bool = false) -> YellowButtonStyle {
        YellowButtonStyle(isDisabled: isDisabled)
    }
}
