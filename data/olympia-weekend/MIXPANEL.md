# Mixpanel tracking plan — Olympia Weekend

Goal for the weekend: know how many people used it, where they came from, which screens mattered at which hour, and whether the community features (saves, confirmations, shares) got any use. Nothing personal is collected; there is no login.

## Setup

- `mixpanel_flutter` package; project token in `--dart-define=MIXPANEL_TOKEN=…` (never in the repo).
- Identify with Mixpanel's anonymous device id only. No email, no name, ever.
- Set super properties once at startup and they ride on every event.
- EU/US data residency: US project.
- Flush on app background and every 30 s while active; Expo hall wifi is bad, so batch generously.

## Super properties (on every event)

| Property | Values |
|---|---|
| `platform` | `ios_web`, `android_web`, `ios`, `android`, `desktop_web` |
| `installed` | `true` when running from the home screen (display-mode standalone), else `false` |
| `theme` | `light` / `dark` (what the system gave us) |
| `app_version` | semver |
| `day` | `wed`…`sun`, from the device clock in Las Vegas time |
| `hour` | 0–23, Las Vegas time |
| `source` | first-touch `utm_source` from the link they opened, persisted (`instagram`, `tiktok`, `qr`, `text`, `direct`) |

## Events

| Event | When | Properties |
|---|---|---|
| `app_open` | every cold start and every return from background after 5+ min | `first_open` (bool) |
| `install_prompt_shown` | the add-to-home-screen hint appears | |
| `install_completed` | first launch in standalone mode | |
| `view_now` | Now tab shown | `now_event_id` (what was "happening now"), `next_event_id` |
| `view_schedule` | Schedule tab shown | `day_selected`, `filter` |
| `filter_change` | user changes a chip | `filter` |
| `day_change` | user taps a day pill | `from`, `to` |
| `view_event` | event detail opened | `event_id`, `access`, `venue`, `from_screen` |
| `save_event` / `unsave_event` | bookmark toggled | `event_id` |
| `view_saved` | Saved tab shown | `count` |
| `view_athletes` | Athletes tab shown | `division` |
| `search_athletes` | query submitted | `query_length`, `results` |
| `view_athlete` | athlete page opened | `athlete_id`, `division`, `has_instagram`, `has_appearance` |
| `open_instagram` | Instagram row tapped | `athlete_id` |
| `confirm_sighting` | "I saw this" tapped on an appearance | `athlete_id`, `booth`, `resulting_status` |
| `report_sighting` | user adds a new booth/time | `athlete_id` |
| `view_venues` | Venues tab shown | |
| `view_venue` | venue row opened | `venue_id` |
| `directions_tap` | Directions pressed | `venue_id`, `maps_app` (`google`, `apple`) |
| `share_tap` | Share pressed | `screen`, `event_id?` |
| `error` | caught exception surfaced to the user | `where`, `message` |

## Questions the dashboard should answer by Sunday night

1. Unique users per day and per hour, split by `source` (which post drove installs).
2. `installed` share: how many added it to the home screen.
3. Screen mix by hour: does `view_schedule` spike before pre-judging, does `view_venues` spike between venues.
4. Top `view_event` by `event_id`, and `save_event` conversion from event views.
5. Athlete engagement: `view_athlete` → `open_instagram` rate, and total `confirm_sighting` (is the crowd-confirm idea real).
6. `directions_tap` by `venue_id` and `maps_app`.
7. Retention: users with `app_open` on 2+ days.

Build these as one Mixpanel board before launch so you can screenshot it Sunday.
