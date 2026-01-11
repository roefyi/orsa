//
//  MainTabView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Query private var userProfiles: [UserProfile]
    
    var body: some View {
        TabView {
            BrewsView()
                .tabItem {
                    Label("Brews", systemImage: "cup.and.saucer")
                }
            
            BeansView()
                .tabItem {
                    Label("Beans", systemImage: "leaf")
                }
            
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
