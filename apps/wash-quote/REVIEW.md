# 'Wash Quote & Invoice' — review

Scaffolded wash-quote. Builder has not run yet.

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged, not blocking."

- Shorebird app ID — `.shorebird/shorebird.yaml` still says `TODO_SHOREBIRD_APP_ID`.
- RevenueCat keys — read at build via --dart-define; blank locally.
- Terms / Privacy URLs — `lib/app_config.dart` uses `example.test`; swap before release.
- Scaffold template lints — fixed inline in `lib/app_config.dart` (double-quote outer for benefits[1]) and `lib/screens/home_screen.dart` (`const Text` in `AdaptiveScaffold.title`). Same bugs in `tools/scaffold/lib/templates.dart` — factory-level fix, out of scope for per-app scaffolder.
- Bundle ID normalization — `flutter create --project-name wash_quote --org com.appfactory` emits `com.appfactory.washQuote` (iOS, camelCased) / `com.appfactory.wash_quote` (Android). Overwrote both to `com.appfactory.washquote` per spec §1 and scaffolder agent step 3. Kotlin source package left as `com.appfactory.wash_quote` (different concept from applicationId, compiles fine). Generator should collapse hyphens for slug-with-hyphen apps by default.
