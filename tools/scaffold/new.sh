#!/usr/bin/env bash
# tools/scaffold/new.sh — thin wrapper. Runs the Dart CLI with pub deps
# resolved on demand. Called by the scaffolder agent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <spec-file> [--dry-run] [--no-git] [--force]" >&2
  exit 64
fi

cd "$SCRIPT_DIR"
if [[ ! -d .dart_tool ]]; then
  fvm dart pub get > /dev/null
fi

cd "$REPO_ROOT"
exec fvm dart run "$SCRIPT_DIR/bin/scaffold.dart" "$@"
