# Implementation Plan

See SPEC.md for full design. This plan is ordered by dependency — each phase requires
the previous to be complete. Phases 0–3 have no LÖVE dependency and are fully testable.

---

## Phase 0 — Foundation

Goal: runnable skeleton, all infrastructure in place, tests passing.

### 0.1 Project skeleton
- [ ] `conf.lua` — window 1280×720, title, disable unused modules (physics, joystick)
- [ ] `main.lua` — thin dispatcher: `love.load/update/draw/keypressed/mousepressed` → state machine
- [ ] `src/state_machine.lua` — `switch(state)`, `update(dt)`, `draw()`, `keypressed(key)`, `mousepressed(x,y,b)`
- [ ] `src/locale.lua` — `locale.set(lang)`, `locale.t(key, vars)`, interpolation with `{var}` syntax, missing-key fallback (return key + warning)
- [ ] `locales/en.lua` — skeleton with section comments, ~10 placeholder keys
- [ ] `locales/pt.lua` — same keys in PT-BR

### 0.2 Minitest runner
- [ ] `tests/runner.lua` — discovers `tests/*_test.lua` via hardcoded list, `pcall`-based, prints PASS/FAIL, exits 1 on failure
- [ ] Helper functions: `assert_eq(a, b, msg)`, `assert_near(a, b, tolerance, msg)`, `assert_true(v, msg)`, `assert_nil(v, msg)`
- [ ] `tests/locale_test.lua` — key lookup, missing key, interpolation, language switch

### 0.3 Virtual canvas
- [ ] `src/ui.lua` — `ui.init()` creates 640×360 canvas; `ui.begin_frame()` / `ui.end_frame(scale)` wraps draw calls; `ui.scale` constant = 2

Acceptance: `love .` opens 1280×720 black window; `lua tests/runner.lua` reports all passing.

---

## Phase 1 — Data Layer

Goal: all game data loadable and queryable. No rendering.

### 1.1 Cities
- [ ] `data/cities.csv` — 30 cities: `id;name_en;name_pt;country_en;country_pt;lat;lon;population`
  - Populate all 30 from original game (see SPEC.md §8)
  - Verify lat/lon values against current sources
- [ ] `src/city.lua`
  - `city.load(path)` — parse CSV, return indexed table `{[id] = City}`
  - `city.haversine(lat1, lon1, lat2, lon2)` → km (pure Lua)
  - `city.distance(city_a, city_b)` → km
  - `city.travel_hours(city_a, city_b)` → hours at 800 km/h
  - `city.connections(city_id, route_graph)` → `string[]`
- [ ] `data/routes.lua` — 8 connection graphs as Lua tables (from iolo disassembly J-routes.json)
- [ ] `tests/city_test.lua`
  - Haversine: Nashville→LA = 2887 km ± 30 km
  - travel_hours: Buenos Aires→Rio de Janeiro ~3h at 800 km/h
  - All 30 cities load without error
  - Each city has ≥ 2 connections in every graph

### 1.2 Suspects
- [ ] `data/suspects.lua` — 10 suspects as Lua table (renamed from originals)
  - Fields: `id, name, sex, hair, hobby, vehicle, feature, food`
  - Trait distribution preserves deduction logic (verify unique trait-set combos)
- [ ] `src/suspect.lua`
  - `suspect.load()` → `Suspect[]`
  - `suspect.filter(suspects, traits)` → `Suspect[]` — returns all matching
  - `suspect.random(suspects, rng)` → single Suspect
- [ ] `tests/suspect_test.lua`
  - `filter` with 0 traits → all 10 returned
  - `filter` with unique combo → exactly 1 returned
  - `filter` contradictory → 0 returned
  - All 10 suspects have distinct `(sex, hair, hobby, vehicle, feature)` combinations

### 1.3 Clues
- [ ] `data/clues/<city_id>.lua` — per-city clue pools (3–6 clues each)
  - Each clue: `{type, category, value, text_key, image, verified}`
  - Start with 5 cities fully authored; rest marked `-- TODO`
  - Geographic facts must be current (post-2020 verified)
