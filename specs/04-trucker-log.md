# App Spec — Owner-Operator Log

> Filled from `SPEC_TEMPLATE.md`. Standalone build. **Provisional:** the research gave this idea structural scores only (business buyer, per-load workflow, no camera or background location) and no competitor, price or review data. Do not assign the build day until r/Truckers (and owner-operator Facebook groups) have been read for an hour and the pricing below is sanity-checked against what they already pay.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Owner-Operator Log |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Loads, fuel, net per mile / Log every load and fuel stop, see real net per mile against your goal, set tax aside. No account. |
| Slug | owner-operator-log |
| Bundle ID / Application ID | `com.[YOUR STUDIO].owneroperatorlog` |
| Category (store) | Business |
| Developer account | A |
| Factory category | trade-tool |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to know what I actually cleared per mile this week so that I can turn down loads that only look good."

**Who pays:** Owner-operator truck driver with one truck and their own authority (or leased on), paid per load, filing quarterly estimated tax, currently doing this in a notebook or a spreadsheet at the truck stop.
**Where they gather:** r/Truckers (community-check here before build); owner-operator Facebook groups and trucking YouTube comment threads second.
**Why they'd pay instead of using a free thing:** Spreadsheets do not work one-handed in a cab; ELD apps track hours, not money; load boards (DAT, Truckstop) show rate per mile before fuel, not after. Business buyers pay monthly, and the buyer's alternative is a $30–$100/mo bookkeeping or TMS subscription. Price is provisional: $12.99/mo / $99.99/yr sits above the factory's other trade tool because the buyer's revenue is per-load and five-figure monthly, but this must be confirmed in the community check.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Week (home, as drawn) | Week / Month / Quarter pill toggle with date range; half-ring gauge with hero "$2.41 net per mile · goal $2.50"; gross, miles and set-aside row; vertical timeline of loads (origin → destination, amount, day · miles · trailer · $/mi) interleaved with fuel stops (grey, negative) and booked future loads (dim); two bottom buttons "Add load" (accent) and "Add fuel" (dark) | Tap period pill → gauge and timeline recalc; tap a timeline row → edit; "Add load" → load form |
| 2 | Add load | Origin, destination, loaded miles, deadhead miles, rate (flat or $/mi), trailer type, pickup / delivery dates, broker, status (booked / delivered / paid) | Autofill last destination as origin; "Save load" primary |
| 3 | Add fuel | Stop name, gallons, price per gallon, total, state (free text, for later IFTA), odometer | Compute total from gallons × price; "Save fuel stop" |
| 4 | Money | Period totals: gross, fuel, other expenses, net, net per mile, tax set-aside at the configured %, unpaid loads | Period toggle; tap unpaid → list; "Export CSV" |
| 5 | Settings | Goal $/mi, tax set-aside %, trailer types, truck name | Edit fields |

## 4. Data model

