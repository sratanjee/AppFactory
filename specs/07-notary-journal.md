# App Spec — Notary Journal

> Filled from `SPEC_TEMPLATE.md`. Standalone build. Not battle-tested in the two research reports; it fits the surviving pattern (business buyer already paying for a worse tool, per-appointment workflow, no camera or background location), so treat pricing as a first draft and read r/Notary before build day.

## 1. Identity

| Field | Value |
|---|---|
| App name (primary ASO keyword) | Notary Journal |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | Entries, fees, mileage, export / Numbered journal entries, fees and mileage per appointment, monthly totals, search, export. No account. |
| Slug | notary-journal |
| Bundle ID / Application ID | `com.[YOUR STUDIO].notaryjournal` |
| Category (store) | Business |
| Developer account | A |
| Factory category | trade-tool |
| Platforms | iOS 17+ and Android 10+ (API 29+), same release, same version number; one Flutter codebase, adaptive UI per DESIGN_GUIDE §1 (Cupertino on iOS, Material 3 Expressive on Android) |

## 2. The job

> "I want every notarization numbered and searchable with the fee and the miles attached, so that I can answer a records request in a minute and know what the month actually paid."

**Who pays:** Mobile notary / loan signing agent doing 20–60 appointments a month, driving to each, currently keeping a paper journal plus a separate mileage app and a spreadsheet for fees.
**Where they gather:** r/Notary and Notary Signing Agent Facebook groups (Loan Signing System alumni groups are the largest); NNA forums second.
**Why they'd pay instead of using a free thing:** Paper journals cannot be searched or totalled, and existing e-journal apps are either state-locked, account-first or priced for firms. The buyer already pays for a mileage tracker ($30–$140/yr per the mileage research) and a signing-agent platform; $19.99/yr for one place that holds entries, fees and miles undercuts the mileage app alone. State-specific journal rules are the risk (see §11), so fields stay generic and the state is a setting that only changes labels and which optional fields are shown.

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | Entries (home, as drawn) | Serif "Notary Journal" title over a small sans commission line ("[name] · Texas · Comm. #[number] · exp. [date]"); search field "Search signer, document, date" with a month chip; a vertical rule down the left with right-aligned accent entry numbers (1042, 1041 …) and rows showing act type, fee, time · signer · ID type · signatures, and small pills (ID verified, Acknowledgment / Jurat, Thumbprint, miles); month footer "September · 27 entries · $1,340 · 412 mi logged"; bottom "New entry" (accent) and "Export" | Tap "New entry" → form with next number pre-filled; type in search → live filter; tap month chip → month picker; tap row → detail |
| 2 | New entry | Act type (acknowledgment, jurat, oath, copy certification, signature witness, other), date/time (now), signer name(s), ID type and expiry, signature count, fee, thumbprint taken (toggle), document description, notes, mileage for this appointment (round trip miles, start / end address optional) | "Save entry" primary; number is sequential and immutable |
| 3 | Entry detail | Read-only record with edit; void with reason (voided entries keep their number, struck through) | "Edit", "Void entry" with confirm |
| 4 | Totals | Month / quarter / year: entries, fees, miles, fee per act type | Period toggle; "Export CSV / PDF" for the period |
| 5 | Settings | Notary name, state (drives labels and optional fields), commission number and expiry, default fee per act type, mileage rate note | Edit; commission expiry reminder toggle |

## 4. Data model

```
Notary      name, stateCode, commissionNumber, commissionExpires, defaultFees(json), mileageRate
Entry       id, number(seq, immutable), at, actType(enum ack|jurat|oath|copyCert|sigWitness|other), signers(json: name, idType, idExpiry, address?), signatureCount, fee, thumbprintTaken, documentDesc, notes, voided, voidReason?
Trip        id, entryId, miles, startAddr?, endAddr?, at   // one per appointment; two entries at one address share a Trip
StateProfile static: labels and which optional fields show per state (e.g. thumbprint field on for CA); default = generic
```

Storage layering: (1) local SQLite via Drift is the source of truth, no login on first run, ever; (2) day one, no account: automatic database backup file to iCloud Drive / Google Drive, plus user-owned export (PDF journal pages with sequential numbers; CSV of entries and trips); (3) optional Supabase sync is not in v1 (see §11); (4) shared backend handles RevenueCat webhooks only.

**Backend needed?** subscription-webhook-only
**Sync?** iCloud/Google backup

## 5. Native surfaces

