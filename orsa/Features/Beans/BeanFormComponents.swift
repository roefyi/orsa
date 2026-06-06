//
//  BeanFormComponents.swift
//  orsa
//
//  Industry-standard reference data and the reusable form controls shared by
//  AddBeanView and EditBeanView (option pickers + the flavor-chip notes editor).
//

import SwiftUI

// MARK: - Reference data

enum CoffeeReference {
    /// Common roast levels, light → dark.
    static let roastLevels = [
        "Light", "Medium-Light", "Medium", "Medium-Dark", "Dark"
    ]

    /// Common green-coffee processing methods.
    static let processes = [
        "Washed", "Natural", "Honey", "Anaerobic", "Carbonic Maceration",
        "Wet-Hulled", "Semi-Washed"
    ]

    /// Major coffee-producing origins (alphabetical).
    static let origins = [
        "Bolivia", "Brazil", "Burundi", "Colombia", "Costa Rica",
        "DR Congo", "Ecuador", "El Salvador", "Ethiopia", "Guatemala",
        "Honduras", "India", "Indonesia", "Jamaica", "Kenya",
        "Mexico", "Nicaragua", "Panama", "Papua New Guinea", "Peru",
        "Rwanda", "Tanzania", "Uganda", "Vietnam", "Yemen", "Zambia"
    ]

    /// Common tasting / flavor descriptors (SCA flavor-wheel staples) offered as
    /// quick-add chips.
    static let flavorNotes = [
        "Chocolate", "Cocoa", "Caramel", "Brown Sugar", "Honey", "Vanilla",
        "Nutty", "Hazelnut", "Almond", "Toffee", "Berry", "Blueberry",
        "Strawberry", "Citrus", "Lemon", "Orange", "Stone Fruit", "Peach",
        "Cherry", "Apple", "Tropical", "Floral", "Jasmine", "Bergamot",
        "Black Tea", "Wine", "Spice", "Cinnamon"
    ]
}

// MARK: - Option picker

/// A Form picker over a fixed set of options, where an empty string means "not set".
struct BeanOptionPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String

    /// Keep any existing value that predates (or falls outside) the standard list so
    /// editing a legacy bean doesn't silently blank or drop it.
    private var allOptions: [String] {
        if !selection.isEmpty, !options.contains(selection) {
            return [selection] + options
        }
        return options
    }

    var body: some View {
        Picker(title, selection: $selection) {
            Text("Not set").tag("")
            ForEach(allOptions, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .tint(.secondary)
    }
}

// MARK: - Flavor notes editor

/// Comma-separated tasting notes with quick-add chips. The notes string remains the
/// single source of truth: chips toggle tokens in/out, and the text field stays fully
/// editable for anything custom.
struct FlavorNotesEditor: View {
    @Binding var notes: String

    private var tokens: [String] {
        notes
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func isSelected(_ flavor: String) -> Bool {
        tokens.contains { $0.caseInsensitiveCompare(flavor) == .orderedSame }
    }

    private func toggle(_ flavor: String) {
        var current = tokens
        if let index = current.firstIndex(where: { $0.caseInsensitiveCompare(flavor) == .orderedSame }) {
            current.remove(at: index)
        } else {
            current.append(flavor)
        }
        notes = current.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("chocolate, berry, citrus…", text: $notes, axis: .vertical)
                .lineLimit(2...4)
                .tint(AppColors.inputTint)

            FlowLayout(spacing: 8) {
                ForEach(CoffeeReference.flavorNotes, id: \.self) { flavor in
                    FlavorChip(label: flavor, isSelected: isSelected(flavor)) {
                        HapticFeedback.light()
                        toggle(flavor)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FlavorChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? "checkmark" : "plus")
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.oscineRegular(size: 14))
            }
            .foregroundColor(isSelected ? .buttonText : .primary)
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(AppColors.buttonYellow) : AnyShapeStyle(.regularMaterial))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var notes = "Chocolate, Citrus"
    return Form {
        Section("origin") {
            BeanOptionPicker(title: "Origin", options: CoffeeReference.origins, selection: .constant("Ethiopia"))
            BeanOptionPicker(title: "Process", options: CoffeeReference.processes, selection: .constant("Washed"))
            BeanOptionPicker(title: "Roast Level", options: CoffeeReference.roastLevels, selection: .constant("Medium"))
        }
        Section("notes") {
            FlavorNotesEditor(notes: $notes)
        }
    }
}
