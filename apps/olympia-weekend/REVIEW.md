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
