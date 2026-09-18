# App Spec — Vape-Free

> Filled from `SPEC_TEMPLATE.md`. Standalone build. **Optional / last in queue:** research rates this the weakest survivor; its differentiator is a marketing position (no account, no community, private) and growth depends almost entirely on short-video posting (Puff Count's $40K MRR was TikTok-driven). Without a concrete short-video plan, expect the $72/mo category median and spend the day on apps 1–3 instead.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Vape-Free |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Private quit counter & widgets / Days, money saved and cravings beaten on your home and lock screen. No account, ever. |
| Slug | vape-free |
| Bundle ID / Application ID | `com.[YOUR STUDIO].vapefree` |
| Category (store) | Health & Fitness (iOS, 17+ rating) / Health & Fitness (Android, Mature 17+) |
| Developer account | C |
| Factory category | faith-recovery |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to see how long it's been and how much I've saved every time I look at my phone, so that the next craving feels smaller than the number."

**Who pays:** Someone quitting disposable vapes, 18–30, who does not want an account, a community feed or their quit date in someone's cloud; already tried a free counter and left over the paywall nag or the login.
**Where they gather:** r/QuitVaping (sentiment unverified in research; read before build) and TikTok / Reels under #quitvaping and #vapefree, which is the only distribution that has moved this category.
**Why they'd pay instead of using a free thing:** I Am Sober (187K ratings) and Smoke Free give the counter away but require accounts and sync to the cloud, with "unclear" privacy settings and "toxic" community complaints; Puff Count's top complaint is its aggressive paywall. The pitch is a private, on-device counter with first-class widgets and a craving tool, at $19.99/yr (below every competitor's annual) with a $29.99 lifetime in the range long-tail lifetime tiers already sell ($24.99–$44.99). Copy stays on days, money and milestones only.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Counter (home, as drawn) | Small "Quit Aug 26 · 11:40 PM" line with a settings disc; hero 236-pt conic ring (accent arc toward the next milestone) with 88-pt "22" and "days vape-free"; "8 days to 30-day mark"; three stat tiles ($154 saved in accent, 2,640 puffs skipped, 7 cravings beat); one milestone card ("Three weeks · Reached yesterday. Next: one month."); full-width accent "I have a craving" button; floating pill tab bar Counter / Milestones / Widgets / Savings | Tap "I have a craving" → craving flow; tap a stat tile → its detail; ring animates only when a milestone is reached |
| 2 | Craving flow | Full-screen: 60-second breathing timer (expand / hold / release ring), then "Still here?" with a one-line note field and "Beat it" / "I slipped" | "Beat it" increments cravings beaten; "I slipped" offers "keep my date" or "restart from now", no guilt copy |
| 3 | Milestones | List of reached and upcoming marks (1 day, 3 days, 1 week, 2 weeks, 3 weeks, 1 month, 3 months, 6 months, 1 year), each with date reached | Tap → share card image (days + money, no app branding beyond name) |
| 4 | Widgets | Gallery of the widget sizes with live previews and add instructions per platform | "Add to home screen" deep link / instruction sheet |
| 5 | Savings | Money saved over time, based on setup answers; edit cost and usage | Edit inputs; graph by week |

## 4. Data model

```
Quit       quitAt, costPerUnit, unitLabel(enum disposable|pod|bottle), unitsPerWeek, puffsPerUnit, currency
Craving    id, at, beaten(bool), note?
Slip       id, at, kept(enum keptDate|restarted)
Milestone  static list; reachedAt computed from quitAt
Computed   daysFree, moneySaved = unitsPerWeek × costPerUnit × weeks, puffsSkipped = unitsPerWeek × puffsPerUnit × weeks, cravingsBeaten
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive (so a new phone keeps the date), plus user-owned export (CSV of cravings and slips); (3) optional Supabase sync is not in v1 and is unlikely ever, since "nothing leaves your phone" is the pitch (see §11); (4) shared backend handles RevenueCat webhooks only.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [x] Home screen widget (sizes: small, medium) — small: ring + days; medium: days + money saved + next milestone; tinted and clear rendering modes on iOS 26, dynamic color on Android
- [x] Lock screen widget (iOS) / Glance (Android) — accessory circular (ring + days), inline ("22 days · $154"); Android Glance small
- [ ] Live Activity / Ongoing notification — no
- [x] Watch complication / Wear tile — days count (the number is glanceable); ship if it fits the day, else cut to REVIEW.md
- [ ] Camera — no
- [x] Notifications (local only) — milestone reached; optional daily "still counting" at a chosen time
- [ ] Share extension / share target — no (share-out of milestone card via share sheet only)
- [x] App Intents / App Shortcuts — "I have a craving" (opens breathing timer); Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Counter) |
| Free trial | 7-day, on annual only |
| Weekly price | none (no monthly either; a weekly trial funnel is the worst-performing shape in the data) |
| Annual price | $19.99/yr (pre-selected, saving shown against lifetime) |
| Lifetime price | $29.99 one-time (shown second) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; quit-date setup (onboarding) is free. |

1. Your days, your money saved, on your lock screen every time you look.
2. Nothing leaves your phone. No account, no feed, no one watching.
3. A craving button that gets you through the next sixty seconds.

## 7. Onboarding (2–4 screens)

1. "When did you quit, or when will you?" — date and time picker, defaults to now; sets the counter and the ring.
2. "What were you spending?" — unit (disposable / pod / bottle), cost, how many a week; seeds money saved and puffs skipped.
3. "Want the number on your lock screen?" — one-line explanation and a preview of the widget; leads straight into the paywall (widget install instructions appear after purchase).

## 8. Design notes

- Accent color (one hex): `#34d399` (from artboard data-props). Dark theme is the default and only theme in v1 (§8 overrides the guide's follow-system rule: the artboard is designed as a night-time, glance-first surface).
- Home screen as drawn: deep navy background (#0b1220) with #f5f7fa text and #151d2e surfaces; a small grey quit-timestamp line top-left and a 36-pt settings disc top-right; hero is a 236-pt ring drawn as a conic gradient (accent from 0° to progress, #1a2438 remainder) with a 204-pt inner disc in the background colour holding an 88-pt tabular "22" and "days vape-free"; a 13-pt "8 days to 30-day mark" line; three equal stat tiles on #151d2e with 16-pt radius (saved amount in accent, the other two in white); one milestone card with a star glyph in a 40-pt accent-tinted disc; a 54-pt full-width accent button with dark text "I have a craving"; and a **floating pill tab bar** (64-pt, 32-pt radius, translucent #151d2e with a soft shadow) holding Counter / Milestones / Widgets / Savings, selected in accent. System sans, 16-pt side margins.
- Icon concept (one sentence): An open ring with a small gap at the top, mint on deep navy.
- Tone of copy: encouraging, quiet, never preachy; days, money and milestones only, no health-recovery timelines, no "your lungs", no treatment or medical language (Apple 1.4.1).
- Different from siblings in faith-recovery: only app in the category so far; the artboard's conic ring, mint-on-navy and floating pill tab bar must not be reused by any later counter app on account C.

## 9. Store listing seeds

- Primary keyword: Vape-Free
- Secondary keywords (5): quit vaping counter, vape free days tracker, nicotine free widget, quit vaping app no account, craving timer
- Screenshot story (5 screenshots, one line each):
  1. Lock screen with the ring widget: "The number, every time you look."
  2. Counter at 22 days with $154 saved: "Days. Money. Cravings beaten."
  3. Craving flow breathing ring: "Sixty seconds. Then it passes."
  4. Milestones list with "Three weeks" reached: "Every mark, dated."
  5. Paywall with the privacy line: "No account. Nothing leaves your phone."

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
- [ ] Lock-screen and home widgets update within a minute of a milestone and show the same day count as the app after a timezone change and a device restart
- [ ] A full-text grep of `lib/l10n/` and store copy finds no health-recovery, lung, blood-pressure, "withdrawal" or treatment phrasing; age rating set to 17+ / Mature on both stores

## 11. Explicitly out of scope

- Health-recovery timelines, "your body after X days", symptom or withdrawal guidance, nicotine-replacement advice (Apple 1.4.1)
- Community, feeds, buddies, chat, leaderboards, coaching
- Accounts, cloud sync, Supabase sync — not in v1 and not planned; backup file only
- Puff counting / tapering mode, usage logging before the quit date
- Alcohol / other-substance lanes (separate keyword market; separate app if ever)
- AI chat, motivational-quote feeds, streak-freeze gimmicks
