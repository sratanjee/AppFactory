# PLAN — Wash Quote & Invoice

## 1. App identity

- Slug: `wash-quote`
- Bundle ID / Application ID: `com.appfactory.washquote`
- App class name: `WashQuote`
- Accent hex: `#0a6ea8`
- Factory category: `trade-tool` (developer account A)
- Engine: standalone (does NOT use `packages/condition_log/`)

## 2. The job

"I want to price a job while I'm standing in the customer's driveway and send them a PDF before I drive off, so that I stop losing jobs to the guy who quoted first."

## 3. Screens

Five screens, matching spec §3 exactly. All built against `core/adaptive`.

### 3.1 Jobs (home)

- Purpose: single home surface for every open and closed job; funnels new work through one hero.
- Layout: large-title "Jobs" with inline Quotes / Invoices segmented control; full-width 168-pt rounded (22 pt) accent hero card "New quote from the driveway" with camera glyph in translucent disc, subline "Snap the surface, pick a service, send the PDF"; horizontal row of 150-pt photo-thumbnail quote cards under "Waiting on the customer · N · $X" with status pill; plain list "Accepted this week" with accent dot + tabular amounts; four-tab bottom bar Jobs / Customers / Services / Money, accent on selected.
- Primary action: tap hero card → new quote flow (camera first).
- Empty state (no jobs yet): hero card only, plus one line under it: "No quotes yet. Snap the driveway and price it."
- Error state (Drift read fails): "Can't open your jobs. Force-quit and reopen." Retry button.

### 3.2 Quote builder

- Purpose: price a job in under a minute in the customer's driveway.
- Layout: customer field (tap to pick or add), service lines (add from price list), qty stepper per line, live total pinned above the primary button, deposit % row, pay-via text row (pre-filled from Business.payVia), "Before photos" strip.
- Primary action: "Save quote" (full-width, bottom-anchored above safe area).
- Empty state (no services yet): inline row "Add a service to start. Uses your prices." with a link to Services tab.
- Error state (save fails): inline banner "Couldn't save. Try again." Save button stays enabled.

### 3.3 Job detail / PDF preview

- Purpose: show the branded PDF exactly as the customer will see it and let the operator send, convert, add photos, or create a deposit link.
- Layout: PDF preview at top (logo, business name, lines, deposit line, pay-via text, photo pages); status chip (Sent / Accepted / Invoiced / Paid); action row: "Send PDF", "Convert to invoice", "Add after photos", "Deposit link".
- Primary action: "Send PDF" (opens platform share sheet with the rendered PDF file).
- Empty state (no photos on invoice yet): "Add after photos" row surfaces at top of action row with tap target.
- Error state (Stripe link creation fails): inline red row under "Deposit link": "Deposit link didn't create. Send the PDF and try again." PDF send stays available.

### 3.4 Services (price list)

- Purpose: the operator's price list, reused on every quote.
- Layout: list of services (name, unit, unit price); reorderable; "+ Add service" row at top.
- Primary action: "Add service" (sheet with name, unit selector sqft/linft/flat/hour, unit price).
- Empty state: "Add what you charge for. House soft wash, driveway, roof, deck." with "Add service" button. (Onboarding seeds this, so should be rare.)
- Error state (save fails): inline banner "Couldn't save that service." Field-level validation for empty name or non-positive price.

### 3.5 Money

- Purpose: at-a-glance totals of what was quoted, accepted, invoiced, paid, filterable by period.
- Layout: period toggle (This week / This month / All time); four large numbers with labels: Quoted, Accepted, Invoiced, Paid; tap a total to open a filtered job list.
- Primary action: tap total → filtered job list on Jobs tab.
- Empty state: "Nothing here yet. Send your first quote."
- Error state (aggregate query fails): "Totals unavailable. Force-quit and reopen." Retry button.

Customers tab is a filtered view of Jobs grouped by customer; not a separate screen file, just a Jobs sub-mode.

## 4. Data model

All entities live in Drift (source of truth). Only `Job.stripeLinkUrl` is written by a backend response.

