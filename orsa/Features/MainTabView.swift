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
        ZStack {
            // Base background layer that materials will blur
            Color.appBackground
                .ignoresSafeArea(.all)
            
            TabView {
                BrewsView()
                    .tabItem {
                        Label("Brews", systemImage: "cup.and.saucer")
                    }
                
                BeansView()
                    .tabItem {
                        Label {
                            Text("Beans")
                        } icon: {
                            Image("BeansIcon")
                                .renderingMode(.template)
                        }
                    }
                
                ToolsView()
                    .tabItem {
                        Label("Tools", systemImage: "list.bullet")
                    }
            }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
