//
//  Colors.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

extension Color {
    // Primary button color - bright yellow
    static let primaryButton = Color(red: 1.0, green: 0.85, blue: 0.0) // Bright yellow
    
    // Background colors
    static let appBackground = Color(red: 200/255.0, green: 193/255.0, blue: 189/255.0) // RGB(200, 193, 189)
    static let cardBackground = Color(red: 233/255.0, green: 231/255.0, blue: 234/255.0) // RGB(233, 231, 234)
    
    // Text colors
    static let primaryText = Color(red: 57/255.0, green: 54/255.0, blue: 46/255.0) // RGB(57, 54, 46)
    static let secondaryText = Color(white: 0.4) // Dark gray
    
    // Accent colors - matching text color
    static let accent = primaryText // RGB(57, 54, 46)
    static let accentDark = Color(red: 35/255.0, green: 33/255.0, blue: 28/255.0) // Darker version for selected tabs
}

// Custom color set for consistency
struct AppColors {
    static let buttonYellow = Color(red: 1.0, green: 0.85, blue: 0.0)
    static let backgroundGray = Color(red: 200/255.0, green: 193/255.0, blue: 189/255.0) // RGB(200, 193, 189)
    static let cardCream = Color(red: 233/255.0, green: 231/255.0, blue: 234/255.0) // RGB(233, 231, 234)
    static let textBlack = Color.black
    static let textGray = Color(white: 0.4)
}
