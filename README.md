# Where in the World is Carmen Sandiego? — LÖVE2D Edition

[![Love2D](https://img.shields.io/badge/Love2D-11.5-e64998?logo=lua&logoColor=white)](https://love2d.org)
[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-legendaryredfox-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/legendaryredfox)

> *A faithful, bilingual (PT-BR / EN) reimagining of the classic 1985 detective game — rebuilt from scratch in Lua + LÖVE2D with pixel art retro aesthetics.*

> Working title only — see [CLAUDE.md](CLAUDE.md#ip-constraints--read-carefully) for the IP constraints this project follows and what must change before any public release.

---

![Screenshot placeholder](assets/images/screenshot_placeholder.png)

---

## About

You are an Interpol detective. A priceless national treasure has been stolen. A suspect was spotted fleeing the scene. You have limited days (7 at Rookie rank, tightening as you rank up) to track them across the globe, gather clues, identify the thief, issue an arrest warrant, and make the arrest.

- **Pixel art retro visuals** — 640×360 virtual canvas, 2× scaled to 1280×720, Press Start 2P font
- **Real world geography** — 30 cities with real lat/lon, distances and flight times via the Haversine formula
- **Bilingual** — Portuguese (PT-BR) and English selectable at the title screen or in settings
- **Real, verified clues** — 30 per-city clue pools (currency, landmark, language, geography, wildlife, culture), current-reality facts, no outdated Cold War-era trivia
- **Save/load** — persisted via `love.filesystem` + JSON
- **Detective ranking** — local leaderboard tracking cases solved and score
- **Settings** — language, music/SFX volume, typewriter text speed, all persisted

## Gameplay

1. Read the mission briefing — a treasure was stolen, a suspect seen
2. Land in a city — see a real photo and a short blurb about it
3. Travel between cities following the trail of clues
4. Interrogate witnesses at each venue — clues narrow down the suspect's traits or point to the next city
5. Cross-reference the Crime Computer to identify the suspect from gathered traits
6. Issue an arrest warrant once exactly one suspect matches
7. Fly to the thief's city and make the arrest before time runs out

## Features

| Feature | Status |
|---|---|
| Core travel system (Haversine distances) | ✅ Done |
| Clue generation & suspect deduction | ✅ Done |
| Suspect roster (10, renamed from the 1985 originals) | ✅ Done |
| Arrest warrant system | ✅ Done |
| Real per-city clue pools (30/30 cities, verified) | ✅ Done |
| World map with city markers | ✅ Done |
| City arrival photos (30/30, real, CC0/CC-BY) | ✅ Done |
| 9-slice pixel UI panels/buttons | ✅ Done |
| Screen transitions (fade) | ✅ Done |
| PT-BR / EN localization | ✅ Done |
| Save / load | ✅ Done |
| Settings (language, volume, text speed) | ✅ Done |
| Detective ranking & leaderboard | ✅ Done |
| Music & SFX | ✅ Done |
| Named venues with per-city images | 🚧 Planned (see PLAN.md Phase 6) |
| Travel-to-venue animation w/ advancing clock | 🚧 Planned (see PLAN.md Phase 6) |
| Clue images (coins, animals, landmarks) | 🚧 Planned |
| City exterior pixel art backgrounds | 🚧 Planned |

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
├── main.lua                  # LÖVE entry point — thin dispatcher
├── conf.lua                  # Window config (640×360 @ 2×)
├── SPEC.md                   # Game specification
├── PLAN.md                   # Implementation plan (phases, backlog)
├── data/
│   ├── cities.csv            # id;name_en;name_pt;country_en;country_pt;lat;lon;population
│   ├── suspects.lua          # 10-suspect roster
│   ├── routes.lua            # City-connection graphs (from the 1985 original)
│   └── clues/                # One file per city, 30 total
├── locales/
│   ├── en.lua
│   └── pt.lua
├── lib/
│   └── json.lua              # rxi/json.lua
├── src/
│   ├── state_machine.lua     # Screen state manager + fade transitions
│   ├── locale.lua            # locale.t("key") accessor
│   ├── city.lua              # City data loading + Haversine distance
│   ├── suspect.lua           # Suspect roster + trait-filter search
│   ├── mission.lua           # Mission generation + clue assignment
│   ├── clue_pool.lua         # Per-city clue pool loading
│   ├── detective.lua         # Player state: location, rank, days, clock
│   ├── save.lua               # Save/load via love.filesystem + json
│   ├── ranking.lua           # Local leaderboard (top 10)
│   ├── settings.lua          # Language/volume/text-speed persistence
│   ├── audio.lua             # Music crossfade + SFX
│   ├── game.lua              # Session state glue (detective/mission/save)
│   ├── map.lua               # World map rendering + city markers
│   ├── ui.lua                # 9-slice panels/buttons, fonts, fade, smoothing
│   └── screens/
│       ├── title.lua, language.lua, menu.lua, settings.lua
│       ├── name_entry.lua, briefing.lua, city_info.lua, city.lua
│       ├── venue.lua, crime_computer.lua, travel.lua
│       ├── arrest.lua, rank_up.lua, leaderboard.lua, game_over.lua
├── assets/
│   ├── fonts/                # Press Start 2P
│   ├── images/
│   │   ├── cities/           # 30 city arrival photos
│   │   ├── ui/                # 9-slice panel sprites
│   │   ├── clues/            # Per-clue images (planned)
│   │   └── map/               # World map base image (planned)
│   ├── sounds/{music,sfx}/   # 7 tracks, 6 SFX
│   ├── CREDITS.md            # Full asset attribution
│   └── download_assets.sh    # Re-downloads music/SFX/font from source
└── tests/
    ├── runner.lua            # Minitest runner
    └── *_test.lua            # One per src/ module with pure-Lua logic
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

All game assets are CC0, Public Domain, CC-BY, or OFL — never CC-BY-SA. Full per-file attribution (30 city photos, 7 music tracks, 6 SFX, font, UI sprites) is in [assets/CREDITS.md](assets/CREDITS.md). Re-download the audio/font set anytime with:

```bash
bash assets/download_assets.sh
```

## Contributing

Pull requests welcome. Please read [CLAUDE.md](CLAUDE.md) for code style, test, and commit conventions before opening a PR.

Key rules:
- All player-visible strings go through `locale.t("key")` — never hardcode
- Every public function needs at least one test in `tests/*_test.lua`
- No globals except `love.*`
- No AI attribution in commits — see [CLAUDE.md](CLAUDE.md#authorship)

## Inspiration & References

- Original Python prototype: [pointtonull/carmensandiego](https://github.com/pointtonull/carmensandiego)
- Classic game: *Where in the World is Carmen Sandiego?* (Broderbund, 1985) — referenced as historical/educational context only, see [CLAUDE.md](CLAUDE.md#ip-constraints--read-carefully)

## License

MIT © Rômulo Fernandes Evangelista

---

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-legendaryredfox-FFDD00?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/legendaryredfox)
