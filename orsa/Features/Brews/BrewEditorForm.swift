//
//  BrewEditorForm.swift
//  orsa
//
//  Shared editor used by both NewBrewView and EditBrewView. Previously these two
//  screens duplicated ~90% of their layout plus a verbatim field-copy block; that
//  logic now lives in one place: `BrewDraft` owns the field <-> model mapping and
//  `BrewEditorForm` owns the shared UI.
//

import SwiftUI
import SwiftData

// MARK: - Options

/// Shared option lists for brew drink/milk selectors, used by both the inline
/// description selectors and the full parameters sheet.
enum BrewOptions {
    static let drinkTypes = [
        "Double Shot", "Cappuccino", "Latte", "Americano", "Macchiato",
        "Flat White", "Cortado", "Espresso Tonic", "Lungo", "Ristretto", "Allongé"
    ]

    static let milkTypes = [
        "None", "Whole", "Oat", "Almond", "Soy", "Coconut", "2%", "Skim", "Tonic Water"
    ]
}

// MARK: - Draft

/// Mutable, view-friendly representation of an editable brew. Holds the in-flight
/// form state and is the single source of truth for converting to/from `Brew`.
struct BrewDraft {
    var selectedBean: Bean?
    var selectedMachine: Equipment?
    var selectedGrinder: Equipment?
    var drinkType: String = "Double Shot"
    var milkType: String = "None"
    var dose: Double = 18.0
    var temperature: String = ""
    var grindSetting: String = ""
    var brewTime: Double = 30.0   // seconds
    var yield: Double = 36.0      // grams or ml
    var rating: Int? = nil
    var notes: String = ""

    init() {}

    /// Build a draft from an existing brew. Bean/equipment objects are resolved by
    /// the caller (which has the `@Query` results) via `resolveReferences(...)`.
    init(from brew: Brew) {
        drinkType = brew.drinkType.isEmpty ? "Double Shot" : brew.drinkType
        milkType = brew.milkType ?? "None"
        dose = brew.dose
        temperature = brew.temperature > 0 ? String(Int(brew.temperature)) : ""
        grindSetting = brew.grindSetting
        brewTime = Double(brew.brewTime.replacingOccurrences(of: "s", with: "")) ?? 30.0
        yield = brew.yield
        rating = brew.rating
        notes = brew.notes ?? ""
    }

    /// Resolve the bean/equipment object references from the model's stored IDs.
    mutating func resolveReferences(from brew: Brew, beans: [Bean], equipment: [Equipment]) {
        selectedBean = beans.first { $0.id == brew.beanID }
        selectedMachine = equipment.first { $0.id == brew.machineID }
        selectedGrinder = equipment.first { $0.id == brew.grinderID }
    }

    /// Copy the draft's values onto a `Brew`. This is the one place the field
    /// mapping lives — it used to be copy-pasted in three spots.
    func apply(to brew: Brew) {
        brew.beanID = selectedBean?.id
        brew.machineID = selectedMachine?.id
        brew.grinderID = selectedGrinder?.id
        brew.drinkType = drinkType
        brew.milkType = milkType == "None" ? nil : milkType
        brew.dose = dose
        brew.grindSetting = grindSetting
        brew.temperature = Double(temperature) ?? 0
        brew.brewTime = "\(Int(brewTime))s"
        brew.yield = yield
        brew.rating = rating
        brew.notes = notes.isEmpty ? nil : notes
        brew.method = drinkType.lowercased()
    }

    /// Create a brand-new `Brew` from the draft.
    func makeBrew() -> Brew {
        let brew = Brew()
        apply(to: brew)
        return brew
    }
}

// MARK: - Form

/// The shared scrollable editor body (description, sliders, rating, notes) plus the
/// "Edit parameters" toolbar button and its sheet. The hosting screen supplies the
/// surrounding `NavigationStack`, title, leading Cancel button, and action buttons.
struct BrewEditorForm<Actions: View>: View {
    @Binding var draft: BrewDraft
    let userName: String
    @ViewBuilder var actions: () -> Actions

    @State private var showingEditParameters = false
    @State private var longPressJustCompleted = false
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                BrewDescriptionView(draft: $draft, userName: userName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    // Brew Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("brew details")
                            .font(.oscineHeadline)
                            .foregroundColor(.primary)
                            .textCase(.lowercase)

                        CustomSlider(
                            title: "Yield",
                            value: $draft.yield,
                            in: 10...110,
                            step: 1,
                            suffix: yieldUnit == "ml" ? "ml" : "g"
                        )

                        CustomSlider(
                            title: "Time",
                            value: $draft.brewTime,
                            in: 15...75,
                            step: 1,
                            suffix: "s"
                        )
                    }

                    // Rating Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("rating")
                            .font(.oscineHeadline)
                            .foregroundColor(.primary)
                            .textCase(.lowercase)

                        BrewRatingPickerRow(
                            selectedRating: $draft.rating,
                            longPressJustCompleted: $longPressJustCompleted
                        )
                    }

                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("notes")
                            .font(.oscineHeadline)
                            .foregroundColor(.primary)
                            .textCase(.lowercase)

                        TextField("Notes", text: $draft.notes, axis: .vertical)
                            .lineLimit(3...6)
                            .tint(AppColors.inputTint)
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundColor(.primary)
                    }

                    // Action Buttons (supplied by host)
                    VStack(spacing: 12) {
                        actions()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
        .scrollContentBackground(.hidden)
        .keyboardDoneToolbar()
        .background(Color.appBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditParameters = true
                }
                .font(.oscineHeadline)
                .foregroundColor(.primary)
            }
        }
        .fullScreenCover(isPresented: $showingEditParameters) {
            EditBrewParametersView(
                selectedBean: $draft.selectedBean,
                selectedMachine: $draft.selectedMachine,
                selectedGrinder: $draft.selectedGrinder,
                temperature: $draft.temperature,
                grindSetting: $draft.grindSetting,
                drinkType: $draft.drinkType,
                milkType: $draft.milkType,
                dose: $draft.dose
            )
        }
    }
}

// MARK: - Brew description sentence

/// Renders the "<name> is making a <drink> with <coffee> by <roaster>" sentence.
/// Drink and bean are read-only here — change them via the parameters sheet.
private struct BrewDescriptionView: View {
    @Binding var draft: BrewDraft
    let userName: String

    private var leadingWords: [String] {
        let lead = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "making a"
            : "\(userName) is making a"
        return lead.split(separator: " ").map(String.init)
    }

    private var drinkWords: [String] {
        draft.drinkType.lowercased().split(separator: " ").map(String.init)
    }

    private var beanWords: [String] {
        let name = draft.selectedBean?.coffeeName ?? "coffee"
        return name.split(separator: " ").map(String.init)
    }

    private var roaster: String {
        draft.selectedBean?.roaster.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var body: some View {
        FlowLayout(spacing: 7) {
            ForEach(Array(leadingWords.enumerated()), id: \.offset) { _, word in
                word.titleWord
            }

            ForEach(Array(drinkWords.enumerated()), id: \.offset) { _, word in
                word.titleWord
            }

            "with".titleWord

            ForEach(Array(beanWords.enumerated()), id: \.offset) { _, word in
                word.titleWord
            }

            if !roaster.isEmpty {
                "by".titleWord
                ForEach(Array(roaster.split(separator: " ").enumerated()), id: \.offset) { _, word in
                    String(word).titleWord
                }
            }
        }
    }
}

private extension String {
    var titleWord: some View {
        Text(self)
            .font(.oscineRegular(size: 28))
            .foregroundColor(.primary)
    }
}