- `Business` (singleton row): `name`, `logoPath?`, `phone?`, `email?`, `address?`, `payVia` (text), `defaultDepositPct` (int), `termsText?`.
- `Customer`: `id`, `name`, `phone?`, `email?`, `address?`.
- `Service`: `id`, `name`, `unit` (enum: `sqft` | `linft` | `flat` | `hour`), `unitPrice` (cents), `sortOrder`.
- `Job`: `id`, `customerId`, `status` (enum: `quote` | `sent` | `accepted` | `invoiced` | `paid`), `number` (seq int, per-business monotonic), `createdAt`, `sentAt?`, `depositPct` (int), `notes?`, `stripeLinkUrl?` (backend-provided).
- `LineItem`: `id`, `jobId`, `serviceId`, `description` (text, defaults from Service.name), `qty` (decimal), `unitPrice` (cents, snapshot), `total` (cents, computed on write).
- `Photo`: `id`, `jobId`, `path` (local file path), `kind` (enum: `before` | `after`), `takenAt`, `caption?`.

Sync / backup:
- Layer 1 (source of truth): Drift.
- Layer 2 (backup): automatic Drift DB file backup to iCloud Drive / Google Drive, including `Photo.path` files. User-owned export: every job as PDF; jobs as CSV (columns: number, status, customer, total, depositPct, sentAt, paidAt). Written to a per-app iCloud Drive / Google Drive folder.
- Layer 3 (Supabase sync): explicitly out of scope, §11.
- Layer 4 (shared backend): RevenueCat webhooks + Stripe payment link creator. App sends `{ amount_cents, currency, job_number, business_name }`; receives `{ url }`. Server holds the Stripe key.

## 5. Native surfaces

Only what's ticked in spec §5.

- Camera: before/after photo capture on the quote builder and invoice. Permission asked in context on first tap of the hero card, after a one-line explanation screen: "Photos of the surface go on the PDF so the price makes sense."
- Notifications (local only): follow-up reminder "Quote to {customerName} sent {N} days ago, follow up?" scheduled 3 days after `Job.sentAt` if `Job.status == sent`. Opt-in prompt after first quote is sent, not on launch.
- Share extension out: iOS `UIActivityViewController` and Android `ACTION_SEND` fed the rendered PDF file (mime `application/pdf`). No inbound share target.
- App Intents / App Shortcuts:
  - iOS: `NewQuoteIntent` (App Intent + App Shortcut), opens app on the quote builder with camera armed. Also surfaced as a Control Center control at small size.
  - Android: `NewQuoteActivity` deep link and a Quick Settings tile that opens the same route.
- No home screen widget, no lock screen widget, no Live Activity, no watch complication in v1.

## 6. Onboarding + paywall placement

Three onboarding screens (spec §7), each asking one question, no "Welcome to..." screen. Thin progress bar at the top.

1. "What's the business called?" — text field for business name, optional logo picker. Writes `Business.name`, `Business.logoPath`.
2. "What do you charge for?" — starter list preselected (house soft wash, driveway, roof, deck, fence, commercial flatwork), editable per-unit prices, unit per row. Writes to `Service` rows.
3. "How do customers pay you?" — pay-via free text (placeholder "Venmo / Zelle / Square / check"), default deposit % stepper. Writes `Business.payVia`, `Business.defaultDepositPct`. On "Continue" → paywall.

Paywall placement: after onboarding step 3, before first real use, and again on first save attempt from the quote builder if the user somehow gets past onboarding without entitlement. Fed by RevenueCat offerings (products already provisioned in ASC + RC; annual pre-selected with saving shown against monthly; lifetime as third option; 7-day trial on annual only). Close X appears top-left after 2 seconds on iOS. Entitlement key: `pro`.

Permission prompt copy:
- Camera: "Photos of the surface go on the PDF so the price makes sense."
- Notifications: "Get a reminder to follow up on quotes that go cold."

## 7. Analytics events

Standard five from CLAUDE.md:

- `onboarding_step` — fired on entry to each of the three onboarding screens, with `step` index.
- `paywall_view` — fired on paywall entry, with `placement` = `post_onboarding` or `first_save`.
- `paywall_purchase` — fired on successful purchase, with `product_id`.
- `core_action` — fired on `Save quote` success. `action` = `save_quote`.
- `widget_added` — fired when the iOS App Shortcut donation or Android QS tile is added. `surface` = `ios_shortcut` | `android_qs_tile`.

