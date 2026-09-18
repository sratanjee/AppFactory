# App Spec — Pet Diabetes Log

> Filled from `SPEC_TEMPLATE.md`. Second SKU on the **condition-log engine** from `02-seizure-log.md`. Build day 5. Do not name it "Feline Diabetes" (taken by the FDMB forum app, May 2026).

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Pet Diabetes Log |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Cat & dog glucose + insulin / Log glucose and insulin, see the daily curve, export in the FDMB sheet layout. No account. |
| Slug | pet-diabetes-log |
| Bundle ID / Application ID | `com.[YOUR STUDIO].petdiabeteslog` |
| Category (store) | Medical (iOS) / Medical (Android) |
| Developer account | B |
| Factory category | utility (condition-log) |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to log every glucose test and every shot in ten seconds so that I can see today's curve and paste it into the spreadsheet the forum asks for."

**Who pays:** Owner of a diabetic cat or dog who home-tests (71% of diabetic-cat owners do); already spending $59.72 per 50 AlphaTRAK strips, so $29.99/yr costs less than a month of consumables. Dogs (1 in 308, lifelong, no remission) are the renewing half; cats (~30% remit within 6 months) are the monthly-plan half.
**Where they gather:** Feline Diabetes Message Board (34,904 members, ~105K concurrent readers) via a signature link, never a pitch thread; r/FelineDiabetes and canine-diabetes Facebook groups second.
**Why they'd pay instead of using a free thing:** Merck's free tracker has documented data loss and crashes and its Android listing was reset to "10+" installs; RVC's app was last updated 2017 and cannot backfill. DiabiPets ($6.99/mo, $39.99/yr) is competent, so the two things this app has that it does not are no account and one-tap export in the exact FDMB column layout. Species toggle and monthly price match the cat treatment arc.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Day / Curve (home, as drawn) | Centered date header "Thu, Sep 17" with prev/next chevrons and "Mochi · Lantus 2.0u BID · mg/dL" subline; 220-pt curve with a pale green target band (90–250 labelled), accent polyline and hollow points, nadir filled; hero "128 · nadir at +6 · in range"; table Time / Reading / Dose / Note with AMPS…PMPS rows; bottom row "Add reading" (accent), "Log dose" (outlined), grid-glyph export button | Tap "Add reading" → sheet with time slot auto-picked from clock; tap "Log dose" → units sheet; swipe date header to change day; tap table row → edit |
| 2 | Add reading / Log dose sheet | Value in mg/dL or mmol/L (unit fixed at setup), slot (AMPS, +1…+11, PMPS or free time), note; dose: units, insulin name preset | Large numeric keypad; "Save reading" primary |
| 3 | Readings table (all days) | Scrollable one-row-per-day grid mirroring FDMB layout; colour by in/under/over band | Tap cell → edit; long-press day → notes |
| 4 | Pet & settings | Species, insulin (Lantus, ProZinc, Vetsulin, Levemir, other), meter, method, diagnosis date, target band low/high, unit | Edit fields; "Export FDMB CSV" and "Vet PDF" buttons |
| 5 | Vet report | Date range, PDF with curve thumbnails per day, readings table, dose history | "Share PDF" |

## 4. Data model

Uses the **condition-log engine** entities from `02-seizure-log.md` (Pet, Event, Dose, Medication, Measurement, Note, ReportRun). This SKU adds only configuration and the FDMB exporter.

