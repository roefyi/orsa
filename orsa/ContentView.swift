//
//  ContentView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \UserProfile.name) private var userProfiles: [UserProfile]
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @Environment(\.modelContext) private var modelContext
    
    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // system
        }
    }
    
    var body: some View {
        Group {
            if onboardingCompleted || (userProfiles.first?.onboardingCompleted ?? false) {
                MainTabView()
            } else {
                OnboardingView(onComplete: {
                    onboardingCompleted = true
                })
            }
        }
        .preferredColorScheme(colorScheme)
        .onAppear {
            // Sync AppStorage with SwiftData on appear
            if let profile = userProfiles.first, profile.onboardingCompleted {
                onboardingCompleted = true
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
