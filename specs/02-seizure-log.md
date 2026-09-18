# App Spec — Seizure Log

> Filled from `SPEC_TEMPLATE.md`. First SKU on the shared **condition-log engine** (see §4); apps 03 and 05 reuse it. Build days 3–4.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Seizure Log |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Dog epilepsy tracker & meds / Time seizures, track clusters and daily meds, hand your vet a clean report. No account. |
| Slug | seizure-log |
| Bundle ID / Application ID | `com.[YOUR STUDIO].seizurelog` |
| Category (store) | Medical (iOS) / Medical (Android) |
| Developer account | B |
| Factory category | utility (condition-log) |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to time and record every seizure and every pill so that my vet can see the pattern instead of my panicked memory of it."

**Who pays:** Owner of an epileptic dog on daily phenobarbital / Keppra / bromide; seizures newly entered Nationwide's top-10 dog conditions in 2025 and ~43% of medicated pets dose daily.
**Where they gather:** Canine-epilepsy Facebook groups (largest reachable); r/dogs and r/AskVet threads second. Member counts were not verifiable in research, so read the groups for an hour before build day.
**Why they'd pay instead of using a free thing:** The only dedicated incumbent (RVC Pet Epilepsy Tracker) is 1.2 stars, last updated Jan 2025, with reviews of 4.5 years of lost data. Generic med-reminder apps (18 of them, none over 77 ratings) cannot record duration, type, cluster or produce a vet PDF. A phone alarm cannot either. Paying $29.99/yr buys a record that survives updates, which is the entire negative-review history of the category.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Home (as drawn) | Pet header (initial avatar, name, breed · weight · meds, vet-report share button); month calendar with seizure days in semantic red and today in accent; hero number "7 days since last seizure" with last-event subline; "Today's doses" as horizontal checkable chips; "Last 90 days" stat card; bottom-anchored red pill button "Seizure started — tap to time it" | Tap red button → timer starts immediately (Live Activity); tap dose chip → marks taken with time; tap calendar day → that day's events |
| 2 | Seizure timer / event form | Running timer; on stop: type (focal / generalized / cluster / unknown), duration auto-filled, cluster flag, triggers, recovery note, optional video attach later | Stop timer → form pre-filled; "Save seizure" primary |
| 3 | History | Reverse-chronological events and doses; filter by type; 90-day stats (count, avg gap, longest gap, doses on time) | Tap row → edit; swipe to delete with confirm |
| 4 | Meds | Medication list: name, strength, dose, times per day; blood-level test dates | Add / edit; toggle reminder per dose time |
| 5 | Vet report | Date-range picker, PDF preview (events table, calendar strip, dose adherence, med list) | "Share PDF"; "Export CSV" |

## 4. Data model

Built as the generic **condition-log engine** in `packages/core` (or `packages/condition_log`): entities below are engine entities; this SKU configures event types, measurement kinds and the report template. Apps 03 and 05 add their own configurations, not new entities.

