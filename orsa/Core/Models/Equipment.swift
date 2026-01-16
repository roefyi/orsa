//
//  Equipment.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import SwiftData

enum EquipmentType: String, Codable, CaseIterable {
    case machine = "machine"
    case grinder = "grinder"
    case scale = "scale"
    case kettle = "kettle"
    case filter = "filter"
}

@Model
final class Equipment {
    var id: UUID
    var type: String // "machine", "grinder", "scale", "kettle"
    var brand: String
    var model: String
    var isPrimary: Bool
    var dateAdded: Date
    
    init(
        id: UUID = UUID(),
        type: String = EquipmentType.machine.rawValue,
        brand: String = "",
        model: String = "",
        isPrimary: Bool = false,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.brand = brand
        self.model = model
        self.isPrimary = isPrimary
        self.dateAdded = dateAdded
    }
    
    var equipmentType: EquipmentType {
        get { EquipmentType(rawValue: type) ?? .machine }
        set { type = newValue.rawValue }
    }
    
    var displayName: String {
        if brand.isEmpty && model.isEmpty {
            return "Untitled"
        } else if brand.isEmpty {
            return model
        } else if model.isEmpty {
            return brand
        } else {
            return "\(brand) \(model)"
        }
    }
}
