//
//  DismissKeyboardModifier.swift
//  orsa
//
//  Created by Rome on 1/9/26.
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
    /// Dismisses the keyboard when the user scrolls content.
    func dismissKeyboardOnDrag() -> some View {
        modifier(DismissKeyboardOnDragModifier())
    }

    /// Adds a "Done" button above the keyboard so number/decimal pads — which have no
    /// return key — can be dismissed, and dismisses the keyboard on interactive scroll.
    /// Apply once at a screen's top-level scroll/form container.
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

struct DismissKeyboardOnDragModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollDismissesKeyboard(.interactively)
    }
}
