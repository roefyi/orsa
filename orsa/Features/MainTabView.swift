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
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
