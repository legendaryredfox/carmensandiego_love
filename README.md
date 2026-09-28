# Where in the World is Carmen Sandiego? — LÖVE2D Edition

[![Love2D](https://img.shields.io/badge/Love2D-11.5-e64998?logo=lua&logoColor=white)](https://love2d.org)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-legendaryredfox-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/legendaryredfox)

> *A faithful, bilingual (PT-BR / EN) reimagining of the classic 1985 detective game — rebuilt from scratch in Lua + LÖVE2D with pixel art retro aesthetics.*

---

![Screenshot placeholder](assets/images/screenshot_placeholder.png)

---

## About

You are an Interpol detective. A priceless national treasure has been stolen. A suspect from the V.I.L.E. criminal organization was spotted at the scene. You have **7 days** to track them across the globe, gather clues, identify the thief, issue an arrest warrant, and make the arrest.

This project is a complete rewrite of the original [carmensandiego](https://github.com/pointtonull/carmensandiego) Python CLI prototype — now as a full LÖVE2D game with:

- **Pixel art retro visuals** — 640×360 virtual canvas, 2× scaled to 1280×720
- **Real world geography** — city coordinates from a curated dataset, distances via the Haversine formula
- **Bilingual** — Portuguese (PT-BR) and English selectable at the title screen
- **Save/load** — multiple detective slots persisted via `love.filesystem`
- **Detective ranking** — local leaderboard tracking time-to-arrest and rank progression

## Gameplay

1. Read the mission briefing — a treasure was stolen, a suspect seen
2. Travel between cities following the trail of clues
3. Interrogate witnesses — each clue narrows down the suspect's traits
4. Cross-reference the V.I.L.E. dossier to identify the criminal
5. Issue an arrest warrant with enough evidence
6. Arrest them before time runs out

## Features

| Feature | Status |
|---|---|
| Core travel system (Haversine distances) | 🚧 In progress |
| Clue generation & suspect deduction | 🚧 In progress |
| V.I.L.E. dossier (10 suspects) | 🚧 In progress |
| Arrest warrant system | 🚧 In progress |
| World map with city markers | 🚧 In progress |
| Pixel art UI & animations | 🚧 In progress |
| PT-BR / EN localization | 🚧 In progress |
| Save / load (multiple slots) | 🚧 In progress |
| Detective ranking & leaderboard | 🚧 In progress |

## Requirements

- [LÖVE 11.5+](https://love2d.org) — download for Linux, macOS, or Windows
- Lua 5.1 (bundled with LÖVE — no separate install needed)
- For running tests: `lua` 5.1+ on PATH

## Running

```bash
# Clone
git clone https://github.com/legendaryredfox/carmensandiego_love.git
cd carmensandiego_love

# Run with LÖVE
love .
```

## Running Tests

Tests are pure Lua — no LÖVE required:

```bash
lua tests/runner.lua
```

Test files follow the `*_test.lua` naming convention and live in `tests/`.

## Project Structure

```
carmensandiego_love/
├── main.lua              # LÖVE entry point
├── conf.lua              # Window config (640×360 @ 2×)
├── data/
│   └── cities.csv        # city;english_name;country;lat;lon;population
├── locales/
│   ├── en.lua            # English strings
│   └── pt.lua            # Portuguese strings
├── src/
│   ├── state_machine.lua # Screen state manager
│   ├── city.lua          # City data + Haversine distance
│   ├── thief.lua         # Suspect roster + search logic
│   ├── mission.lua       # Mission generation + clue system
│   ├── detective.lua     # Player state: location, rank, days
│   ├── save.lua          # Save/load via love.filesystem
│   ├── ranking.lua       # Local leaderboard
│   ├── map.lua           # World map rendering
│   └── ui.lua            # Shared UI primitives
├── assets/
│   ├── fonts/
│   ├── images/
│   └── sounds/
└── tests/
    ├── runner.lua         # Minitest runner
    ├── city_test.lua
    ├── thief_test.lua
    ├── mission_test.lua
    ├── detective_test.lua
    └── save_test.lua
```

## Tech Stack

| What | Tool |
|---|---|
| Language | Lua 5.1 |
| Game framework | [LÖVE2D 11.5](https://love2d.org) |
| Serialization | [rxi/json.lua](https://github.com/rxi/json.lua) |
| Test framework | Custom minitest (zero external deps) |
| Virtual resolution | 640×360 → 1280×720 (2× integer scale) |
| Font | [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) (OFL) |

## Assets & Licenses

All game assets are free for commercial use:

| Asset type | Source | License |
|---|---|---|
| UI sprites | [Kenney Pixel UI Pack](https://kenney.nl/assets/pixel-ui-pack) | CC0 |
| Character sprites | [Kenney Roguelike Characters](https://kenney.nl/assets/roguelike-characters) | CC0 |
| Map icons | [Kenney Board Game Icons](https://kenney.nl/assets/board-game-icons) | CC0 |
| Music | [OpenGameArt — 15 Melodic RPG Chiptunes](https://opengameart.org/content/15-melodic-rpg-chiptunes) | CC0 |
| SFX | [OpenGameArt — 512 Sound Effects 8-bit](https://opengameart.org/content/512-sound-effects-8-bit-style) | CC0 |
| Font | [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) | OFL |

## Contributing

Pull requests welcome. Please read [CLAUDE.md](CLAUDE.md) for code style, test, and commit conventions before opening a PR.

Key rules:
- All player-visible strings go through `locale.t("key")` — never hardcode
- Every public function needs at least one test in `tests/*_test.lua`
- No globals except `love.*`

## Inspiration & References

- Original Python prototype: [pointtonull/carmensandiego](https://github.com/pointtonull/carmensandiego)
- Classic game: *Where in the World is Carmen Sandiego?* (Broderbund, 1985)

## License

MIT © Rômulo Fernandes Evangelista

---

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-legendaryredfox-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/legendaryredfox)
