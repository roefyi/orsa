//
//  Colors.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

extension Color {
    // Primary button color - bright yellow (kept as requested)
    static let primaryButton = Color(red: 1.0, green: 0.85, blue: 0.0) // Bright yellow
    
    // Background colors - clean white/light gray palette
    static let appBackground = Color.white // White background
    static let cardBackground = Color(red: 249/255.0, green: 249/255.0, blue: 249/255.0) // Very light gray for cards
    static let cardText = Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0) // Dark text on light cards
    
    // Text colors
    static let primaryText = Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0) // Dark gray/black
    static let secondaryText = Color(white: 0.5) // Medium gray
    
    // Accent colors
    static let accent = primaryText
    static let accentDark = Color(red: 20/255.0, green: 20/255.0, blue: 20/255.0) // Darker for selected tabs
}

// Custom color set for consistency
struct AppColors {
    static let buttonYellow = Color(red: 1.0, green: 0.85, blue: 0.0) // Yellow button (kept)
    static let backgroundGray = Color.white // White background
    static let cardCream = Color(red: 249/255.0, green: 249/255.0, blue: 249/255.0) // Very light gray cards
    static let textBlack = Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0)
    static let textGray = Color(white: 0.5)
}
