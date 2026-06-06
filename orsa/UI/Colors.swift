//
//  Colors.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

extension Color {
    // Background colors - adaptive
    static let appBackground = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0) // Dark grey background for dark mode
        default:
            return UIColor.white // White background for light mode
        }
    })
    
    static let cardBackground = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 44/255.0, green: 44/255.0, blue: 46/255.0, alpha: 1.0) // Dark grey cards for dark mode
        default:
            return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0) // Very light gray for light mode
        }
    })
    
    static let cardText = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.white // White text on dark cards
        default:
            return UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0) // Dark text on light cards
        }
    })
    
    // Text colors - adaptive
    static let secondaryText = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.7, alpha: 1.0) // Lighter gray for dark mode
        default:
            return UIColor(white: 0.5, alpha: 1.0) // Medium gray for light mode
        }
    })
    
    // Accent color - adaptive
    static let accent = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.white
        default:
            return UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
        }
    })
    
    // Button text color - always dark for yellow buttons
    static let buttonText = Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0) // Always dark text
}

// Custom color set for consistency
struct AppColors {
    static let buttonYellow = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0) // Slightly lighter yellow for dark mode
        default:
            return UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0) // Yellow button for light mode
        }
    })

    /// Yellow accent used for text-field cursors/tints throughout forms.
    /// Single source of truth — do not inline `Color(red: 1.0, green: 0.8, blue: 0.0)`.
    static let inputTint = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    static let backgroundGray = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0)
        default:
            return UIColor.white
        }
    })
    
    static let cardCream = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 44/255.0, green: 44/255.0, blue: 46/255.0, alpha: 1.0)
        default:
            return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        }
    })
    
    static let textBlack = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.white
        default:
            return UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
        }
    })
    
    static let textGray = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(white: 0.7, alpha: 1.0)
        default:
            return UIColor(white: 0.5, alpha: 1.0)
        }
    })
}

enum AppGradients {
    static let shareYellow = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.75, blue: 0.0),
            Color(red: 1.0, green: 0.85, blue: 0.0),
            Color(red: 1.0, green: 0.95, blue: 0.3)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let shareBlack = LinearGradient(
        colors: [
            Color(red: 15/255.0, green: 15/255.0, blue: 15/255.0),
            Color(red: 25/255.0, green: 25/255.0, blue: 25/255.0),
            Color(red: 35/255.0, green: 35/255.0, blue: 35/255.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
