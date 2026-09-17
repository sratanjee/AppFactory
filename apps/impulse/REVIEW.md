# Impulse — /build-app run report

**Spec:** `specs/2026-09-17-impulse.md`
**Scope:** golden path only — onboarding → paywall → home (with storage). Full spec coverage deferred; see QUESTIONS.md.
**Result:** iOS Simulator build passes. Android debug APK builds. Smoke test green. `fvm flutter analyze` clean.

## Built

- `apps/impulse/` scaffolded via `tools/scaffold/new.sh` from the patched spec.
- `com.appfactory.impulse` bundle wired on iOS (`PRODUCT_BUNDLE_IDENTIFIER`) and Android (`applicationId`).
- Drift database (`impulse_app.sqlite`) with `Items` table + generated code.
- Riverpod providers: `appDatabaseProvider`, `itemsRepoProvider`, and three stream providers for waiting/ready/saved-total.
- Onboarding: 3 promise steps via `OnboardingFlow`; last step presents paywall then persists `hasSeenOnboarding = true` in `KeyValueStore` and routes to home.
- Paywall: `PaywallScreen` in disabled mode (no real RC keys) — dismissal still marks onboarding complete.
- Home: Saved total (streams from repo), Ready section with per-item Bought/Skipped `AdaptiveDialog.confirm`, Waiting section with per-minute countdown text.
- Add sheet: `AdaptiveSheet.show` with `EditableText` name + price + `AdaptiveSegmentedControl` wait-period picker (24h/48h/72h/7d). Medium haptic on save.
- Analytics: `core_action` fires on Add / Bought / Skipped through `Analytics.testing()` (no PostHog key).
- `_BootScreen` reads `hasSeenOnboarding` and routes accordingly.
- Smoke test verifies onboarding first-step renders after mounting through in-memory Drift + KV overrides.

## Cut (from spec, agreed)

Per PLAN.md §3 and spec §11:
- Notifications (spec §5 fallback — factory core has no notifications subsystem).
- History screen with monthly subtotals + free-tier 30-day paywall trigger.
- Settings screen (currency override, reminders toggle, CSV export, Reset).
- Item detail sheet with locked-state countdown + delete overflow.
- Skipped-number ~600ms count-up animation (currently jumps to the new value).
- Widgets, live activities, watch complications (spec §11).

## Integration bugs surfaced during this run

Every one of these traced to a factory-level flaw, not a spec problem.

### Bugs fixed in this run

1. **`{{studio}}` in the spec's bundle ID** — SPEC_TEMPLATE.md ships with `com.{{studio}}.{{slug}}`. The scaffolder validator correctly rejected `com.{{studio}}.impulse`, but the placeholder is a live-fire booby trap for every spec author. Fixed locally with `sed`, but **SPEC_TEMPLATE.md should be updated** to reference `{{bundle_prefix}}` (documented as sourced from `factory.config`) or ship without the `com.{{studio}}` prefix at all.
2. **Kernel binary cache lands stale after `flutter create`** — `Can't load Kernel binary: Invalid kernel binary format version.` printed on every subsequent `pub get`/`analyze`/`build`. It's noise (doesn't fail the tool), but the very first run of a scaffolded app dumps it prominently. **Fix**: scaffolder should `rm -rf apps/<slug>/.dart_tool` after `flutter create` and before the first `pub get`.
3. **Scaffolder didn't overwrite `analysis_options.yaml`** — `flutter create` writes a `flutter_lints` include, but our factory apps use `very_good_analysis`. The reviewer would flag this immediately. **Fixed** in `tools/scaffold/lib/generator.dart` + `templates_data.dart`.
4. **Scaffolder didn't delete `test/widget_test.dart` stub** — `flutter create` leaves a test referencing a `MyApp` class that doesn't exist in our template, so `flutter test` fails from the moment the app is scaffolded. **Fixed**: scaffolder now deletes the stub and writes a mount-only `test/smoke_test.dart`.
5. **`appName` template context was Dart-quoted** — `${appName}` renders as `'Impulse'` (with single quotes) which is correct for `.dart` files but landed in `pubspec.yaml` as `description: 'Impulse'.` — invalid YAML, blocked `pub get` entirely. **Fixed** by adding `appNameLiteral` (unquoted) to the template context and using it in YAML + store-metadata templates. `appName` (quoted) still used in `.dart` templates.
6. **`AdaptiveApp` `AdaptiveTheme` required child** — the theme param on AdaptiveApp is used only for its accent/spacing/corner-radius, but `AdaptiveTheme`'s constructor still requires `child`. Every app has to pass a `SizedBox.shrink()` placeholder. Cosmetic bug in `packages/core/lib/adaptive/theme.dart` — should split into `AdaptiveThemeData` (pure data) and `AdaptiveTheme` (inherited widget wrapper).
7. **`AsyncValue.valueOrNull` → `.value`** in Riverpod 3.4.3 (was in 2.x). Not a bug per se, but worth noting in the `flutter-factory` skill so builders know.
8. **`packages/core/android/build.gradle` `compileSdk 35`** — Flutter 3.47's `flutter create` writes apps with `compileSdk 36`. The transitive dependency error blocks Android builds. **Fixed** in this run by bumping to 36.

