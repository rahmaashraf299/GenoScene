#!/usr/bin/env bash
# ==============================================================================
# mobile-frontend-designer — Stop Hook
# ==============================================================================
# Runs automatically when Claude Code session ends or before finishing.
# Executes flutter test to catch regressions before the session closes.
#
# Skips gracefully if not a Flutter project or if no test directory exists.
# ==============================================================================

set -euo pipefail

# --- Resolve project root (look for pubspec.yaml) ---
find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" && "$dir" != "" ]]; do
    if [[ -f "$dir/pubspec.yaml" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

PROJECT_ROOT=$(find_project_root) || {
  # Not a Flutter/Dart project — skip silently
  exit 0
}

cd "$PROJECT_ROOT"

# --- Check if test directory exists ---
if [[ ! -d "test" ]]; then
  echo "[mobile-frontend-designer] No test/ directory found — skipping tests."
  exit 0
fi

# --- Check if there are any test files ---
TEST_COUNT=$(find test -name "*_test.dart" 2>/dev/null | wc -l)
if [[ "$TEST_COUNT" -eq 0 ]]; then
  echo "[mobile-frontend-designer] No test files found — skipping tests."
  exit 0
fi

# --- Run flutter test ---
if command -v flutter &>/dev/null; then
  echo "[mobile-frontend-designer] Running flutter test ($TEST_COUNT test files)..."
  echo "=============================================="

  flutter test --no-pub 2>&1 || {
    EXIT_CODE=$?
    echo "=============================================="
    echo "[mobile-frontend-designer] WARNING: Tests failed (exit code $EXIT_CODE)."
    echo "[mobile-frontend-designer] Review failures above before deploying."
    # Don't block session exit — just warn
    exit 0
  }

  echo "=============================================="
  echo "[mobile-frontend-designer] All tests passed."
else
  echo "[mobile-frontend-designer] Warning: flutter not found on PATH, skipping tests."
fi
