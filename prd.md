# Orsa - Product Requirements Document

## Product Vision
Orsa is a no-fluff espresso journal that eliminates tedious data entry by auto-populating brew parameters. Users can log shots in ~15 seconds, track their dialing-in process, and share beautiful brew cards that drive app growth.

## Core Value Proposition
**Other apps:** Pull shot → manually enter 10+ fields → 2+ minutes of typing  
**Orsa:** Pull shot → confirm pre-filled data → add yield/time/notes → 15 seconds done

---

## Target User
Home espresso enthusiasts who:
- Brew one bag of beans at a time
- Make small adjustments while dialing in
- Switch methods (espresso/pour over) more often than switching beans simultaneously
- Want to track progress without friction

---

## V1 Scope

### Onboarding Journey
**Goal:** Get users to their first logged brew in under 2 minutes

1. Open app
2. Welcome greeting
3. Ask name
4. Input primary machine
5. Input primary grinder
6. Input usual dose
7. Done → prompt to add beans or log first brew

---

### Add Beans Journey
**Goal:** Capture essential bean info for reference and sharing

1. Open app → Beans tab
2. Tap "Add Beans"
3. Input coffee name
4. Input roaster
5. Roast date
6. Select process (washed/natural/honey/etc.)
7. Origin (country/region)
8. Roast level (light/medium/dark)
9. Tasting notes (optional)
10. Bag weight (new field - e.g., 12oz/340g)
11. Set as current beans
12. Done

**Bean Status:**
- Current (actively brewing)
- Next (in queue)
- Archived (finished)

---

### First Brew Journey
**Goal:** Establish baseline parameters for auto-population

1. Tap "New Brew"
2. App pre-fills: equipment (from onboarding), dose (from onboarding)
3. Select beans (if multiple marked as "current")
4. Select drink type (espresso/americano/latte/cappuccino/etc.)
5. If milk drink → select milk type (whole/oat/almond/etc.)
6. Input grind setting (e.g., "3.5")
7. Input temperature (e.g., "200°F" or "93°C")
8. Input brew time (e.g., "28s" - manual entry or timer)
9. Input yield (e.g., "36g")
10. Add notes (optional text field)
11. Add rating (1-5 stars or similar)
12. Add photo (optional)
13. Save
14. Option to share

---

### Regular Brew Journey (Same Parameters)
**Goal:** Log a shot in ~15 seconds

1. Tap "New Brew"
2. App auto-populates ALL previous parameters:
   - Equipment (machine/grinder)
   - Beans (current bag)
   - Drink type & milk
   - Dose
   - Grind setting
   - Temperature
3. User inputs brew time
4. User inputs yield
5. Add notes (optional)
6. Add rating
7. Add photo (optional)
8. Save
9. Option to share

**Auto-population logic:**
- Use parameters from most recent brew with same beans + same method
- If user switches method (espresso → pour over), pull last parameters for that method

---

### Dialing In Journey (Different Parameters)
**Goal:** Make adjustments without starting from scratch

1. Tap "New Brew"
2. App auto-populates previous parameters
3. Tap "Edit Parameters"
4. Parameters appear in editable list:
   - Equipment (dropdown to other saved equipment)
   - Beans (dropdown)
   - Drink type (dropdown)
   - Milk type (dropdown if applicable)
   - Dose (number input)
   - Grind setting (number input)
   - Temperature (number input)
5. Adjust what changed (e.g., grind from 3.5 → 3.0)
6. Input brew time
7. Input yield
8. Add notes (e.g., "Going coarser - last shot was sour")
9. Add rating
10. Add photo (optional)
11. Save
12. Option to share

---

### Method Switching Journey
**Goal:** Seamlessly switch between espresso/pour over with same beans

**Scenario:** User has been making espresso, now wants pour over with same beans

1. Tap "New Brew"
2. Currently shows last espresso parameters
3. User changes drink type dropdown: "Espresso" → "Pour Over"
4. App switches to last pour over parameters for these beans:
   - Grind setting updates (e.g., 3.5 → 12)
   - Dose updates (e.g., 18g → 20g)
   - Temperature, equipment persist if applicable
5. Input brew time/yield
6. Continue as normal

**Memory system:**
- Track "last used parameters" per method per bean
- Don't bleed espresso settings into pour over and vice versa

---

## Pages & Navigation

### 1. Brews (Home)
- Default view: Chronological list of all brews (most recent first)
- Filter options: By date / by beans / by drink type / rating
- Each brew card shows:
  - Date/time
  - Bean name + roaster
  - Drink type
- AB (Action Button): "New Brew"

### 2. Beans
- Three sections:
  - **Current** (actively brewing)
  - **Next** (queued up)
  - **Archived** (finished bags)
- Each bean card shows:
  - Roaster + coffee name
  - Origin
  - Roast date + days since roast
  - Remaining weight (if tracked)
  - For archived: best rating, optimal grind settings, best temp
- AB: "Add Beans"

### 3. Tools (Equipment)
- List of saved equipment:
  - Machines
  - Grinders
  - (Future: scales, kettles, etc.)
