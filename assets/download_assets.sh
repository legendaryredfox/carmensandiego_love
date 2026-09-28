#!/usr/bin/env bash
# Downloads CC0 audio assets for Detective Agency (carmensandiego_love).
# Run from the project root: bash assets/download_assets.sh
# Requires: curl, unzip, ffmpeg

set -e
cd "$(dirname "$0")/.."

echo "=== Detective Agency — Asset Downloader ==="
echo "All assets are CC0 (public domain). See assets/CREDITS.md."
echo ""

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }
need curl; need unzip; need ffmpeg

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p assets/sounds/music assets/sounds/sfx assets/fonts

# ── Music: 15 Melodic RPG Chiptunes (CC0) ──────────────────────────────────
echo "[1/3] Downloading 15 Melodic RPG Chiptunes..."
curl -L -o "$TMPDIR/chiptunes.zip" \
  "https://opengameart.org/sites/default/files/15_Melodic_RPG_Chiptunes_0.zip"
unzip -q "$TMPDIR/chiptunes.zip" -d "$TMPDIR/chiptunes"

# Map tracks to our music slots (filenames may vary by archive version)
# Adjust if track numbers differ after extraction
CHIPTUNE_DIR="$TMPDIR/chiptunes"
tracks=( $(ls "$CHIPTUNE_DIR"/*.ogg 2>/dev/null | sort) )

copy_track() {
  local idx=$1 dest=$2
  local src="${tracks[$idx]:-}"
  if [ -n "$src" ] && [ -f "$src" ]; then
    cp "$src" "assets/sounds/music/$dest"
    echo "  -> $dest"
  else
    echo "  WARNING: track $idx not found for $dest"
  fi
}

copy_track 0  "title.ogg"
copy_track 2  "city.ogg"
copy_track 5  "computer.ogg"
copy_track 7  "briefing.ogg"  # shrine_of_mysteries
copy_track 14 "failure.ogg"   # game_over

# ── Music: 4 Chiptunes Adventure (CC0, Juhani Junkala) ─────────────────────
echo "[2/3] Downloading 4 Chiptunes Adventure..."
curl -L -o "$TMPDIR/adventure.zip" \
  "https://opengameart.org/sites/default/files/4_chiptunes_adventure.zip"
unzip -q "$TMPDIR/adventure.zip" -d "$TMPDIR/adventure"

adv_tracks=( $(ls "$TMPDIR/adventure"/*.ogg 2>/dev/null | sort) )
[ -f "${adv_tracks[1]:-}" ] && cp "${adv_tracks[1]}" "assets/sounds/music/travel.ogg" && echo "  -> travel.ogg"
[ -f "${adv_tracks[0]:-}" ] && cp "${adv_tracks[0]}" "assets/sounds/music/success.ogg" && echo "  -> success.ogg"

# ── SFX: 512 Sound Effects 8-bit (CC0) ─────────────────────────────────────
echo "[3/3] Downloading 512 Sound Effects..."
curl -L -o "$TMPDIR/sfx.zip" \
  "https://opengameart.org/sites/default/files/512_Sound_Effects_8-bit_0.zip"
unzip -q "$TMPDIR/sfx.zip" -d "$TMPDIR/sfx"

sfx_files=( $(ls "$TMPDIR/sfx"/*.wav 2>/dev/null | sort) )
# Pick reasonable candidates by index
[ -f "${sfx_files[0]:-}" ]  && cp "${sfx_files[0]}"  "assets/sounds/sfx/click.wav"       && echo "  -> click.wav"
[ -f "${sfx_files[10]:-}" ] && cp "${sfx_files[10]}" "assets/sounds/sfx/clue.wav"        && echo "  -> clue.wav"
[ -f "${sfx_files[20]:-}" ] && cp "${sfx_files[20]}" "assets/sounds/sfx/warrant.wav"     && echo "  -> warrant.wav"
[ -f "${sfx_files[30]:-}" ] && cp "${sfx_files[30]}" "assets/sounds/sfx/arrest_ok.wav"   && echo "  -> arrest_ok.wav"
[ -f "${sfx_files[40]:-}" ] && cp "${sfx_files[40]}" "assets/sounds/sfx/arrest_fail.wav" && echo "  -> arrest_fail.wav"
[ -f "${sfx_files[5]:-}" ]  && cp "${sfx_files[5]}"  "assets/sounds/sfx/type.wav"        && echo "  -> type.wav"

# ── Font: Press Start 2P (OFL) ──────────────────────────────────────────────
echo "[+] Downloading Press Start 2P font..."
curl -L -o "$TMPDIR/font.zip" \
  "https://fonts.google.com/download?family=Press+Start+2P"
unzip -q "$TMPDIR/font.zip" -d "$TMPDIR/font" 2>/dev/null || true
find "$TMPDIR/font" -name "*.ttf" | head -1 | xargs -I{} cp {} "assets/fonts/PressStart2P.ttf" 2>/dev/null \
  && echo "  -> PressStart2P.ttf" || echo "  WARNING: font download failed (try manually)"

echo ""
echo "Done. Audio files are in assets/sounds/. Font in assets/fonts/."
echo "If any file is missing, download it manually (see assets/CREDITS.md for URLs)."
echo ""
echo "To activate Press Start 2P in-game, update src/ui.lua:"
echo '  font_sm = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 8)'
echo '  font_md = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 10)'
echo '  font_lg = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 14)'
