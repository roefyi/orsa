//
//  NewBrewView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct NewBrewView: View {
    let existingBrew: Brew?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var userProfiles: [UserProfile]
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    @Query(sort: \Brew.timestamp, order: .reverse) private var brews: [Brew]
    
    @State private var brewTime: Double = 30.0 // seconds, default 30
    @State private var yield: Double = 36.0 // grams or ml, default 36
    @State private var notes = ""
    @State private var selectedRating: Int? = nil
    @State private var temperature = ""
    @State private var grindSetting = ""
    
    // This will be auto-populated based on last brew
    @State private var selectedBean: Bean?
    @State private var selectedMachine: Equipment?
    @State private var selectedGrinder: Equipment?
    @State private var drinkType = "Single Shot"
    @State private var milkType = "None"
    @State private var dose: Double = 18.0
    @State private var showingEditParameters = false
    @State private var longPressJustCompleted = false
    @State private var showingShareCard = false
    @State private var shareBrew: Brew?
    @State private var savedBrewForShare: Brew?
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"
    
    init(existingBrew: Brew? = nil) {
        self.existingBrew = existingBrew
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
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        // Brew Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("brew details")
                                .font(.oscineHeadline)
                                .foregroundColor(.primaryText)
                                .textCase(.lowercase)
                            
                            // Time Slider
                            CustomSlider(
                                title: "Time",
                                value: $brewTime,
                                in: 15...75,
                                step: 1,
                                suffix: "s"
                            )
                            .background(Color.cardBackground)
                            .cornerRadius(8)
                            
                            // Yield Slider
                            CustomSlider(
                                title: "Yield",
                                value: $yield,
                                in: 10...110,
                                step: 1,
                                suffix: yieldUnit == "ml" ? "ml" : "g"
                            )
                            .background(Color.cardBackground)
                            .cornerRadius(8)
                        }
                        
                        // Rating Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("rating")
                                .font(.oscineHeadline)
                                .foregroundColor(.primaryText)
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
                                            .foregroundColor(.cardText.opacity(0.8))
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
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
                                        // Reset flag after a short delay to allow tap gestures to work again
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
                                        // Create a simple neutral face outline
                                        ZStack {
                                            Circle()
                                                .stroke(Color.cardText.opacity(0.8), lineWidth: 2)
                                                .frame(width: 20, height: 20)
                                            // Eyes
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color.cardText.opacity(0.8))
                                                    .frame(width: 2, height: 2)
                                                Circle()
                                                    .fill(Color.cardText.opacity(0.8))
                                                    .frame(width: 2, height: 2)
                                            }
                                            .offset(y: -2)
                                            // Mouth (straight line)
                                            Rectangle()
                                                .fill(Color.cardText.opacity(0.8))
                                                .frame(width: 8, height: 1.5)
                                                .offset(y: 4)
                                        }
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
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
                                            .foregroundColor(.cardText.opacity(0.8))
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
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
                                            .foregroundColor(.cardText.opacity(0.8))
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
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
                                .foregroundColor(.primaryText)
                                .textCase(.lowercase)
                            
                            TextField("Notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.cardBackground)
                                .foregroundColor(.cardText)
                                .cornerRadius(8)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Home button (primary) - submits and saves
                            Button {
                                HapticFeedback.medium()
                                // Only save if not already saved for sharing
                                if savedBrewForShare == nil {
                                    saveBrew()
                                } else {
                                    // Update the already-saved brew
                                    if let brew = savedBrewForShare {
                                        updateBrew(brew)
                                    }
                                }
                                dismiss()
                            } label: {
                                Text("home")
                                    .font(.oscineHeadline)
                                    .foregroundColor(.buttonText)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.buttonYellow)
                                    .cornerRadius(12)
                            }
                            
                            // Share button (secondary) - always visible
                            Button {
                                HapticFeedback.light()
                                if let brew = existingBrew {
                                    // Use existing brew
                                    shareBrew = brew
                                    showingShareCard = true
                                } else if let brew = savedBrewForShare {
                                    // Use already-saved brew
                                    updateBrew(brew)
                                    shareBrew = brew
                                    showingShareCard = true
                                } else {
                                    // Save new brew first, then share
                                    let newBrew = Brew(
                                        beanID: selectedBean?.id,
                                        machineID: selectedMachine?.id,
                                        grinderID: selectedGrinder?.id,
                                        drinkType: drinkType,
                                        milkType: milkType == "None" ? nil : milkType,
                                        dose: dose,
                                        grindSetting: grindSetting,
                                        temperature: Double(temperature) ?? 0,
                                        brewTime: "\(Int(brewTime))s",
                                        yield: yield,
                                        rating: selectedRating,
                                        notes: notes.isEmpty ? nil : notes,
                                        method: drinkType.lowercased()
                                    )
                                    modelContext.insert(newBrew)
                                    do {
                                        try modelContext.save()
                                        savedBrewForShare = newBrew
                                        shareBrew = newBrew
                                        showingShareCard = true
                                    } catch {
                                        print("Error saving brew for share: \(error)")
                                    }
                                }
                            } label: {
                                Text("share")
                                    .font(.oscineHeadline)
                                    .foregroundColor(.primaryText)
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
            .background(Color.appBackground)
            .navigationTitle(existingBrew != nil ? "brew details" : "new brew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditParameters = true
                    }
                    .tint(.accent)
                    .font(.oscineHeadline)
                }
            }
            .onAppear {
                setupAutoPopulation()
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
                if let brew = shareBrew {
                    BrewShareCardView(brew: brew)
                }
            }
        }
    }
    
    private func setupAutoPopulation() {
        if let brew = existingBrew {
            // Load existing brew data for editing
            brewTime = Double(brew.brewTime.replacingOccurrences(of: "s", with: "")) ?? 30.0
            yield = brew.yield
            notes = brew.notes ?? ""
            selectedRating = brew.rating
            temperature = brew.temperature > 0 ? String(brew.temperature) : ""
            grindSetting = brew.grindSetting
            drinkType = brew.drinkType
            milkType = brew.milkType ?? "None"
            dose = brew.dose
            selectedBean = beans.first { $0.id == brew.beanID }
            selectedMachine = equipment.first { $0.id == brew.machineID }
            selectedGrinder = equipment.first { $0.id == brew.grinderID }
        } else {
            // Get default dose from user profile
            if let profile = userProfiles.first {
                dose = profile.defaultDose
            }
            
            // Get current beans
            selectedBean = beans.first { $0.status == BeanStatus.current.rawValue }
            
            // Load last brew's parameters (drink type, temperature, grind setting)
            if let lastBrew = brews.first {
                // Always use last brew's drink type, temperature, and grind setting
                drinkType = lastBrew.drinkType.isEmpty ? "Single Shot" : lastBrew.drinkType
                temperature = lastBrew.temperature > 0 ? String(Int(lastBrew.temperature)) : ""
                grindSetting = lastBrew.grindSetting.isEmpty ? "" : lastBrew.grindSetting
                milkType = lastBrew.milkType ?? "None"
                
                // Also load equipment and dose from last brew
                if lastBrew.machineID != nil {
                    selectedMachine = equipment.first { $0.id == lastBrew.machineID }
                } else {
                    // Fallback to primary machine if last brew had none
                    selectedMachine = equipment.first { $0.equipmentType == .machine && $0.isPrimary }
                }
                
                if lastBrew.grinderID != nil {
                    selectedGrinder = equipment.first { $0.id == lastBrew.grinderID }
                } else {
                    // Fallback to primary grinder if last brew had none
                    selectedGrinder = equipment.first { $0.equipmentType == .grinder && $0.isPrimary }
                }
                
                if lastBrew.dose > 0 {
                    dose = lastBrew.dose
                }
            } else {
                // No previous brews - use defaults
                drinkType = "Single Shot"
                milkType = "None"
                
                // Use primary equipment
                selectedMachine = equipment.first { $0.equipmentType == .machine && $0.isPrimary }
                selectedGrinder = equipment.first { $0.equipmentType == .grinder && $0.isPrimary }
            }
        }
    }
    
    private func updateBrew(_ brew: Brew) {
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
    
    private func saveBrew() {
        if let brew = existingBrew {
            // Update existing brew
            updateBrew(brew)
        } else {
            // Create new brew
            let brew = Brew(
                beanID: selectedBean?.id,
                machineID: selectedMachine?.id,
                grinderID: selectedGrinder?.id,
                drinkType: drinkType,
                milkType: milkType == "None" ? nil : milkType,
                dose: dose,
                grindSetting: grindSetting,
                temperature: Double(temperature) ?? 0,
                brewTime: "\(Int(brewTime))s",
                yield: yield,
                rating: selectedRating,
                notes: notes.isEmpty ? nil : notes,
                method: drinkType.lowercased()
            )
            modelContext.insert(brew)
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving brew: \(error)")
            }
        }
    }
}

#Preview {
    NewBrewView()
        .modelContainer(for: [Brew.self, Bean.self, UserProfile.self, Equipment.self])
}
