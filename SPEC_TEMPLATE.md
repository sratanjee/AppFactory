# App Spec — {{app_name}}

> Copy to `specs/YYYY-MM-DD-{{slug}}.md`. Fill every field. If a field is blank, the Planner stops and asks, it does not guess.
> Target length: under 60 lines. If you need more, the app is too big for one day.

---

## 1. Identity

| Field | Value |
|---|---|
| App name (this is the primary ASO keyword) | |
| Subtitle (iOS, 30 chars) / Short description (Android, 80 chars) | |
| Slug (lowercase, hyphenated) | |
| Bundle ID / Application ID | `com.{{studio}}.{{slug}}` |
| Category (store) | |
| Developer account | A / B / C |
| Factory category | utility · ai-camera · widget · faith-recovery · trade-tool · sleep-focus |

## 2. The job

One sentence, in the user's words, describing the single thing this app does.

> "I want to ______ so that ______."

**Who pays:** (one specific person, e.g. "DoorDash driver filing quarterly taxes")
**Where they gather:** (one subreddit / FB group / TikTok hashtag we will post in on launch day)
**Why they'd pay instead of using a free thing:**

## 3. Screens (3–5 max)

| # | Screen | Purpose | Key interaction |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

Empty states and error states are required for every screen; the Builder writes them from this table.

## 4. Data model

Local-first by default. List entities and fields. Mark anything that must sync or hit the shared backend.

```
Entity
  field: type  // note
```

**Backend needed?** no · ai-proxy · usage-cap · subscription-webhook-only
**Sync?** none · iCloud/Google backup · shared backend (justify)

## 5. Native surfaces

Tick what ships in v1. Each tick is Swift + Kotlin work; keep it minimal.

- [ ] Home screen widget (sizes: )
- [ ] Lock screen widget (iOS) / Glance (Android)
- [ ] Live Activity (iOS) / Ongoing notification (Android)
- [ ] Watch complication / Wear tile
- [ ] Camera
- [ ] Notifications (local only unless stated)
- [ ] Share extension / share target
- [ ] App Intents / App Shortcuts

## 6. Monetization

| Field | Value |
|---|---|
| Paywall placement | after onboarding step __, before first real use |
| Free trial | none · 3-day · 7-day |
| Weekly price | |
| Annual price | |
| Lifetime price (optional) | |
| RevenueCat entitlement | `pro` |
| What is gated vs. free | |

Paywall copy: three benefit lines in the user's words, no feature names.

1.
2.
3.

## 7. Onboarding (2–4 screens)

Each screen is one question or one promise. Last screen leads straight into the paywall.

1.
2.
3.

## 8. Design notes

Keep to `DESIGN_GUIDE.md`. Only list what's specific to this app.

- Accent color (one hex):
- Icon concept (one sentence):
- Tone of copy (e.g. calm, blunt, encouraging):
- Anything that must feel different from sibling apps in this category:

## 9. Store listing seeds

- Primary keyword:
- Secondary keywords (5):
- Screenshot story (5 screenshots, one line each):
  1.
  2.
  3.
  4.
  5.

## 10. Done means

The Reviewer signs off only when every line is true.

- [ ] All screens in §3 exist with empty and error states
- [ ] Paywall appears at the placement in §6 and purchases work in sandbox on both platforms
- [ ] Widgets in §5 render with real data on both platforms
- [ ] Zero placeholder text, lorem ipsum, or TODO strings
- [ ] Passes `store-review-checklist` skill
- [ ] Integration tests green on iOS Simulator and Android emulator
- [ ] Screenshots generated for both stores in all required sizes
- [ ] `REVIEW.md` written: what was built, what was cut, open questions

## 11. Explicitly out of scope

List what you are tempted to add and are not adding. This is what stops the day from becoming three days.

-
-
