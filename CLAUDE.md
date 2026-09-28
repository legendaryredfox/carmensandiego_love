# Carmen Sandiego — LÖVE2D Edition

Clone of the classic "Where in the World is Carmen Sandiego?" (Broderbund, 1985) rebuilt in Lua + LÖVE2D.
Bilingual: PT-BR and EN. Pixel art retro aesthetic.

## Project goals

- Faithful recreation of the 1985 Broderbund mechanics: travel, clues, dossier, arrest warrant
- Extended: real-world coordinates (Haversine distances), save/load, detective ranking
- Modular, testable, no global state pollution

## Tech stack

| What | Tool |
|---|---|
| Language | Lua 5.1 (LÖVE runtime) |
| Framework | LÖVE2D 11.5 (love2d.org) |
| Serialization | rxi/json.lua (single file, no deps) |
| Tests | Custom minitest framework (no external deps) |
| i18n | Locale files per language, menu selection at title screen |
| Virtual resolution | 640×360 canvas, 2× scale → 1280×720 window |

## Directory structure

```
carmensandiego_love/
├── main.lua                  # LÖVE entry point — thin dispatcher only
├── conf.lua                  # LÖVE window/module config
├── CLAUDE.md
├── SPEC.md                   # game specification
├── PLAN.md                   # implementation plan
├── data/
│   ├── cities.csv            # id;name_en;name_pt;country_en;country_pt;lat;lon;population
│   ├── suspects.lua          # suspect roster (Lua table, no CSV — complex data)
│   ├── routes.lua            # 8 city-connection graphs (from original game)
│   └── clues/                # per-city clue pools
│       └── <city_id>.lua
├── locales/
│   ├── en.lua
│   └── pt.lua
├── lib/
│   └── json.lua              # rxi/json.lua
├── src/
│   ├── state_machine.lua     # screen state manager
│   ├── locale.lua            # locale.t("key") accessor
│   ├── city.lua              # city data loading + Haversine distance
│   ├── suspect.lua           # suspect roster + trait-filter search
│   ├── mission.lua           # mission generation + clue system
│   ├── detective.lua         # player state: location, rank, days, clues gathered
│   ├── save.lua              # save/load slots via love.filesystem + json
│   ├── ranking.lua           # local leaderboard (top 10)
│   ├── screens/
│   │   ├── title.lua
│   │   ├── language.lua
│   │   ├── menu.lua
│   │   ├── name_entry.lua
│   │   ├── briefing.lua
│   │   ├── city.lua
│   │   ├── venue.lua
│   │   ├── crime_computer.lua
│   │   ├── travel.lua
│   │   ├── arrest.lua
│   │   ├── rank_up.lua
│   │   ├── leaderboard.lua
│   │   └── game_over.lua
│   ├── map.lua               # world map rendering + city markers
│   └── ui.lua                # shared UI primitives: panels, buttons, fonts
├── assets/
│   ├── fonts/
│   ├── images/
│   │   ├── map/              # world map base image
│   │   ├── clues/            # per-clue images (coins, animals, landmarks)
│   │   └── ui/               # panels, buttons, icons
│   └── sounds/
│       ├── music/
│       └── sfx/
└── tests/
    ├── runner.lua            # minitest runner — discovers *_test.lua
    ├── city_test.lua
    ├── suspect_test.lua
    ├── mission_test.lua
    ├── detective_test.lua
    ├── locale_test.lua
    └── save_test.lua
```

## AI rules (read before every task)

### Authorship
- AI must NEVER appear as author or co-author in commits.
- No "Co-Authored-By: Claude" or any AI attribution in commit messages.
- Commit messages written by the developer, not generated wholesale by AI.

### Code style
- Every module returns a single table. No globals except `love.*`.
- `local M = {}` at top, `return M` at bottom.
- Snake_case for functions and variables. PascalCase for "class-like" tables.
- Max ~80 chars per line where practical.
- No comments explaining WHAT the code does — only WHY when non-obvious.
- No docstring blocks.

### Tests
- Test files end with `_test.lua`, live in `tests/`.
- Run with: `lua tests/runner.lua` (no LÖVE required for logic tests).
- Every public function in `src/` must have at least one test.
- Tests must not depend on LÖVE APIs — keep logic pure Lua.
- New feature = new test before or alongside implementation.

### i18n
- All player-visible strings go through `locale.t("key")`. Never hardcode in src/.
- Add key to BOTH `locales/en.lua` AND `locales/pt.lua` together — never one without the other.

### Assets
- Pixel art: `love.graphics.setDefaultFilter("nearest", "nearest")` before any asset loads.
- Virtual canvas 640×360, scaled 2× to 1280×720 — scale factor defined once in `conf.lua`.
- Integer scaling only. Never 1.5× or fractional scales.
- All assets must be CC0, CC-BY, or OFL licensed. Document source + license in `assets/CREDITS.md`.

### Mechanics constraints
- Distance calculated by Haversine from real lat/lon in cities.csv.
- Detective has limited days (default 7 at Rookie, tightens at higher ranks).
- Arrest warrant requires all entered traits to match exactly one suspect.

### IP constraints — READ CAREFULLY
- This project references the **1985 Broderbund game only** as historical/educational context.
- **NEVER** use visual assets, character designs, or narrative elements from:
  - Netflix animated series "Carmen Sandiego" (2019–2021)
  - "Carmen Sandiego: To Steal or Not to Steal" (Netflix, 2020)
  - Nintendo Switch game "Carmen Sandiego" (2021)
  - Any post-1995 Broderbund/HMH Carmen Sandiego media
- The modern Netflix Carmen (red trench coat, stylized fedora) is active copyrighted IP.
- Character sprites must be **generic pixel art detectives/villains** — not imitations of any specific Carmen Sandiego design.
- **Working title only** — the final game title must not include "Carmen Sandiego" (registered trademark of HMH Co.). Resolve before public release.
- Suspect names may be inspired by 1985 originals but should be **renamed** to avoid IP issues.

### Geographic accuracy
- Clue facts (currency, language, flag, religion, political system, capital, fauna) must reflect **current reality**, not 1985 data.
- The original game's clues are outdated: USSR → Russia, drachma → Euro (Greece), Yugoslavia dissolved, etc.
- Before adding any factual clue, verify against a current authoritative source (Wikipedia, CIA World Factbook, etc.).
- Mark unverified clues with a `-- TODO: verify` comment in the clue data file.
- Open-source country images (Wikimedia Commons CC0/CC-BY) may be used for visual clues.

### Visual clue system
- Clues should **suggest, not reveal**. A clue about Greece shows a drachma coin image — not the word "Greece".
- Clue text is intentionally vague: "The informant mentioned unusual currency" + coin image.
- At Rookie rank: text clue includes a soft geographic hint ("a Mediterranean currency").
- At Ace Detective rank: image only, no text hint.
- **Flags are NEVER shown as images.** Flag clues are always text-only descriptions of colors/symbols/layout. A flag image is too direct a giveaway.

### Forbidden patterns
- `require` inside functions (top-level only).
- Modifying `package.path` at runtime.
- `os.execute` or `io.popen` in game code.
- Storing mutable state in module-level variables (use returned table instances).
- Hardcoded strings visible to the player outside `locales/`.
