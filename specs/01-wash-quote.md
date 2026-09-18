# App Spec — Wash Quote & Invoice

> Filled from `SPEC_TEMPLATE.md`. Standalone build, no shared engine. Build days 1–2 in the queue.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Wash Quote & Invoice |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Pressure washing quotes & PDFs / Quote on the driveway, send a branded PDF, invoice and collect a deposit. No account. |
| Slug | wash-quote |
| Bundle ID / Application ID | `com.[YOUR STUDIO].washquote` |
| Category (store) | Business |
| Developer account | A |
| Factory category | trade-tool |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want to price a job while I'm standing in the customer's driveway and send them a PDF before I drive off, so that I stop losing jobs to the guy who quoted first."

**Who pays:** Solo pressure-washing / exterior-cleaning operator (one truck, ~32,000 such US businesses) currently paying Jobber Core ($29–49/mo) or capped at 3–5 documents/month on Invoice Simple / Joist.
**Where they gather:** Pressure-washing Facebook groups and YouTube comment threads (launch-day post); r/pressurewashing second, since its sentiment was not verifiable in research.
**Why they'd pay instead of using a free thing:** Square/Wave/Zoho make free PDFs but push accounts, branding and price hikes; the trade's documented grievance is "they keep raising the price" and document caps. The pitch is unlimited documents, no branding, flat price, works with no signal, plus before/after photo pages that generic invoice apps do not offer. Business apps have the highest download-to-trial rate of any category (9.1%), so a hard paywall is an advantage here.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Jobs (home, as drawn) | Large "Jobs" title with a Quotes / Invoices segmented toggle; full-width accent hero card "New quote from the driveway" with camera glyph; horizontal row of photo-thumbnail quote cards under "Waiting on the customer · 4 · $1,865"; simple list "Accepted this week"; four-tab bar Jobs / Customers / Services / Money | Tap hero card → new quote flow (opens camera first); tap a card → job detail; toggle Quotes / Invoices |
| 2 | Quote builder | Customer, service lines from the operator's price list, quantities (sq ft / linear ft / flat), deposit %, "pay via" free-text field, before photos | Add service line from list; adjust qty; live total; "Save quote" primary button |
| 3 | Job detail / PDF preview | Rendered branded PDF (logo, business name, lines, deposit line, pay-via text, photo pages); status Sent / Accepted / Invoiced / Paid | "Send PDF" share sheet; "Convert to invoice" one tap; "Add after photos"; "Deposit link" creates Stripe payment link |
| 4 | Services (price list) | Operator's own services and unit prices, reused on every quote | Add / edit service; reorder |
| 5 | Money | Totals by week / month: quoted, accepted, invoiced, paid | Period toggle; tap total → filtered job list |

Customers tab is a filtered view of Jobs grouped by customer, not a separate screen.

## 4. Data model

