//
//  Fonts.swift
//  orsa
//

import SwiftUI

extension Font {
    static func oscineRegular(size: CGFloat) -> Font {
        .custom("OscineTrial-Regular", size: size)
    }
    
    static func oscineBold(size: CGFloat) -> Font {
        .custom("OscineTrial-Bold", size: size)
    }
    
    static func oscineExtraBold(size: CGFloat) -> Font {
        .custom("OscineTrial-XBold", size: size)
    }
    
    static let oscineLargeTitle = oscineExtraBold(size: 34)
    static let oscineHeadline = oscineBold(size: 17)
    static let oscineBody = oscineRegular(size: 17)
    static let oscineSubheadline = oscineRegular(size: 15)
    static let oscineCaption = oscineRegular(size: 12)
}
