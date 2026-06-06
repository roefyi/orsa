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

enum BrewActionIcon {
    static let font = Font.system(size: 20, weight: .light)
    static let done = "checkmark"
    static let share = "square.and.arrow.up"
    static let delete = "trash"
    static let create = "plus"
}

extension View {
    func appInputFieldStyle() -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .tint(AppColors.inputTint)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
