#!/usr/bin/env bash
# Runs impulse with --dart-define values sourced from factory.config so
# RevenueCat / PostHog keys land in app_config.dart's String.fromEnvironment
# reads. Pass any extra args through to `flutter run`.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

# shellcheck disable=SC1090
source "$REPO_ROOT/factory.config"
if [[ -f "$REPO_ROOT/factory.config.local" ]]; then
  # shellcheck disable=SC1090
  source "$REPO_ROOT/factory.config.local"
fi

cd "$APP_DIR"
exec fvm flutter run \
  --dart-define=REVENUECAT_IOS_KEY="${REVENUECAT_IOS_PUBLIC_KEY:-}" \
  --dart-define=REVENUECAT_ANDROID_KEY="${REVENUECAT_ANDROID_PUBLIC_KEY:-}" \
  --dart-define=POSTHOG_KEY="${POSTHOG_KEY:-}" \
  "$@"
