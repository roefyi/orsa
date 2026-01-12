//
//  OnboardingView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var existingProfiles: [UserProfile]
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    let onComplete: (() -> Void)?
    
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var machineName = ""
    @State private var grinderName = ""
    @State private var defaultDose = "18.0"
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            switch currentStep {
            case 0:
                OnboardingIntroView(onNext: { currentStep = 1 })
            case 1:
                OnboardingNameView(
                    userName: $userName,
                    onNext: { currentStep = 2 }
                )
            case 2:
                OnboardingSetupView(
                    machineName: $machineName,
                    grinderName: $grinderName,
                    userName: userName,
                    onNext: { currentStep = 3 }
                )
            case 3:
                OnboardingDoseView(
                    defaultDose: $defaultDose,
                    onComplete: completeOnboarding
                )
            default:
                OnboardingIntroView(onNext: { currentStep = 1 })
            }
        }
    }
    
    private func completeOnboarding() {
        // Add equipment first
        if !machineName.isEmpty {
            let machine = Equipment(
                id: UUID(),
                type: EquipmentType.machine.rawValue,
                brand: machineName,
                model: "",
                isPrimary: true
            )
            modelContext.insert(machine)
            print("Inserted machine: \(machineName) with id: \(machine.id)")
        }
        
        if !grinderName.isEmpty {
            let grinder = Equipment(
                id: UUID(),
                type: EquipmentType.grinder.rawValue,
                brand: grinderName,
                model: "",
                isPrimary: true
            )
            modelContext.insert(grinder)
            print("Inserted grinder: \(grinderName) with id: \(grinder.id)")
        }
        
        // Get or create user profile
        let profile: UserProfile
        if let existingProfile = existingProfiles.first {
            profile = existingProfile
            profile.name = userName
            profile.defaultDose = Double(defaultDose) ?? 18.0
        } else {
            profile = UserProfile(
                name: userName,
                defaultDose: Double(defaultDose) ?? 18.0
            )
            modelContext.insert(profile)
        }
        
        profile.onboardingCompleted = true
        
        // Save everything together
        do {
            try modelContext.save()
            print("Successfully saved onboarding data - profile and equipment")
            
            // Verify equipment was saved by fetching it
            let descriptor = FetchDescriptor<Equipment>()
            let savedEquipment = try? modelContext.fetch(descriptor)
            print("Total equipment in database: \(savedEquipment?.count ?? 0)")
            savedEquipment?.forEach { eq in
                print("  - \(eq.displayName) (\(eq.type))")
            }
            
            // Update AppStorage immediately
            onboardingCompleted = true
            // Call completion handler if provided
            onComplete?()
        } catch {
            print("Error saving onboarding data: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
    }
}

#Preview {
    OnboardingView(onComplete: nil)
        .modelContainer(for: [UserProfile.self, Equipment.self])
}
