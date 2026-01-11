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
    
    @State private var brewTime: Double = 30.0 // seconds, default 30
    @State private var yield: Double = 36.0 // grams, default 36
    @State private var notes = ""
    @State private var selectedRating: Int? = nil
    @State private var temperature = ""
    @State private var grindSetting = ""
    
    // This will be auto-populated based on last brew
    @State private var selectedBean: Bean?
    @State private var drinkType = "Espresso"
    @State private var dose: Double = 18.0
    
    var userName: String {
        userProfiles.first?.name ?? ""
    }
    
    var descriptionText: String {
        let coffeeName = selectedBean?.coffeeName ?? "coffee"
        let roasterName = selectedBean?.roaster ?? ""
        if !roasterName.isEmpty {
            return "\(userName) is making a \(drinkType) with \(coffeeName) by \(roasterName)"
        } else {
            return "\(userName) is making a \(drinkType) with \(coffeeName)"
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
                            HStack(spacing: 16) {
                                Text("Time")
                                    .font(.oscineBody)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                Slider(value: $brewTime, in: 15...75, step: 1)
                                    .tint(.accent)
                                
                                Text("\(Int(brewTime))s")
                                    .font(.oscineBody)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(8)
                            
                            // Yield Slider
                            HStack(spacing: 16) {
                                Text("Yield")
                                    .font(.oscineBody)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                Slider(value: $yield, in: 10...110, step: 1)
                                    .tint(.accent)
                                
                                Text("\(Int(yield))g")
                                    .font(.oscineBody)
                                    .foregroundColor(.primaryText)
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(8)
                        }
                        
                        // Rating Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("rating")
                                .font(.oscineHeadline)
                                .foregroundColor(.primaryText)
                                .textCase(.lowercase)
                            
                            HStack(spacing: 20) {
                                // Thumbs down
                                Button {
                                    selectedRating = selectedRating == 1 ? nil : 1
                                } label: {
                                    Image(systemName: selectedRating == 1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                        .font(.oscineTitle2)
                                        .foregroundColor(selectedRating == 1 ? .red : .gray)
                                }
                                
                                // Neutral face
                                Button {
                                    selectedRating = selectedRating == 3 ? nil : 3
                                } label: {
                                    Image(systemName: selectedRating == 3 ? "face.neutral.fill" : "face.neutral")
                                        .font(.oscineTitle2)
                                        .foregroundColor(selectedRating == 3 ? .yellow : .gray)
                                }
                                
                                // Thumbs up
                                Button {
                                    selectedRating = selectedRating == 4 ? nil : 4
                                } label: {
                                    Image(systemName: selectedRating == 4 ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .font(.oscineTitle2)
                                        .foregroundColor(selectedRating == 4 ? .green : .gray)
                                }
                                
                                // Heart
                                Button {
                                    selectedRating = selectedRating == 5 ? nil : 5
                                } label: {
                                    Image(systemName: selectedRating == 5 ? "heart.fill" : "heart")
                                        .font(.oscineTitle2)
                                        .foregroundColor(selectedRating == 5 ? .red : .gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(8)
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
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("new brew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Edit parameters
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .foregroundColor(.primaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        saveBrew()
                        dismiss()
                    }
                    .disabled(false) // Sliders always have values, so always enabled
                    .tint(.accent)
                    .font(.oscineHeadline)
                }
            }
            .onAppear {
                setupAutoPopulation()
            }
        }
    }
    
    private func setupAutoPopulation() {
        // Get default dose from user profile
        if let profile = userProfiles.first {
            dose = profile.defaultDose
        }
        
        // Get current beans
        selectedBean = beans.first { $0.status == BeanStatus.current.rawValue }
        
        // TODO: Get last brew parameters and auto-populate
    }
    
    private func saveBrew() {
        let brew = Brew(
            beanID: selectedBean?.id,
            drinkType: drinkType,
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

#Preview {
    NewBrewView()
        .modelContainer(for: [Brew.self, Bean.self, UserProfile.self, Equipment.self])
}
