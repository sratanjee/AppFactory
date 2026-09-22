# Olympia Weekend — review

Scaffolded olympia-weekend. Builder has not run yet.

## Deviations from factory defaults

The spec (§0, §4, §6) authorises these overrides of CLAUDE.md
non-negotiables 2 and 3:

- **No paywall.** `PaywallConfig.disabled()` in `lib/app_config.dart`; no
  RevenueCat keys in `factory.config`; `purchases_flutter` is pulled in
  transitively via `factory_core` but never invoked.
- **Mixpanel, not PostHog.** Factory `AnalyticsConfig` is disabled; the
  app owns its own `MixpanelService` (built in the builder step).
- **Web-first.** `flutter create` ran with `ios,android,web`. Vercel
  deploy is a builder task; a `vercel.json` at the app root lands then.
- **Supabase (anon insert).** Only the `sightings` table. Migration and
  edge function live under `apps/olympia-weekend/supabase/`.
- **Onboarding: none.** Spec §7 says first open lands on the Now screen
  with a dismissible install hint.

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged,
not blocking."

- **Shorebird app ID** — `.shorebird/shorebird.yaml` still says
  `TODO_SHOREBIRD_APP_ID`. Wire before the store builds.
- **Mixpanel token** — landed in `factory.config` as
  `MIXPANEL_TOKEN_olympiaweekend`; the run script passes it via
  `--dart-define=MIXPANEL_TOKEN`.
- **Supabase project** — `SUPABASE_OLYMPIAWEEKEND_*` in `factory.config`
  are empty; fill after `supabase projects create`.
- **Google Maps keys** — `GOOGLE_MAPS_{WEB,IOS,ANDROID}_KEY_olympiaweekend`
  in `factory.config` are empty; create in GCP project
  `appfactory-509001` with Maps JS + Maps SDK iOS/Android + Places API.
- **Web deploy domain** — `WEB_DEPLOY_DOMAIN_olympiaweekend` in
  `factory.config` is empty; pick a Vercel domain before the Thursday
  deadline.
- **Terms / Privacy URLs** — factory template still references
  `example.test`; swap before store submission (web-only doesn't need
  a privacy policy at Vercel-time but a link is required for store
  submissions next week).

## Not built

Track the reviewer's "cut list" here as the pipeline runs.
