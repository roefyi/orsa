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
}

struct DismissKeyboardOnDragModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollDismissesKeyboard(.interactively)
    }
}