App-specific (with justification, one line each):

- `pdf_sent` — the whole product is "send the PDF before you drive off"; the send is a distinct funnel step from save.
- `deposit_link_created` — Stripe backend call is the one place a network failure is user-visible; needs its own success/failure event.

## 8. Task list for the builder

Ordered, each <2h, each with acceptance criteria.

1. **Wire app shell against `core/adaptive`.** Adaptive scaffold, four-tab bottom bar (Jobs / Customers / Services / Money), `go_router` routes, dark-mode from system. Accept: `flutter analyze` clean; tab bar renders Cupertino on iOS sim and Material 3 on Android emulator; predictive back and swipe-back both work.
2. **Add Drift schema and DAOs for Business, Customer, Service, Job, LineItem, Photo.** Migrations at v1. Accept: unit tests for each DAO cover insert, update, delete, and one query used by a screen.
3. **Build onboarding flow (3 screens) and seed starter services.** Accept: fresh install completes onboarding in under 30 seconds; `Business` row and 6 `Service` rows exist afterward; analyzer clean; unit test covers "seed only runs on first launch".
4. **Wire `core/paywall` at post-onboarding placement and first-save fallback.** Accept: without `pro`, tapping the hero card routes to paywall; with `pro` it opens the quote builder; sandbox purchase on both platforms flips the state.
5. **Build Jobs screen with hero card, waiting-list row, accepted-this-week list, Quotes / Invoices segmented toggle.** Accept: renders empty state; renders 3-job fixture; toggle switches list source; 200% text does not clip.
6. **Build Services (price list) screen with add / edit / reorder.** Accept: adding a service updates the list; reorder persists across app restart; validation blocks empty name / non-positive price.
7. **Build quote builder screen (customer picker, service line add, qty stepper, live total, deposit %, pay-via, before-photos strip).** Accept: adding two lines and one photo yields the correct total; save writes a `Job` with `status = quote` and matching `LineItem` + `Photo` rows; empty-state links to Services tab.
8. **Wire camera capture for before / after photos.** Uses `core/permissions` for the in-context prompt; images written to app documents dir; `Photo` row created with local path. Accept: permission prompt appears once, only after tap; denying does not crash; captured photo appears in the strip.
9. **Build PDF renderer (logo, business name, line items table, deposit line, pay-via text, photo pages).** Deterministic layout, one A4 / US-Letter locale switch based on device region. Accept: golden-file test renders identical bytes for a fixed fixture; renders correctly with and without a logo; renders with 0 and 6 photos.
10. **Build Job detail / PDF preview screen with share sheet, convert-to-invoice, add-after-photos, deposit-link.** Accept: share sheet receives the PDF file with correct mime type; convert-to-invoice moves status `sent` → `invoiced` and re-renders; deposit-link failure shows the inline error while PDF send remains available.
11. **Wire Stripe payment link backend call from `core/backend`.** Sends `{ amount_cents, currency, job_number, business_name }`, writes `stripeLinkUrl` on `Job`. Accept: mocked backend returns URL and is written to Drift; failure surfaces inline error, no crash, no toast.
12. **Build Money screen with weekly / monthly / all-time totals for quoted, accepted, invoiced, paid.** Accept: tapping a total opens Jobs tab pre-filtered; period toggle recomputes; empty state shows.
13. **Wire follow-up local notification (3 days after `sentAt` if still `sent`).** Opt-in prompted once after first send. Accept: unit test verifies scheduling and cancellation on status change; deny path is silent.
14. **Wire iCloud Drive / Google Drive backup of Drift DB file plus photo dir, and PDF/CSV export.** Uses `core/storage` backup helpers. Accept: manual test writes backup file and reads it back on a fresh install; CSV opens in Numbers and Sheets; PDFs open in iOS Files, Gmail and WhatsApp.
15. **Wire the five standard analytics events plus `pdf_sent` and `deposit_link_created` through `core/analytics`.** Accept: instrumentation test confirms every event fires exactly once per user action; no events fire before onboarding step 1.
16. **Add empty and error states for all five screens per §3.** Accept: fixture toggle in debug menu renders each state; screenshots captured for reviewer.
17. **Add integration tests: onboarding → paywall → save quote → send PDF → convert to invoice.** Runs on iOS Simulator and Android emulator. Accept: green on both platforms; test uses fake RC entitlement in debug.

