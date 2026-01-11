//
//  FontRegistrar.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import UIKit
import CoreText

struct FontRegistrar {
    static func registerFonts() {
        let fontNames = [
            "Oscine_Trial_Rg.ttf",
            "Oscine_Trial_XBd.ttf"
        ]
        
        let bundle = Bundle.main
        
        for fontName in fontNames {
            guard let fontPath = bundle.path(forResource: fontName.components(separatedBy: ".").first!, ofType: "ttf") else {
                print("⚠️ Could not find font: \(fontName)")
                continue
            }
            let fontURL = URL(fileURLWithPath: fontPath)
            
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
                print("✓ Successfully registered font: \(fontName)")
            } else {
                if let error = error?.takeRetainedValue() {
                    let errorDescription = CFErrorCopyDescription(error) as String? ?? "Unknown error"
                    print("✗ Failed to register font \(fontName): \(errorDescription)")
                } else {
                    print("✗ Failed to register font: \(fontName)")
                }
            }
        }
        
        // Verify fonts are now available
        print("\n=== Verifying Registered Fonts ===")
        let testNames = ["OscineTrial-Regular", "OscineTrial-XBold"]
        for name in testNames {
            if UIFont(name: name, size: 17) != nil {
                print("✓ Font available: \(name)")
            } else {
                print("✗ Font NOT available: \(name)")
            }
        }
    }
}
