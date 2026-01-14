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
        // Configure navigation bar appearance with clean white background
        let appBackgroundColor = UIColor.white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = appBackgroundColor
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        let textColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
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
        
        let accentColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        let accentDarkColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = accentColor.withAlphaComponent(0.5)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: accentColor.withAlphaComponent(0.5)
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = accentDarkColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accentDarkColor
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().backgroundColor = appBackgroundColor
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().unselectedItemTintColor = accentColor.withAlphaComponent(0.5)
        UITabBar.appearance().tintColor = accentDarkColor
        
        // Configure button/control tint color globally
        UIButton.appearance().tintColor = accentColor
        UIBarButtonItem.appearance().tintColor = accentColor
        
        // Configure slider appearance
        let sliderTrackColor = UIColor(white: 0.9, alpha: 1.0) // Light gray track
        UISlider.appearance().minimumTrackTintColor = accentColor // Filled portion (left of thumb)
        UISlider.appearance().maximumTrackTintColor = sliderTrackColor // Unfilled portion (right of thumb)
        UISlider.appearance().thumbTintColor = accentColor // Thumb color
        
        // Configure Form appearance
        let cardBackgroundUIColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        UITableView.appearance().backgroundColor = appBackgroundColor
        UITableViewCell.appearance().backgroundColor = cardBackgroundUIColor
        
        // Configure section header text color
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = accentColor.withAlphaComponent(0.6)
        
        // Configure text field text color in forms
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = accentColor
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = accentColor
        
        // Configure label text color in table view cells
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = accentColor
        
        #if DEBUG
        FontBundleChecker.checkFontsInBundle()
        FontDebugHelper.listAllOscineFonts()
        FontDebugHelper.testFontNames()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(createModelContainer())
        }
    }
    
    private func createModelContainer() -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            Equipment.self,
            Bean.self,
            Brew.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, try to delete the database and create a fresh one
            print("⚠️ Migration failed: \(error.localizedDescription)")
            print("Attempting to reset database...")
            
            // Get the default database URL
            let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let databaseURL = url.appendingPathComponent("default.store")
            
            // Try to delete the corrupted database
            if FileManager.default.fileExists(atPath: databaseURL.path) {
                do {
                    try FileManager.default.removeItem(at: databaseURL)
                    print("✓ Deleted corrupted database")
                } catch {
                    print("✗ Could not delete database: \(error.localizedDescription)")
                }
            }
            
            // Try creating a fresh container
            do {
                let freshContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✓ Created fresh database")
                return freshContainer
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }
}