- [ ] Add clue text keys to `locales/en.lua` and `locales/pt.lua`
- [ ] `src/mission.lua` (partial — clue selection only)
  - `mission.clues_for_city(city_id, count)` → `Clue[]` random selection

Acceptance: `lua tests/runner.lua` all pass; `city.haversine` error < 1%.

---

## Phase 2 — Game Logic

Goal: complete game loop as pure Lua, no rendering. All testable.

### 2.1 Mission generation
- [ ] `src/mission.lua` (complete)
  - `mission.new(suspects, cities, route_graphs, rank, rng)` → Mission
    - Random suspect selection
    - Random starting city
    - Route: N cities chained via route graph connections (N per rank — see SPEC §2.7)
    - Assign 3 clues per city: 2 destination + 1 trait (shuffled)
    - Terminal city: all 3 clues signal "thief is here"
  - `mission.clue_at(mission, city_id, venue_index)` → Clue
  - `mission.is_terminal(mission, city_id)` → boolean
- [ ] `tests/mission_test.lua`
  - Fixed seed → deterministic mission
  - Route length matches rank requirement
  - All route cities are connected in the chosen graph
  - Terminal city clues differ from mid-route clues

### 2.2 Detective state
- [ ] `src/detective.lua`
  - `detective.new(name)` → Detective
  - `detective.travel(det, city, hours)` → ok | "time_expired"
  - `detective.investigate(det, mission, city_id, venue_index)` → Clue
  - `detective.add_trait(det, attr, value)`
  - `detective.issue_warrant(det, suspects, traits)` → "issued" | "multiple" | "none"
  - `detective.attempt_arrest(det, mission)` → "success" | "wrong_warrant" | "no_warrant" | "wrong_city"
  - `detective.advance_rank(det)` — called on success
  - `detective.score(det)` → number
- [ ] `tests/detective_test.lua`
  - Rank advances at correct case thresholds
  - Time expiry triggers correctly
  - Warrant issue/deny logic (see SPEC §2.4)
  - Arrest outcomes cover all 4 cases

### 2.3 Save / Load
- [ ] `lib/json.lua` — rxi/json.lua (copy single file, no modification)
- [ ] `src/save.lua`
  - `save.write(slot, detective)` — serialize to JSON via love.filesystem
  - `save.read(slot)` → detective table | nil
  - `save.exists(slot)` → boolean
  - `save.delete(slot)`
  - Slot paths: `"carmensandiego/save_1.json"` etc.
- [ ] `tests/save_test.lua` (mock love.filesystem with io.tmpfile)
  - Round-trip: write then read returns identical data
  - Missing slot returns nil without error
  - Corrupt JSON returns nil without crash

### 2.4 Ranking
- [ ] `src/ranking.lua`
  - `ranking.load(save_slot)` → Entry[]
  - `ranking.add(ranking, entry)` — insert sorted, keep top 10
  - `ranking.save(ranking, save_slot)`
  - Entry: `{name, rank, cases_solved, score, date}`
- [ ] `tests/ranking_test.lua` (can reuse save mock)
  - Top 10 cap enforced
  - Sort order: descending by score
  - Ties broken by cases_solved

Acceptance: `lua tests/runner.lua` all pass; full game loop simulatable by calling detective/mission functions in sequence.

---

## Phase 3 — Screens & UI

Goal: all screens implemented, game playable end-to-end.

### 3.1 Shared UI primitives
- [ ] `src/ui.lua` (complete)
  - `ui.panel(x, y, w, h)` — draws 9-slice panel from Kenney Pixel UI Pack
  - `ui.button(x, y, label, selected)` → draws button; returns true if clicked this frame
  - `ui.text(x, y, str, color)` — Press Start 2P font
  - `ui.title(x, y, str)` — larger variant
  - `ui.fade(alpha)` — full-screen black overlay at given alpha
  - `ui.load_assets()` — loads fonts, sprites; called once in love.load

