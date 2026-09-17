# factory_core

Shared Flutter package for App Factory apps. Every app depends on this and nothing outside of it, apart from `packages/widgets_ios` and `packages/widgets_android` for native widget targets.

## Subsystems

| Subsystem | Purpose | Status |
|---|---|---|
| adaptive | Platform-adaptive UI layer (scaffold, tab bar, sheets, lists, controls, transitions, haptics, theme tokens) | in progress (step 4b) |
| storage | Drift setup helper for per-app databases; `KeyValueStore` for scalar prefs | pending (step 4c) |
| analytics | PostHog-backed event tracker; fixed factory event set | pending (step 4d) |
| l10n | Localization scaffolding; base English ARB | pending (step 4e) |
| onboarding | `OnboardingFlow`, `OnboardingStep`, `PermissionPrompt` | pending (step 4f) |
| paywall | RevenueCat offerings-driven paywall; annual pre-selected; delayed close | pending (step 4g) |
| widget_bridge | Dart → native JSON contract; App Group / DataStore | pending (step 4h) |
| shorebird | Updater bootstrap | pending (step 4i) |

## Rules of use

- Apps import `package:factory_core/factory_core.dart` and use `AdaptiveApp` at the root. They never import `package:flutter/material.dart` or `package:flutter/cupertino.dart` directly.
- One accent color per app. Set on `AdaptiveTheme`; used for primary action, selected state, and widget tint. Nowhere else.
- Analytics events are the fixed set from `CLAUDE.md` §Conventions. Extensions require justification in the app's `PLAN.md` §7.
- Storage: use Drift for structured data, `KeyValueStore` for single scalars. No `shared_preferences` directly.

## Example

The `example/` app exercises every subsystem on iOS and Android. It is the smoke test the tester agent runs before any real app.
