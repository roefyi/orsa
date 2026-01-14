# SwiftData Setup Guide for Orsa

## ✅ What's Already Configured

Your app already has a **complete SwiftData implementation**. Here's what's in place:

### 1. **Models** (All properly defined with `@Model`)
- ✅ `Brew` - Brew records with all parameters
- ✅ `Bean` - Coffee bean information
- ✅ `Equipment` - Machines, grinders, etc.
- ✅ `UserProfile` - User settings and onboarding status

### 2. **ModelContainer Setup** (`orsaApp.swift`)
- ✅ Schema defined with all 4 models
- ✅ Persistent storage (not in-memory)
- ✅ Automatic migration handling with database reset on failure
- ✅ ModelContainer injected into view hierarchy

### 3. **View Integration**
- ✅ `ContentView` receives ModelContainer
- ✅ All views use `@Query` for data fetching
- ✅ All views use `@Environment(\.modelContext)` for saving/deleting
- ✅ Proper data flow throughout the app

### 4. **Permissions** (`Info.plist`)
- ✅ Camera access (`NSCameraUsageDescription`)
- ✅ Photo library access (`NSPhotoLibraryUsageDescription`)

### 5. **Fonts**
- ✅ Custom fonts registered in `Info.plist`
- ✅ Font files included in project

---

## 🔧 What You Need to Verify in Xcode

### 1. **Deployment Target**
- Open your project in Xcode
- Select the project in the navigator
- Go to **General** tab
- Ensure **iOS Deployment Target** is set to **iOS 17.0+** (SwiftData requires iOS 17+)

### 2. **Build Settings**
- Verify **Swift Language Version** is set to **Swift 5.9+**
- Check that **SwiftData** framework is available (should be automatic in iOS 17+)

### 3. **Capabilities** (if needed in future)
Currently, no special capabilities are required. If you add:
- **iCloud** (for sync) - would need iCloud capability
- **Background Modes** (for timers) - would need background capability

---

## 📱 How SwiftData Works in Your App

### Data Flow:

```
orsaApp.swift
  └─> Creates ModelContainer with all models
      └─> Injects into ContentView
          └─> All child views inherit ModelContainer
              └─> Views use @Query to fetch data
              └─> Views use @Environment(\.modelContext) to save/delete
```

### Example Usage (Already Implemented):

**Fetching Data:**
```swift
@Query(sort: \Brew.timestamp, order: .reverse) private var brews: [Brew]
```

**Saving Data:**
```swift
@Environment(\.modelContext) private var modelContext

modelContext.insert(newBrew)
try modelContext.save()
```

**Deleting Data:**
```swift
modelContext.delete(brew)
try modelContext.save()
```

---

## 🧪 Testing Your Setup

### 1. **Run the App**
- Build and run in Xcode
- Complete onboarding
- Add a bean
- Add equipment
- Create a brew
- Close and reopen the app
- **Verify:** Data should persist

### 2. **Check Database Location** (Debug)
The database is stored at:
```
~/Library/Application Support/default.store
```

You can add this debug code to see the location:
```swift
let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
print("Database location: \(url)")
```

### 3. **Test Migration**
- If you change a model (add/remove properties), the app will:
  1. Try to migrate automatically
  2. If migration fails, reset the database (as configured)
  3. User will lose data (acceptable for development)

---

## ⚠️ Common Issues & Solutions

### Issue: "Cannot find ModelContainer"
**Solution:** Make sure `.modelContainer()` is called on the root view (ContentView)

### Issue: Data not persisting
**Solution:** 
- Check that `isStoredInMemoryOnly: false` in ModelConfiguration
- Verify `modelContext.save()` is called after insertions/updates

### Issue: Migration errors
**Solution:** The app automatically resets the database on migration failure. For production, implement proper migration strategies.

### Issue: @Query not updating
**Solution:** 
- Ensure ModelContainer is properly injected
- Check that sort descriptors are correct
- Verify the view is observing the query

---

## 🚀 Next Steps (Optional Enhancements)

### 1. **Add Data Export** (Future)
```swift
// Export all data as JSON
func exportData() -> Data? {
    // Fetch all models and encode to JSON
}
```

### 2. **Add Data Import** (Future)
```swift
// Import data from JSON
func importData(from data: Data) throws {
    // Decode and insert models
}
```

### 3. **Add CloudKit Sync** (Future)
- Enable iCloud capability
- Use `ModelConfiguration` with CloudKit
- Automatic sync across devices

### 4. **Add Migration Versioning** (Production)
- Implement `VersionedSchema` for proper migrations
- Handle data transformations between versions

---

## 📚 SwiftData Resources

- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WWDC 2023: Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- [WWDC 2023: Migrate to SwiftData](https://developer.apple.com/videos/play/wwdc2023/10189/)

---

## ✅ Summary

**Your app is fully configured for SwiftData!** 

Everything needed is already in place:
- ✅ Models defined
- ✅ Container configured
- ✅ Views integrated
- ✅ Permissions set
- ✅ Migration handling

**Just build and run** - SwiftData will automatically:
- Create the database
- Store your data
- Handle queries
- Persist across app launches

No additional setup required! 🎉
