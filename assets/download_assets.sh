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
  "https://opengameart.org/sites/default/files/15_melodic_rpg_chiptunes_ogg.zip"
unzip -q "$TMPDIR/chiptunes.zip" -d "$TMPDIR/chiptunes"

# Filenames are stable (author-provided names), so match by name rather
# than by sorted index — the pack's track order isn't documented anywhere.
copy_named() {
  local pattern=$1 dest=$2
  local src
  src=$(find "$TMPDIR/chiptunes" -iname "$pattern" | head -1)
  if [ -n "$src" ]; then
    cp "$src" "assets/sounds/music/$dest"
    echo "  -> $dest"
  else
    echo "  WARNING: no match for '$pattern' (wanted $dest)"
  fi
}

copy_named "*title_screen*"        "title.ogg"
copy_named "*town*"                "city.ogg"
copy_named "*dungeon*"             "computer.ogg"
copy_named "*shrine_of_mysteries*" "briefing.ogg"
copy_named "*game_over*"           "failure.ogg"

# ── Music: Chiptune Adventures (CC0, Juhani Junkala) ───────────────────────
echo "[2/3] Downloading Chiptune Adventures..."
curl -L -o "$TMPDIR/adventure.zip" \
  "https://opengameart.org/sites/default/files/Juhani%20Junkala%20%5BChiptune%20Adventures%5D%20OGG.zip"
unzip -q "$TMPDIR/adventure.zip" -d "$TMPDIR/adventure"

copy_adventure() {
  local pattern=$1 dest=$2
  local src
  src=$(find "$TMPDIR/adventure" -iname "$pattern" | head -1)
  if [ -n "$src" ]; then
    cp "$src" "assets/sounds/music/$dest"
    echo "  -> $dest"
  else
    echo "  WARNING: no match for '$pattern' (wanted $dest)"
  fi
}

copy_adventure "*1. Stage 1*"     "travel.ogg"
copy_adventure "*4. Stage Select*" "success.ogg"

# ── SFX: The Essential Retro Video Game Sound Effects Collection (CC0) ─────
echo "[3/3] Downloading 512 Sound Effects..."
curl -L -o "$TMPDIR/sfx.zip" \
  "https://opengameart.org/sites/default/files/The%20Essential%20Retro%20Video%20Game%20Sound%20Effects%20Collection%20%5B512%20sounds%5D.zip"
unzip -q "$TMPDIR/sfx.zip" -d "$TMPDIR/sfx"

copy_sfx() {
  local pattern=$1 dest=$2
  local src
  src=$(find "$TMPDIR/sfx" -iname "$pattern" | head -1)
  if [ -n "$src" ]; then
    cp "$src" "assets/sounds/sfx/$dest"
    echo "  -> $dest"
  else
    echo "  WARNING: no match for '$pattern' (wanted $dest)"
  fi
}

copy_sfx "sfx_menu_select1.wav"   "click.wav"
copy_sfx "sfx_sounds_powerup10.wav" "clue.wav"
copy_sfx "sfx_sounds_fanfare1.wav"  "warrant.wav"
copy_sfx "sfx_sounds_fanfare3.wav"  "arrest_ok.wav"
copy_sfx "sfx_sounds_error10.wav"   "arrest_fail.wav"
copy_sfx "sfx_sounds_Blip1.wav"     "type.wav"

# ── Font: Press Start 2P (OFL, from the Google Fonts source repo) ─────────
echo "[+] Downloading Press Start 2P font..."
curl -L -o "assets/fonts/PressStart2P.ttf" \
  "https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf"
if [ -s "assets/fonts/PressStart2P.ttf" ]; then
  echo "  -> PressStart2P.ttf"
else
  rm -f "assets/fonts/PressStart2P.ttf"
  echo "  WARNING: font download failed (try manually)"
fi

echo ""
echo "Done. Audio files are in assets/sounds/. Font in assets/fonts/."
echo "If any file is missing, download it manually (see assets/CREDITS.md for URLs)."
echo ""
echo "To activate Press Start 2P in-game, update src/ui.lua:"
echo '  font_sm = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 8)'
echo '  font_md = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 10)'
echo '  font_lg = love.graphics.newFont("assets/fonts/PressStart2P.ttf", 14)'
