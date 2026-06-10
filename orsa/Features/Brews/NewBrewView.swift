//
//  NewBrewView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct NewBrewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var userProfiles: [UserProfile]
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    @Query(sort: \Brew.timestamp, order: .reverse) private var brews: [Brew]

    @State private var draft = BrewDraft()
    @State private var shareBrew: Brew?
    /// A brew that was persisted early because the user tapped Share. Tracked so we
    /// can update it on Done, or delete it on Cancel (otherwise Cancel would leave a
    /// stray saved brew behind).
    @State private var savedBrewForShare: Brew?

    var userName: String {
        userProfiles.first?.name ?? ""
    }

    var body: some View {
        NavigationStack {
            BrewEditorForm(draft: $draft, userName: userName) {
                // Done button (primary) — submits and saves
                Button {
                    HapticFeedback.medium()
                    if let brew = savedBrewForShare {
                        draft.apply(to: brew)
                        modelContext.saveOrLog("update brew")
                    } else {
                        let brew = draft.makeBrew()
                        modelContext.insert(brew)
                        modelContext.saveOrLog("save brew")
                    }
                    dismiss()
                } label: {
                    Image(systemName: BrewActionIcon.done)
                        .font(BrewActionIcon.font)
                        .foregroundColor(.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.buttonYellow)
                        .cornerRadius(12)
                }

                // Share button (secondary) — persists then opens the share card
                Button {
                    HapticFeedback.light()
                    let brew: Brew
                    if let existing = savedBrewForShare {
                        draft.apply(to: existing)
                        brew = existing
                    } else {
                        brew = draft.makeBrew()
                        modelContext.insert(brew)
                        savedBrewForShare = brew
                    }
                    modelContext.saveOrLog("save brew for share")
                    shareBrew = brew
                } label: {
                    Image(systemName: BrewActionIcon.share)
                        .font(BrewActionIcon.font)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationTitle("new brew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // If Share created an early brew, discard it on cancel.
                        if let orphan = savedBrewForShare {
                            modelContext.delete(orphan)
                            modelContext.saveOrLog("discard unsaved brew")
                        }
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .onAppear(perform: setupAutoPopulation)
            .fullScreenCover(item: $shareBrew) { brew in
                BrewShareCardView(brew: brew)
            }
        }
    }

    private func setupAutoPopulation() {
        // Start from the user's default dose.
        if let profile = userProfiles.first {
            draft.dose = profile.defaultDose
        }

        // Default to a current bean.
        draft.selectedBean = beans.first { $0.status == BeanStatus.current.rawValue }

        if let lastBrew = brews.first {
            // Carry over the last brew's parameters.
            draft.drinkType = lastBrew.drinkType.isEmpty ? "Double Shot" : lastBrew.drinkType
            draft.temperature = lastBrew.temperature > 0 ? String(Int(lastBrew.temperature)) : ""
            draft.grindSetting = lastBrew.grindSetting
            draft.milkType = lastBrew.milkType ?? "None"

            draft.selectedMachine = equipment.first { $0.id == lastBrew.machineID }
                ?? equipment.first { $0.equipmentType == .machine && $0.isPrimary }
            draft.selectedGrinder = equipment.first { $0.id == lastBrew.grinderID }
                ?? equipment.first { $0.equipmentType == .grinder && $0.isPrimary }

            if lastBrew.dose > 0 {
                draft.dose = lastBrew.dose
            }
        } else {
            // No history — fall back to defaults + primary equipment.
            draft.drinkType = "Double Shot"
            draft.milkType = "None"
            draft.selectedMachine = equipment.first { $0.equipmentType == .machine && $0.isPrimary }
            draft.selectedGrinder = equipment.first { $0.equipmentType == .grinder && $0.isPrimary }
        }
    }
}

#Preview {
    NewBrewView()
        .modelContainer(for: [Brew.self, Bean.self, UserProfile.self, Equipment.self])
}
