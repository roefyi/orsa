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
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(equipment.displayName)
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                    Text(typeDisplay)
                        .font(.oscineCaption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if equipment.isPrimary {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(Color.clear)
        }
        .buttonStyle(.plain)
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
