# Carmen Sandiego — LÖVE2D Edition

Clone of the classic "Where in the World is Carmen Sandiego?" rebuilt in Lua + LÖVE2D.
Bilingual: PT-BR and EN. Pixel art retro aesthetic.

## Project goals

- Faithful recreation of the original mechanics: travel, clues, dossier, arrest warrant
- Extended: real-world coordinates (Haversine distances), save/load, detective ranking
- Modular, testable, no global state pollution

## Tech stack

| What | Tool |
|---|---|
| Language | Lua 5.1 (LÖVE runtime) |
| Framework | LÖVE2D (love2d.org) |
| Tests | Custom minitest framework (no external deps) |
| i18n | Locale files per language, menu selection |

## Directory structure

```
carmensandiego_love/
├── main.lua              # LÖVE entry point
├── conf.lua              # LÖVE window config
├── CLAUDE.md
├── data/
│   └── cities.csv        # city;english_name;country;population (from original)
├── locales/
│   ├── en.lua
│   └── pt.lua
├── src/
│   ├── state_machine.lua # screen state manager
│   ├── city.lua          # city data + Haversine distance
│   ├── thief.lua         # suspect roster + search logic
│   ├── mission.lua       # mission generation + clue system
│   ├── detective.lua     # player state: location, rank, days
│   ├── save.lua          # save/load via love.filesystem
│   ├── ranking.lua       # local leaderboard
│   ├── map.lua           # world map rendering
│   └── ui.lua            # shared UI primitives (panels, fonts, buttons)
├── assets/
│   ├── fonts/
│   ├── images/
│   └── sounds/
└── tests/
    ├── runner.lua         # minitest runner — discovers *_test.lua files
    ├── city_test.lua
    ├── thief_test.lua
    ├── mission_test.lua
    ├── detective_test.lua
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
- All player-visible strings go through `locale.t("key")`. Never hardcode strings in src/.
- Add key to both `locales/en.lua` and `locales/pt.lua` together.

### Assets
- Pixel art: nearest-neighbor filter (`love.graphics.setDefaultFilter("nearest", "nearest")`).
- Scale factor defined once in `conf.lua` (e.g. `2x` or `3x`).

### Mechanics constraints
- Distance calculated by Haversine from real lat/lon in cities.csv.
- Detective has limited days (default 7). Exceeding = mission failed.
- Arrest warrant requires matching ≥ 3 suspect traits.

### Forbidden patterns
- `require` inside functions (top-level only).
- Modifying `package.path` at runtime.
- `os.execute` or `io.popen` in game code.
- Storing mutable state in module-level variables (use returned table instances).
