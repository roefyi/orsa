//
//  ContentView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var userProfiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    
    var isOnboardingComplete: Bool {
        userProfiles.first?.onboardingCompleted ?? false
    }
    
    var body: some View {
        Group {
            if isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