```
Truck     name, trailerTypes(json), goalNetPerMile, taxSetAsidePct
Load      id, origin, destination, loadedMiles, deadheadMiles, rateTotal, ratePerMile?, trailer, pickupAt, deliverAt, broker, status(enum booked|delivered|paid), paidAt?, note
FuelStop  id, at, stopName, gallons, pricePerGal, total, stateCode(text), odometer
Expense   id, at, category(enum tolls|scale|repair|parking|other), amount, note
Period    computed: gross, fuel, expenses, net, miles, netPerMile, setAside = net × taxSetAsidePct
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (loads, fuel and expenses as CSV; period summary as PDF); (3) optional Supabase sync is not in v1 (see §11); (4) shared backend handles RevenueCat webhooks only.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [ ] Home screen widget — not in v1
- [ ] Lock screen widget / Glance — no
- [x] Live Activity (iOS) / Ongoing notification (Android) — optional: "Load in progress: Dallas → Memphis · 452 mi" with a "Delivered" action; ship only if it fits the day, else cut to REVIEW.md
- [ ] Watch complication / Wear tile — no
- [ ] Camera — no (rate confirmation photo attach is v1.1)
- [x] Notifications (local only) — "Load to Atlanta marked delivered 14 days ago, still unpaid?" opt-in
- [ ] Share extension / share target — no
- [x] App Intents / App Shortcuts — "Add fuel stop" (most frequent action at the pump); Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Week screen) |
| Free trial | 7-day, on annual only |
| Weekly price | none (monthly instead: $12.99/mo, provisional) |
| Annual price | $99.99/yr (pre-selected, saving shown; provisional) |
| Lifetime price | none in v1 (add a lifetime tier if the community check says owner-operators resent subscriptions the way pressure washers do) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; truck setup (onboarding) is free. |

1. Know what you really cleared per mile, after fuel, this week.
2. Log a load or a fuel stop in the cab in under a minute.
3. See how much to set aside before the quarterly bill shows up.

## 7. Onboarding (2–4 screens)

1. "What's your net-per-mile goal?" — dollar input with a default of $2.50; draws the gauge target.
2. "What do you pull?" — trailer types multi-select (dry van, reefer, flatbed, step deck, tanker, other); seeds the picker.
3. "How much do you set aside for taxes?" — percent slider, default 25%; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#f2b23a` (from artboard data-props). Dark theme is the default and only theme in v1 (§8 overrides the guide's follow-system rule: cab use at night).
- Home screen as drawn: near-black background (#111214) with light text (#f5f5f7); no tab bar, a three-pill Week / Month / Quarter toggle at top left (selected pill solid accent with dark text) and the date range at right; hero is a 260×140 half-ring gauge, 18-pt stroke, dark track (#2c2d33) with the accent arc filling toward goal, 52-pt tabular "$2.41" centered under the arc with "net per mile · goal $2.50"; one row of three stats (gross, miles, set-aside in accent); a vertical timeline with a 2-pt rail and 16-pt dots (accent for loads, grey for fuel, dim for booked), each row origin → destination with tabular amount and a grey meta line; two 54-pt bottom buttons in a 2-column grid, "Add load" solid accent with dark text and "Add fuel" on #1c1d21. System sans, tabular numerals everywhere.
- Icon concept (one sentence): A half-ring gauge with a single needle, amber on near-black.
- Tone of copy: blunt, short, no fluff; cab-readable at arm's length.
- Different from siblings in trade-tool: the only dark, gauge-first home; Wash Quote is a light photo-card home, Schedule E is a ledger, Notary is serif.

## 9. Store listing seeds

- Primary keyword: Owner-Operator Log
- Secondary keywords (5): trucking profit per mile, owner operator expenses, truck fuel log, load tracker trucking, trucker tax set aside
- Screenshot story (5 screenshots, one line each):
  1. Gauge at $2.41 vs goal: "What you really made per mile."
  2. Timeline with a fuel stop between two loads: "Loads and fuel, in order."
  3. Add fuel form at the pump: "118 gallons. Done."
  4. Money screen with set-aside: "Quarterly taxes, already counted."
  5. Quarter view: "The whole quarter on one screen."

## 10. Done means

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms (n/a; Live Activity verified if shipped, App Shortcut and QS tile verified)
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] Android build reviewed on a Pixel and a small phone: Material 3 components, predictive back, edge-to-edge, dynamic color with the accent as fallback
- [ ] iOS build reviewed on an iPhone Pro and an SE-class device: Cupertino components, swipe-back, large title, Dynamic Type at 200%
- [ ] TestFlight build AND Play internal-testing build both uploaded from the same commit
- [ ] `REVIEW.md` written: what was built, what was cut, open questions
- [ ] Net per mile = (gross − fuel − expenses) ÷ (loaded + deadhead miles) matches a hand calculation for week, month and quarter with loads spanning period boundaries
- [ ] Dark theme passes 4.5:1 contrast on every text element, including grey meta lines

## 11. Explicitly out of scope

- Automatic mileage / GPS tracking, background location (Play policy blocker; research killed this for mileage apps)
- IFTA state-mile reporting and fuel-tax calculation (state is a free-text note on fuel stops in v1; IFTA report is a v1.1 candidate after community check)
- ELD / hours-of-service, load boards, broker directory, rate lookup
- Invoicing brokers, factoring, per-diem calculators, full bookkeeping / QuickBooks sync
- Fleet / multiple trucks / drivers
- Supabase sync (multi-device) — not in v1
