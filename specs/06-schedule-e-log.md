# App Spec — Schedule E Log

> Filled from `SPEC_TEMPLATE.md`. Standalone build. **Build in December, launch the first week of January**: Stessa's own CEO frames the category as a tax-season product, and 35% of annual cancellations happen in month one, so a September launch buys nine months of nothing.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Schedule E Log |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Landlord rent & expense ledger / Rent in, expenses out, every receipt tagged to its Schedule E line. One price, no account. |
| Slug | schedule-e-log |
| Bundle ID / Application ID | `com.[YOUR STUDIO].scheduleelog` |
| Category (store) | Finance |
| Developer account | A |
| Factory category | trade-tool |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to log rent and every repair receipt as it happens so that in February I can hand my preparer a Schedule E that is already filled in by line."

**Who pays:** Self-managing landlord with 1–4 units (78% of such owners self-manage; ~46% of US rental units are in 1–4 unit properties) who currently uses a spreadsheet and a shoebox and pays a preparer to sort it out in February.
**Where they gather:** BiggerPockets forums (the "use a spreadsheet" advice thread is the launch-day reply target); r/Landlord second.
**Why they'd pay instead of using a free thing:** Stessa Essentials, Landlord Studio GO, Innago and Avail are free but require an account, push bank links and tenant-paid fees, and gate Schedule E reporting behind $12/mo tiers. Landlordy ($14.99–$99.99 one-time, 4.7 stars on 2,224 reviews) proves a no-account one-time purchase sustains a solo developer for a decade. The single feature the free tiers withhold is the line-mapped Schedule E export with receipts; that is the product, and $39.99 once is below Landlordy Plus ($49.99) and far below RentDue ($79.99/yr).

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Ledger (home, as drawn) | Year picker "2026 ▾" with property filter pills (All / 14 Elm / 22B Oak); two-column summary "Rents received · line 3 $31,200" (green) and "Expenses · lines 5–19 $12,260"; "Net so far" strip in accent; two scrolling columns Income (month · property, paid date, late flag in amber) and Expenses (name, amount, property · line · receipt); bottom "Add entry" (accent) and "Schedule E" export button | Tap property pill → filters both columns and totals; tap year → switch tax year; tap a row → edit; "Add entry" → sheet |
| 2 | Add entry sheet | Type (rent / expense), property, amount, date, for rent: month covered and paid date (late computed vs due day); for expense: Schedule E line picker (5 Advertising … 19 Other, with plain-English names), vendor, receipt photo | Camera / photo picker; line picker remembers last choice per vendor; "Save entry" |
| 3 | Properties | 1–4 properties: address, units, monthly rent, due day, tenant name (optional), ownership % | Add / edit; archive |
| 4 | Schedule E export | Per property, per year: line-by-line totals 3–19, net, count of receipts; preview | "Export PDF" (line-mapped summary + receipt appendix), "Export CSV" (one row per entry with line number) |

Receipts are viewed from the entry row; no separate receipts screen.

## 4. Data model

