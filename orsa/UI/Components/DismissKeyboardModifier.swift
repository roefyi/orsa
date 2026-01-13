//
//  DismissKeyboardModifier.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

extension View {
    /// Dismisses keyboard when user drags/scrolls
    func dismissKeyboardOnDrag() -> some View {
        self.modifier(DismissKeyboardOnDragModifier())
    }
}

struct DismissKeyboardOnDragModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}
