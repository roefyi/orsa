//
//  MainTabView.swift
//  orsa
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
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
            .tint(.primary)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
}
