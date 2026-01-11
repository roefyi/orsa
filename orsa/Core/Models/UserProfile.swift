//
//  UserProfile.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var preferredUnits: String // "metric" or "imperial"
    var defaultDose: Double // grams
    var onboardingCompleted: Bool
    
    init(
        name: String = "",
        preferredUnits: String = "metric",
        defaultDose: Double = 18.0,
        onboardingCompleted: Bool = false
    ) {
        self.name = name
        self.preferredUnits = preferredUnits
        self.defaultDose = defaultDose
        self.onboardingCompleted = onboardingCompleted
    }
}
