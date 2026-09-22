# PLAN — Olympia Weekend

## 1. App identity

- Slug: `olympia-weekend`
- Bundle ID / Application ID: `com.appfactory.olympiaweekend`
- Accent hex: `#e2231a` (Olympia red, used identically in light and dark)
- Factory category: utility (event guide)
- Platforms, ordered by ship priority: web PWA (installable, iOS Safari + Android Chrome), then iOS 17+, then Android 10+
- Deviations from CLAUDE.md, authorised by spec §0: no paywall (overrides #3), Supabase + Mixpanel network calls (overrides #2), Mixpanel replaces PostHog

## 2. The job

"I'm at Olympia and I want to know what's happening right now, what's next, and where to go, without digging through the official site."

## 3. Screens

1. **Now** (`design/olympia-weekend/*-main.html`)
   - Purpose: answer "what now, what next" in one glance, on the device's Vegas-local clock.
   - Primary action: tap "Happening now" card to open its Event detail.
   - Empty state: "Nothing on right now. Next up shows here." shown between the last event of a day and midnight local.
   - Error state: "Couldn't refresh live data. Showing the schedule that shipped with the app." Bundled data still renders.
2. **Schedule** (`design/olympia-weekend/*-schedule.html`)
   - Purpose: browse every event, filter by access.
   - Primary action: tap a row to open Event detail; filter chips (All / Free / Ticketed / At Palms) narrow in place.
   - Empty state: "No events match this filter." with a "Clear filters" button.
   - Error state: same fallback message as Now; the bundled schedule always renders.
3. **Event detail** (`design/olympia-weekend/*-event.html`, `*-expo.html`)
   - Purpose: give the three facts a fan needs (doors, venue, access) plus running order or meet-and-greets.
   - Primary action: "Directions" opens the maps sheet; "Save to my day" bookmarks.
   - Empty state: for events with no running order and no meet-and-greets, hide the section entirely rather than show a stub.
   - Error state: "Couldn't open Directions. Copy the address?" with the address and a copy button.
4. **Athletes** (`design/olympia-weekend/*-athletes.html`) with the Athlete page
   - Purpose: booths, meet-and-greets, Instagram, crowd confirmation.
   - Primary action: tap Athlete → Athlete page; "I saw this" on an appearance inserts a sighting.
   - Empty state (search): "No athletes match \"{query}\"." Empty state (division with no listings yet): "Roster still coming in from IFBB Pro. Check back Wednesday."
   - Error state: "Couldn't send that sighting. Try again in a moment." Row stays enabled.
5. **Venues** (`design/olympia-weekend/*-venues.html`) with Saved
   - Purpose: one map with five pins, drive times, shuttle note; Saved lists bookmarked events grouped by day.
   - Primary action: tap venue → Directions sheet; Saved rows open Event detail.
   - Empty state (Saved): "Nothing saved yet — tap the bookmark on any event."
   - Error state (map): "Map couldn't load. Venue list still works."

## 4. Data model

Bundled JSON assets under `apps/olympia-weekend/assets/data/`:

- **Event** — `id, date, start?, end?, title, venueId, room?, access(free|ticket|vip), divisions[], plus?, presentedBy?, featuring?, vipEntry?, generalEntry?, shuttle, amateur, notes?, runningOrder[]?, runningOrderNote?, endEstimate, doorsEstimate?`
- **Venue** — `id, name, short, address, lat, lng, placeId, role, driveFromPalmsMin?, shuttle, rooms[]?`
- **Division** — `id, name, prejudgingEventId, finalsEventId, prize?`
- **Athlete** — `id, name, divisionId, country, tagline, instagram?, booth?, appearances[]`
- **Appearance** — `date, start, end?, venueId, booth, sponsor?, status(reported|confirmed), confirmations, source`

Local device storage (`shared_preferences`):

- **Saved** — `eventId, savedAt`
- **FirstTouchSource** — `utm_source` captured on first web open, persisted forever
- **InstallHintDismissed** — bool

Remote (Supabase, anon-only):

- **Sighting** — `id, athleteId, appearanceKey, deviceId, createdAt`; RLS anon-insert (spec §4 / migration `20260922000000_sightings.sql`); unique per `(appearance_key, device_id)`; rate limit 30/device/hour via trigger.
- **Storage bucket** `olympia-live` — public; holds `athletes.seed.json` (uploaded at release) and `athletes.json` (rewritten every 5 min by `recompute-athlete-status` edge function).

Time: all display times are Las Vegas local (`America/Los_Angeles`), computed via `package:timezone` regardless of device clock.

## 5. Native surfaces

Per spec §5, v1 ships zero platform-native surfaces (no widgets, no Live Activity, no Glance, no tiles, no watch). Native-adjacent surfaces are:

- **Share** — Web Share API on web, share sheet on iOS/Android; wired from Now, Event detail, Athlete pages. Share URL carries `?utm_source=share`.
- **Maps** — Google Maps JS on web (`GOOGLE_MAPS_WEB_KEY`), `google_maps_flutter` on stores (`GOOGLE_MAPS_IOS_KEY` / `GOOGLE_MAPS_ANDROID_KEY`).
- **Add to Home Screen** — one-line dismissible banner on Now; iOS Safari opens an instruction sheet; Android intercepts `beforeinstallprompt` and shows a native prompt.
- **Directions deep links** — Android → `google.com/maps/dir/?api=1&destination={lat},{lng}&destination_place_id={placeId}`; iOS → sheet with Apple Maps (`maps://?daddr={lat},{lng}`) and Google Maps (`comgooglemaps://?daddr={lat},{lng}`), falling back to the web URL if neither app is installed.

## 6. Onboarding + paywall placement

- Onboarding screens: 0. First open lands directly on Now.
- Install-hint banner: one dismissible line under the "Today" title on Now — "Unofficial fan guide. Add to your home screen for one-tap access." with a "How" link that opens the platform-appropriate install sheet.
- Permission prompts: none. No notifications, no location, no camera in v1.
- Paywall entry point: none. `PaywallConfig.disabled()` is already wired in `lib/app_config.dart`; do not add the RevenueCat SDK.

## 7. Analytics events

Contract is `data/olympia-weekend/MIXPANEL.md`, not the factory-standard five. The five factory events (`onboarding_step`, `paywall_view`, `paywall_purchase`, `core_action`, `widget_added`) do not fire — there is no onboarding, no paywall, no widget.

Super properties (attached to every event by the Mixpanel service on startup):

- `platform` (`ios_web` | `android_web` | `desktop_web` | `ios` | `android`)
- `installed` (bool — true when display-mode standalone)
- `theme` (`light` | `dark`, from system)
- `app_version` (semver)
- `day` (`wed`…`sun` in Vegas time)
- `hour` (0–23 in Vegas time)
- `source` (first-touch `utm_source`; persisted; defaults `direct`)

Events:

| Event | When | Properties | Why |
|---|---|---|---|
| `app_open` | cold start and return from background after 5+ min | `first_open` (bool) | daily active count |
| `install_prompt_shown` | install hint appears | — | measures banner exposure |
| `install_completed` | first launch in standalone mode | — | conversion of banner to home-screen install |
| `view_now` | Now tab shown | `now_event_id`, `next_event_id` | screen mix by hour |
| `view_schedule` | Schedule tab shown | `day_selected`, `filter` | schedule popularity by day |
| `filter_change` | filter chip changed | `filter` | which filter fans use |
| `day_change` | day pill tapped | `from`, `to` | day-hop behaviour |
| `view_event` | event detail opened | `event_id`, `access`, `venue`, `from_screen` | top events, entry path |
| `save_event` | bookmark added | `event_id` | save conversion from view |
| `unsave_event` | bookmark removed | `event_id` | save churn |
| `view_saved` | Saved shown | `count` | Saved usage |
| `view_athletes` | Athletes tab shown | `division` | division interest |
| `search_athletes` | search submitted | `query_length`, `results` | search behaviour |
| `view_athlete` | athlete page opened | `athlete_id`, `division`, `has_instagram`, `has_appearance` | athlete interest |
| `open_instagram` | Instagram row tapped | `athlete_id` | Instagram funnel |
| `confirm_sighting` | "I saw this" tapped | `athlete_id`, `booth`, `resulting_status` | crowd-confirmation traction |
| `report_sighting` | user reports a new booth/time | `athlete_id` | user-reported data volume |
| `view_venues` | Venues tab shown | — | venue tab traffic |
| `view_venue` | venue row opened | `venue_id` | which venues get inspected |
| `directions_tap` | Directions pressed | `venue_id`, `maps_app` (`google` \| `apple`) | Directions usage split |
| `share_tap` | Share pressed | `screen`, `event_id?` | share funnel |
| `error` | caught exception surfaced to user | `where`, `message` | error rate by surface |

Flush cadence: on app background and every 30 s while active (Expo wifi is bad; batch generously).

## 8. Task list for the builder

Order optimises for a public web build by Thu Sep 24, 8 AM PT. Each task <2h.

1. **Wire adaptive shell and router.** Build `AppShell` with five-tab bottom navigation (Now, Schedule, Athletes, Venues, Saved) using `core/adaptive`; wire `go_router` with tab-preserving routes and platform transitions. Acceptance: `flutter analyze` clean; no `material.dart` or `cupertino.dart` import in `apps/olympia-weekend/lib/`; each tab renders a placeholder screen with its title only.
2. **Load bundled JSON assets.** Add `assets/data/schedule.json`, `venues.json`, `athletes.json` (already copied) to `pubspec.yaml`; write typed decoders (`Event`, `Venue`, `Division`, `Athlete`, `Appearance`); expose Riverpod providers `scheduleProvider`, `venuesProvider`, `athletesProvider`. Acceptance: unit test parses all three files without error and returns non-empty collections; date/start fields deserialise to `DateTime` in `America/Los_Angeles`.
3. **Build the Vegas-time clock.** Add `timezone` initialisation; expose `nowVegasProvider` (Riverpod stream tick every 30 s) that yields `TZDateTime` in `America/Los_Angeles`. Acceptance: unit test with a fake clock set to 2026-09-25 22:00 Eastern returns 19:00 Vegas.
4. **Compute Now / Up next / All day.** Pure function `computeNowState(events, nowVegas) -> {happening, next[], allDay[]}`. Acceptance: unit tests cover (a) mid-Friday pre-judging → correct `happening`, (b) Friday 22:00 → after last, `next` is Saturday's first, (c) all-day items only surface on their day.
5. **Build Now screen.** Render date title, Wed–Sun day pills, "Happening now" card (1 px red border, red dot, title, divisions, venue, until-time, access tag), "Up next" list with relative times, "All day" list, and the install-hint banner. Match `design/*-main.html` in both themes. Acceptance: golden test light + dark; taps route to Event detail; empty and error states render.
6. **Build Schedule screen.** Day pills reused; filter chips All / Free / Ticketed / At Palms; events grouped Morning / Afternoon / Evening; access tags; chevrons. Acceptance: filter combinations show correct subset; golden test light + dark matches `design/*-schedule.html`.
7. **Build Event detail.** Red 6 px top band, back link, round Save button, three-fact strip (Doors or VIP entry / Venue / Access), running order (times semibold 17), "Afterward" / "Good to know" copy, "Save to my day" + "Directions" primary actions; Expo variant swaps running order for meet-and-greets. Acceptance: golden light + dark for both variants; Save toggles `shared_preferences`; running-order rows accessible under 200% text.
8. **Build Athletes list + Athlete page.** Division chips + search; division header showing pre-judging and finals times pulled from the referenced events; athlete rows with initials avatar, tagline, booth or "No booth listed", meet-and-greet time. Athlete page: name, division, country, Instagram row (hidden when `instagram == null`), appearances list with Confirmed / Reported badge and "I saw this" button, "Report a booth or time" link. Acceptance: search filters case-insensitively; null-Instagram rows are hidden; golden light + dark.
9. **Wire Instagram deep link.** Helper `openInstagram(handle)` tries `instagram://user?username={handle}`, falls back to `https://instagram.com/{handle}`; fires `open_instagram`. Acceptance: unit test the URL-building; integration test on web falls back to https.
10. **Build Venues screen.** Google Maps widget with five pins from `venues.json`; venue rows with role and drive time; shuttle note. Acceptance: map renders on web with `GOOGLE_MAPS_WEB_KEY`; graceful text-only fallback when key is missing.
11. **Build Directions sheet.** Android → open Google Maps universal URL with `destination_place_id`; iOS → action sheet offering Apple Maps and Google Maps, falling back to the web URL if the app is not installed; web → open Google Maps in a new tab. Fires `directions_tap` with `maps_app`. Acceptance: unit test URL construction for all five venues; integration test taps each option.
12. **Build Saved screen.** Read `shared_preferences`; group events by day; empty-state copy exact. Acceptance: bookmarking on Event detail immediately updates Saved; unbookmark removes row.
13. **Wire Mixpanel service.** `core/analytics` binding: initialise from `MIXPANEL_TOKEN` at startup; set super properties from device (`platform`, `installed`, `theme`, `app_version`, `day`, `hour`, `source`); flush on background and every 30 s; anonymous device id only. Acceptance: every event in §7 has a typed helper (`Analytics.viewNow(...)`, etc); unit test that super properties are attached to every call.
14. **Capture first-touch source.** On web, read `utm_source` from `window.location.search` on first open and persist to `shared_preferences`; default `direct`. Acceptance: unit test parses `?utm_source=instagram` and persists; second open reuses stored value.
15. **Wire Supabase sightings insert.** `SightingsRepo.confirm(athleteId, appearance)` inserts a row with the composite `appearance_key` (`{athleteId}|{date}|{start}|{venueId}|{booth}`) and the anonymous device id; collapses `23505` unique-violation silently; on `rate_limited` shows a snackbar and fires `error`. Acceptance: successful insert flips local UI to "Confirmed" optimistically; rate-limit path surfaces friendly copy.
16. **Wire live athletes.json refresh.** On app open (and every 5 min while foregrounded, if online), fetch `{SUPABASE_URL}/storage/v1/object/public/olympia-live/athletes.json?v={ts}`; on success, merge appearance `status` and `confirmations` into the in-memory athletes store; on failure, keep bundled data and fire `error` with `where=live_refresh`. Acceptance: integration test with a stub server; offline mode keeps working.
17. **Build Share helper.** Web Share API on web; `share_plus` on stores; canonical URL is `{WEB_DEPLOY_DOMAIN}/e/{eventId}?utm_source=share` (or `/a/{athleteId}` for athletes). Fires `share_tap`. Acceptance: share sheet opens on both platforms; URL is copied to clipboard as fallback.
18. **Wire About sheet.** Reachable from Now header; contains "Unofficial fan guide" line, links to `mrolympia.com/tickets` and the official livestream, app version, and a "Report a fix" mailto. Acceptance: about sheet uses adaptive sheet; text renders correctly under 200% type.
19. **Customise web manifest and index.html.** `web/manifest.json`: name "Olympia Weekend", short_name "Olympia", display `standalone`, theme_color reads system pref via inline script (already staged), icons 192/512, Apple touch icon. Acceptance: Lighthouse PWA installability green in Chrome.
20. **Add Vercel deploy config.** `apps/olympia-weekend/vercel.json` at app root pointing at `build/web` output; SPA rewrite `/* -> /index.html`; `Cache-Control: public, max-age=31536000, immutable` for hashed assets; `no-cache` for `index.html`. Acceptance: `vercel --prod` from the app dir deploys a working PWA against staging.
21. **Build the install-hint banner.** Now-screen banner with copy from §6; "How" opens a sheet — iOS Safari shows Share → Add to Home Screen; Android calls the captured `beforeinstallprompt`; standalone hides the banner entirely. Fires `install_prompt_shown` and `install_completed`. Acceptance: banner appears exactly once per device on web; hidden on stores; hidden in standalone mode.
22. **Error surface.** Global `AsyncErrorBoundary` around network calls; user-visible copy uses spec §3 error strings; fires `error` with `where`, `message`. Acceptance: forced offline triggers "Couldn't refresh…"; retry works.
23. **Integration tests.** `integration_test/` covers: (a) first launch → Now renders with bundled data, (b) tap Athlete → Instagram deep link, (c) bookmark event → appears in Saved, (d) confirm sighting → optimistic flip to Confirmed, (e) rate-limited sighting shows friendly error, (f) day pill change fires `day_change`. Acceptance: green on Chrome, iOS Simulator, Android emulator.
24. **Web deploy dry-run.** `flutter build web --release --dart-define=…` with the deviation defines; `vercel --prod` to a staging domain; add to home screen on a real iPhone Safari and an Android Chrome. Acceptance: PWA installs; offline mode after first load; Mixpanel Live View shows `app_open` from the installed instance.

## 9. Task list for the native-builder

Per spec §5, v1 ships zero native surfaces. The native-builder is a no-op for v1. If store builds happen the week after web launch, the native-builder queues:

- **iOS.** Nothing shipping in v1. v1.1 candidates (deferred): local notification 30 min before saved event; small WidgetKit "Happening now" widget; App Intent "What's on now".
- **Android.** Nothing shipping in v1. v1.1 candidates (deferred): local notification 30 min before saved event; small Glance widget "Happening now"; Quick Settings tile.

The native-builder does verify the store-build entitlements: Google Maps API keys in `Info.plist` / `AndroidManifest.xml`, `LSApplicationQueriesSchemes` for `instagram`, `comgooglemaps`, `maps`, and Android `<queries>` intents for the same. Acceptance: `flutter build ios` and `flutter build appbundle` compile clean once keys land.

## 10. Deferred

- Push notifications on web (spec §11).
- Live results and scoring (link to official livestream only, spec §11).
- Sponsor listings (spec §11).
- Ticket sales or ticket-flavoured links beyond the mrolympia.com/tickets link in About (spec §11).
- Any Olympia logo, Sandow imagery, or official wordmark (spec §11).
- Native widgets, Live Activities, watch complications (spec §11; store v1.1 if the weekend goes well).
- Local notifications for saved events (store v1.1 only; not on web).
- Accounts, login, profiles, comments, chat (spec §11).
- iPad / tablet layouts beyond default phone-scaled behaviour.
- Localisation beyond English.

## 11. Open assumptions

- **Places API `placeId` values.** `data/olympia-weekend/venues.json` ships placeholder placeIds. Task 11 resolves each venue via Places API (Find Place from Text) at build and commits real IDs; if the Places key is not provisioned by Thu, the Directions URL falls back to `destination={lat},{lng}` without `destination_place_id` and still works.
- **Web renderer.** Default to `--web-renderer canvaskit` for correct SF rendering on iOS Safari. If Lighthouse or real-device testing shows canvaskit blocking install on Safari, switch to `html`. Test both during Task 24 and pick whichever renders the type scale from `DESIGN_GUIDE.md §2` correctly.
- **Four empty credentials in `factory.config`.** `GOOGLE_MAPS_WEB_KEY_olympiaweekend`, `GOOGLE_MAPS_IOS_KEY_olympiaweekend`, `GOOGLE_MAPS_ANDROID_KEY_olympiaweekend`, `SUPABASE_OLYMPIAWEEKEND_URL` / `_ANON_KEY` / `_SERVICE_ROLE_KEY` / `_PROJECT_REF` / `_DB_PASSWORD`, `WEB_DEPLOY_DOMAIN_olympiaweekend`, `WEB_DEPLOY_PROVIDER_olympiaweekend`. All required to ship. Web build gracefully text-degrades the Venues map when the maps key is missing and no-ops sightings when Supabase is missing, so a partial ship is possible if any single one lags.
- **Live athletes.json seed upload.** The edge function reads `olympia-live/athletes.seed.json` from Storage. The release task uploads the current `assets/data/athletes.json` once before scheduling the function. Assumed manual for v1 (documented in `apps/olympia-weekend/supabase/functions/recompute-athlete-status/index.ts`).
- **iOS `LSApplicationQueriesSchemes`.** Store builds must whitelist `instagram`, `comgooglemaps`, `maps`; Android needs `<queries>` for the same. Web is unaffected; landed with the native-builder pass.
- **Sibling-check.** No prior apps exist in `apps/*/store/` under the "utility (event guide)" factory category — `apps/*` today are `wash-quote`, `kidney-log`, `seizure-log`, none of which share glyph, accent, or story. No collision to design around.
