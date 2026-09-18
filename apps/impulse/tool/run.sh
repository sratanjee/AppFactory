#!/usr/bin/env bash
# Runs impulse with --dart-define values sourced from factory.config so
# RevenueCat / PostHog keys land in app_config.dart's String.fromEnvironment
# reads. Pass any extra args through to `flutter run`.
#
# Per-slug key lookup: REVENUECAT_IOS_KEY_impulse /
# REVENUECAT_ANDROID_KEY_impulse are the canonical names in
# factory.config. This wrapper resolves them into REVENUECAT_IOS_KEY /
# REVENUECAT_ANDROID_KEY for the app to consume.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

# shellcheck disable=SC1090
source "$REPO_ROOT/factory.config"
if [[ -f "$REPO_ROOT/factory.config.local" ]]; then
  # shellcheck disable=SC1090
  source "$REPO_ROOT/factory.config.local"
fi

SLUG="impulse"
RC_IOS_VAR="REVENUECAT_IOS_KEY_${SLUG}"
RC_ANDROID_VAR="REVENUECAT_ANDROID_KEY_${SLUG}"
RC_IOS_KEY="${!RC_IOS_VAR:-}"
RC_ANDROID_KEY="${!RC_ANDROID_VAR:-}"

cd "$APP_DIR"
exec fvm flutter run \
  --dart-define=REVENUECAT_IOS_KEY="$RC_IOS_KEY" \
  --dart-define=REVENUECAT_ANDROID_KEY="$RC_ANDROID_KEY" \
  --dart-define=POSTHOG_KEY="${POSTHOG_KEY:-}" \
  "$@"
