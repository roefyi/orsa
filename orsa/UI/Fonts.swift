//
//  Fonts.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import UIKit

extension Font {
    // Oscine Regular (for body text)
    static func oscineRegular(size: CGFloat) -> Font {
        return .custom("OscineTrial-Regular", size: size)
    }
    
    // Oscine ExtraBold (for headers and titles)
    static func oscineExtraBold(size: CGFloat) -> Font {
        return .custom("OscineTrial-XBold", size: size)  // Confirmed PostScript name
    }
    
    // Headers and Titles (ExtraBold)
    static let oscineLargeTitle = oscineExtraBold(size: 34)
    static let oscineTitle = oscineExtraBold(size: 28)
    static let oscineTitle2 = oscineExtraBold(size: 22)
    static let oscineTitle3 = oscineExtraBold(size: 20)
    static let oscineHeadline = oscineExtraBold(size: 17)
    
    // Body Text (Regular)
    static let oscineBody = oscineRegular(size: 17)
    static let oscineCallout = oscineRegular(size: 16)
    static let oscineSubheadline = oscineRegular(size: 15)
    static let oscineFootnote = oscineRegular(size: 13)
    static let oscineCaption = oscineRegular(size: 12)
    static let oscineCaption2 = oscineRegular(size: 11)
}

// View modifier for easier application
struct OscineFont: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.oscineRegular(size: size))
    }
}

extension View {
    func oscineFont(size: CGFloat) -> some View {
        modifier(OscineFont(size: size))
    }
}
