//
//  DataService.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import Foundation
import SwiftData

@MainActor
class DataService: ObservableObject {
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Brew.self,
            Bean.self,
            Equipment.self,
            UserProfile.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - User Profile
    
    func getOrCreateUserProfile() -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        
        if let profile = try? context.fetch(descriptor).first {
            return profile
        }
        
        let profile = UserProfile()
        context.insert(profile)
        save()
        return profile
    }
    
    // MARK: - Equipment
    
    func getAllEquipment() -> [Equipment] {
        let descriptor = FetchDescriptor<Equipment>()
        let allEquipment = (try? context.fetch(descriptor)) ?? []
        return allEquipment.sorted { first, second in
            if first.isPrimary != second.isPrimary {
                return first.isPrimary
            }
            return first.dateAdded > second.dateAdded
        }
    }
    
    func getPrimaryMachine() -> Equipment? {
        let descriptor = FetchDescriptor<Equipment>(
            predicate: #Predicate<Equipment> { equipment in
                equipment.type == "machine" && equipment.isPrimary
            }
        )
        return try? context.fetch(descriptor).first
    }
    
    func getPrimaryGrinder() -> Equipment? {
        let descriptor = FetchDescriptor<Equipment>(
            predicate: #Predicate<Equipment> { equipment in
                equipment.type == "grinder" && equipment.isPrimary
            }
        )
        return try? context.fetch(descriptor).first
    }
    
    // MARK: - Beans
    
    func getAllBeans() -> [Bean] {
        let descriptor = FetchDescriptor<Bean>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getCurrentBeans() -> [Bean] {
        let descriptor = FetchDescriptor<Bean>(
            predicate: #Predicate<Bean> { bean in
                bean.status == "current"
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Brews
    
    func getAllBrews() -> [Brew] {
        let descriptor = FetchDescriptor<Brew>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getLastBrew(for beanID: UUID?, method: String) -> Brew? {
        let descriptor = FetchDescriptor<Brew>(
            predicate: #Predicate<Brew> { brew in
                if let beanID = beanID {
                    return brew.beanID == beanID && brew.method == method
                } else {
                    return brew.method == method
                }
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }
}