```
Business   name, logo(path), phone, email, address, payVia(text), defaultDepositPct, termsText
Customer   id, name, phone, email, address
Service    id, name, unit(enum sqft|linft|flat|hour), unitPrice, sortOrder
Job        id, customerId, status(enum quote|sent|accepted|invoiced|paid), number(seq), createdAt, sentAt, depositPct, notes, stripeLinkUrl?  // stripeLinkUrl is the only field that comes from the backend
LineItem   id, jobId, serviceId, description, qty, unitPrice, total
Photo      id, jobId, path, kind(enum before|after), takenAt, caption
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (every quote and invoice as PDF; jobs as CSV); (3) optional Supabase sync is not in v1 (see §11); (4) shared backend handles RevenueCat webhooks and creates Stripe payment links for deposits (server holds the Stripe key; app sends amount + job number, receives a URL).

**Backend needed?** subscription-webhook-only + stripe-payment-link
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [ ] Home screen widget — not in v1 (no glanceable number that beats opening the app)
- [ ] Lock screen widget / Glance — no
- [ ] Live Activity / Ongoing notification — no
- [ ] Watch complication / Wear tile — no
- [x] Camera — before/after photos on quote and invoice; permission asked in context when the hero card is first tapped
- [x] Notifications (local only) — "Quote to Okafor sent 3 days ago, follow up?" reminder, opt-in
- [x] Share extension / share target — share sheet out for PDF; no inbound share target
- [x] App Intents / App Shortcuts — "New quote" (opens builder with camera), Quick Settings tile on Android

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the quote builder opens) |
| Free trial | 7-day, on annual only |
| Weekly price | none (monthly instead: $9.99/mo) |
| Annual price | $59.99/yr (pre-selected, saving shown against monthly) |
| Lifetime price | $79 one-time (third option) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated. Business setup (onboarding) is free; the first quote requires `pro`. |

1. Quote from the driveway and send the PDF before you leave.
2. Unlimited quotes and invoices, your logo, nobody else's.
3. One price that does not go up, and it works with no signal.

## 7. Onboarding (2–4 screens)

1. "What's the business called?" — business name + optional logo picker; used on every PDF and the Jobs title.
2. "What do you charge for?" — pick from starter list (house soft wash, driveway, roof, deck, fence, commercial flatwork) with editable per-unit prices; seeds Services.
3. "How do customers pay you?" — pay-via text (Venmo / Zelle / Square / check) and default deposit %; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#0a6ea8` (from artboard data-props; alternates #0b7a75, #1f5fbf not used)
- Home screen as drawn: white background (#ffffff), light theme, large-title "Jobs" with an inline segmented Quotes / Invoices control; hero is a full-width 168-pt rounded (22 pt) accent card with a subtle offset circle highlight, camera glyph in a translucent disc, headline "New quote from the driveway" and subline "Snap the surface, pick a service, send the PDF"; below it a horizontal row of 150-pt-wide photo-thumbnail quote cards on #f2f2f7 with a status pill ("Sent 2d ago"); then a plain list of accepted jobs with accent dot + tabular amounts; standard four-tab bottom bar (Jobs / Customers / Services / Money), accent on the selected tab. System sans (SF Pro / Roboto Flex).
- Icon concept (one sentence): A single spray-wand arc leaving a clean stripe, white on the accent blue.
- Tone of copy: blunt, tradesman-to-tradesman, no exclamation marks.
- Different from siblings in trade-tool: the only light-theme, photo-card home in the category; Trucker is dark amber timeline, Schedule E is a two-column ledger, Notary is serif.

## 9. Store listing seeds

- Primary keyword: Wash Quote & Invoice
- Secondary keywords (5): pressure washing estimate, power washing invoice, soft wash quote, exterior cleaning invoice, contractor estimate PDF
- Screenshot story (5 screenshots, one line each):
  1. Hero card on the Jobs screen: "Quote from the driveway."
  2. Quote builder with three service lines and a live total: "Your prices, your units."
  3. The PDF with logo, deposit line and pay-via text: "Looks like a real company. Because you are one."
  4. Before/after photo page on the invoice: "Show the work. Get paid faster."
  5. Paywall: "Unlimited documents. One price. Never a surprise."

## 10. Done means

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms (n/a: none in v1; App Shortcut and QS tile verified instead)
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] Android build reviewed on a Pixel and a small phone: Material 3 components, predictive back, edge-to-edge, dynamic color with the accent as fallback
- [ ] iOS build reviewed on an iPhone Pro and an SE-class device: Cupertino components, swipe-back, large title, Dynamic Type at 200%
- [ ] TestFlight build AND Play internal-testing build both uploaded from the same commit
- [ ] `REVIEW.md` written: what was built, what was cut, open questions
- [ ] PDF renders correctly with and without a logo, with 0 and 6 photos, and opens in iOS Files, Gmail and WhatsApp
- [ ] Stripe payment link created from the shared backend opens and shows the deposit amount; failure shows an inline error and the PDF still sends

## 11. Explicitly out of scope

- Scheduling, booking, calendar, route planning (that is Jobber's job; quote-only is the wedge)
- In-app card payments, Tap to Pay, Stripe Connect onboarding (payment link only, created server-side)
- Customer portal, e-signature, quote acceptance tracking beyond a manual status change
- Automatic sq-ft measurement, satellite measuring, AI pricing
- Lawn care / other trades templates (pressure washing only in v1)
- Team members, multi-truck, accounting sync (QuickBooks)
- Supabase sync (multi-device) — not in v1
