#!/usr/bin/env bash
# ==============================================================================
# mobile-frontend-designer — PostToolUse Hook
# ==============================================================================
# Runs automatically after Edit/Write tool calls on .dart files.
# 1. Formats the changed file with dart format.
# 2. Runs flutter analyze on the project.
#
# Skips gracefully if not a Flutter project or if the changed file isn't Dart.
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

# --- Determine which file was changed ---
# The hook receives the file path as the first argument (from Claude Code hook system).
CHANGED_FILE="${1:-}"

# If no file argument, try to find recently modified .dart files
if [[ -z "$CHANGED_FILE" ]]; then
  exit 0
fi

# Skip if not a Dart file
if [[ "$CHANGED_FILE" != *.dart ]]; then
  exit 0
fi

# --- Step 1: Format the changed file ---
if command -v dart &>/dev/null; then
  echo "[mobile-frontend-designer] Formatting: $CHANGED_FILE"
  dart format "$CHANGED_FILE" 2>/dev/null || true
else
  echo "[mobile-frontend-designer] Warning: dart not found on PATH, skipping format."
fi

# --- Step 2: Run flutter analyze (project-wide, but fast) ---
if command -v flutter &>/dev/null; then
  echo "[mobile-frontend-designer] Analyzing project..."
  cd "$PROJECT_ROOT"
  flutter analyze --no-fatal-infos 2>/dev/null || {
    echo "[mobile-frontend-designer] Analysis found issues (see above)."
  }
else
  echo "[mobile-frontend-designer] Warning: flutter not found on PATH, skipping analyze."
fi

echo "[mobile-frontend-designer] Post-edit hook complete."
