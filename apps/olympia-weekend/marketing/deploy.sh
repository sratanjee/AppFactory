#!/usr/bin/env bash
# ---------------------------------------------------------------
# olympiaweekend.app — one-shot deploy
#
# Builds a Vercel-ready folder that serves:
#   /            -> marketing landing page (apps/olympia-weekend/marketing/)
#   /app/*       -> Flutter web build (apps/olympia-weekend/build/web/)
#
# Then runs `vercel deploy --prod --yes` from that folder.
# Assumes the Vercel project is already linked (i.e. `apps/olympia-weekend/.vercel/`
# exists). If not, run `vercel link` once from apps/olympia-weekend first.
# ---------------------------------------------------------------
set -euo pipefail

# Resolve paths relative to this script — safe from any cwd.
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
APP_DIR="$( cd -- "$SCRIPT_DIR/.." &> /dev/null && pwd )"
REPO_ROOT="$( cd -- "$APP_DIR/../.." &> /dev/null && pwd )"
MARKETING_DIR="$SCRIPT_DIR"
FLUTTER_BUILD_DIR="$APP_DIR/build/web"
DEPLOY_DIR="$APP_DIR/build/vercel-deploy"

# ---- 0. Source factory config for --dart-define values ---------
# Mirrors tool/run.sh so both flutter-run and vercel-deploy see the
# same MIXPANEL_TOKEN / SUPABASE / MAPS keys. Missing config → build
# proceeds with empty tokens (Mixpanel + Supabase no-op in the app,
# marketing analytics stays a stub — matches local preview behaviour).
if [[ -f "$REPO_ROOT/factory.config" ]]; then
  # shellcheck disable=SC1090,SC1091
  source "$REPO_ROOT/factory.config"
fi
if [[ -f "$REPO_ROOT/factory.config.local" ]]; then
  # shellcheck disable=SC1090,SC1091
  source "$REPO_ROOT/factory.config.local"
fi

SLUG="olympiaweekend"
MIXPANEL_TOKEN="${MIXPANEL_TOKEN_olympiaweekend:-}"
SUPABASE_URL="${SUPABASE_OLYMPIAWEEKEND_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_OLYMPIAWEEKEND_ANON_KEY:-}"
GOOGLE_MAPS_WEB_KEY="${GOOGLE_MAPS_WEB_KEY_olympiaweekend:-}"
WEB_DEPLOY_DOMAIN="${WEB_DEPLOY_DOMAIN_olympiaweekend:-}"
export MIXPANEL_TOKEN

echo ""
echo "  olympiaweekend.app — deploy"
echo "  ============================"
echo "  app dir       : $APP_DIR"
echo "  marketing dir : $MARKETING_DIR"
echo "  deploy dir    : $DEPLOY_DIR"
if [[ -n "$MIXPANEL_TOKEN" ]]; then
  echo "  mixpanel      : enabled (token from factory.config)"
else
  echo "  mixpanel      : DISABLED (MIXPANEL_TOKEN_${SLUG} not set)"
fi
echo ""

# ---- 1. Build Flutter web with /app/ base href -----------------
echo "-> Building Flutter web (--base-href /app/) ..."
cd "$APP_DIR"
flutter build web --release \
  --base-href "/app/" \
  --dart-define=MIXPANEL_TOKEN="$MIXPANEL_TOKEN" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=GOOGLE_MAPS_WEB_KEY="$GOOGLE_MAPS_WEB_KEY" \
  --dart-define=WEB_DEPLOY_DOMAIN="$WEB_DEPLOY_DOMAIN"

if [ ! -f "$FLUTTER_BUILD_DIR/index.html" ]; then
  echo "!! flutter build did not produce build/web/index.html. Aborting."
  exit 1
fi

# ---- 2. Assemble merged deploy folder --------------------------
echo "-> Assembling merged deploy folder ..."
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"

# Marketing site at the root. Exclude vercel.json (handled below) and this script.
rsync -a \
  --exclude 'deploy.sh' \
  --exclude 'README.md' \
  --exclude 'vercel.json' \
  "$MARKETING_DIR"/ "$DEPLOY_DIR"/

# Flutter build under /app/.
mkdir -p "$DEPLOY_DIR/app"
rsync -a "$FLUTTER_BUILD_DIR"/ "$DEPLOY_DIR/app"/

# vercel.json (from marketing/) sits at the root of the deploy folder.
cp "$MARKETING_DIR/vercel.json" "$DEPLOY_DIR/vercel.json"

# ---- 2a. Substitute the Mixpanel token into the marketing HTML --
# The static pages ship the literal placeholder `__MP_TOKEN__` so
# local preview stays inert. Deploy replaces it with the real token
# in-place. Perl (portable, no sed -i quirks) reads from $ENV so we
# don't have to escape regex chars.
if [[ -n "$MIXPANEL_TOKEN" ]]; then
  echo "-> Substituting Mixpanel token into HTML ..."
  find "$DEPLOY_DIR" -maxdepth 2 -name '*.html' -type f -print0 \
    | xargs -0 perl -pi -e 's/__MP_TOKEN__/$ENV{MIXPANEL_TOKEN}/g'
fi

echo "-> Merge complete."
echo ""
du -sh "$DEPLOY_DIR" || true
echo ""

# ---- 3. Deploy to Vercel ---------------------------------------
# Prefer the Vercel project link that already lives under apps/olympia-weekend/.vercel/.
if [ -d "$APP_DIR/.vercel" ]; then
  cp -R "$APP_DIR/.vercel" "$DEPLOY_DIR/.vercel"
fi

echo "-> vercel deploy --prod --yes"
cd "$DEPLOY_DIR"
# Scope is required because the copied .vercel/project.json points at a
# stale team_id — passing --scope routes the deploy to the current team.
vercel deploy --prod --yes --scope sarang-ratanjees-projects

echo ""
echo "  Done. Visit https://olympiaweekend.app/"
echo ""
