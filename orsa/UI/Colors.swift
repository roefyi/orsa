//
//  Colors.swift
//  orsa
//

import SwiftUI

extension Color {
    static let appBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1.0)
            : UIColor.white
    })
    
    static let cardBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 44/255.0, green: 44/255.0, blue: 46/255.0, alpha: 1.0)
            : UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
    })
    
    static let cardText = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
    })
    
    static let secondaryText = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.7, alpha: 1.0)
            : UIColor(white: 0.5, alpha: 1.0)
    })
    
    static let accent = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
    })
    
    static let buttonText = Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0)
}

struct AppColors {
    static let buttonYellow = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
    })

    static let inputTint = Color(red: 1.0, green: 0.8, blue: 0.0)
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
