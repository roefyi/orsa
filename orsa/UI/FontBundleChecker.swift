//
//  FontBundleChecker.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import UIKit

struct FontBundleChecker {
    static func checkFontsInBundle() {
        print("=== Checking Font Files in Bundle ===")
        let bundle = Bundle.main
        
        let fontNames = [
            "Oscine_Trial_Rg.ttf",
            "Oscine_Trial_XBd.ttf",
            "Oscine_Trial_Bd.ttf"
        ]
        
        for fontName in fontNames {
            if let fontPath = bundle.path(forResource: fontName.components(separatedBy: ".").first!, ofType: "ttf") {
                print("✓ FOUND in bundle: \(fontName)")
                print("  Path: \(fontPath)")
            } else {
                print("✗ NOT FOUND in bundle: \(fontName)")
            }
        }
        
        // Also list all .ttf files in bundle
        print("\n=== All .ttf files in bundle ===")
        if let bundlePath = bundle.bundlePath as String? {
            let fileManager = FileManager.default
            if let files = try? fileManager.contentsOfDirectory(atPath: bundlePath) {
                let ttfFiles = files.filter { $0.hasSuffix(".ttf") }
                if ttfFiles.isEmpty {
                    print("⚠️ NO .ttf files found in bundle!")
                } else {
                    for file in ttfFiles {
                        print("  - \(file)")
                    }
                }
            }
        }
        
        print("====================================")
        
        // Try to load fonts directly and get their PostScript names
        print("\n=== Loading Fonts Directly ===")
        let fontFileNames = [
            "Oscine_Trial_Rg.ttf",
            "Oscine_Trial_XBd.ttf",
            "Oscine_Trial_Bd.ttf"
        ]
        
        for fontName in fontFileNames {
            if let fontPath = bundle.path(forResource: fontName.components(separatedBy: ".").first!, ofType: "ttf"),
               let fontData = NSData(contentsOfFile: fontPath) as Data?,
               let dataProvider = CGDataProvider(data: fontData as CFData),
               let fontRef = CGFont(dataProvider) {
                let postScriptName = fontRef.postScriptName as String? ?? "Unknown"
                print("Font: \(fontName)")
                print("  PostScript Name: \(postScriptName)")
                
                // Try to create UIFont with the PostScript name
                if UIFont(name: postScriptName, size: 17) != nil {
                    print("  ✓ UIFont created successfully!")
                } else {
                    print("  ✗ UIFont creation failed")
                }
            }
        }
        print("================================")
    }
}
