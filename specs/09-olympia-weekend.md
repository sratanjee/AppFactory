# App Spec — Olympia Weekend

> Filled from `SPEC_TEMPLATE.md`. **Out-of-pattern for the factory:** free, no paywall, web target first, Mixpanel instead of PostHog, a small Supabase table for crowd confirmations. Every deviation is called out in §4 and §6 and overrides CLAUDE.md non-negotiables 2 and 3 for this app only.
> **Hard deadline:** a public link people can add to their home screen by **Thursday, Sep 24, 8 AM PT**. Stores come the week after.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Olympia Weekend |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Unofficial fan guide, Vegas 2026 / What's on now, what's next, where it is, and which athletes are at the expo. Unofficial. |
| Slug | olympia-weekend |
| Bundle ID / Application ID | `com.appfactory.olympiaweekend` |
| Category (store) | Sports |
| Developer account | A |
| Factory category | utility (event guide) |
| Platforms | **Web first** (installable PWA, iOS Safari + Android Chrome), then iOS 17+ and Android 10+ from the same Flutter codebase. Adaptive UI per DESIGN_GUIDE §1. |
| Design references | `design/light-*.html` (Option A) and `design/dark-*.html` (Option B). Theme follows the system; dark is the fallback. |

## 2. The job

> "I'm at Olympia and I want to know what's happening right now, what's next, and where to go, without digging through the official site."

**Who pays:** nobody. Free, no ads, no account. The goal is a following for the weekend and Mixpanel data on what fans actually use.
**Where they gather:** Instagram and TikTok during the weekend (post the link with a screen recording), r/bodybuilding, the Expo floor itself (QR code on a phone screen or a printed card).
**Why they'd use it instead of the official site:** the official schedule is a long page with no "now," no map, no saved list, and no athlete booth info. This is one tap from the home screen and answers "what now" in one glance.
**Legal line:** "Unofficial" appears in the subtitle, the About sheet, and the store listing. No Olympia logo, no Sandow image, no official wordmark. Our own icon (see §8).

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Now (as drawn: `design/*-main.html`) | Today's date; day pills Wed–Sun; "Happening now" card (red dot, title, divisions, venue, until-time, access tag); "Up next" list with times relative to now; "All day" list; tab bar Now / Schedule / Athletes / Venues / Saved | Tap any row → Event detail; tap day pill → that day's Now view |
| 2 | Schedule (`*-schedule.html`) | Day pills; filter chips All / Free / Ticketed / At Palms; events grouped Morning / Afternoon and evening; access tags; chevrons | Tap row → Event detail; chips filter in place |
| 3 | Event detail (`*-event.html`, `*-expo.html`) | Red band; back + Save; date/time; title; divisions; three facts (Doors or VIP entry / Venue / Access); Running order with estimates, or Meet-and-greets for the Expo; Afterward or Good to know; "Save to my day" + "Directions" | Save toggles bookmark; Directions opens maps; athlete rows → Athlete |
| 4 | Athletes (`*-athletes.html`) + Athlete page | Division chips; search; division header with pre-judging/finals times; athlete rows with avatar initials, tagline, booth or "No booth listed," meet-and-greet time. Athlete page: name, division, country, **Instagram row** (opens app or web), appearances with Confirmed/Reported and an "I saw this" button, "Report a booth or time" | Tap athlete → Athlete page; tap Instagram → `instagram://user?username=…` then web fallback; "I saw this" → Supabase insert |
| 5 | Venues (`*-venues.html`) + Saved | Google Map with five pins; venue rows with role and drive time; shuttle note. Saved: bookmarked events grouped by day with a "Nothing saved yet — tap the bookmark on any event" empty state | Tap venue → Directions sheet; Saved rows → Event detail |

Empty and error states for every screen; offline is the normal case at the Orleans, so all data ships in the app and the only network calls are Mixpanel and confirmations, both fire-and-forget.

## 4. Data model

Local-first. All schedule, venue, and athlete data ships as JSON assets (`data/schedule.json`, `data/venues.json`, `data/athletes.json`). Saved events live in local storage. The only remote table is confirmations.

```
Event        id, date, start?, end?, title, venueId, room?, access(free|ticket|vip), divisions[], plus?, presentedBy?, featuring?, vipEntry?, generalEntry?, shuttle, amateur, notes?, runningOrder[]?, endEstimate, doorsEstimate?
Venue        id, name, short, address, lat, lng, placeId, role, driveFromPalmsMin?, shuttle
Division     id, name, prejudgingEventId, finalsEventId, prize?
Athlete      id, name, divisionId, country, tagline, instagram?, booth?, appearances[]
Appearance   date, start, end?, venueId, booth, sponsor?, status(reported|confirmed), confirmations, source
Saved        eventId, savedAt                       // local only
Sighting     id, athleteId, appearanceKey, deviceId, createdAt   // Supabase, anonymous insert
```