```
Pet          id, name, species(enum dog|cat), breed, weightKg, birthDate, photo(path), conditionLabel
Event        id, petId, kind(enum seizure), startedAt, durationSec, subtype(enum focal|generalized|cluster|unknown), clusterFlag, triggers(text), note
Medication   id, petId, name, strengthMg, doseText, timesPerDay, times(json), active
Dose         id, medicationId, scheduledAt, takenAt?, skipped  // chip state on home
Measurement  id, petId, kind(enum weight|bloodLevel), value, unit, takenAt, label(text)  // pheno/bromide level dates
Note         id, petId, at, text
ReportRun    id, petId, from, to, generatedAt, path
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (vet PDF and full CSV); (3) optional Supabase sync (shared project, `app_id` column, RLS per user, Sign in with Apple/Google), shown only after purchase, for shared-household use — v1.1 candidate, not v1; (4) shared backend handles RevenueCat webhooks only. No dosing advice, no "give more" logic anywhere (Apple 1.4.2); a persistent "Talk to your vet before changing any medication" line sits on Meds and Report.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [x] Home screen widget (sizes: small, medium) — "7 days since last seizure" + pet name; medium adds today's dose chips state
- [x] Lock screen widget (iOS) / Glance (Android) — accessory circular: days count; Glance small: days count
- [x] Live Activity (iOS) / Ongoing notification (Android) — running seizure timer with Stop; Dynamic Island compact shows mm:ss
- [ ] Watch complication / Wear tile — no
- [ ] Camera — no (video attach via file picker only, v1.1)
- [x] Notifications (local only) — dose-time reminders per medication
- [ ] Share extension / share target — no
- [x] App Intents / App Shortcuts — "Start seizure timer"; Android Quick Settings tile for the same

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the home screen) |
| Free trial | 7-day, on annual only |
| Weekly price | none (monthly instead: $4.99/mo) |
| Annual price | $29.99/yr (pre-selected, saving shown) |
| Lifetime price | $49.99 one-time (third option) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; pet setup (onboarding) is free. |

1. Time a seizure with one tap, even with shaking hands.
2. See the pattern your vet keeps asking about, on one page.
3. Your dog's whole history, on your phone, never lost in an update.

## 7. Onboarding (2–4 screens)

1. "Who are we looking after?" — dog's name, breed, weight; personalizes the header and the widget.
2. "What does [name] take every day?" — add medications with times (pre-filled list: phenobarbital, levetiracetam / Keppra, potassium bromide, zonisamide); seeds dose chips.
3. "When was the last seizure?" — date picker or "not sure yet"; sets the hero number; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#7a3fb8` (from artboard data-props). Semantic red `#d92d20` is used only for seizure days and the "Seizure started" button, as an alarm color, not a second accent.
- Home screen as drawn: light grouped background (#f2f2f7), no tab bar (single scrolling home with push navigation to History / Meds / Report); header row with 44-pt accent initial avatar, pet name, breed · weight · meds subline and a white circular share button; 7-column calendar grid of 34-pt rounded cells (white default, pale red with red bold numeral for seizure days, solid accent for today, muted for future); hero 64-pt tabular accent numeral "7" with "days since last seizure"; "Today's doses" horizontal chips (solid accent = taken with check glyph, white outlined = pending); one white "Last 90 days" card with four stats; bottom-anchored 58-pt red pill button with a clock glyph. System sans.
- Icon concept (one sentence): A calendar square with one filled day, white on the accent purple.
- Tone of copy: calm, steady, plain; never alarming, never medical advice.
- Different from siblings in condition-log: purple, calendar-first, red emergency button; Pet Diabetes is orange curve-first on white, Kidney is teal ring + tiles on mint.

## 9. Store listing seeds

- Primary keyword: Seizure Log
- Secondary keywords (5): dog epilepsy tracker, canine seizure diary, pet medication log, phenobarbital tracker, seizure timer
- Screenshot story (5 screenshots, one line each):
  1. Home with the big number: "7 days since the last one."
  2. Timer running in the Dynamic Island: "One tap. It times it for you."
  3. Calendar with clusters marked: "See the pattern."
  4. Dose chips checked off: "Pills done, every day."
  5. Vet PDF on a table: "Hand your vet the whole story."

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
- [ ] Backup file restores a full history on a fresh install on both platforms; CSV opens in Google Sheets and Numbers with correct dates and durations
- [ ] Engine entities and report generator live in the shared package with no seizure-specific strings, so app 03 can be scaffolded from it

## 11. Explicitly out of scope

- Any dosing suggestion, dose calculator, rescue-med prompt or "call the vet if" threshold logic (Apple 1.4.2)
- Video recording in-app, camera access (attach from files in v1.1)
- Multi-pet in v1 (one Pet row; engine supports many, UI shows one)
- Community, forums, sharing to groups, vet messaging
- Generic pet-care features: vaccines, vet appointments, weight goals, food
- Supabase sync / shared household — v1.1 candidate, not v1
