//
//  FontDebugHelper.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import UIKit

struct FontDebugHelper {
    static func listAllOscineFonts() {
        print("=== Available Oscine Fonts ===")
        let fontFamilies = UIFont.familyNames.sorted()
        var foundOscine = false
        for family in fontFamilies {
            if family.lowercased().contains("oscine") {
                foundOscine = true
                print("Font Family: \(family)")
                let fonts = UIFont.fontNames(forFamilyName: family)
                for font in fonts {
                    print("  - Font Name: \(font)")
                }
            }
        }
        if !foundOscine {
            print("⚠️ NO OSCINE FONTS FOUND - Fonts may not be loading!")
            print("Total font families available: \(fontFamilies.count)")
        }
        print("==============================")
    }
    
    static func testFontNames() {
        let testNames = [
            "OscineTrial-Regular",  // Try this first (from font file)
            "OscineTrial-ExtraBold",  // Try this first (likely name)
            "Oscine_Trial_Rg",
            "OscineTrial-Rg",
            "OscineTrialRg",
            "Oscine-Trial-Rg",
            "Oscine_Trail_Rg",
            "OscineTrial-Regular",
            "Oscine_Trial_XBd",
            "OscineTrial-XBd",
            "OscineTrialXBd",
            "Oscine-Trial-XBd",
            "Oscine_Trail_XBd",
            "OscineTrial-ExtraBold",
            "OscineTrialXBd",
            "OscineTrial",
            "Oscine"
        ]
        
        print("=== Testing Font Names ===")
        for name in testNames {
            let font = UIFont(name: name, size: 17)
            if font != nil {
                print("✓ FOUND: \(name)")
            } else {
                print("✗ NOT FOUND: \(name)")
            }
        }
        print("==========================")
    }
}