### 3.2 Title + Language + Menu screens
- [ ] `src/screens/title.lua` — game logo, press-any-key prompt, retro scanline effect
- [ ] `src/screens/language.lua` — EN / PT-BR selection; stores to save slot 0
- [ ] `src/screens/menu.lua` — New Game / Continue / Leaderboard / Quit; Continue grayed if no save

### 3.3 Name entry + Briefing
- [ ] `src/screens/name_entry.lua` — text input (love.textinput), max 20 chars, confirm with Enter
- [ ] `src/screens/briefing.lua` — teleprinter effect (reveal text char by char), mission summary

### 3.4 City screen (main game screen)
- [ ] `src/screens/city.lua`
  - Shows city exterior layout (left: Interpol | 3 venues | right: Airport)
  - Status bar: city name, days remaining, rank
  - Keyboard/mouse navigation between action zones
  - Dispatches to venue, crime computer, travel, or arrest screens

### 3.5 Venue screen
- [ ] `src/screens/venue.lua`
  - Witness dialogue with typewriter effect
  - Clue reveal: text + optional image (side by side)
  - Image clue: no country label, no flag images
  - "Back" returns to city screen

### 3.6 Crime Computer screen
- [ ] `src/screens/crime_computer.lua`
  - 6 attribute dropdowns (sex, hair, hobby, vehicle, feature, food)
  - Each cycles through known values + blank (unset)
  - "Search" button → shows matching suspects
  - "Issue Warrant" button → only if exactly 1 match
  - Suspect dossier view: traits listed, no photo (avoid IP)

### 3.7 Travel screen
- [ ] `src/screens/travel.lua`
  - Lists connected cities with Haversine distance and travel time
  - World map inset showing current city + destinations as dots
  - Confirm → triggers travel animation → city screen for destination

### 3.8 Map rendering
- [ ] `src/map.lua`
  - `map.load()` — loads world map base image
  - `map.draw(cities, current_city, connections)` — renders map with markers
  - City markers: dot at geographic position (normalized lat/lon → screen coords)
  - `map.lat_lon_to_screen(lat, lon, map_w, map_h)` — equirectangular projection

### 3.9 Arrest + Outcome screens
- [ ] `src/screens/arrest.lua` — confrontation text, result (success/failure), animation
- [ ] `src/screens/rank_up.lua` — rank promotion announcement
- [ ] `src/screens/game_over.lua` — time expired or wrong arrest message
- [ ] `src/screens/leaderboard.lua` — top 10 table display

Acceptance: full game loop playable from title to arrest with keyboard.

---

## Phase 4 — Audio

Goal: music and SFX integrated.

- [ ] Download and convert assets (MP3→OGG where needed: `ffmpeg -i in.mp3 out.ogg`)
- [ ] Place in `assets/sounds/music/` and `assets/sounds/sfx/`
- [ ] Add to `assets/CREDITS.md`
- [ ] `src/audio.lua`
  - `audio.load()` — loads all sources
  - `audio.play_music(track)` — fades out current, fades in new (0.5s crossfade)
  - `audio.stop_music()`
  - `audio.play_sfx(name)`
- [ ] Wire music to screen transitions (see SPEC §5.1)
- [ ] Wire SFX to button clicks, clue reveals, warrant issue, arrest

---

## Phase 5 — Content

Goal: all 30 cities have complete, verified clue pools.

- [ ] Author clue pools for remaining 25 cities
- [ ] Verify all geographic facts against current sources (Wikipedia / CIA Factbook)
- [ ] Remove all `-- TODO: verify` markers
- [ ] Download CC0 clue images for each city (coins, animals, landmarks)
  - Source: Wikimedia Commons CC0/CC-BY
  - Resize to max 128×128 px for pixel art feel; nearest-neighbor downscale
  - No flags as images
- [ ] Add all image credits to `assets/CREDITS.md`
- [ ] Localize all clue text keys for both EN and PT-BR

