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

## Provisioned

- **Mixpanel** — project `4066052`, token in `factory.config` as
  `MIXPANEL_TOKEN_olympiaweekend`.
- **Supabase — olympia-weekend project** — ref `eyssbcnvtxcnpmuivmny`,
  region us-west-2, org `ydluibrbwqpsnzkhofpu` (same org as
  wash-quote-cloud). All keys + DB password in `factory.config` as
  `SUPABASE_OLYMPIAWEEKEND_*`. Two migrations applied:
  `20260922000000_sightings` (table, RLS, rate-limit trigger, public
  `olympia-live` bucket) and `20260922000100_schedule_recompute`
  (`pg_cron` + `pg_net` + `*/5 * * * *` job that invokes the edge
  function). Vault secrets `olympia_project_ref` +
  `olympia_service_role_key` inserted so the cron JSON body doesn't
  hold plaintext creds. Edge function
  `recompute-athlete-status` deployed with JWT verification on; seed
  file `olympia-live/athletes.seed.json` uploaded; a manual invocation
  primed `olympia-live/athletes.json`.
- **Google Maps** — three API keys in `appfactory-509001`, values in
  `factory.config` as `GOOGLE_MAPS_{WEB,IOS,ANDROID}_KEY_olympiaweekend`.
  Each has an API-scope restriction (web = Maps JS + Places, iOS =
  Maps SDK iOS, Android = Maps SDK Android).
  - Web key HTTP referrer allowlist:
    `https://olympia-weekend.vercel.app/*`,
    `https://olympia-weekend-*.vercel.app/*` (preview URLs),
    `http://localhost:*/*`, `http://127.0.0.1:*/*`. Replace with the
    real custom domain once picked.
  - iOS key bundle allowlist: `com.appfactory.olympiaweekend`.
  - Android key application restriction: **still open**. Needs
    package `com.appfactory.olympia_weekend` + the release keystore
    SHA-1 (add via `gcloud alpha services api-keys update
    projects/appfactory-509001/locations/global/keys/0240a479-5976-48b5-80d5-3872e080ec1c
    --allowed-application=sha1_fingerprint=<SHA>,package_name=com.appfactory.olympia_weekend`
    once the release keystore exists).

## Open at scaffold time

Fill in as the pipeline progresses. Empty at scaffold means "flagged,
not blocking."

- **Shorebird app ID** — `.shorebird/shorebird.yaml` still says
  `TODO_SHOREBIRD_APP_ID`. Wire before the store builds.
- **Android Maps key SHA-1** — see the "Provisioned" note above.
  Blocking only for the Play internal build later this week.
- **Custom Vercel domain** — swap the `olympia-weekend.vercel.app`
  placeholder in the web key referrer list for the real domain once
  picked.
- **Web deploy domain** — `WEB_DEPLOY_DOMAIN_olympiaweekend` in
  `factory.config` is empty; pick a Vercel domain before the Thursday
  deadline.
- **Terms / Privacy URLs** — factory template still references
  `example.test`; swap before store submission (web-only doesn't need
  a privacy policy at Vercel-time but a link is required for store
  submissions next week).

## Not built

Track the reviewer's "cut list" here as the pipeline runs.
