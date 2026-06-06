//
//  ModelContext+Save.swift
//  orsa
//

import SwiftData

extension ModelContext {
    /// Saves pending changes, logging (rather than throwing) on failure.
    /// Centralizes the `do { try save() } catch { print(...) }` pattern that was
    /// previously copy-pasted across every view that mutates the store.
    /// - Parameter context: short label describing the operation, used in the log line.
    func saveOrLog(_ context: String = "") {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            let suffix = context.isEmpty ? "" : " (\(context))"
            print("⚠️ SwiftData save failed\(suffix): \(error)")
        }
    }
}
