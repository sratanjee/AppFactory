# App Spec — Kidney Care Log

> Filled from `SPEC_TEMPLATE.md`. Third SKU on the **condition-log engine** from `02-seizure-log.md`. Build after 02 and 03 have shipped and one of them has a paying user (research: cut new SKUs only from engines that converted).

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Kidney Care Log |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | CKD cat & dog daily tracker / Food, meds and sub-Q fluids each day, weight and water trends, bloodwork by IRIS stage. No account. |
| Slug | kidney-care-log |
| Bundle ID / Application ID | `com.[YOUR STUDIO].kidneycarelog` |
| Category (store) | Medical (iOS) / Medical (Android) |
| Developer account | B |
| Factory category | utility (condition-log) |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to tick off food, meds and fluids every day and notice when the weight or the water changes, so that I catch a slide before the next blood panel does."

**Who pays:** Owner of a cat (or dog) with chronic kidney disease giving sub-Q fluids at home, on a renal diet and phosphate binder; kidney disease is among the chronic conditions that make up 7 of the top-10 cat conditions in Nationwide's 2025 claims, and CKD care is lifelong with daily tasks.
**Where they gather:** Feline CKD Facebook groups and the Tanya's CKD community (the reference site for this condition); r/FelineCKD second. Member counts were not verified in research; read for an hour before build day.
**Why they'd pay instead of using a free thing:** No dedicated CKD app with traction exists; owners use paper charts, generic reminder apps (none over 77 ratings) or a spreadsheet. The tasks are daily and the numbers that matter (weight, water, creatinine, SDMA, phosphorus) live in three places today. Same buyer psychology as the diabetes log: already spending on fluids, needles and renal food, so the app is the cheapest part of the regimen. Same category warning: the record must never be lost on update.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Today (home, as drawn) | Greeting line "Good evening. Pepper's day so far:"; 132-pt progress ring "2/3 done" beside a "Fluids tonight" headline with the next-task note; three big 120-pt tiles Food / Meds / Fluids (done tiles solid accent with a check, pending tile white with dashed border and a drop glyph, "Tap when done"); "Watching" section with three white cards (Weight sparkline, Water intake with amber flag, Last bloodwork with "Stage 2" pill) and a "Vet summary" link; underline tabs Today / History / Labs / Pepper | Tap a tile → marks done with time (Fluids tile asks mL, default from settings); ring fills; tap a Watching card → its trend; tap "Vet summary" → report |
| 2 | History | Calendar-strip of days with 0–3 tiles done; list of check-ins, fluids (mL, site), meds, notes | Tap a day → edit; long-press → add a note |
| 3 | Labs | Bloodwork entries: date, creatinine, SDMA, phosphorus, BUN, USG, potassium, IRIS stage (picked by the owner from the vet's report, never computed); per-value trend lines | "Add panel" form; tap a value → trend |
| 4 | Pet (settings + trends) | Pet details, daily plan (food, meds with times, fluids mL and usual time), weight and water entries with flags (weight down ≥5% over 4 weeks; water up ≥20% week over week) | Edit plan; add weight / water; toggle reminders |
| 5 | Vet summary | Date range; PDF with adherence %, fluids given, weight and water trends, lab table by date with IRIS stage | "Share PDF"; "Export CSV" |

## 4. Data model

Uses the **condition-log engine** entities from `02-seizure-log.md` (Pet, Event, Dose, Medication, Measurement, Note, ReportRun). This SKU adds a daily-plan configuration and lab measurement kinds.

```
Pet          + irisStage(enum 1|2|3|4|unknown, owner-entered), dailyPlan(json: food, medIds, fluidsMl, fluidsTime)
Event        kind = checkin(food) | fluids(ml, site, at) | vetVisit
Dose         medicationId, scheduledAt, takenAt?   // Meds tile
Measurement  kind = weight | water(ml/day) | creatinine | sdma | phosphorus | bun | usg | potassium; value, unit, takenAt, panelId?
LabPanel     id, petId, at, irisStageAtPanel, note   // groups Measurements from one blood draw
Flag         computed: weightDrop5pct4w, waterUp20pctWoW  // shown as amber "mention to vet" text, never as advice
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (vet summary PDF and full CSV); (3) optional Supabase sync (shared project, `app_id` column, RLS per user, Sign in with Apple/Google), shown only after purchase, for shared-household use (two people alternating fluids is the concrete case) — v1.1 candidate, not v1; (4) shared backend handles RevenueCat webhooks only. No dosing advice, no fluid-volume calculator, no IRIS stage computed from values (Apple 1.4.2); flags say "mention to vet", nothing more.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [x] Home screen widget (sizes: small, medium) — today's ring "2/3" with pet name; medium shows the three tiles' states
- [x] Lock screen widget (iOS) / Glance (Android) — accessory circular: ring progress
- [ ] Live Activity / Ongoing notification — no
- [ ] Watch complication / Wear tile — no
- [ ] Camera — no
- [x] Notifications (local only) — per-task reminders (meds times, fluids time); "nothing logged today" evening nudge, opt-in
- [ ] Share extension / share target — no
- [x] App Intents / App Shortcuts — "Log fluids" (asks mL, defaults to plan); Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Today screen) |
| Free trial | 7-day, on annual only |
| Weekly price | none (no monthly tier either: CKD care is lifelong, so annual and lifetime only) |
| Annual price | $29.99/yr (pre-selected, saving shown against lifetime) |
| Lifetime price | $49.99 one-time (third option shown second, since there are two plans) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; pet setup (onboarding) is free. |

1. Food, meds, fluids: three taps and today is done.
2. Notice the weight or the water drifting before the next blood panel does.
3. Every lab result in one place, ready to show the vet.

## 7. Onboarding (2–4 screens)

1. "Who are we looking after?" — name, cat or dog, current weight; personalizes the greeting, ring and widget.
2. "What does a normal day look like?" — food (renal diet name), meds with times, fluids mL and usual time (or "no fluids yet"); seeds the three tiles.
3. "What stage did the vet say?" — IRIS 1–4 or "not sure", last creatinine and SDMA if known; seeds Labs; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#0f766e` (from artboard data-props). Amber `#b45309` is a semantic flag colour for "mention to vet" only.
- Home screen as drawn: soft mint background (#eef6f4), light theme, 24-pt side margins; opens with a conversational greeting line; hero is a 132-pt ring (12-pt stroke, #d6e8e4 track, accent arc) with "2/3 done" inside, next to a 22-pt "Fluids tonight" headline and a one-line note; three equal 120-pt tiles with 20-pt radius (solid accent + white check when done, white with dashed #9fc7bf border and accent drop glyph when pending); a "Watching" header with a "Vet summary" accent link and three white 16-pt-radius cards each with title, one-line status and a 72×28 sparkline (amber line when flagged), the bloodwork card ending in a "Stage 2" pill; bottom underline-style text tabs Today / History / Labs / Pepper (accent underline on the selected tab) instead of an icon tab bar. System sans.
- Icon concept (one sentence): A single water drop inside an open ring, white on the accent teal.
- Tone of copy: gentle, conversational, daily-companion voice ("Pepper's day so far"); never clinical, never advice.
- Different from siblings in condition-log: teal on mint, ring + three tiles, text tabs; Seizure is purple calendar-first on grey, Pet Diabetes is orange curve-first on white.

## 9. Store listing seeds

- Primary keyword: Kidney Care Log
- Secondary keywords (5): cat kidney disease tracker, CKD cat app, sub-Q fluids log, feline creatinine tracker, IRIS stage pet
- Screenshot story (5 screenshots, one line each):
  1. Today with two tiles done and the ring at 2/3: "Three taps and today is done."
  2. Fluids tile sheet with mL and site: "Fluids logged, warm bag reminder included."
  3. Weight and water trends with an amber flag: "Notice the drift early."
  4. Labs with creatinine / SDMA / phosphorus trends: "Every panel, in order."
  5. Vet summary PDF: "Bring the whole month to the appointment."

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
- [ ] Weight and water flags fire at exactly the thresholds in §4 and never show text beyond "mention to vet"; IRIS stage is only ever owner-entered
- [ ] Ring, widget and Today tiles agree after a day rolls over at local midnight and after a timezone change

## 11. Explicitly out of scope

- Fluid-volume calculators, dose or diet advice, IRIS stage computed from lab values (Apple 1.4.2)
- Food database, calorie counting, renal-diet comparisons
- Multi-pet in v1 (engine supports it; UI shows one)
- Camera, photo of lab report with OCR
- Community, sharing to groups, vet messaging, appointment booking
- Supabase sync / shared household — v1.1 candidate, not v1
