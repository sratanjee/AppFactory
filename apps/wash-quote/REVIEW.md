# 'Wash Quote & Invoice' — review

## Reviewer sign-off — round 2
Pass. Ship this.

### Built

- App shell: four-tab bottom bar (Jobs / Customers / Services / Money) with
  `go_router` routes `/boot`, `/onboarding`, `/home`, `/quote/new`,
  `/job/:id`; adaptive Cupertino/Material 3 per platform via `core/adaptive`.
- Drift schema v1 for Business, Customer, Service, Job, LineItem, Photo,
  each with a per-DAO unit test.
- Onboarding flow (3 steps) with starter service seed on first launch, and
  a thin top progress bar (no "Welcome to..." screen).
- `core/paywall` presented at `after_onboarding` and `first_save` via
  `ensureProEntitlement`. `pro` entitlement gates the hero card.
- Jobs screen matches `design/jobs.html`: large-title header, Quotes /
  Invoices segmented control, full-width accent hero card with camera
  glyph in a translucent disc, horizontal waiting-list, plain "Accepted
  this week" list with accent dot + tabular amounts, four-tab bar.
- Services screen: add / edit / delete / reorder via
  `ReorderableListView`.
- Quote builder: customer picker sheet, service line adder, qty stepper,
  live total, deposit % stepper, pay-via input pre-filled from Business,
  before-photos strip.
- Camera capture via `image_picker` behind an in-context one-line
  rationale, files land in `<docs>/photos/photo_<millis>.<ext>`.
- Job detail / PDF preview: renderer (logo, business name, line items
  table, deposit line, pay-via, photo pages, US-Letter/A4 by locale),
  share sheet, convert-to-invoice, add-after-photos, Stripe deposit-link
  client with inline error handling.
- Money screen with This week / This month / All time toggle and
  Quoted / Accepted / Invoiced / Paid totals.
- Follow-up local notification (3 days after `sentAt` if still `sent`),
  opt-in prompted after first send.
- On-demand export (Drift DB + PDFs + CSV) via share sheet.
- Analytics: standard five (`onboarding_step`, `paywall_view`,
  `paywall_purchase`, `core_action`, `widget_added`) plus `pdf_sent` and
  `deposit_link_created` per PLAN §7.

### Native surfaces

- iOS: `NewQuoteIntent` App Intent + `WashQuoteShortcuts` App Shortcut in
  `ios/Runner/WashQuoteIntents.swift`; deep-links `washquote:///quote/new`
  and arms the camera. `NSCameraUsageDescription`,
  `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`
  with PLAN §6 copy. URL scheme registered in `CFBundleURLTypes` with
  `FlutterDeepLinkingEnabled`.
- Android: `NewQuoteTileService` Quick Settings tile in
  `android/app/src/main/kotlin/.../NewQuoteTileService.kt`, fires the same
  deep link. Manifest gates `android.permission.CAMERA` +
  `android.permission.POST_NOTIFICATIONS`; MainActivity intent-filter for
  `washquote://…`. Core library desugaring enabled for
  `flutter_local_notifications`; `minSdk=29` per spec §1.

### Round-2 blocker fixes (verified against diff)

1. **Cupertino nav-bar hero-tag collision (commit `4c60b7a`).**
   `AdaptiveScaffold` gained `transitionBetweenRoutes` (default `false`)
   forwarded to both `CupertinoNavigationBar` and
   `CupertinoSliverNavigationBar`. Covered by
   `packages/core/test/adaptive/adaptive_scaffold_test.dart` — four
   coexisting Cupertino scaffolds, sliver variant, and per-instance opt-in.
2. **200% text-size overflows (commit `e6ac2d2`).**
   Onboarding `_StarterRow` refactored to a `Wrap` with a 110pt price
   input cell that drops to a second line at large text. Jobs `_HeroCard`
   dropped its fixed 168pt height, uses `mainAxisSize.min` with an
   explicit 24pt gap and `maxLines: 2` + ellipsis on both text runs.
   Money's four-tile column became a responsive `_TotalsGrid` (2×2 on
   ≥440pt width, 1×4 otherwise) with `FittedBox` on the price so large
   numerals scale down. Covered by
   `apps/wash-quote/test/screens/text_scale_overflow_test.dart` — pumps
   each screen at `textScaler=2.0` and asserts `takeException()` is null.
3. **Paywall gate dead-ends without RC keys (commit `dbc69a6`).**
   `Paywall.isDisabled` getter added; `hasEntitlement()` returns `true`
   when `isDisabled && (kDebugMode || kIsWeb)`. `ensureProEntitlement`
   in `apps/wash-quote/lib/features/paywall_gate.dart` short-circuits
   to `true` when the paywall is disabled at all, so a factory-scaffold
   default (or an accidental release without keys) opens the gated
   action instead of no-op'ing. Covered by
   `apps/wash-quote/test/features/paywall_gate_test.dart` and the
   updated `packages/core/test/paywall/paywall_test.dart`.
4. **Onboarding replay (commit `dff1d8d`).**
   New `packages/core/lib/storage/reset.dart` exports `resetAppData`,
   which clears the KV store and truncates every user Drift table.
   Refuses to run in release mode unless `allowInRelease: true`. A
   `Reset (debug)` pill wired into `apps/wash-quote/lib/screens/app_shell.dart`
   is visible only under `kDebugMode`; tap runs `resetAppData` on the
   app's KV + `AppDatabase` and routes to `/boot` so onboarding re-runs.
   Covered by `packages/core/test/storage/reset_test.dart`.

### Cut (from spec, agreed)

- iOS Control Center control (PLAN §9 iOS task 2): requires a separate
  WidgetKit extension target with its own bundle + entitlements. Deferred
  until the factory adds a `widgets_ios` extension scaffolder. Spec §5's
  "App Intents / App Shortcuts" requirement is satisfied by the App
  Shortcut alone.
- iCloud Drive / Google Drive automatic backup (PLAN §4 layer 2): the
  current release ships an on-demand share-sheet export (CSV + PDFs +
  Drift DB); the native cloud-provider integration waits on a
  factory-level plugin choice.
- No home widget, no lock widget, no Live Activity, no watch complication
  (spec §5 excludes — no glanceable number).
- Weekly subscription tier (spec §6 excludes — monthly + annual +
  lifetime).
- Supabase multi-device sync (spec §11).

### Non-blocking notes

- Round-1 QA screenshots under
  `apps/wash-quote/qa/iphone-17-pro/light/100/*.png` predate the r2 fixes
  (the pass captured with the paywall bug swallowed, hero card overflowing,
  Money as a hard 4-column stack). Tester needs to re-shoot the matrix on
  the r2 code before the release step — that's the tester's job, not a
  reviewer blocker.
- Store screenshots (5 per platform, non-placeholder) still need to be
  generated. Release step handles this.
- Android emulator install blocked in round 1 with
  `INSTALL_FAILED_INSUFFICIENT_STORAGE` on the local AVDs. Factory infra
  issue — bigger AVD storage or a CI emulator lane. Not app-scope.

### Open questions for founder

- Shorebird app ID still `TODO_SHOREBIRD_APP_ID` in
  `.shorebird/shorebird.yaml`; needs the real ID before first release.
- RevenueCat annual / lifetime / monthly products must exist in the RC
  dashboard with identifiers matching the offering; the paywall renders
  whatever RC returns.
- Terms / privacy URLs point at `sratanjee.github.io/appfactory-site/…`;
  confirm those pages exist before store review.

Pass. Ship this.
