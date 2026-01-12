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
    @Environment(\.modelContext) private var modelContext
    
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
