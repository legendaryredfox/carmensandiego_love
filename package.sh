#!/bin/sh
# Packages the game as a distributable .love file (see PLAN.md Phase 6).
# Usage: ./package.sh [output-path]
set -eu

cd "$(dirname "$0")"
out="${1:-game.love}"

rm -f "$out"
zip -9 -r "$out" . \
    -x "*.git*" \
    -x "tests/*" \
    -x "references/*" \
    -x "SPEC.md" \
    -x "PLAN.md" \
    -x "CLAUDE.md" \
    -x "README.md" \
    -x "package.sh" \
    -x "assets/download_assets.sh" \
    -x "*.love"

echo "Wrote $out ($(du -h "$out" | cut -f1))"
