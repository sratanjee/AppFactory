# Build queue — eight specs

Read by the Planner before any `/build-app`. Order, engine sharing, accounts and the storage layering that every spec's §4 assumes are all here so they do not have to be re-derived per app.

## Order

| # | Spec | App | Account | Engine | Why this slot |
|---|---|---|---|---|---|
| 1 | `01-wash-quote.md` | Wash Quote & Invoice | A | standalone | Strongest survivor: business buyer already paying Jobber $29–49/mo, one reachable trade community, hard paywall is an advantage. Only app that needs the Stripe payment-link backend. |
| 2 | `02-seizure-log.md` | Seizure Log | B | **builds the condition-log engine** | Highest stickiness in the portfolio (lifelong daily dosing; RVC users kept 4.5 years of data until it broke); no competent incumbent. Engine entities: Pet, Event, Dose, Medication, Measurement, Note, ReportRun + report generator. |
| 3 | `03-pet-diabetes.md` | Pet Diabetes Log | B | **second SKU on the engine** | Only verified large community (FDMB, 34.9K members); incumbents documented as broken; wedge is no account + FDMB-layout CSV. Name must not be "Feline Diabetes". |
| 4 | `04-trucker-log.md` | Owner-Operator Log | A | standalone | **Provisional.** Structural fit only (business buyer, per-load workflow, no camera / background location); zero competitor or price data. Community-check on r/Truckers before assigning the day. |
| 5 | `05-kidney-log.md` | Kidney Care Log | B | **third SKU on the engine** | Cut only after the engine has converted a paying user on 02 or 03. Same buyer psychology as 03; daily three-task check-in is the habit. |
| 6 | `06-schedule-e-log.md` | Schedule E Log | A | standalone | **Build in December, launch first week of January.** One paid feature (line-mapped Schedule E export); $39.99 one-time, anchored by Landlordy. |
| 7 | `07-notary-journal.md` | Notary Journal | A | standalone | Fits the surviving pattern but was not battle-tested; state journal rules are the risk, so fields stay generic with a state setting. Serif typeface. |
| 8 | `08-vape-free.md` | Vape-Free | C | standalone | **Optional / last.** Weakest survivor; outcome depends on short-video distribution, not product. Skip the day if there is no concrete TikTok / Reels plan. |

Accounts: A = trade-tool (1, 4, 6, 7); B = condition-log (2, 3, 5); C = faith-recovery (8). Spreading apps across accounts limits Apple 4.3 blast radius.

Factory categories: 1, 4, 6, 7 = `trade-tool`; 2, 3, 5 = `utility` (noted "condition-log"); 8 = `faith-recovery`.

## Condition-log engine (apps 2, 3, 5)

Built once during app 2 in the shared package. SKUs add configuration (event kinds, measurement kinds, report template, exporter), never new entities. No dosing advice, dose calculators, or computed clinical staging in any SKU (Apple 1.4.2); each carries a persistent "talk to your vet" line. Sibling rule still applies: different accent, glyph, home layout, onboarding copy and screenshot story (purple calendar / orange curve / teal ring as drawn).

## Storage layering (applies to every spec's §4)

- **Layer 1 — source of truth:** local SQLite via Drift. No login on first run, ever.
- **Layer 2 — day one, no account:** automatic database backup file to iCloud Drive / Google Drive (including attached images where the app has them), plus user-owned export: CSV and/or PDF as fits the app (vet PDF + CSV for 2/3/5; quote and invoice PDFs for 1; Schedule E PDF/CSV for 6; journal PDF/CSV for 7; CSV for 4 and 8). Data loss on update is the entire negative-review history of the pet category; backup and export are not optional.
- **Layer 3 — paid, not in v1:** optional Supabase sync (one shared project, `app_id` column, RLS per user, Sign in with Apple / Google), shown only after purchase, for multi-device and shared-household use. Listed in every spec's §11. Marked **v1.1 candidate** for apps 2, 3 and 5 (shared household is the paid feature in that category); plain out-of-scope for 1, 4, 6, 7; not planned at all for 8.
- **Layer 4 — shared backend:** RevenueCat webhooks for all eight; Stripe payment links for app 1 only. No AI proxy in any of these eight.

So every spec has `Backend needed? subscription-webhook-only` (app 1: `subscription-webhook-only + stripe-payment-link`) and `Sync? iCloud/Google backup`.

## Common rules already applied in the specs

- Paywall after the last onboarding screen, before first real use; 7-day trial on annual, annual pre-selected, lifetime as the third option (exceptions: 06 is one-time only with no trial; 05 and 07 have no monthly tier). The template's "Weekly price" row is filled "none" everywhere; monthly prices are noted in that row where they exist.
- Onboarding: 2–4 screens, one question or promise each, answers personalize the home screen.
- Widgets: 2 (days since), 3 (last reading), 5 (today's ring), 8 (days + lock screen). Live Activity: 2 (seizure timer), 4 (load in progress, optional). Camera: 1 and 6. App Shortcut + Android QS tile for the single most common action in every app.
- Dark theme only: 4 and 8. Serif: 7.

## Platforms

Every app ships to iOS and Android from the same commit, same version. The Builder writes one Flutter codebase against `core/adaptive`; the Native Builder ships both the Swift and the Kotlin widget targets for anything ticked in §5; the Tester runs on an iOS Simulator and an Android emulator; Release uploads to TestFlight and Play internal testing in the same run. A spec is not done if either platform is missing.
