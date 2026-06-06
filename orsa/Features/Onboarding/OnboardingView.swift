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
    @State private var defaultDose = ""
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    private static let screenTransition = Animation.smooth(duration: 0.6)
    
    var body: some View {
        ZStack {
            if currentStep == 0 {
                OnboardingIntroView(
                    onNext: {
                        withAnimation(Self.screenTransition) {
                            currentStep = 1
                        }
                    },
                    onSkip: completeOnboarding
                )
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                        removal: .opacity.combined(with: .offset(x: -24))
                    )
                )
            } else {
                OnboardingQuestionsView(
                    userName: $userName,
                    machineName: $machineName,
                    grinderName: $grinderName,
                    defaultDose: $defaultDose,
                    onComplete: completeOnboarding,
                    onSkip: completeOnboarding,
                    onBackToIntro: {
                        withAnimation(Self.screenTransition) {
                            currentStep = 0
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                        removal: .opacity.combined(with: .offset(x: 24))
                    )
                )
            }
        }
        .animation(Self.screenTransition, value: currentStep)
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
            
            // Update AppStorage immediately
            onboardingCompleted = true
            // Call completion handler if provided
            onComplete?()
        } catch {
            print("Error saving onboarding data: \(error)")
        }
    }
}

#Preview {
    OnboardingView(onComplete: nil)
        .modelContainer(for: [UserProfile.self, Equipment.self])
}
