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
    
    @State private var brewTime: Double
    @State private var yield: Double
    @State private var notes: String
    @State private var selectedRating: Int?
    @State private var temperature: String
    @State private var grindSetting: String
    @State private var selectedBean: Bean?
    @State private var selectedMachine: Equipment?
    @State private var selectedGrinder: Equipment?
    @State private var drinkType: String
    @State private var milkType: String
    @State private var dose: Double
    @State private var showingEditParameters = false
    @State private var longPressJustCompleted = false
    @State private var showingShareCard = false
    
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"
    
    init(brew: Brew) {
        self.brew = brew
        
        // Initialize all state from the brew object
        _brewTime = State(initialValue: Double(brew.brewTime.replacingOccurrences(of: "s", with: "")) ?? 30.0)
        _yield = State(initialValue: brew.yield)
        _notes = State(initialValue: brew.notes ?? "")
        _selectedRating = State(initialValue: brew.rating)
        _temperature = State(initialValue: brew.temperature > 0 ? String(Int(brew.temperature)) : "")
        _grindSetting = State(initialValue: brew.grindSetting)
        _drinkType = State(initialValue: brew.drinkType)
        _milkType = State(initialValue: brew.milkType ?? "None")
        _dose = State(initialValue: brew.dose)
    }
    
    var userName: String {
        userProfiles.first?.name ?? ""
    }
    
    var descriptionText: String {
        let coffeeName = selectedBean?.coffeeName ?? "coffee"
        let roasterName = selectedBean?.roaster ?? ""
        let drinkTypeLower = drinkType.lowercased()
        if !roasterName.isEmpty {
            return "\(userName) is making a \(drinkTypeLower) with \(coffeeName) by \(roasterName)"
        } else {
            return "\(userName) is making a \(drinkTypeLower) with \(coffeeName)"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Description text left-aligned with title styling
                    Text(descriptionText)
                        .font(.oscineTitle)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        // Brew Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("brew details")
                                .font(.oscineHeadline)
                                .foregroundColor(.primary)
                                .textCase(.lowercase)
                            
                            // Time Slider
                            CustomSlider(
                                title: "Time",
                                value: $brewTime,
                                in: 15...75,
                                step: 1,
                                suffix: "s"
                            )
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            // Yield Slider
                            CustomSlider(
                                title: "Yield",
                                value: $yield,
                                in: 10...110,
                                step: 1,
                                suffix: yieldUnit == "ml" ? "ml" : "g"
                            )
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        
                        // Rating Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("rating")
                                .font(.oscineHeadline)
                                .foregroundColor(.primary)
                                .textCase(.lowercase)
                            
                            HStack(spacing: 12) {
                                // Thumbs down
                                Group {
                                    if selectedRating == 1 {
                                        Text("👎")
                                            .font(.system(size: 24))
                                    } else {
                                        Image(systemName: "hand.thumbsdown")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !longPressJustCompleted && selectedRating != 1 {
                                        HapticFeedback.light()
                                        selectedRating = 1
                                    }
                                    longPressJustCompleted = false
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    if selectedRating == 1 {
                                        longPressJustCompleted = true
                                        HapticFeedback.medium()
                                        selectedRating = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            longPressJustCompleted = false
                                        }
                                    }
                                }
                                
                                // Neutral face
                                Group {
                                    if selectedRating == 3 {
                                        Text("😐")
                                            .font(.system(size: 24))
                                    } else {
                                        // Create a simple neutral face outline matching other icons
                                        ZStack {
                                            Circle()
                                                .stroke(Color.secondary, lineWidth: 2)
                                                .frame(width: 20, height: 20)
                                            // Eyes - using primary with opacity to match stroke weight
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color.primary.opacity(0.6))
                                                    .frame(width: 2.5, height: 2.5)
                                                Circle()
                                                    .fill(Color.primary.opacity(0.6))
                                                    .frame(width: 2.5, height: 2.5)
                                            }
                                            .offset(y: -2)
                                            // Mouth (straight line) - using primary with opacity to match stroke weight
                                            Rectangle()
                                                .fill(Color.primary.opacity(0.6))
                                                .frame(width: 8, height: 2)
                                                .offset(y: 4)
                                        }
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !longPressJustCompleted && selectedRating != 3 {
                                        HapticFeedback.light()
                                        selectedRating = 3
                                    }
                                    longPressJustCompleted = false
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    if selectedRating == 3 {
                                        longPressJustCompleted = true
                                        HapticFeedback.medium()
                                        selectedRating = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            longPressJustCompleted = false
                                        }
                                    }
                                }
                                
                                // Thumbs up
                                Group {
                                    if selectedRating == 4 {
                                        Text("👍")
                                            .font(.system(size: 24))
                                    } else {
                                        Image(systemName: "hand.thumbsup")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !longPressJustCompleted && selectedRating != 4 {
                                        HapticFeedback.light()
                                        selectedRating = 4
                                    }
                                    longPressJustCompleted = false
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    if selectedRating == 4 {
                                        longPressJustCompleted = true
                                        HapticFeedback.medium()
                                        selectedRating = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            longPressJustCompleted = false
                                        }
                                    }
                                }
                                
                                // Heart
                                Group {
                                    if selectedRating == 5 {
                                        Text("❤️")
                                            .font(.system(size: 24))
                                    } else {
                                        Image(systemName: "heart")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !longPressJustCompleted && selectedRating != 5 {
                                        HapticFeedback.light()
                                        selectedRating = 5
                                    }
                                    longPressJustCompleted = false
                                }
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    if selectedRating == 5 {
                                        longPressJustCompleted = true
                                        HapticFeedback.medium()
                                        selectedRating = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            longPressJustCompleted = false
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("notes")
                                .font(.oscineHeadline)
                                .foregroundColor(.primary)
                                .textCase(.lowercase)
                            
                            TextField("Notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundColor(.primary)
                                .textInputAutocapitalization(.sentences)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
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
                                Text("share")
                                    .font(.oscineHeadline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.appBackground.ignoresSafeArea())
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditParameters = true
                    }
                    .font(.oscineHeadline)
                    .foregroundColor(.primary)
                }
            }
            .onAppear {
                // Load bean and equipment references from queries
                selectedBean = beans.first { $0.id == brew.beanID }
                selectedMachine = equipment.first { $0.id == brew.machineID }
                selectedGrinder = equipment.first { $0.id == brew.grinderID }
            }
            .fullScreenCover(isPresented: $showingEditParameters) {
                EditBrewParametersView(
                    selectedBean: $selectedBean,
                    selectedMachine: $selectedMachine,
                    selectedGrinder: $selectedGrinder,
                    temperature: $temperature,
                    grindSetting: $grindSetting,
                    drinkType: $drinkType,
                    milkType: $milkType,
                    dose: $dose
                )
            }
            .fullScreenCover(isPresented: $showingShareCard) {
                BrewShareCardView(brew: brew)
            }
        }
    }
    
    private func saveBrew() {
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
        brew.rating = selectedRating
        brew.notes = notes.isEmpty ? nil : notes
        brew.method = drinkType.lowercased()
        
        do {
            try modelContext.save()
        } catch {
            print("Error updating brew: \(error)")
        }
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
