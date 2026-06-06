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
    var defaultDose: Double // grams
    var onboardingCompleted: Bool

    init(
        name: String = "",
        defaultDose: Double = 18.0,
        onboardingCompleted: Bool = false
    ) {
        self.name = name
        self.defaultDose = defaultDose
        self.onboardingCompleted = onboardingCompleted
    }
}