```
Property   id, nickname, address, units, monthlyRent, dueDay, tenantName?, ownershipPct, archived
Entry      id, propertyId, type(enum rent|expense), amount, date, taxYear
           rent:    monthCovered, paidAt, isLate(computed vs dueDay)
           expense: scheduleELine(int 5..19), vendor, note
Receipt    id, entryId, path, takenAt
LineMap    static: 5 Advertising, 6 Auto and travel, 7 Cleaning and maintenance, 8 Commissions, 9 Insurance, 10 Legal and professional, 11 Management fees, 12 Mortgage interest, 13 Other interest, 14 Repairs, 15 Supplies, 16 Taxes, 17 Utilities, 18 Depreciation (entry allowed, flagged "ask your preparer"), 19 Other
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file (including receipt images) to iCloud Drive / Google Drive, plus user-owned export (Schedule E PDF with receipt appendix; CSV); (3) optional Supabase sync is not in v1; an optional $19.99/yr sync add-on is the only planned subscription and ships later, if ever (see §11); (4) shared backend handles RevenueCat webhooks only.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [ ] Home screen widget — not in v1
- [ ] Lock screen widget / Glance — no
- [ ] Live Activity / Ongoing notification — no
- [ ] Watch complication / Wear tile — no
- [x] Camera — receipt photo on expense entry; permission asked in context on first "Add receipt"
- [x] Notifications (local only) — "Rent for 22B Oak due tomorrow" and "not marked paid" nudges, opt-in
- [x] Share extension / share target — receive an image or PDF (emailed receipt) into a new expense entry
- [x] App Intents / App Shortcuts — "Add receipt" (opens camera into a new expense); Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Ledger) |
| Free trial | none (one-time purchase; a trial on a $39.99 lifetime SKU is refund bait in January) |
| Weekly price | none |
| Annual price | none in v1; $19.99/yr "sync" add-on reserved for a later release, shown nowhere in v1 |
| Lifetime price | $39.99 one-time (the only option on the v1 paywall, a single "Buy once" button) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; property setup (onboarding) is free. |

1. Every rent payment and every receipt, logged the day it happens.
2. Each expense already on its Schedule E line, so February takes an hour.
3. Buy it once. No account, no bank link, no tenant fees.

## 7. Onboarding (2–4 screens)

1. "What's the first property?" — nickname, address, units; names the filter pill.
2. "What's the rent, and when is it due?" — monthly rent and due day; seeds expected income and late flags.
3. "Which tax year are we filling?" — defaults to current year, with "start with last year" for January buyers; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#1d4ed8` (from artboard data-props). Green `#1d7a4a` for income amounts and amber `#b45309` for late flags are semantic, not accents.
- Home screen as drawn: white background (#ffffff), light theme, ledger-like with hairline rules between zones (allowed: it is a two-column financial grid, not a list of unrelated cards); header row with a bold "2026" year picker and small filter pills (selected pill near-black, others #f2f2f7); a two-cell summary band split by a vertical rule, each cell with a 12-pt grey label naming the IRS line, a 26-pt tabular amount (income in green) and a 12-pt status line; a pale #f8f9ff "Net so far" strip with the net in accent; then two side-by-side columns headed Income / Expenses with compact rows (bold name, tabular amount, grey meta line naming property · line · receipt); bottom bar with a 50-pt accent "Add entry" and a grey "Schedule E" export button with a document glyph. No tab bar; Properties and Export are reached from the year picker menu and the export button. System sans, tabular numerals.
- Icon concept (one sentence): A ledger page with one bold "E", white on the accent blue.
- Tone of copy: dry, exact, accountant-adjacent; IRS line names spelled out in plain English.
- Different from siblings in trade-tool: the only two-column ledger and the only one-time-purchase paywall; Wash Quote is photo cards, Trucker is a dark gauge, Notary is serif.

## 9. Store listing seeds

- Primary keyword: Schedule E Log
- Secondary keywords (5): landlord expense tracker, rental income log, rent tracker landlord, rental property receipts, Schedule E export
- Screenshot story (5 screenshots, one line each):
  1. Ledger with two columns and the net strip: "Rent in, expenses out, by tax year."
  2. Expense sheet with the line picker open: "Every receipt already on its line."
  3. Receipt photo attached to a water heater entry: "Shoebox, retired."
  4. Schedule E export preview, lines 3–19 totalled: "February takes an hour."
  5. One-button paywall: "$39.99 once. No account. No bank link."

## 10. Done means

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms (n/a; share target, App Shortcut and QS tile verified instead)
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] Android build reviewed on a Pixel and a small phone: Material 3 components, predictive back, edge-to-edge, dynamic color with the accent as fallback
- [ ] iOS build reviewed on an iPhone Pro and an SE-class device: Cupertino components, swipe-back, large title, Dynamic Type at 200%
- [ ] TestFlight build AND Play internal-testing build both uploaded from the same commit
- [ ] `REVIEW.md` written: what was built, what was cut, open questions
- [ ] Schedule E export line totals (3, 5–19, net) match the ledger for every property and for "All", including entries dated Dec 31 and Jan 1 across two tax years
- [ ] Backup restores receipt images, not only rows, on a fresh install on both platforms

## 11. Explicitly out of scope

- Tenant portal, online rent collection, ACH / card payments, tenant screening, lease e-sign
- Bank feeds, Plaid, automatic transaction import, receipt OCR
- Depreciation schedules, cost-basis tracking, tax calculation or filing (line 18 is a manual entry flagged for the preparer)
- Multi-owner splits beyond a single ownership %, LLC / partnership K-1 logic, more than ~10 properties
- Maintenance requests, work orders, vendor management, mileage
- Supabase sync (multi-device) and the $19.99/yr sync add-on — not in v1
