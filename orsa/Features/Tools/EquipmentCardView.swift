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
            HStack(spacing: 16) {
                // Square equipment icon (Apple Books style)
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.secondary.opacity(0.2))
                    Image(systemName: equipmentIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .frame(width: 80, height: 80)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Equipment name
                    Text(equipment.displayName)
                        .font(.oscineHeadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Type
                    Text(typeDisplay)
                        .font(.oscineSubheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Bottom row: primary indicator
                    HStack {
                        Spacer()
                        
                        if equipment.isPrimary {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .frame(height: 104)
            .background(Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    private var equipmentIcon: String {
        switch equipment.equipmentType {
        case .machine:
            return "cup.and.saucer.fill"
        case .grinder:
            return "circle.grid.cross.fill"
        case .scale:
            return "scalemass.fill"
        case .kettle:
            return "drop.fill"
        case .filter:
            return "circle.hexagongrid.fill"
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
