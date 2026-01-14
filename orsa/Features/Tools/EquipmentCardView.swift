//
//  EquipmentCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI

struct EquipmentCardView: View {
    let equipment: Equipment
    let onTap: () -> Void
    
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
        case .filter:
            return "filter"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.displayName)
                    .font(.oscineHeadline)
                    .foregroundColor(.cardText)
                Text(typeDisplay)
                    .font(.oscineCaption)
                    .foregroundColor(.cardText.opacity(0.7))
            }
            Spacer()
            if equipment.isPrimary {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.cardText)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticFeedback.light()
            onTap()
        }
    }
}

#Preview {
    let machine = Equipment(type: EquipmentType.machine.rawValue, brand: "Lelit", model: "Anna", isPrimary: true)
    let grinder = Equipment(type: EquipmentType.grinder.rawValue, brand: "Varia", model: "VS1", isPrimary: false)
    
    List {
        EquipmentCardView(equipment: machine, onTap: {})
        EquipmentCardView(equipment: grinder, onTap: {})
    }
}
