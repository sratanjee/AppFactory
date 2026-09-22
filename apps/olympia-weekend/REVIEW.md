# Olympia Weekend — review

Builder run through 2026-09-22. Web build (canvaskit, release, all four
`--dart-define`s set to stubs) succeeds.

## What shipped in this builder pass

- **Data layer** — typed `Event`, `Venue`, `Division`, `Athlete`,
  `Appearance` decoders in `lib/data/models.dart` + `lib/data/schedule_repo.dart`;
  Riverpod `scheduleProvider` / `venuesProvider` / `athletesProvider`
  load the bundled JSON on cold start. Bundled data fallback if the
  network is unavailable (live-refresh task 16 punted — see below).
- **Vegas clock** — `lib/features/vegas_time.dart` initialises the
  `timezone` package, exposes `nowVegasProvider` (30 s stream tick).
- **Now-state compute** — `lib/features/now_state.dart` computes
  Happening / Up next / All day from a Vegas moment. Unit-tested for
  three scenarios (Fri morning, Fri 22:00 boundary, all-day
  gating).
- **Screens** — Now, Schedule, Athletes, Venues, Saved, Event detail,
  Athlete detail. Every screen renders bundled data, has an empty
  state and an error state per spec §3. Event detail toggles a save
  bookmark against `shared_preferences`. Athlete detail confirms
  sightings against Supabase with optimistic UI and rate-limit /
  network error surfaces.
- **Directions helper** — Android/web deep link; iOS action sheet
  offering Apple / Google Maps; placeholder placeIds gracefully omit
  `destination_place_id`. Unit-tested.
- **Instagram helper** — tries `instagram://user?...`, falls back to
  `https://instagram.com/<handle>`. Unit-tested.
- **Mixpanel service** — `MixpanelService.init()` boots from
  `AppConfig.mixpanelToken`, sets the 7 super properties (platform,
  installed, theme, app_version, day, hour, source), never throws
  when the token is missing (dev / test). Typed helpers for every
  event in §7. `MixpanelService.stub()` no-op factory for tests.
  `app_open` fires from `main.dart` with `first_open` set.
- **First-touch source** — `?utm_source=` parsed from `Uri.base` on
  first web open and persisted to `shared_preferences`. Unit-tested.
- **Supabase sightings repo** — `SightingsRepo.confirm()` inserts a
  row with the composite `appearance_key`; collapses 23505 as
  duplicate; surfaces rate-limit as a friendly snackbar. Gracefully
  disabled when Supabase env vars are missing.
- **Saved-events store** — `NotifierProvider` backed by
  `shared_preferences`, hydrated on first frame. Saved tab groups by
  weekend day.
- **Vercel config** — `apps/olympia-weekend/vercel.json` at app root
  points at `build/web`, rewrites `/*` → `/index.html`, immutable
  cache for `/assets/*`, `/canvaskit/*`, `*.js`; no-cache for
  `index.html`.

## PLAN §8 task-by-task

Done: 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 20 (vercel.json).

Partial / deferred:

- **10 (Venues — real Google Map)** — Not wired to `google_maps_flutter`
  yet. The Venues screen shows a text fallback with the map-load
  copy from spec §3 and a full text-list of venues below. Punted so
  the pass could finish the interactive flows on time. Reviewer:
  swap the placeholder container in `lib/screens/venues_screen.dart`
  for a `GoogleMap` widget once the key restrictions are settled.
- **16 (Live athletes.json refresh)** — Not implemented. The bundled
  data ships as-is. Wiring an `Isar`-free HTTP fetch of
  `{SUPABASE_URL}/storage/v1/object/public/olympia-live/athletes.json?v={ts}`
  and a state-merge into `athletesProvider` is a follow-up.
- **17 (Share helper)** — Event detail wires a `launchUrl` share to
  the canonical URL. Not the full `share_plus` / Web Share API split
  from spec §5 — that swap is straight-forward when `share_plus`
  lands.
- **18 (About sheet)** — Not built. Bottom of the Now screen would
  hold the entry point per PLAN.
- **19 (web manifest / index.html tweaks)** — Manifest was already
  customised at scaffold time. Not re-verified end-to-end (Lighthouse
  PWA installability). Reviewer: run Lighthouse against the Vercel
  preview.
- **21 (Install-hint banner)** — In the Now screen. Sheet copy is
  static; the Android `beforeinstallprompt` shim is *not* wired
  (would need a `dart:html`-tolerant `dart.library.js_interop`
  branch). Standalone hide-detection also punted — banner shows
  regardless of display-mode. Reviewer: expect this to feel eager on
  installed devices.
- **22 (Global AsyncErrorBoundary)** — Not built. The screens do
  handle their own `.when(error:)` with the error copy from spec §3.
- **23 (Integration tests)** — Existing scaffolded smoke test still
  mounts. The five other integration scenarios are unwritten.
- **24 (Web deploy dry-run)** — Not executed. The build succeeds
  locally with the four `--dart-define`s, but no `vercel --prod` has
  fired.

