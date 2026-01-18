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
        
        let yellowAccentColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0) // Bright yellow for dark mode
            default:
                return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Bright yellow for light mode
            }
        }
        
        let standardAccentColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white // White for dark mode
            default:
                return UIColor.systemBlue // Blue for light mode (standard iOS)
            }
        }
        
        // Configure navigation bar appearance with custom font
        // Ensure Oscine font is used for navigation titles
        let largeTitleFont = UIFont(name: "OscineTrial-XBold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        let titleFont = UIFont(name: "OscineTrial-XBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        
        // Navigation bar appearance - use OpaqueBackground for proper material blur per HIG
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground() // Proper material effect with blur
        navAppearance.backgroundColor = .clear // Let material show through
        navAppearance.shadowColor = .clear // No separator line
        navAppearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor.label
        ]
        navAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        
        // Apply to all navigation bar states
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navAppearance
        
        // Tab bar appearance - use OpaqueBackground for proper material blur per HIG
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground() // Proper material effect with blur
        tabBarAppearance.backgroundColor = .clear // Let material show through
        tabBarAppearance.shadowColor = .clear // No separator line
        
        // Configure stacked layout (iPhone portrait)
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        // Configure inline layout (iPhone landscape)
        tabBarAppearance.inlineLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        tabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        tabBarAppearance.inlineLayoutAppearance.selected.iconColor = UIColor.label
        tabBarAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        // Configure compact inline layout (iPad)
        tabBarAppearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        tabBarAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]
        tabBarAppearance.compactInlineLayoutAppearance.selected.iconColor = UIColor.label
        tabBarAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        // Apply to all tab bar states
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel
        UITabBar.appearance().tintColor = UIColor.label
        
        // Configure button/control tint color globally - use standard colors for action sheets
        UIButton.appearance().tintColor = standardAccentColor
        UIBarButtonItem.appearance().tintColor = standardAccentColor
        
        // Configure slider appearance
        let sliderTrackColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(white: 0.3, alpha: 1.0) // Darker track for dark mode
            default:
                return UIColor(white: 0.9, alpha: 1.0) // Light gray track for light mode
            }
        }
        UISlider.appearance().minimumTrackTintColor = yellowAccentColor // Filled portion (left of thumb)
        UISlider.appearance().maximumTrackTintColor = sliderTrackColor // Unfilled portion (right of thumb)
        UISlider.appearance().thumbTintColor = yellowAccentColor // Thumb color
        
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
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = standardAccentColor.withAlphaComponent(0.6)
        
        // Configure text field text color and cursor in forms
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = standardAccentColor
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = yellowAccentColor // Yellow cursor
        
        // Configure text field cursor globally (including action sheets and pickers)
        UITextField.appearance().tintColor = yellowAccentColor // Yellow cursor everywhere
        
        // Configure date pickers to use yellow - multiple properties for full coverage
        UIDatePicker.appearance().tintColor = yellowAccentColor
        
        // Configure date picker internal components (month/year text, navigation arrows)
        // This affects the inline calendar style used in Forms
        if #available(iOS 14.0, *) {
            UIDatePicker.appearance().backgroundColor = .clear
            // Set tint for all subviews of date picker
            UIView.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = yellowAccentColor
        }
        
        // Configure navigation bar buttons within date picker
        UIButton.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = yellowAccentColor
        
        // Configure toggles/switches to use yellow
        UISwitch.appearance().onTintColor = yellowAccentColor
        
        // Configure segmented control to use yellow
        UISegmentedControl.appearance().selectedSegmentTintColor = yellowAccentColor
        
        // Configure page control to use yellow
        UIPageControl.appearance().currentPageIndicatorTintColor = yellowAccentColor
        
        // Configure stepper to use yellow
        UIStepper.appearance().tintColor = yellowAccentColor
        
        // Configure label text color in table view cells
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = standardAccentColor
        
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