---

## Phase 6 — Polish

- [x] Screen transitions: fade-in/out between all state switches (centralized in `src/state_machine.lua`)
- [x] Typewriter effect speed configurable (fast/slow in settings)
- [x] Settings screen: language, music volume, SFX volume
- [ ] City exterior pixel art backgrounds (1 unique image per city — or 5 regional variants)
- [ ] Animated airplane on travel screen
- [ ] Hall of Fame screen (after catching final target)
- [ ] Confirm working on Linux, macOS, Windows (LÖVE is cross-platform)
- [ ] Package as `.love` file: `zip -9 -r game.love . -x "*.git*" "tests/*" "SPEC.md" "PLAN.md"`

### City screen redesign — named venues + travel animation

Requested 2026-09-28, not yet implemented. Current `src/screens/city.lua` shows
5 generic equal-width zones ("CRIME COMPUTER", "VENUE 1/2/3", "AIRPORT") in a
single row with a sliding selection cursor (see `ui.new_smooth`).

- [ ] Give each venue a real, per-city name instead of "VENUE N" — venues must
      differ from city to city (e.g. not the same 3 names everywhere). The
      per-city clue data in `data/clues/<id>.lua` already tags each clue with
      a `category` (`landmark`, `currency`, `language`, `geography`,
      `wildlife`, `culture`, ...) — a natural source to derive a venue
      name/type from (e.g. `currency` → "Bank"/"Market", `landmark` →
      "Museum"/"Overlook", `wildlife` → "Nature Reserve"). Needs a
      category→venue-name mapping (localized, EN+PT) or dedicated per-city
      venue name data — decide which when implementing.
- [ ] Layout: venues move to a top row, each showing its name (text, already
      required by i18n rules) **and** a representative image. The other
      actions (crime computer, airport) move to a row below the venues.
- [ ] When the player selects a venue, don't cut straight to the venue
      screen — play a short "traveling to location" transition first while
      the in-game clock visibly advances (see `detective.investigate`'s
      `INVESTIGATION_HOURS` in `src/detective.lua`, currently applied
      instantly with no visual feedback), mirroring the original 1985 game's
      travel-time feel. Likely its own screen/overlay between `city` and
      `venue`, analogous to how `city_info.lua` sits between `travel`/
      `briefing` and `city` today.

---

## Technical Decisions

| Decision | Choice | Reason |
|---|---|---|
| State machine | Custom (no lib) | Simple, zero deps, fits the project scope |
| JSON | rxi/json.lua | Single file, no LuaRocks, proven in production |
| Camera | None (map is static) | World map is not panned; no camera lib needed |
| Animation | Manual quads | Simple frame-based, no overdependence on libs |
| Virtual resolution | Manual canvas | push lib is overkill for a fixed 2× scale |
| CSV parsing | Pure Lua | Semicolon-delimited, no quoted fields in cities.csv |
| Route graphs | Lua tables | Loaded once, no runtime modification |
| Clue data | Per-city Lua files | Easier to author and review than CSV |

---

## Libraries (copy into `lib/`, no LuaRocks)

| Lib | File | Why |
|---|---|---|
| rxi/json.lua | `lib/json.lua` | Save file serialization |

No other external libraries. Keep deps minimal.

---

## References

- iolo disassembly (original game data): https://github.com/iolo/apple2-carmen-sandiego-world-disasm
- thiefcatcher (C++ clone, best complete reference): https://github.com/Ponup/thiefcatcher
- JulienVerkest (React, bilingual, JSON case structure): https://github.com/JulienVerkest/carmen-sandiego
- Haversine formula reference: https://www.movable-type.co.uk/scripts/latlong.html
- LÖVE2D wiki: https://love2d.org/wiki
- Kenney assets: https://kenney.nl/assets
- OpenGameArt CC0 music: https://opengameart.org/content/15-melodic-rpg-chiptunes
- Press Start 2P font: https://fonts.google.com/specimen/Press+Start+2P
