//
//  orsaApp.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData

@main
struct orsaApp: App {
    init() {
        // Configure navigation bar appearance to use Oscine font and app background color
        let appBackgroundColor = UIColor(red: 200/255, green: 193/255, blue: 189/255, alpha: 1.0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = appBackgroundColor
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        let textColor = UIColor(red: 57/255, green: 54/255, blue: 46/255, alpha: 1.0)
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "OscineTrial-XBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: textColor
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "OscineTrial-XBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: textColor
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().backgroundColor = appBackgroundColor
        UINavigationBar.appearance().shadowImage = UIImage()
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = appBackgroundColor
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.shadowImage = UIImage()
        
        let accentColor = UIColor(red: 57/255, green: 54/255, blue: 46/255, alpha: 1.0)
        let accentDarkColor = UIColor(red: 35/255, green: 33/255, blue: 28/255, alpha: 1.0)
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = accentColor.withAlphaComponent(0.6)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: accentColor.withAlphaComponent(0.6)
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = accentDarkColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accentDarkColor
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().backgroundColor = appBackgroundColor
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().unselectedItemTintColor = accentColor.withAlphaComponent(0.6)
        UITabBar.appearance().tintColor = accentDarkColor
        
        // Configure button/control tint color globally
        UIButton.appearance().tintColor = accentColor
        UIBarButtonItem.appearance().tintColor = accentColor
        
        #if DEBUG
        FontBundleChecker.checkFontsInBundle()
        FontDebugHelper.listAllOscineFonts()
        FontDebugHelper.testFontNames()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [UserProfile.self, Equipment.self, Bean.self, Brew.self])
        }
    }
}