- [ ] Home screen widget — not in v1
- [ ] Lock screen widget / Glance — no
- [ ] Live Activity / Ongoing notification — no
- [ ] Watch complication / Wear tile — no
- [ ] Camera — no (ID photos are a legal risk and are excluded; see §11)
- [x] Notifications (local only) — commission expiry at 90 / 30 days; opt-in
- [ ] Share extension / share target — no
- [x] App Intents / App Shortcuts — "New journal entry"; Android Quick Settings tile

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step 3, before first real use (before the Entries screen) |
| Free trial | 7-day, on annual only |
| Weekly price | none (no monthly tier: appointment volume is steady, so annual and lifetime only) |
| Annual price | $19.99/yr (pre-selected, saving shown against lifetime) |
| Lifetime price | $34.99 one-time (shown second) |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | Everything is gated; notary setup (onboarding) is free. |

1. Every notarization numbered, searchable, and backed up on your phone.
2. Fees and miles land on the same entry, so the month adds itself up.
3. Answer a records request in a minute, not an evening.

## 7. Onboarding (2–4 screens)

1. "Which state are you commissioned in?" — state picker; sets labels and optional fields; personalizes the commission line.
2. "Your name and commission details" — name, commission number, expiry; printed on every export page.
3. "What do you usually charge?" — default fee per act type and a loan-signing flat fee; leads straight into the paywall.

## 8. Design notes

- Accent color (one hex): `#7c2d12` (from artboard data-props).
- Home screen as drawn: warm paper background (#f6f4ef), light theme, no tab bar; **typeface differs from every sibling**: titles, act types and signer lines in a serif (Georgia / Iowan Old Style on iOS, Noto Serif on Android), while the commission line, search field, meta lines, pills, numbers and buttons are the system sans; 30-pt serif "Notary Journal" title with a 12-pt sans commission line beneath; a white search field with 1-pt #e3ded4 border and a "Sep" month chip; a 1-pt vertical rule at 64 pt from the left with right-aligned 12-pt bold accent entry numbers in tabular figures, and each row a 17-pt serif act type with a tabular fee, a 13-pt grey meta line, and 11-pt pills (accent on #efe4dc for ID verified / act type / thumbprint, grey for miles) with a hairline row rule (allowed: this is a numbered register, and the rule is part of the ledger look); footer line with month totals; bottom 52-pt accent "New entry" with 10-pt radius and a white bordered "Export". Amounts and numbers always tabular.
- Icon concept (one sentence): A round seal outline with a single numeral "1" inside, cream on the accent brown.
- Tone of copy: formal, brief, register-like; no exclamation marks, no jokes.
- Different from siblings in trade-tool: the only serif app in the factory and the only paper-toned background; Wash Quote is blue photo cards, Trucker is a dark gauge, Schedule E is a blue ledger.

## 9. Store listing seeds

- Primary keyword: Notary Journal
- Secondary keywords (5): notary public journal app, loan signing agent log, mobile notary mileage, notary fee tracker, electronic notary journal
- Screenshot story (5 screenshots, one line each):
  1. Entries list with numbers down the rule: "Numbered. Searchable. Yours."
  2. New entry form: "Act, signer, ID, fee, miles. One screen."
  3. Search result for a signer name: "Records request? One minute."
  4. Totals for the month: "$1,340 · 412 miles. Already added up."
  5. Exported PDF journal page with the commission header: "Prints like the book, without the book."

## 10. Done means

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms (n/a; App Shortcut and QS tile verified instead)
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] Android build reviewed on a Pixel and a small phone: Material 3 components, predictive back, edge-to-edge, dynamic color with the accent as fallback
- [ ] iOS build reviewed on an iPhone Pro and an SE-class device: Cupertino components, swipe-back, large title, Dynamic Type at 200%
- [ ] TestFlight build AND Play internal-testing build both uploaded from the same commit
- [ ] `REVIEW.md` written: what was built, what was cut, open questions
- [ ] Entry numbers are gapless and immutable across create, void, delete-attempt and restore-from-backup; voided entries keep their number
- [ ] Serif renders correctly at 200% text size on both platforms with no clipped act types; PDF export uses the same serif

## 11. Explicitly out of scope

- State-certified electronic journal compliance, RON (remote online notarization), e-seal, audio-video recording (state rules differ; this is a personal record, and the listing says so)
- Signer signature capture, thumbprint image capture, ID photo capture (liability; thumbprint is a yes/no flag only)
- Automatic GPS mileage, background location (manual miles per appointment only)
- Scheduling, calendar sync, signing-platform integrations (Snapdocs, SigningOrder), invoicing title companies
- Multi-notary / firm accounts, team sharing
- Supabase sync (multi-device) — not in v1