```
Pet          + species(cat|dog), insulinName, meterName, method(enum ear|paw|lip|cgm), diagnosisDate, unit(enum mgdl|mmol), targetLow, targetHigh
Measurement  kind = glucose; value stored in mg/dL, displayed in unit; slot(enum AMPS|P1..P11|PMPS|free), takenAt, note
Dose         medicationId (insulin), units(decimal), takenAt, slot(enum AM|PM)
Event        kind = hypo | vetVisit | remissionTrial  // optional markers on the curve
FdmbExport   one row per day: Date, AMPS, units, +1…+11, PMPS, units, +1…+11
             header rows: diagnosis date, insulin, method, meter (matches FDMB US template; a "World" variant swaps unit to mmol/L)
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (FDMB-layout CSV and vet PDF); (3) optional Supabase sync (shared project, `app_id` column, RLS per user, Sign in with Apple/Google), shown only after purchase, for shared-household use — v1.1 candidate, not v1; (4) shared backend handles RevenueCat webhooks only. No dose suggestion, no shoot/no-shoot logic, no TR/SLGS protocol arithmetic anywhere (Apple 1.4.2); persistent "Never change insulin without your vet" line on the dose sheet.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [x] Home screen widget (sizes: small, medium) — last reading with slot and time ("128 · +6 · 2:10 PM"), tinted by in/out of band; medium adds today's mini curve
- [x] Lock screen widget (iOS) / Glance (Android) — accessory rectangular: last reading + slot
- [ ] Live Activity / Ongoing notification — no
- [ ] Watch complication / Wear tile — no
- [ ] Camera — no
- [x] Notifications (local only) — AM/PM shot reminders; optional "+6 test" reminder after a shot is logged
- [ ] Share extension / share target — no
- [x] App Intents / App Shortcuts — "Add glucose reading" (Siri asks for the number); Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Day screen) |
| Free trial | 7-day, on annual only |
| Weekly price | none (monthly instead: $4.99/mo, aimed at the cat remission arc) |
| Annual price | $29.99/yr (pre-selected, saving shown) |
| Lifetime price | $49.99 one-time (third option, aimed at dog owners) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; pet setup (onboarding) is free. |

1. Log a test and a shot in the time it takes the strip to read.
2. See today's curve and where the low landed, without a spreadsheet.
3. One tap gives the forum the exact sheet they ask for.

## 7. Onboarding (2–4 screens)

1. "Cat or dog, and what's their name?" — species toggle + name; sets ranges, copy and the header.
2. "Which insulin, and how do you measure?" — insulin preset, meter, mg/dL or mmol/L, target band defaults by species (editable); seeds the subline and the band.
3. "When was [name] diagnosed?" — date; fills the FDMB header; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#b8530f` (from artboard data-props). Pale green band `#eaf6ee` / `#1d7a4a` is a semantic "in range" colour, not a second accent.
- Home screen as drawn: white background (#ffffff), light theme, no tab bar; a day-navigator header (chevrons either side of a centered bold date and a small pet · insulin · unit subline); the curve is the hero: 220-pt tall, target band drawn as a soft green rectangle with tiny "250 target high" / "90 target low" labels, 3-pt accent polyline with 5-pt white-filled accent-stroked points and the nadir point filled solid; x-axis labels AMPS / +2 … / PMPS in tabular 11-pt grey; 44-pt tabular hero "128" with "nadir at +6 · in range" beside it; a four-column data table with hairline row separators (allowed here: it is a data grid, not a list); bottom row of two 50-pt buttons (solid accent "Add reading", outlined "Log dose") plus a square grey export button with a spreadsheet glyph. System sans.
- Icon concept (one sentence): A single curve dipping through a horizontal band, white on the accent orange.
- Tone of copy: precise, warm, unhurried; numbers first.
- Different from siblings in condition-log: orange on white with a chart hero and a data table; Seizure is purple calendar-first on grey, Kidney is teal ring + tiles on mint. No calendar on this home.

## 9. Store listing seeds

- Primary keyword: Pet Diabetes Log
- Secondary keywords (5): cat diabetes tracker, dog diabetes log, blood glucose curve pet, insulin tracker cat, FDMB spreadsheet export
- Screenshot story (5 screenshots, one line each):
  1. Today's curve with the band: "See the curve, not a column of numbers."
  2. Numeric keypad sheet: "Log a reading in three taps."
  3. Readings grid: "AMPS to PMPS, every day, one row."
  4. CSV opening in Sheets: "Exports in the exact forum layout."
  5. Cat / dog toggle with insulin presets: "Made for cats and dogs."

## 10. Done means

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] Android build reviewed on a Pixel and a small phone: Material 3 components, predictive back, edge-to-edge, dynamic color with the accent as fallback
- [ ] iOS build reviewed on an iPhone Pro and an SE-class device: Cupertino components, swipe-back, large title, Dynamic Type at 200%
- [ ] TestFlight build AND Play internal-testing build both uploaded from the same commit
- [ ] `REVIEW.md` written: what was built, what was cut, open questions
- [ ] FDMB CSV opens correctly in Google Sheets: header rows, one row per day, column order Date, AMPS, units, +1…+11, PMPS, units, +1…+11, no shifted cells when a slot is empty
- [ ] mmol/L ↔ mg/dL conversion round-trips exactly (18.0182 factor) in table, curve, widget and export

## 11. Explicitly out of scope

- Dose suggestions, shoot/no-shoot prompts, TR/SLGS protocol logic, ketone thresholds with advice (Apple 1.4.2)
- Google Sheets API write / live shared sheet (needs a Google account; CSV export only)
- CGM (FreeStyle Libre) import, meter Bluetooth, camera OCR of the meter screen
- Food, weight goals, vet appointments, general pet-care features
- Community, forum posting, sharing curves to social
- Supabase sync / shared household — v1.1 candidate, not v1