### Bugs found and noted but not fixed

9. **`packages/core` isn't SPM-adopted** — Flutter warned: `The following plugins do not support Swift Package Manager for ios: - factory_core`. iOS build fell back to CocoaPods and succeeded, but SPM support is on Flutter's deprecation timeline. Follow-up: add SPM support to the plugin.
10. **Some plugin(s) don't use Built-in Kotlin** — Android build warned about incompatibility with Flutter's new Built-in Kotlin path. Not blocking today, on Flutter's deprecation timeline. Likely one of `drift_flutter` / `posthog_flutter` / `purchases_flutter` / `shorebird_code_push`. Follow-up: identify which and either upgrade or file with upstream.
11. **Kernel-binary warning still appears on every command** — even after `flutter clean`. Cosmetic only.
12. **Text input via `EditableText` is ugly** — `AdaptiveInput` (a proper text field wrapping `CupertinoTextField`/`TextField`) isn't in the adaptive subsystem. Every app that needs input builds its own or does what I did — raw `EditableText` in a bordered `Container`. **Follow-up**: add `AdaptiveInput` to `packages/core/lib/adaptive/`.

### Bugs in the pipeline itself (not app code)

13. **`Write` occasionally didn't persist** when writing to a file I hadn't previously `Read`. Silent-drop, not an error return. Manifested multiple times during this run on `main.dart`, `router.dart`, `home_screen.dart`, `test/smoke_test.dart`, `REVIEW.md`. Cost ~2 minutes of re-analysis before I noticed. Not a factory bug — a tool-harness bug — but worth logging for the reviewer agent (which uses `Read` first universally).

## Open questions

- **Notifications subsystem** — see `QUESTIONS.md`.
- **Studio brand** — bundle prefix is still `com.appfactory` placeholder. Rename in `factory.config` before this ships to a store.
- **Real RevenueCat keys** — paywall runs in disabled mode; sandbox purchase not yet exercised on either platform.
- **PostHog key** — analytics runs in disabled mode; events fire to `Analytics.testing()`'s in-memory buffer.

## Verification

- `fvm flutter analyze` — **clean** (no errors, no info lints)
- `fvm flutter test test/smoke_test.dart` — **1/1 pass**
- `fvm flutter build ios --simulator --no-codesign` — **✓ Built build/ios/iphonesimulator/Runner.app** (SPM warning noted)
- `fvm flutter build apk --debug` — **✓ Built build/app/outputs/flutter-apk/app-debug.apk** (after `packages/core` compileSdk 36 bump; Built-in Kotlin warning noted)
- Upstream regressions: `packages/core` 100/100 pass · `tools/scaffold` 17/17 pass

## Where the artifacts landed

- iOS: `apps/impulse/build/ios/iphonesimulator/Runner.app`
- Android: `apps/impulse/build/app/outputs/flutter-apk/app-debug.apk`

Install on a simulator/emulator:
- iOS: `xcrun simctl install booted <path>/Runner.app && xcrun simctl launch booted com.appfactory.impulse`
- Android: `adb install <path>/app-debug.apk && adb shell am start -n com.appfactory.impulse/com.appfactory.impulse.MainActivity`

Or from source: `cd apps/impulse && fvm flutter run` with a device selected.