- Each item shows:
  - Name/model
  - Type
  - Mark as "primary" (used in auto-population)
- FAB: "Add Tool"

### 4. Profile / Settings (Optional for V1)
- User name
- Preferred units (metric/imperial)
- Default dose
- Sharing preferences

---

## Sharing Feature

### Goal
Drive growth through beautiful, shareable brew cards that link back to app

### Share Flow
1. After saving a brew, tap "Share"
2. App generates brew card with user's data
3. User selects style template:
4. If user added photo → overlays on template
5. If no photo → template uses illustration/texture
6. Preview all styles instantly (no rendering lag)
7. Select template → Share to Instagram/Messages/etc.


### Link-Back Experience
When someone clicks shared link:
1. Opens web view showing full brew details:
   - All parameters
   - Photo
   - Notes
   - "Try This Recipe" CTA
2. Download Orsa CTA
3. If app installed → deep link to that brew or pre-fill those parameters

**Future consideration:** Let users save/import shared recipes directly

---

## Data Requirements

### Brew Record
- Timestamp (auto)
- Bean ID (reference)
- Equipment IDs (machine, grinder)
- Drink type
- Milk type (if applicable)
- Dose (grams)
- Grind setting (string - allows "3.5" or "fine" or "15 clicks")
- Temperature (°F or °C)
- Brew time (seconds or MM:SS)
- Yield (grams or ml)
- Rating (1-5 scale)
- Notes (text, optional)
- Photo (optional)
- Method (espresso/pour over/aeropress/etc.)

### Bean Record
- Coffee name
- Roaster
- Roast date
- Process (washed/natural/honey/anaerobic/etc.)
- Origin (country + region optional)
- Roast level (light/medium/dark)
- Tasting notes
- Bag weight (grams or oz)
- Remaining weight (for future updates)
- Status (current/next/archived)
- Date added
- Date finished (when archived)

### Equipment Record
- Type (machine/grinder/scale/kettle)
- Brand
- Model
- Is primary (boolean)
- Date added

### User Profile
- Name
- Preferred units (metric/imperial)
- Default dose
- Onboarding completed (boolean)

---

## Auto-Population Logic (Critical)

### On "New Brew"
1. Check: What was user's last brew?
2. Pre-fill ALL parameters from that brew:
   - Equipment
   - Current beans
   - Drink type + milk
   - Dose
   - Grind setting
   - Temperature

### If User Changes Method (Drink Type)
1. Detect drink type change (e.g., Espresso → Pour Over)
2. Query: "Last brew with [current beans] + [new method]"
3. If found → load those parameters (grind, dose, temp, time, yield)
4. If not found → keep equipment/beans, clear method-specific parameters

### Parameter Memory Strategy
- Track per bean + per method combination
- Don't let espresso settings pollute pour over and vice versa
- Always default to most recent within that bean+method combo

---

## V1 Success Metrics
- **Core engagement:** % of users who log 5+ brews in first week
- **Retention:** 7-day and 30-day active users
- **Logging speed:** Median time from "New Brew" to "Save"
- **Sharing:** % of brews shared, click-through rate on shared links
- **Growth:** Install attribution from shared links

---

## Out of Scope for V1 (Future Updates)

### Analytics & Insights
- Charts showing dial-in progress (ratings over time)
- Optimal parameter recommendations per bean
- Shot consistency tracking
- Best shots per bean

### Advanced Features
- Bluetooth scale integration
- Built-in timer with auto-logging
- Recipe discovery feed
- Social features (follow users, like brews)
- Taste profile building
- Bean inventory management with depletion tracking

### Guidance Features
- Dial-in assistant ("Your last 3 shots were sour, try going coarser")
- Troubleshooting tips based on notes

---

## Technical Considerations

### Data Persistence
- Local-first: All data stored on device
- Cloud sync (optional, future): Cross-device access
- Export option: CSV or JSON for data portability

### Photo Handling
- Compress images for storage efficiency
- Allow photo editing/cropping before save
- Store original + compressed version for sharing

### Share Card Generation
- Pre-render templates for instant preview
- Generate final image on-device (don't require server)
- Embed deep link in shared image metadata when possible

---

## Open Questions
1. **Timer integration:** Should V1 include a built-in timer, or assume users use separate timer?
2. **Units:** Support both metric (grams/°C) and imperial (oz/°F) with user preference?
3. **Grind setting format:** Free text or structured (brand + setting number)?
4. **Rating system:** Stars (1-5), thumbs up/down, or numeric score (0-10)?
5. **Photo requirement:** Optional always, or required for sharing?

---

## Development Phases

### Phase 1: Core Logging (MVP)
- Onboarding flow
- Add beans
- Add equipment  
- Log brews with auto-population
- View brews list

### Phase 2: Sharing
- Template system
- Share card generation
- Deep linking
- Web view for shared brews

### Phase 3: Organization
- Beans management (current/next/archived)
- Filtering brews by bean/date/type
- Search

### Phase 4: Polish & Insights
- Simple charts/stats
- Best shot indicators
- Export data
- Settings/preferences

---

**Version:** 1.0  
**Last Updated:** January 2026  
**Owner:** Orsa Product Team