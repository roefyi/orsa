# Font Debugging - Fonts Not Loading

The console shows NO Oscine fonts are loading. This means the fonts aren't being copied into the app bundle.

## Current Status
- ✅ Fonts exist in file system: `orsa/Resources/TrialStaticFonts/`
- ✅ PostScript names identified: `OscineTrial-Regular` and `OscineTrial-XBold`
- ✅ Code updated with correct PostScript names
- ✅ Info.plist entries added (filenames with .ttf)
- ❌ Fonts NOT in Copy Bundle Resources (project file shows empty)
- ❌ Fonts NOT loading in app (console confirms)

## The Problem
The `PBXResourcesBuildPhase` section in the project file is empty - the fonts aren't being copied into the app bundle during build.

## Solution: Verify in Xcode

1. **Open Xcode** (if not already open)

2. **Project Navigator** → Click the blue "orsa" project icon at the top

3. **Select "orsa" target** (under TARGETS, not PROJECT)

4. **Click "Build Phases" tab**

5. **Expand "Copy Bundle Resources"**

6. **Look for:**
   - `Oscine_Trial_Rg.ttf`
   - `Oscine_Trial_XBd.ttf`

7. **If they're NOT there:**
   - Click the **"+"** button at bottom of "Copy Bundle Resources"
   - In the popup, navigate to `orsa/Resources/TrialStaticFonts/`
   - Select BOTH font files (hold Cmd to select both)
   - Click **"Add"**
   - Make sure they appear in the list

8. **If they ARE there but still not working:**
   - Try removing them (select and press Delete or click "-")
   - Then add them again using step 7
   - Make sure Target Membership is checked for "orsa" on each font file

9. **Clean and Rebuild:**
   - Press `Shift + Cmd + K` (Clean Build Folder)
   - Press `Cmd + B` (Build)
   - Press `Cmd + R` (Run)
   - Check console again

## Alternative: Check Built App Bundle

After building, you can check if fonts are in the app bundle:

1. Build the app
2. In Xcode, go to **Window → Devices and Simulators**
3. Or find the built app at:
   - Simulator: `~/Library/Developer/CoreSimulator/Devices/[device-id]/data/Containers/Bundle/Application/[app-id]/orsa.app/`
4. Check if the `.ttf` files are inside the app bundle

If fonts aren't in the bundle, they won't load no matter what names we use!