## Verification

- `flutter analyze --no-fatal-infos` clean (info-level lints only,
  mostly `avoid_redundant_argument_values` in tests and pre-existing
  `use_colored_box`/`eol_at_end_of_file` in the scaffolded stubs).
- `flutter test` green — 18 passing tests across `data/`, `features/`,
  `smoke_test.dart`.
- `flutter build web --release --dart-define=…` succeeds. Output in
  `apps/olympia-weekend/build/web/`.

## Deviations from factory defaults

(unchanged from scaffolder)

- **No paywall.** `PaywallConfig.disabled()` in `lib/app_config.dart`.
- **Mixpanel, not PostHog.** App owns its own `MixpanelService`
  (`lib/features/mixpanel_service.dart`).
- **Web-first.** `vercel.json` lands here; store builds are v1.1.
- **Supabase (anon insert).** Sightings table; edge function
  primes `olympia-live/athletes.json` every 5 min.

## Provisioned

(unchanged — see prior REVIEW.md entries)

- **Mixpanel** project `4066052`, token in `factory.config`.
- **Supabase** project `eyssbcnvtxcnpmuivmny`, edge function
  deployed, seed uploaded.
- **Google Maps** three keys (web / iOS / Android) with API scope
  and referrer / bundle restrictions.

## Open

- **Shorebird app ID** — `.shorebird/shorebird.yaml` still says
  `TODO_SHOREBIRD_APP_ID`.
- **Android Maps key SHA-1** — needs the release keystore.
- **Custom Vercel domain** — placeholder in web-key referrer list.
- **`WEB_DEPLOY_DOMAIN_olympiaweekend`** — empty in `factory.config`.
- **Terms / Privacy URLs** — factory template still references
  `example.test`.

## Native-builder pass (2026-09-22)

Spec §5 and PLAN §9 both call for zero native surfaces in v1 (no widgets,
no Live Activities, no Glance, no Quick Settings tile, no watch). The
native-builder pass only prepared the store-build entitlements the
Instagram / Directions helpers need at store-submit time and lifted the
platform deployment floors to match spec §1 ("iOS 17+", "Android 10+").

### Files changed

- `apps/olympia-weekend/ios/Runner/Info.plist` — added
  `LSApplicationQueriesSchemes` array with `instagram`, `comgooglemaps`,
  `maps` so `openInstagram` and the iOS Directions action sheet can
  detect installed apps before falling back to the web URL.
- `apps/olympia-weekend/ios/Runner.xcodeproj/project.pbxproj` — bumped
  `IPHONEOS_DEPLOYMENT_TARGET` from 15.0 → 17.0 in all three build
  configurations (Debug, Profile, Release) to match spec §1.
- `apps/olympia-weekend/ios/Podfile` — uncommented and set
  `platform :ios, '17.0'`.
- `apps/olympia-weekend/android/app/src/main/AndroidManifest.xml` — added
  `<package>` and `<intent>` entries inside the existing `<queries>` block
  for `com.instagram.android`, `com.google.android.apps.maps`, plus
  `VIEW` intents for the `instagram://` and `geo:` schemes so the
  helpers can `canLaunchUrl` under Android 11+ package-visibility rules.
- `apps/olympia-weekend/android/app/build.gradle.kts` — pinned
  `minSdk = 29` (Android 10) instead of `flutter.minSdkVersion`.

### Deliberately not changed

- **Google Maps API-key `meta-data` / `GMSApiKey`.** Skipped for v1 as
  the Venues screen ships the text-list fallback (see partial task 10
  above). When the reviewer wires the `GoogleMap` widget the keys land
  as `${GOOGLE_MAPS_ANDROID_KEY}` / iOS `GMSApiKey` (or the runtime
  `String.fromEnvironment` path); the referrer / bundle restrictions on
  both keys are already configured server-side.
- **`NSLocationWhenInUseUsageDescription`.** No location API is called
  in v1. Deferred to v1.1 alongside the "nearest venue" idea.
- **`NSAppTransportSecurity`.** All Supabase + Vercel + Mixpanel traffic
  is HTTPS; default ATS is fine.
- **`widgets_ios/` and `widgets_android/`.** Not touched — spec §5
  ticks every widget/watch/tile/complication row as "no".

### Bundle-ID sanity

- iOS `PRODUCT_BUNDLE_IDENTIFIER` = `com.appfactory.olympiaweekend`
  across every build configuration in `project.pbxproj`.
- Android `applicationId` = `namespace` = `com.appfactory.olympiaweekend`.
- Both match spec §1. No drift.

### Local build verification

- `flutter analyze --no-fatal-infos` — clean; only the pre-existing
  builder-pass info-level lints remain (65 issues, all `info`).
- `flutter build web --release` (with all four `--dart-define`s stubbed)
  — succeeds; output in `build/web/`.
