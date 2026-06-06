//
//  Brew.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import SwiftData

@Model
final class Brew: Identifiable {
    var id: UUID
    var timestamp: Date
    var beanID: UUID?
    var machineID: UUID?
    var grinderID: UUID?
    var drinkType: String
    var milkType: String?
    var dose: Double // grams
    var grindSetting: String
    var temperature: Double // °F or °C
    var brewTime: String // "28s" or "MM:SS"
    var yield: Double // grams or ml
    var rating: Int? // 0=☹️, 1=👎, 3=😐, 4=👍, 5=❤️
    var notes: String?
    var photoData: Data?
    var method: String // "espresso", "pour over", etc.
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        beanID: UUID? = nil,
        machineID: UUID? = nil,
        grinderID: UUID? = nil,
        drinkType: String = "",
        milkType: String? = nil,
        dose: Double = 0,
        grindSetting: String = "",
        temperature: Double = 0,
        brewTime: String = "",
        yield: Double = 0,
        rating: Int? = nil,
        notes: String? = nil,
        photoData: Data? = nil,
        method: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.beanID = beanID
        self.machineID = machineID
        self.grinderID = grinderID
        self.drinkType = drinkType
        self.milkType = milkType
        self.dose = dose
        self.grindSetting = grindSetting
        self.temperature = temperature
        self.brewTime = brewTime
        self.yield = yield
        self.rating = rating
        self.notes = notes
        self.photoData = photoData
        self.method = method
    }
}