## 9. Task list for the native-builder

Ordered, per platform. Only surfaces ticked in §5.

### iOS (Swift, `widgets_ios` where reusable; app target otherwise)

1. **Add `NewQuoteIntent` App Intent + App Shortcut.** Deep-links to `washquote://new`. Accept: Shortcuts app lists "New quote"; running it opens the builder with camera armed.
2. **Add Control Center control for "New quote" at small size.** Accept: appears in Control Center picker under App Factory; tap opens builder.
3. **Wire `UIActivityViewController` share sheet from Flutter via `core/share_bridge` for PDF export.** Accept: PDF appears in Mail, Messages, Files, WhatsApp.
4. **Camera permission `NSCameraUsageDescription` in Info.plist with the copy from §6.** Accept: prompt shows the exact copy; App Store review passes the string check.
5. **Local notification permission `UNUserNotificationCenter` request path.** Accept: prompt fires only after first PDF send.

### Android (Kotlin, `widgets_android` where reusable; app module otherwise)

1. **Add `NewQuoteActivity` with deep-link intent-filter for `washquote://new`.** Accept: adb intent launches the builder with camera armed.
2. **Add Quick Settings tile "New quote".** Uses accent as fallback tint; dynamic color where available. Accept: appears in QS editor; tap opens builder.
3. **Wire `ACTION_SEND` chooser from Flutter for PDF export via `core/share_bridge`.** Accept: PDF appears in Gmail, Drive, WhatsApp chooser.
4. **Camera permission runtime prompt with rationale copy from §6.** Accept: rationale shown once before the system prompt; denial state handled.
5. **Notification permission (Android 13+) request path tied to first PDF send.** Accept: prompt fires only after first send; older devices skip the permission but still schedule.

## 10. Deferred (Not built)

- Home screen widget, lock screen widget, Live Activity, watch complication (§5 explicitly excludes; no glanceable number).
- Inbound share target (spec §5 explicitly excludes).
- Weekly subscription tier (spec §6 says none; monthly-only alongside annual and lifetime).
- Scheduling, booking, calendar, route planning (§11).
- In-app card payments, Tap to Pay, Stripe Connect onboarding (§11); payment link only, server-created.
- Customer portal, e-signature, quote acceptance tracking beyond manual status change (§11).
- Automatic sq-ft measurement, satellite measuring, AI pricing (§11).
- Lawn care / other trades templates (§11).
- Team members, multi-truck, QuickBooks sync (§11).
- Supabase sync / multi-device (§11; not a v1.1 candidate for trade-tool).
- Customers tab as a separate screen (spec §3 note: it is a filtered Jobs sub-mode).
- Analytics beyond the standard five plus `pdf_sent` and `deposit_link_created` (CLAUDE.md rule).

## 11. Open assumptions

- Job number sequence is per-business monotonic starting at 1001; spec §4 says `number(seq)` without a starting value, and 1001 gives every quote a four-digit look on the PDF.
- Locale for PDF paper size: US-Letter for `en_US`, A4 for every other locale. Spec does not specify; this matches the target US operator without breaking non-US test devices.
- `Photo.path` files are backed up alongside the Drift DB. Spec §4 says "including attached images"; interpreted as writing the whole photo dir into the iCloud / Drive backup payload.
- CSV columns: number, status, customer, total, depositPct, sentAt, paidAt. Spec §4 says "jobs as CSV" without column names.
- Follow-up notification cadence: single reminder at 3 days after `sentAt`. Spec §5 gives the example copy "3 days ago" but not a cadence; a single fire keeps it out of the noisy-notifications review risk.
- Control Center control on iOS is small size only. Spec §5 lists "Control Center controls" via App Intents but no size; small is the safest single choice.
- Paywall re-appears on first save attempt as a defensive fallback if a user reaches the builder without `pro`. Spec §6 says "after onboarding step 3, before first real use"; treating "first real use" as the save action covers the corner case.
