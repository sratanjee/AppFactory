# Impulse — plan

## 1. App identity
- Slug: `impulse`
- Bundle ID: `com.appfactory.impulse`
- Accent: `#1D9A6C`
- Factory category: `utility`

## 2. The job
"I want to put a 48-hour wait between wanting something and buying it so that I stop spending money on things I regret."

## 3. Golden-path scope for this run
Ship only enough to prove the factory pipeline gets to a working iOS + Android app with **onboarding → paywall → storage** exercised. Full spec coverage is deferred.

**In**:
- 3-step onboarding flow (per spec §7).
- Paywall on `paywallProvider` in disabled mode — shows on completing onboarding, dismisses back to home; sandbox purchase not wired.
- Home screen: Saved total + waiting/ready item lists.
- Add sheet: name + price + wait-period picker (24h / 48h / 72h / 7d).
- Item decision: Bought / Skipped for ready items; Skipped increments Saved.
- Storage: Drift for `Item` rows, `KeyValueStore` for `hasSeenOnboarding` flag.

**Out (spec §11 + this-run deferrals)**:
- Notifications (spec §5 falls back to shipping without when factory core has no notifications subsystem — noted in QUESTIONS.md).
- History screen with monthly subtotals.
- Settings screen (currency override, reminders toggle, CSV export, reset).
- Item sheet with delete/countdown detail view.
- Widgets, live activities, watch complications (spec §11 out of scope).
- Currency selection — inferred from locale, no override UI.
- Real RevenueCat products (paywall runs in disabled mode).

## 4. Data model
```dart
Item
  id: int (autoincrement)
  name: text
  priceMinor: int          // cents in currency
  currency: text           // ISO 4217 from device locale at creation
  createdAt: int           // millisSinceEpoch
  decideAt: int            // createdAt + waitHours * 3600 * 1000
  decision: text?          // 'bought' | 'skipped' | null
  decidedAt: int?
```

Drift database file: `impulse_app.sqlite` under app documents (via `FactoryDatabase.open`).

`hasSeenOnboarding` bool stored in `KeyValueStore`.

Saved total is derived, not stored: `SUM(priceMinor) WHERE decision = 'skipped'`.

## 5. Native surfaces
None ship in this run. Notifications intentionally deferred (factory-level, not per-app).

## 6. Onboarding + paywall
1. "Wanting and paying happen in the same moment. Impulse puts 48 hours between them." — promise.
2. "Add the thing. Wait. Then decide." — promise.
3. "Every skipped item adds up. Watch the number grow." — promise with $1,240 sample.
→ paywall shown via `PaywallScreen.show(context, paywall: ..., placement: 'after_onboarding')`; dismissal (or purchase) marks `hasSeenOnboarding = true` and lands on home.

## 7. Analytics events
Standard five only:
- `onboarding_step` — fired by `OnboardingFlow`
- `paywall_view` — fired by `PaywallScreen`
- `paywall_purchase` — no-op (paywall disabled)
- `core_action` — fired on Add / Bought / Skipped with `{'action': ...}`
- `widget_added` — no widgets in this run

## 8. Builder task list
1. Add drift + build_runner dev deps to pubspec.
2. Write `lib/data/app_database.dart` with `Items` table + generated code.
3. Write `lib/data/items_repo.dart` — insert, watchWaiting, watchReady, watchDecided, decide.
4. Riverpod providers wiring the DB and repo.
5. Onboarding screen using `OnboardingFlow` — 3 steps, last completes to paywall.
6. Home screen — Saved total (streams from repo), Waiting list, Ready list.
7. Add sheet — `AdaptiveSheet.show` with name, price, wait-period `AdaptiveSegmentedControl`.
8. Ready-item actions — Bought / Skipped via `AdaptiveDialog.confirm`, Skipped animates Saved via `TweenAnimationBuilder`.
9. Router: `/onboarding` and `/home`; boot decides based on `hasSeenOnboarding`.

## 9. Deferred
See §3 "Out" above.

## 10. Open assumptions
- Currency inference via `Platform.localeName` fallback — will surface as USD symbol if locale parsing fails.
- Paywall in disabled mode always returns `notPresented` — the flow just marks onboarding complete on dismissal.
