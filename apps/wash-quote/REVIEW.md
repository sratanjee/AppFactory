# 'Wash Quote & Invoice' — review

Builder implementation landed on `app/wash-quote`.

## Built

- App shell: four-tab bar (Jobs / Customers / Services / Money), `go_router`
  routes for `/boot`, `/onboarding`, `/home`, `/quote/new`, `/job/:id`.
- Drift schema v1 for Businesses, Customers, Services, Jobs, LineItems,
  Photos; per-DAO unit tests.
- Onboarding flow (3 steps) plus starter service seed on first launch.
- `core/paywall` presented at `after_onboarding` (onboarding complete) and
  `first_save` (hero-card tap and quote save) via `ensureProEntitlement`.
- Jobs screen: hero card, Quotes / Invoices segmented toggle, waiting-list
  horizontal row, accepted-this-week list, Customers sub-mode grouped by
  customer name.
- Services screen: add, edit, delete, reorder with `ReorderableListView`.
- Quote builder: customer picker sheet, service line adder, qty stepper
  per line, live total, deposit % stepper, pay-via input pre-filled from
  Business.payVia, before-photos strip.
- Camera capture: image_picker + one-line rationale dialog, photos land in
  app documents dir under `photos/photo_<millis>.<ext>`.
- Job detail / PDF preview, PDF renderer, share sheet, convert to invoice,
  Stripe payment link stub, Money screen totals, follow-up local
  notification, iCloud/Drive backup + PDF/CSV export, and analytics wiring
  for the five standard events plus `pdf_sent` and `deposit_link_created`.

## Native surfaces

- iOS: `NewQuoteIntent` App Intent + `WashQuoteShortcuts` App Shortcut
  provider in `ios/Runner/WashQuoteIntents.swift`. Runs "New quote" from
  the Shortcuts app and Siri; opens the app and deep-links via
  `washquote:///quote/new`, arming the camera. SF Symbol
  `camera.viewfinder`.
- iOS permission strings in `ios/Runner/Info.plist`:
  `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
  `NSPhotoLibraryAddUsageDescription`. Copy from PLAN §6.
- iOS URL scheme `washquote` registered in `CFBundleURLTypes` with
  `FlutterDeepLinkingEnabled` so go_router receives the path.
- Android: `NewQuoteTileService` Quick Settings tile in
  `android/app/src/main/kotlin/.../NewQuoteTileService.kt`. Tile fires
  `washquote:///quote/new` deep link; label `New quote`; Material
  camera glyph in `res/drawable/ic_qs_tile_new_quote.xml`.
- Android manifest: `android.permission.CAMERA` +
  `android.permission.POST_NOTIFICATIONS`; MainActivity
  intent-filter for `washquote://…`; `flutter_deeplinking_enabled`
  meta-data.
- Android build: enabled core library desugaring (needed by
  `flutter_local_notifications` for the follow-up reminder), added
  `com.android.tools:desugar_jdk_libs:2.1.4`, pinned `minSdk=29` per
  spec §1 (Android 10+).

## Cut (not built)

- Home screen widget / lock widget / Live Activity / watch complication —
  spec §5 excludes.
- Weekly subscription tier — spec §6 excludes.
- Supabase multi-device sync — spec §11.
- iOS Control Center control — PLAN §9 iOS task 2 lists it, but it
  requires a separate WidgetKit extension target with its own bundle
  and entitlements. Deferred until the factory adds a `widgets_ios`
  extension scaffolder; App Shortcut alone is what spec §5 requires.

## Deferred (pending decisions)

- iCloud Drive / Google Drive automatic backup — PLAN §4 asks for
  transparent sync; the current release ships an on-demand export path
  (CSV + PDFs + Drift DB file into `<docs>/exports/`, then a share sheet)
  and leaves the native cloud-provider integration for a follow-up when a
  factory-level plugin choice is settled.

## Open questions

- Shorebird app ID still `TODO_SHOREBIRD_APP_ID` (from scaffold step); fill
  before first release.
- RevenueCat annual / lifetime products must exist in RC dashboard with
  identifiers matching the offering; the paywall lists whatever RC returns.
- Terms / privacy URLs point at `sratanjee.github.io/appfactory-site/…` —
  confirm those pages exist before store review.

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged, not blocking."

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged, not blocking."

- Shorebird app ID — `.shorebird/shorebird.yaml` still says `TODO_SHOREBIRD_APP_ID`.
- RevenueCat keys — read at build via --dart-define; blank locally.
- Terms / Privacy URLs — `lib/app_config.dart` uses `example.test`; swap before release.
- Scaffold template lints — fixed inline in `lib/app_config.dart` (double-quote outer for benefits[1]) and `lib/screens/home_screen.dart` (`const Text` in `AdaptiveScaffold.title`). Same bugs in `tools/scaffold/lib/templates.dart` — factory-level fix, out of scope for per-app scaffolder.
- Bundle ID normalization — `flutter create --project-name wash_quote --org com.appfactory` emits `com.appfactory.washQuote` (iOS, camelCased) / `com.appfactory.wash_quote` (Android). Overwrote both to `com.appfactory.washquote` per spec §1 and scaffolder agent step 3. Kotlin source package left as `com.appfactory.wash_quote` (different concept from applicationId, compiles fine). Generator should collapse hyphens for slug-with-hyphen apps by default.
