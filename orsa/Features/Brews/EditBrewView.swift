//
//  EditBrewView.swift
//  orsa
//
//  Created by Rome on 1/15/26.
//

import SwiftUI
import SwiftData

struct EditBrewView: View {
    let brew: Brew

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var userProfiles: [UserProfile]
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]

    @State private var draft: BrewDraft
    @State private var showingShareCard = false

    init(brew: Brew) {
        self.brew = brew
        _draft = State(initialValue: BrewDraft(from: brew))
    }

    var userName: String {
        userProfiles.first?.name ?? ""
    }

    var body: some View {
        NavigationStack {
            BrewEditorForm(draft: $draft, userName: userName) {
                // Save button (primary)
                Button {
                    HapticFeedback.medium()
                    saveBrew()
                    dismiss()
                } label: {
                    Text("save")
                        .font(.oscineHeadline)
                        .foregroundColor(.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.buttonYellow)
                        .cornerRadius(12)
                }

                // Share button (secondary)
                Button {
                    HapticFeedback.light()
                    saveBrew()
                    showingShareCard = true
                } label: {
                    Image(systemName: BrewActionIcon.share)
                        .font(BrewActionIcon.font)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationTitle("brew details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
            .onAppear {
                draft.resolveReferences(from: brew, beans: beans, equipment: equipment)
            }
            .fullScreenCover(isPresented: $showingShareCard) {
                BrewShareCardView(brew: brew)
            }
        }
    }

    private func saveBrew() {
        draft.apply(to: brew)
        modelContext.saveOrLog("edit brew")
    }
}

#Preview {
    let brew = Brew(
        drinkType: "Cortado",
        dose: 18.0,
        grindSetting: "3.5",
        temperature: 200.0,
        brewTime: "28s",
        yield: 36.0
    )
    return EditBrewView(brew: brew)
        .modelContainer(for: [Brew.self, Bean.self, Equipment.self, UserProfile.self])
}
