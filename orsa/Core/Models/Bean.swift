//
//  Bean.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import SwiftData

enum BeanStatus: String, Codable, CaseIterable {
    case current = "current"
    case next = "next"
    case archived = "archived"
}

@Model
final class Bean {
    var id: UUID
    var coffeeName: String
    var roaster: String
    var roastDate: Date?
    var process: String? // "washed", "natural", "honey", etc.
    var origin: String? // country
    var region: String? // region within country
    var roastLevel: String? // "light", "medium", "dark"
    var tastingNotes: String?
    var bagWeight: Double? // grams or oz
    var remainingWeight: Double? // grams or oz
    var status: String // "current", "next", "archived"
    var dateAdded: Date
    var dateFinished: Date?
    var photoData: Data?
    
    init(
        id: UUID = UUID(),
        coffeeName: String = "",
        roaster: String = "",
        roastDate: Date? = nil,
        process: String? = nil,
        origin: String? = nil,
        region: String? = nil,
        roastLevel: String? = nil,
        tastingNotes: String? = nil,
        bagWeight: Double? = nil,
        remainingWeight: Double? = nil,
        status: String = BeanStatus.current.rawValue,
        dateAdded: Date = Date(),
        dateFinished: Date? = nil,
        photoData: Data? = nil
    ) {
        self.id = id
        self.coffeeName = coffeeName
        self.roaster = roaster
        self.roastDate = roastDate
        self.process = process
        self.origin = origin
        self.region = region
        self.roastLevel = roastLevel
        self.tastingNotes = tastingNotes
        self.bagWeight = bagWeight
        self.remainingWeight = remainingWeight
        self.status = status
        self.dateAdded = dateAdded
        self.dateFinished = dateFinished
        self.photoData = photoData
    }
    
    var beanStatus: BeanStatus {
        get { BeanStatus(rawValue: status) ?? .current }
        set { status = newValue.rawValue }
    }
}
