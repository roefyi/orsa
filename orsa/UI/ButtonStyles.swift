//
//  ButtonStyles.swift
//  orsa
//

import SwiftUI

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

    func appFormStyle() -> some View {
        font(.oscineRegular(size: 17))
            .tint(AppColors.inputTint)
    }
}
