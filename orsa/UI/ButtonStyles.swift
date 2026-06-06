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
            .foregroundColor(isDisabled ? .secondary : .buttonText)
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

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.oscineHeadline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension View {
    func appInputFieldStyle() -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
