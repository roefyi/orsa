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
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var machineName = ""
    @State private var grinderName = ""
    @State private var defaultDose = "18.0"
    
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
        let profile = UserProfile(
            name: userName,
            defaultDose: Double(defaultDose) ?? 18.0
        )
        profile.onboardingCompleted = true
        
        // Add equipment
        if !machineName.isEmpty {
            let machine = Equipment(
                type: EquipmentType.machine.rawValue,
                brand: machineName,
                model: "",
                isPrimary: true
            )
            modelContext.insert(machine)
        }
        
        if !grinderName.isEmpty {
            let grinder = Equipment(
                type: EquipmentType.grinder.rawValue,
                brand: grinderName,
                model: "",
                isPrimary: true
            )
            modelContext.insert(grinder)
        }
        
        modelContext.insert(profile)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving onboarding data: \(error)")
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [UserProfile.self, Equipment.self])
}
