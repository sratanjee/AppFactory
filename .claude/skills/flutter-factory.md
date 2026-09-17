---
name: flutter-factory
description: Patterns and conventions for factory Flutter apps. Use when writing screens, state, routing, or wiring core services in apps/<slug>/lib.
---

# flutter-factory

The one-page reference for what a factory app looks like. All rules here are enforced by the reviewer.

## Project shape (apps/<slug>/)

```
lib/
  main.dart           # entry, wraps ProviderScope + Shorebird + go_router
  app.dart            # AdaptiveApp widget (from core/adaptive)
  app_config.dart     # bundle-time constants (RevenueCat keys, backend URL)
  routes/             # go_router routes; one file per top-level branch
  screens/            # one widget per screen; snake_case.dart
  data/
    models/           # plain Dart classes; freezed if a union or many fields
    repositories/    # repos backed by Drift + core/storage
    db/              # Drift definitions
  state/              # Riverpod providers, one file per feature
  services/           # thin wrappers around core (paywall, analytics, widget_bridge)
  l10n/
    intl_en.arb
test/
  unit/
  golden/
integration_test/
  <app>_flow_test.dart
```

## Imports

**Never** import these directly in `apps/<slug>/lib`:
- `package:flutter/material.dart`
- `package:flutter/cupertino.dart`

**Instead**, use `package:factory_core/adaptive/*`. The adaptive layer picks the right platform component at runtime.

Allowed direct imports: `flutter/widgets.dart` (for `Widget`, `BuildContext`, `Text`), `flutter/services.dart` (for `HapticFeedback`), `flutter/foundation.dart`.

## State

Riverpod v2, `hooks_riverpod` optional. Providers live in `state/`, one file per feature.

```dart
// state/counter_state.dart
final counterProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(counterRepoProvider).currentValue();
  void increment() { state++; ref.read(counterRepoProvider).save(state); }
}
```

- No `Provider.of`, no `InheritedWidget` by hand.
- Repositories are providers too. Screens read providers, never repos directly.

## Routing

`go_router`, one router in `main.dart`. Route enums in `routes/route_names.dart`. Platform-correct transitions come from `core/adaptive/adaptive_page.dart`.

- Interactive swipe-back on iOS: **always on**.
- Predictive back on Android: **always on**. Never wrap the whole route in a custom `WillPopScope`.

## Screens

One screen = one file. Every screen has:
1. **Loading state** — shimmer or spinner only if something is actually loading. Empty screen otherwise.
2. **Empty state** — one-line copy telling the user what to do, plus the primary action.
3. **Error state** — one line, actionable, no apology.
4. **Populated state** — the main render.

Layout skeleton:

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    return AdaptiveScaffold(
      title: Text('Home'),
      body: state.when(
        loading: () => AdaptiveLoading(),
        empty: () => HomeEmpty(),
        error: (msg) => AdaptiveError(msg),
        data: (items) => HomeList(items: items),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Start counting',
        onPressed: () => ref.read(homeProvider.notifier).start(),
      ),
    );
  }
}
```

## Paywall

Every app calls `core/paywall`:

```dart
await ref.read(paywallProvider).presentIfNotEntitled(context, placement: 'after_onboarding');
```

- Placement string matches PLAN §6.
- Never call `purchases_flutter` directly.
- `paywallProvider` is a no-op in tests unless overridden.

## Analytics

Fixed event set from CLAUDE.md:
- `onboarding_step` — props: `{step: int}`
- `paywall_view` — props: `{placement: String}`
- `paywall_purchase` — props: `{sku: String, price: String}`
- `core_action` — props: app-specific from PLAN §7
- `widget_added` — props: `{surface: String, size: String}`

Additional events only if PLAN §7 lists them.

Fire through `ref.read(analyticsProvider).track(...)`.

## Storage

Drift, always. Per-app schema in `data/db/`. Migrations checked in.

```dart
// data/db/app_database.dart
@DriftDatabase(tables: [Entries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  @override int get schemaVersion => 1;
}
```

No `shared_preferences` for structured data. `core/storage` provides a `KeyValueStore` for single-scalar prefs only.

## Widgets → native

Push data to native widgets through `core/widget_bridge`. Never touch `App Group` or `SharedPreferences` for widget data directly.

```dart
await ref.read(widgetBridgeProvider).publish({
  'count': state.count,
  'label': state.label,
});
```

See the `widgetkit-bridge` skill for the native side.

## Style

- Small, obvious functions. No abstractions beyond what's needed.
- No comments except where WHY is non-obvious.
- Filenames: `snake_case.dart`. Classes: `PascalCase`. Constants: `lowerCamelCase`.
- Strings in `lib/l10n/intl_en.arb` from day one.

## The one thing to remove

Before you say a screen is done, take one thing off it. If you can't take anything off, the screen is done.
