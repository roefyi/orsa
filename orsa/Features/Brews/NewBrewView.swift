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
    @State private var yield: Double = 36.0 // grams, default 36
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
                                suffix: "g"
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
                                Button {
                                    selectedRating = selectedRating == 1 ? nil : 1
                                } label: {
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
                                }
                                
                                // Neutral face
                                Button {
                                    selectedRating = selectedRating == 3 ? nil : 3
                                } label: {
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
                                }
                                
                                // Thumbs up
                                Button {
                                    selectedRating = selectedRating == 4 ? nil : 4
                                } label: {
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
                                }
                                
                                // Heart
                                Button {
                                    selectedRating = selectedRating == 5 ? nil : 5
                                } label: {
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
                                saveBrew()
                                dismiss()
                            } label: {
                                Text("home")
                                    .font(.oscineHeadline)
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.buttonYellow)
                                    .cornerRadius(12)
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
        }
    }
    
    private func saveBrew() {
        if let brew = existingBrew {
            // Update existing brew
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
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving brew: \(error)")
        }
    }
}

#Preview {
    NewBrewView()
        .modelContainer(for: [Brew.self, Bean.self, UserProfile.self, Equipment.self])
}
