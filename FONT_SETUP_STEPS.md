# Step-by-Step: Adding Fonts to Xcode Project

Follow these steps in order:

## Step 1: Add Font Files to Project

1. **Open Xcode** (make sure the `orsa.xcodeproj` is open)

2. **In the Project Navigator** (left sidebar), find the `orsa` folder

3. **Right-click on `Resources` folder** (or wherever the `TrialStaticFonts` folder is)
   - If you don't see `TrialStaticFonts` in the navigator, right-click on `orsa` folder instead

4. **Select "Add Files to 'orsa'..."** from the context menu

5. **In the file picker dialog:**
   - Navigate to: `orsa/Resources/TrialStaticFonts/`
   - Select these TWO files (hold Cmd to select multiple):
     - `Oscine_Trial_Rg.ttf`
     - `Oscine_Trial_XBd.ttf`
   - **IMPORTANT:** Make sure these checkboxes are selected:
     - ✅ "Copy items if needed" (should be checked if files are outside project)
     - ✅ Under "Add to targets:", check the box for **"orsa"** (your app target)
   - Click **"Add"** button

6. **Verify the files appear** in the Project Navigator under `orsa/Resources/TrialStaticFonts/`

---

## Step 2: Verify Target Membership

1. **Click on `Oscine_Trial_Rg.ttf`** in the Project Navigator (left sidebar)

2. **Look at the File Inspector** (right sidebar, first tab - looks like a document)

3. **Under "Target Membership" section**, make sure:
   - ✅ The checkbox next to **"orsa"** is checked

4. **Repeat for `Oscine_Trial_XBd.ttf`:**
   - Click on `Oscine_Trial_XBd.ttf`
   - Verify the checkbox for **"orsa"** is checked in Target Membership

---

## Step 3: Add to Copy Bundle Resources

1. **Click on the project file** at the top of the Project Navigator (the blue "orsa" icon)

2. **Select the "orsa" target** in the main editor (under "TARGETS", not "PROJECT")

3. **Click on the "Build Phases" tab** at the top

4. **Expand "Copy Bundle Resources"** section (click the triangle to expand)

5. **Check if the font files are listed:**
   - Look for `Oscine_Trial_Rg.ttf`
   - Look for `Oscine_Trial_XBd.ttf`

6. **If they're NOT there:**
   - Click the **"+" button** at the bottom of the "Copy Bundle Resources" section
   - In the popup, select both font files (hold Cmd to select both)
   - Click **"Add"**

---

## Step 4: Clean and Build

1. **In Xcode menu bar**, go to **Product → Clean Build Folder** (or press `Shift + Cmd + K`)

2. **Wait for the clean to complete** (you'll see it in the status bar at the top)

3. **Build the project**: Press `Cmd + B` or go to **Product → Build**

4. **Check for errors** in the Issue Navigator (left sidebar, warning icon). There should be no errors.

---

## Step 5: Run the App and Check Console

1. **Run the app**: Press `Cmd + R` or click the Play button

2. **Open the Console**:
   - In Xcode, go to **View → Debug Area → Show Debug Area** (or press `Cmd + Shift + Y`)
   - Make sure you're looking at the **console output** (bottom panel)

3. **Look for the debug output**. You should see something like:
   ```
   === Available Oscine Fonts ===
   Font Family: [some name]
     - Font Name: [PostScript name]
   ==============================
   === Testing Font Names ===
   ✓ FOUND: [working name]
   ✗ NOT FOUND: [other names]
   ==========================
   ```

4. **Copy the console output** and share it - this will tell us the exact font names to use!

---

## Troubleshooting

**If the fonts still don't show:**
- Make sure you completed ALL steps above
- Try restarting Xcode
- Make sure the font files are physically in the `orsa/Resources/TrialStaticFonts/` folder
- Double-check that both font files have Target Membership checked for "orsa"

**If you see errors:**
- Check that the font file paths in Info.plist match where the files actually are
- Verify the font files aren't corrupted (try opening them in Font Book)