**Backend needed?** `supabase-anon-insert` for `sightings` only (RLS: insert for anon with rate limit by deviceId; select public). A tiny edge function recomputes `status = confirmed` when distinct `deviceId` count ≥ 2 and republishes `athletes.json` to Storage every 5 minutes; the app fetches that file on open if online. **No auth.**
**Sync?** none. Saved events are per device.
**Analytics:** Mixpanel per `MIXPANEL.md` (replaces PostHog for this app). Events and super properties are the contract; the tester checks every event fires.
**Web deploy:** Flutter web (`--web-renderer canvaskit` unless html renders the fonts better on iOS Safari; test both), `manifest.json` with name "Olympia Weekend", standalone display, icons 192/512, theme color per theme, Apple touch icon. Host on Vercel (or Firebase Hosting) at a short domain; every share link carries `?utm_source=`.
**Time:** all times are Las Vegas local. Compute "now" from device clock converted to `America/Los_Angeles` so a phone still on Eastern time doesn't break the Now screen.

## 5. Native surfaces

- [ ] Home screen widget — no (web first)
- [ ] Lock screen widget / Glance — no
- [ ] Live Activity — no
- [ ] Watch — no
- [ ] Camera — no
- [x] Notifications — web push not in v1; store builds may add "your saved event starts in 30 min" local notifications
- [x] Share — Web Share API / share sheet on Now, Event, Athlete, with `?utm_source=share`
- [x] Maps — Google Maps JS on web, `google_maps_flutter` on stores; Directions deep links per `venues.json`
- [x] Add to Home Screen — show a one-time hint sheet on iOS Safari (share → Add to Home Screen) and use the `beforeinstallprompt` prompt on Android

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | **none** (overrides CLAUDE.md 3 for this app) |
| Free trial | n/a |
| Weekly / Annual / Lifetime | n/a |
| RevenueCat entitlement | none; do not add the RevenueCat SDK |
| What is gated vs. free | everything free |

## 7. Onboarding (2–4 screens)

None. First open lands on Now. A dismissible one-line banner under the title: "Unofficial fan guide. Add to your home screen for one-tap access." with a small "How" link that opens the install hint sheet.

## 8. Design notes

Keep to `DESIGN_GUIDE.md`; the artboards win where they differ.

- Accent color: `#e2231a` (Olympia red) in both themes.
- **Light (Option A):** ground `#f7f7f5`, cards `#ffffff` with `0 1px 2px rgba(0,0,0,0.04)`, text `#141414`, secondary `#6b6b68`, caption `#9a9a96`, dividers `#eeeeeb`. Selected day pill red with white text. Tags: Free `#0f6e56` on `#dcf3ea`, Ticket `#3d3d3a` on `#ebebe7`, VIP `#5b3fb8` on `#ece6fb`.
- **Dark (Option B):** ground `#0e0e0e`, cards and chips `#222222`, text `#f5f5f3`, section headers `#ffffff`, secondary `#a3a39e`, caption `#7a7a76`, dividers `#2e2e2e`, tab bar `#141414` with `#2a2a2a` top line. "Happening now" card has a 1 px red border; no other card has a border. Times in rows 17 px semibold. Athlete avatars `#3a1a18` with `#f0a39c` initials. Tags: Free `#6fd3a5` on `#123d2e`, Ticket `#d0d0cc` on `#2a2a2a`, VIP `#b8a4e0` on `#2a2340`.
- Type: system (SF on iOS, Roboto Flex/Google Sans on Android, system-ui on web). Title 32/700, section 17/600, row 15/500, caption 13, tag 12/600.
- Cards 18 px radius; row padding 14×18; screen gutter 24. Tab bar 84 px, five items, outline icons, active in text color (not red).
- Detail pages: 6 px red band at the very top, "‹ Schedule" back link, round Save button.
- Icon concept: a white "now" dot inside a red rounded square; no Olympia marks.
- Tone: short, factual, second person. "Unofficial" is never hidden.

## 9. Store listing seeds (for next week)

- Primary keyword: Olympia Weekend
- Secondary keywords (5): mr olympia schedule, olympia 2026 las vegas, olympia expo, bodybuilding schedule, olympia athletes
- Screenshot story: 1 Now ("What's happening right now"), 2 Schedule ("Every event, Wed to Sun"), 3 Event ("Running order and doors"), 4 Athletes ("Booths, meet-and-greets, Instagram"), 5 Venues ("Five venues, one map, directions in a tap")

## 10. Done means

- [ ] All screens in §3 exist with empty and error states, in both themes, matching `design/`
- [ ] Zero placeholder text, lorem ipsum, or TODO strings; athletes with `instagram: null` hide the row
- [ ] Passes `store-review-checklist` skill for the store build; web build passes Lighthouse PWA installability
- [ ] Integration tests green on iOS Simulator, Android emulator, and Chrome (web)
- [ ] Every Mixpanel event in `MIXPANEL.md` fires with its properties; verified in Mixpanel Live View from a real phone
- [ ] Web build deployed to the public URL; installs to the home screen on an iPhone and an Android phone; works fully offline after first load
- [ ] Directions opens Google Maps on Android and offers Apple/Google on iOS for all five venues
- [ ] "I saw this" inserts a row in Supabase and the athlete's appearance flips to Confirmed after two distinct devices
- [ ] Now screen shows the right "happening now" when the device clock is set to Eastern time
- [ ] `REVIEW.md` written; store screenshots generated for next week

## 11. Explicitly out of scope

- Accounts, login, profiles, comments, chat
- Ticket sales or links that look like sales (link to mrolympia.com/tickets in the About sheet only)
- Live results or scoring (link to the official livestream in About)
- Push notifications on web
- Any Olympia logo, Sandow imagery, or official wordmark
- Sponsor listings
- Native widgets and Live Activities (store v1.1 if the weekend goes well)
