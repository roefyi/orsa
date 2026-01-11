//
//  EquipmentCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct EquipmentCardView: View {
    let equipment: Equipment
    
    var typeDisplay: String {
        switch equipment.equipmentType {
        case .machine:
            return "espresso machine"
        case .grinder:
            return "grinder"
        case .scale:
            return "scale"
        case .kettle:
            return "kettle"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.displayName)
                    .font(.oscineHeadline)
                    .foregroundColor(.primaryText)
                Text(typeDisplay)
                    .font(.oscineCaption)
                    .foregroundColor(.secondaryText)
            }
            Spacer()
            if equipment.isPrimary {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accent)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

#Preview {
    let machine = Equipment(type: EquipmentType.machine.rawValue, brand: "Lelit", model: "Anna", isPrimary: true)
    let grinder = Equipment(type: EquipmentType.grinder.rawValue, brand: "Varia", model: "VS1", isPrimary: false)
    
    return List {
        EquipmentCardView(equipment: machine)
        EquipmentCardView(equipment: grinder)
    }
}
