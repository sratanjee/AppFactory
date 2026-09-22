#!/usr/bin/env bash
# Runs olympia-weekend with --dart-define values sourced from factory.config.
#
# This app deviates from the factory defaults (spec §0, §4, §6):
#   * No RevenueCat, no PostHog — Mixpanel replaces analytics.
#   * Supabase (anon insert) for the `sightings` table.
#   * Google Maps browser + mobile keys.
#
# Per-slug variable lookup mirrors factory.config's naming:
#   MIXPANEL_TOKEN_olympiaweekend
#   SUPABASE_OLYMPIAWEEKEND_URL / _ANON_KEY
#   GOOGLE_MAPS_{WEB,IOS,ANDROID}_KEY_olympiaweekend
#   WEB_DEPLOY_DOMAIN_olympiaweekend
#
# Pass any extra args through to `flutter run` (e.g. `-d chrome` to
# launch the web target).
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

# shellcheck disable=SC1090
source "$REPO_ROOT/factory.config"
if [[ -f "$REPO_ROOT/factory.config.local" ]]; then
  # shellcheck disable=SC1090
  source "$REPO_ROOT/factory.config.local"
fi

SLUG="olympiaweekend"

resolve() {
  local var="$1"
  echo "${!var:-}"
}

MIXPANEL_TOKEN="$(resolve MIXPANEL_TOKEN_${SLUG})"
SUPABASE_URL="$(resolve SUPABASE_OLYMPIAWEEKEND_URL)"
SUPABASE_ANON_KEY="$(resolve SUPABASE_OLYMPIAWEEKEND_ANON_KEY)"
GOOGLE_MAPS_WEB_KEY="$(resolve GOOGLE_MAPS_WEB_KEY_${SLUG})"
GOOGLE_MAPS_IOS_KEY="$(resolve GOOGLE_MAPS_IOS_KEY_${SLUG})"
GOOGLE_MAPS_ANDROID_KEY="$(resolve GOOGLE_MAPS_ANDROID_KEY_${SLUG})"
WEB_DEPLOY_DOMAIN="$(resolve WEB_DEPLOY_DOMAIN_${SLUG})"

cd "$APP_DIR"
exec flutter run \
  --dart-define=MIXPANEL_TOKEN="$MIXPANEL_TOKEN" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=GOOGLE_MAPS_WEB_KEY="$GOOGLE_MAPS_WEB_KEY" \
  --dart-define=GOOGLE_MAPS_IOS_KEY="$GOOGLE_MAPS_IOS_KEY" \
  --dart-define=GOOGLE_MAPS_ANDROID_KEY="$GOOGLE_MAPS_ANDROID_KEY" \
  --dart-define=WEB_DEPLOY_DOMAIN="$WEB_DEPLOY_DOMAIN" \
  "$@"
