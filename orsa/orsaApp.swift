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
        // Configure adaptive colors
        let appBackgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0) // Dark grey for dark mode
            default:
                return UIColor.white // White for light mode
            }
        }
        
        let accentColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white // White for dark mode
            default:
                return UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0) // Dark for light mode
            }
        }
        
        // Configure navigation bar appearance with custom font
        // Ensure Oscine font is used for navigation titles
        let largeTitleFont = UIFont(name: "OscineTrial-XBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        let titleFont = UIFont(name: "OscineTrial-XBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        
        // Standard appearance (when scrolled)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor.label
        ]
        standardAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        
        // Scroll edge appearance (at top, large title visible)
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithDefaultBackground()
        scrollEdgeAppearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor.label
        ]
        scrollEdgeAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
        UINavigationBar.appearance().isTranslucent = true
        
        // Configure tab bar appearance - transparent to allow SwiftUI materials
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = .clear
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.shadowImage = UIImage()
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel
        UITabBar.appearance().tintColor = UIColor.label
        
        // Configure button/control tint color globally
        UIButton.appearance().tintColor = accentColor
        UIBarButtonItem.appearance().tintColor = accentColor
        
        // Configure slider appearance
        let sliderTrackColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(white: 0.3, alpha: 1.0) // Darker track for dark mode
            default:
                return UIColor(white: 0.9, alpha: 1.0) // Light gray track for light mode
            }
        }
        UISlider.appearance().minimumTrackTintColor = accentColor // Filled portion (left of thumb)
        UISlider.appearance().maximumTrackTintColor = sliderTrackColor // Unfilled portion (right of thumb)
        UISlider.appearance().thumbTintColor = accentColor // Thumb color
        
        // Configure Form appearance
        let cardBackgroundUIColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0) // Dark grey cards for dark mode
            default:
                return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0) // Light grey cards for light mode
            }
        }
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
