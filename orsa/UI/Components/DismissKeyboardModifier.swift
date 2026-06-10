//
//  DismissKeyboardModifier.swift
//  orsa
//

import SwiftUI
import UIKit

enum KeyboardDismissal {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    /// Adds a "Done" button above the keyboard and dismisses it on interactive scroll.
    func keyboardDoneToolbar() -> some View {
        self
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        HapticFeedback.light()
                        KeyboardDismissal.dismiss()
                    }
                    .font(.oscineHeadline)
                    .foregroundStyle(.primary)
                }
            }
    }
}