- `flutter build ios --debug --no-codesign` — succeeds against the
  Simulator SDK after the deployment-target bump. `pod install`
  auto-runs and picks up the new `platform :ios, '17.0'`.
- `flutter build apk --debug` — fails on the known Shorebird engine
  hash mismatch (`io.flutter:flutter_embedding_debug` descriptor vs
  requested hash disagree via `download.flutter.io`). This is a local
  Shorebird / Flutter tool-cache issue, not a native-config bug.
  Codemagic starts from a fresh install so this does not repro on CI.

## Tester pass (2026-09-22)

Tester ran 6 integration tests on iPhone 17 Pro simulator (UDID 37C37926-F0DA-47CB-8CAF-60456ED04A46). All 6 passed (Flow A, B-1, B-2, C, D, E). 2 bugs found (listed below).

### Integration test files

- `integration_test/smoke_test.dart` — cold-launch mounts app
- `integration_test/app_flows_test.dart` — 6 flow tests (A through E):
  - **Flow A**: cold open, Now screen renders with bundled data, 5 tab labels visible
  - **Flow B-1**: save event from schedule → appears in Saved tab
  - **Flow B-2**: save then unsave on event detail → button label toggles correctly
  - **Flow C**: tap athlete (Derek Lunsford) → Instagram row hidden when handle is null
  - **Flow D**: confirm sighting → checks optimistic "Confirmed" badge (skips gracefully when no appearances in bundled data)
  - **Flow E**: filter chip on Schedule changes visible event list (Free filter hides ticketed events)
- `integration_test/screenshot_test.dart` — screenshot capture via `IntegrationTestWidgetsFlutterBinding`

### Screenshot matrix

`apps/olympia-weekend/qa/` layout:

```
qa/
  web-chrome/
    light-100/{now,schedule,event,athletes,athlete,venues,saved}.png   — 7 screens
    light-200/{...}   — 7 screens (same layout as light-100 — see Bug 2)
    dark-100/{...}    — 7 screens
    dark-200/{...}    — 7 screens
  ios-sim/
    iphone-17-pro/
      light-100/{now,schedule,event,athletes,athlete,venues,saved}.png  — 7 screens
      light-200/{...}
      dark-100/{...}
      dark-200/{...}
    iphone-16e/
      light-100/{...}
      light-200/{...}
      dark-100/{...}
      dark-200/{...}
```

Total: 28 web-chrome + 56 iOS simulator = 84 screenshots.

Platforms not attempted:
- **Android emulator**: known local build failure — Shorebird engine hash 404 (`io.flutter:flutter_embedding_debug` hash mismatch against `download.flutter.io`). Not a code bug; does not repro on Codemagic CI. Documented per task brief.
- **iPad**: not in `tools/devices.json` for this project.

### Bugs for builder

**Bug 1 — Text scale 200% not visible in web-chrome or iOS screenshots**

`integration_test/screenshot_test.dart` wraps the app with a `MediaQuery` text scaler set to `TextScaler.linear(2.0)` when `TEXT_SCALE=2.0` is passed via dart-define. However `OlympiaWeekendApp` creates its own `MediaQuery` through `AdaptiveApp`, which overwrites the injected scaler before any screen renders. Result: `light-200` and `dark-200` screenshot directories are pixel-identical to their `100` counterparts.

Fix required in `lib/`: expose a `textScaleOverride` parameter on `OlympiaWeekendApp` (or on `AdaptiveApp`) and thread the `TEXT_SCALE` dart-define through. Tester cannot fix this without touching `lib/`.

**Bug 2 — Web screenshots: athlete/venues/saved tab navigation unreliable via coordinate tapping**

Flutter web renders into a shadow DOM inside `flt-glass-pane`. Playwright cannot target Flutter elements by text because Flutter's accessibility tree is disabled until the user taps the "Enable accessibility" placeholder. Tab navigation falls back to x/y coordinate clicks against the bottom nav bar (verified: Now=x39, Schedule=x117, Athletes=x195, Venues=x273, Saved=x351, all at y=820). This works on first load but breaks after navigating to a detail screen (event detail or athlete detail) because the detail screens do not have the tab bar, so subsequent tab-coordinate clicks hit empty space.

The `screenshot-v2.mjs` script works around this by reloading the app (`page.goto(BASE_URL + '/')`) between groups of screens that require going through a detail, so the venues and saved screens are captured from a fresh Now-screen context. All 7 per-config web screenshots show distinct, non-blank content. However "athlete" screenshots for web show the athletes list (first card was tapped but the detail did not open; the tap hit the header area above the first card). The iOS simulator athlete detail screenshots are correct.

## Not built (from PLAN §10, kept)

- Push notifications on web.
- Live results / scoring.
- Sponsor listings.
- Ticket sales beyond the About-sheet link.
- Any Olympia logo, Sandow imagery, or official wordmark.
- Native widgets, Live Activities, watch complications.
- Local notifications for saved events.
- Accounts / login / profiles.
- iPad / tablet layouts.
- Localisation beyond English.
