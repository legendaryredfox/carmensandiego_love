# Implementation Plan

See SPEC.md for full design. This plan is ordered by dependency — each phase requires
the previous to be complete. Phases 0–3 have no LÖVE dependency and are fully testable.

---

## Phase 0 — Foundation

Goal: runnable skeleton, all infrastructure in place, tests passing.

### 0.1 Project skeleton
- [x] `conf.lua` — window 1280×720, title, disable unused modules (physics, joystick)
- [x] `main.lua` — thin dispatcher: `love.load/update/draw/keypressed/mousepressed` → state machine
- [x] `src/state_machine.lua` — `switch(state)`, `update(dt)`, `draw()`, `keypressed(key)`, `mousepressed(x,y,b)`
- [x] `src/locale.lua` — `locale.set(lang)`, `locale.t(key, vars)`, interpolation with `{var}` syntax, missing-key fallback (return key + warning)
- [x] `locales/en.lua` — skeleton with section comments, ~10 placeholder keys
- [x] `locales/pt.lua` — same keys in PT-BR

### 0.2 Minitest runner
- [x] `tests/runner.lua` — discovers `tests/*_test.lua` via hardcoded list, `pcall`-based, prints PASS/FAIL, exits 1 on failure
- [x] Helper functions: `assert_eq(a, b, msg)`, `assert_near(a, b, tolerance, msg)`, `assert_true(v, msg)`, `assert_nil(v, msg)`
- [x] `tests/locale_test.lua` — key lookup, missing key, interpolation, language switch

### 0.3 Virtual canvas
- [x] `src/ui.lua` — `ui.init()` creates 640×360 canvas; `ui.begin_frame()` / `ui.end_frame(scale)` wraps draw calls; `ui.scale` constant = 2

Acceptance: `love .` opens 1280×720 black window; `lua tests/runner.lua` reports all passing.

---

## Phase 1 — Data Layer

Goal: all game data loadable and queryable. No rendering.

### 1.1 Cities
- [x] `data/cities.csv` — 30 cities: `id;name_en;name_pt;country_en;country_pt;lat;lon;population`
  - Populate all 30 from original game (see SPEC.md §8)
  - Verify lat/lon values against current sources
- [x] `src/city.lua`
  - `city.load(path)` — parse CSV, return indexed table `{[id] = City}`
  - `city.haversine(lat1, lon1, lat2, lon2)` → km (pure Lua)
  - `city.distance(city_a, city_b)` → km
  - `city.travel_hours(city_a, city_b)` → hours at 800 km/h
  - `city.connections(city_id, route_graph)` → `string[]`
- [x] `data/routes.lua` — 8 connection graphs as Lua tables (from iolo disassembly J-routes.json)
- [x] `tests/city_test.lua`
  - Haversine: Nashville→LA = 2887 km ± 30 km
  - travel_hours: Buenos Aires→Rio de Janeiro ~3h at 800 km/h
  - All 30 cities load without error
  - Each city has ≥ 2 connections in every graph

### 1.2 Suspects
- [x] `data/suspects.lua` — 10 suspects as Lua table (renamed from originals)
  - Fields: `id, name, sex, hair, hobby, vehicle, feature, food`
  - Trait distribution preserves deduction logic (verify unique trait-set combos)
- [x] `src/suspect.lua`
  - `suspect.load()` → `Suspect[]`
  - `suspect.filter(suspects, traits)` → `Suspect[]` — returns all matching
  - `suspect.random(suspects, rng)` → single Suspect
- [x] `tests/suspect_test.lua`
  - `filter` with 0 traits → all 10 returned
  - `filter` with unique combo → exactly 1 returned
  - `filter` contradictory → 0 returned
  - All 10 suspects have distinct `(sex, hair, hobby, vehicle, feature)` combinations

### 1.3 Clues
- [x] `data/clues/<city_id>.lua` — per-city clue pools (3–6 clues each)
  - Each clue: `{type, category, value, text_key, image, verified}`
  - Start with 5 cities fully authored; rest marked `-- TODO`
  - Geographic facts must be current (post-2020 verified)
- [x] Add clue text keys to `locales/en.lua` and `locales/pt.lua`
- [x] `src/mission.lua` (partial — clue selection only)
  - `mission.clues_for_city(city_id, count)` → `Clue[]` random selection

Acceptance: `lua tests/runner.lua` all pass; `city.haversine` error < 1%.

---

## Phase 2 — Game Logic

Goal: complete game loop as pure Lua, no rendering. All testable.

### 2.1 Mission generation
- [x] `src/mission.lua` (complete)
  - `mission.new(suspects, cities, route_graphs, rank, rng)` → Mission
    - Random suspect selection
    - Random starting city
    - Route: N cities chained via route graph connections (N per rank — see SPEC §2.7)
    - Assign 3 clues per city: 2 destination + 1 trait (shuffled)
    - Terminal city: all 3 clues signal "thief is here"
  - `mission.clue_at(mission, city_id, venue_index)` → Clue
  - `mission.is_terminal(mission, city_id)` → boolean
- [x] `tests/mission_test.lua`
  - Fixed seed → deterministic mission
  - Route length matches rank requirement
  - All route cities are connected in the chosen graph
  - Terminal city clues differ from mid-route clues

### 2.2 Detective state
- [x] `src/detective.lua`
  - `detective.new(name)` → Detective
  - `detective.travel(det, city, hours)` → ok | "time_expired"
  - `detective.investigate(det, mission, city_id, venue_index)` → Clue
  - `detective.add_trait(det, attr, value)`
  - `detective.issue_warrant(det, suspects, traits)` → "issued" | "multiple" | "none"
  - `detective.attempt_arrest(det, mission)` → "success" | "wrong_warrant" | "no_warrant" | "wrong_city"
  - `detective.advance_rank(det)` — called on success
  - `detective.score(det)` → number
- [x] `tests/detective_test.lua`
  - Rank advances at correct case thresholds
  - Time expiry triggers correctly
  - Warrant issue/deny logic (see SPEC §2.4)
  - Arrest outcomes cover all 4 cases

### 2.3 Save / Load
- [x] `lib/json.lua` — rxi/json.lua (copy single file, no modification)
- [x] `src/save.lua`
  - `save.write(slot, detective)` — serialize to JSON via love.filesystem
  - `save.read(slot)` → detective table | nil
  - `save.exists(slot)` → boolean
  - `save.delete(slot)`
  - Slot paths: `"carmensandiego/save_1.json"` etc.
- [x] `tests/save_test.lua` (mock love.filesystem with io.tmpfile)
  - Round-trip: write then read returns identical data
  - Missing slot returns nil without error
  - Corrupt JSON returns nil without crash

### 2.4 Ranking
- [x] `src/ranking.lua`
  - `ranking.load(save_slot)` → Entry[]
  - `ranking.add(ranking, entry)` — insert sorted, keep top 10
  - `ranking.save(ranking, save_slot)`
  - Entry: `{name, rank, cases_solved, score, date}`
- [x] `tests/ranking_test.lua` (can reuse save mock)
  - Top 10 cap enforced
  - Sort order: descending by score
  - Ties broken by cases_solved

Acceptance: `lua tests/runner.lua` all pass; full game loop simulatable by calling detective/mission functions in sequence.

---

## Phase 3 — Screens & UI

Goal: all screens implemented, game playable end-to-end.

### 3.1 Shared UI primitives
- [x] `src/ui.lua` (complete)
  - `ui.panel(x, y, w, h)` — draws 9-slice panel from Kenney Pixel UI Pack
  - `ui.button(x, y, label, selected)` → draws button; returns true if clicked this frame
  - `ui.text(x, y, str, color)` — Press Start 2P font
  - `ui.title(x, y, str)` — larger variant
  - `ui.fade(alpha)` — full-screen black overlay at given alpha
  - `ui.load_assets()` — loads fonts, sprites; called once in love.load

### 3.2 Title + Language + Menu screens
- [x] `src/screens/title.lua` — game logo, press-any-key prompt, retro scanline effect
- [x] `src/screens/language.lua` — EN / PT-BR selection; stores to save slot 0
- [x] `src/screens/menu.lua` — New Game / Continue / Leaderboard / Quit; Continue grayed if no save

### 3.3 Name entry + Briefing
- [x] `src/screens/name_entry.lua` — text input (love.textinput), max 20 chars, confirm with Enter
- [x] `src/screens/briefing.lua` — teleprinter effect (reveal text char by char), mission summary

### 3.4 City screen (main game screen)
- [x] `src/screens/city.lua`
  - Shows city exterior layout (left: Interpol | 3 venues | right: Airport)
  - Status bar: city name, days remaining, rank
  - Keyboard/mouse navigation between action zones
  - Dispatches to venue, crime computer, travel, or arrest screens

### 3.5 Venue screen
- [x] `src/screens/venue.lua`
  - Witness dialogue with typewriter effect
  - Clue reveal: text + optional image (side by side)
  - Image clue: no country label, no flag images
  - "Back" returns to city screen

### 3.6 Crime Computer screen
- [x] `src/screens/crime_computer.lua`
  - 6 attribute dropdowns (sex, hair, hobby, vehicle, feature, food)
  - Each cycles through known values + blank (unset)
  - "Search" button → shows matching suspects
  - "Issue Warrant" button → only if exactly 1 match
  - Suspect dossier view: traits listed, no photo (avoid IP)

### 3.7 Travel screen
- [x] `src/screens/travel.lua`
  - Lists connected cities with Haversine distance and travel time
  - World map inset showing current city + destinations as dots
  - Confirm → triggers travel animation → city screen for destination

### 3.8 Map rendering
- [x] `src/map.lua`
  - `map.load()` — loads world map base image
  - `map.draw(cities, current_city, connections)` — renders map with markers
  - City markers: dot at geographic position (normalized lat/lon → screen coords)
  - `map.lat_lon_to_screen(lat, lon, map_w, map_h)` — equirectangular projection

### 3.9 Arrest + Outcome screens
- [x] `src/screens/arrest.lua` — confrontation text, result (success/failure), animation
- [x] `src/screens/rank_up.lua` — rank promotion announcement
- [x] `src/screens/game_over.lua` — time expired or wrong arrest message
- [x] `src/screens/leaderboard.lua` — top 10 table display

Acceptance: full game loop playable from title to arrest with keyboard.

---

## Phase 4 — Audio

Goal: music and SFX integrated.

- [x] Download and convert assets — all present under `assets/sounds/`
- [x] Place in `assets/sounds/music/` and `assets/sounds/sfx/`
- [x] Add to `assets/CREDITS.md`
- [x] `src/audio.lua` — sources are loaded lazily on first use (`get_music`/
      `get_sfx`) rather than eagerly via a single `load()`, but the public
      surface matches: `play_music`, `crossfade`, `stop_music`, `play_sfx`,
      `update` (for fade tweening)
- [x] Wire music to screen transitions — every screen calls
      `audio.crossfade(key)` in `S.enter()`
- [x] Wire SFX to button clicks, clue reveals, warrant issue, arrest

---

## Phase 5 — Content

Goal: all 30 cities have complete, verified clue pools.

- [x] Author clue pools for all 30 cities (`data/clues/<id>.lua`, 4 clues each)
- [x] Verify all geographic facts against current sources — every clue has
      `verified = true`, no `-- TODO: verify` markers remain
- [ ] Download CC0 clue images for each city (coins, animals, landmarks) —
      partially done. All 23 clue entries that already had an `image` path
      set in `data/clues/*.lua` now have a real, license-checked file under
      `assets/images/clues/`. The other 97 clues (most cities) still have
      `image = nil` and render the "?" placeholder — no image path was ever
      assigned for them, so there's nothing to source yet until those
      fields get authored.
  - Source: Wikimedia Commons, filtered to CC0/CC-BY only (CC-BY-SA
    rejected per CLAUDE.md's license list — it's the majority license for
    well-known landmark/wildlife photos on Commons, so several cities
    needed 2-3 search rounds to find a compliant, recognizable shot)
  - Resized to 128×128, nearest-neighbor downscale
  - No flags as images
  - Caught two bad auto-picks on manual review: a 9/11-era Statue of
    Liberty photo with WTC smoke in frame (swapped for a NPS close-up),
    and a Cristo Redentor image where the statue itself wasn't visible in
    frame at 128×128 (swapped for one where it is)
- [x] Add all image credits to `assets/CREDITS.md` — the 23 images above
      are listed; the section will grow as more clues get an `image` path
- [x] Localize all clue text keys for both EN and PT-BR (clue text is
      inline `{en=..., pt=...}` per entry, not locale-key based, but both
      languages are present for all 30 cities)

---

## Phase 6 — Polish

- [x] Screen transitions: fade-in/out between all state switches (centralized in `src/state_machine.lua`)
- [x] Typewriter effect speed configurable (fast/slow in settings)
- [x] Settings screen: language, music volume, SFX volume
- [ ] City exterior pixel art backgrounds (1 unique image per city — or 5 regional variants)
- [x] Animated airplane on travel screen (`src/screens/flying.lua` — a
      transition between `travel` and `city_info`/`arrest` that flies a
      triangle marker along the map between origin and destination while
      the clock ticks forward, mirroring `investigating.lua`'s pattern)
- [x] Hall of Fame screen (after catching final target) — `data/leader.lua`
      (the organization leader, excluded from the regular 10-suspect draw),
      `src/mission.lua`'s `M.new(..., leader)` param forces her as thief and
      sets `mission.is_final`, `src/game.lua`'s `leader_for()` passes her in
      once `cases_solved >= M.FINAL_CASE_CASES_SOLVED` (29 — matches the
      original's separate rank+cases gate, see SPEC.md §2.7). Catching her
      sets `detective.career_complete`, routes to `src/screens/hall_of_fame.lua`
      instead of the next mission, and disables Continue on the main menu.
      Also fixed `rank_up.lua`, which existed but was never wired in —
      `arrest.lua` now detects a rank change and shows it before briefing.
- [ ] Confirm working on Linux, macOS, Windows (LÖVE is cross-platform)
- [x] Package as `.love` file: `./package.sh [output-path]` (defaults to
      `game.love`). Also excludes `references/*` (76MB of local-only clone
      repos, already gitignored but not excluded by the plan's original zip
      line — would have bloated the distributable), `CLAUDE.md`,
      `README.md`, and `assets/download_assets.sh` alongside the
      already-planned `tests/`, `SPEC.md`, `PLAN.md`, `.git*`. Verified the
      output boots cleanly under `love game.love`.

### City screen redesign — named venues + travel animation

Requested 2026-09-28, implemented 2026-09-28. `src/screens/city.lua` now
shows a top row of 3 venue cards and a bottom row with the crime computer
and airport actions, replacing the old 5-zone single-row strip.

- [x] Give each venue a real, per-city name instead of "VENUE N" — venues
      must differ from city to city. Implemented in `src/venue_name.lua`:
      derives the name from the venue's own clue `category` (falling back to
      `trait`/`terminal`/`generic`), with 2-3 localized variants per category
      picked deterministically per (city, venue) via a hash, so redraws don't
      flicker but different cities/missions don't all show identical labels.
      Locale keys added under `venue_name.<category>.<n>` in both
      `locales/en.lua` and `locales/pt.lua`.
- [x] Layout: venues moved to a top row, each showing its name and a
      representative image (falls back to a bordered placeholder box when
      the clue has no `image`, same pattern as `city_info.lua`'s photo
      fallback). Crime computer and airport moved to a row below.
- [x] Selecting a venue no longer cuts straight to the venue screen — a new
      `src/screens/investigating.lua` transition plays first, visually
      ticking the clock from the current time toward
      `detective.INVESTIGATION_HOURS` later before handing off to
      `src/screens/venue.lua`.

### Full-codebase review pass — 2026-09-28

Requested: a code review of the whole codebase (not just recent diffs),
followed by a QA/UX/UI pass. Found and fixed, most severe first:

- **Every trait clue in the game displayed as a raw locale key** instead of
  readable text (`mission.lua` generated `"clue.trait.*"`, the locale files
  only define `"trait.*"`) — deterministic, both languages, always.
- **An undeducible thief was possible on literally the first case of any
  playthrough.** Trait clues cycled sex→hair→hobby→... blindly by route
  position; Rookie's 3-clue-city route only ever revealed sex/hair/hobby,
  and two suspects (`marina_delacroix`, `kat_sterling`) share exactly
  those three. `mission.lua` now computes the actual minimal
  distinguishing attribute set per thief and reveals those first — a test
  simulates every thief at every rank and confirms the crime computer's
  filter always narrows to exactly one match.
- **A correctly-identified warrant could report "no match" forever** — the
  crime computer's blank dropdown state was stored as a literal `""`
  instead of clearing the key, which `suspect.filter` compared literally.
- **A successful arrest saved before the mission advanced**, so an abnormal
  exit before pressing Enter, followed by Continue, replayed the
  auto-arrest and double-counted the case.
- `investigate()` had no time-limit guard (`travel()` does) — a player past
  the deadline could re-enter venues for free clues indefinitely.
- `clue_pool.load` treated a real syntax/runtime error in a
  `data/clues/*.lua` file identically to "file doesn't exist," silently
  masking content bugs.
- **Save files didn't persist the in-progress mission at all** — Continue
  restored only the detective + ranking, leaving `game.mission` nil and
  crashing the next screen. Now round-trips through JSON as-is (it's
  already plain data) and Continue drops the player back into the city
  screen instead of replaying the briefing.
- The crime computer auto-filled a trait the instant a witness mentioned
  it — removed; the player now has to enter what the witness said
  themselves, same as any other deduction.
- Mission-generation matched the 1985 original more closely at the user's
  request: routes are built backward from a randomly-picked hideout (not
  forward from a random start), and the organization-leader "final case"
  now triggers on the original's exact two-part gate (top rank **and**
  29 cases solved — not just the rank-up threshold).
- UX, from live feedback: the world map was nearly invisible (near-black
  background, 2px dots) — brighter/bigger markers, and the destination
  currently selected on the travel screen now draws its route in a
  distinct highlighted color instead of every candidate route looking
  identical. Replaced "time left in X days" with the actual current
  day/time (with a "Day N" prefix — plain weekday+time made "now" and a
  same-weekday deadline read identically). Fixed a status-bar text overlap
  that surfaced once those strings got longer. Added a witness-portrait
  slot to the venue screen (generic pixel art, no art sourced yet —
  same bordered-"?" fallback as the other planned image slots).
- Dedup/efficiency cleanup: `game.should_auto_arrest()` / `game.can_continue()`
  replace duplicated logic that lived independently in two screens each;
  `venue_name.name_for` memoized (was re-hashing + re-resolving locale
  keys every single draw() frame); `ITEM_BY_CITY` moved into
  `data/items.lua` alongside the project's other content data.
- Also routed the last remaining hardcoded strings (`language.lua`'s
  entire screen, `"DETECTIVE AGENCY"`, several nav hints) through
  `locale.t`, per CLAUDE.md's i18n rule.

Deliberately not done (real findings, judged not worth the blast radius
for zero behavior change): renaming every screen's `local S = {}` to the
literal `M` CLAUDE.md's style rule specifies, and replacing the
`require("src.screens.X")`-inside-handler navigation idiom with a central
string-keyed registry — the latter is also the standard idiomatic Lua fix
for the circular dependencies a screen-graph state machine like this one
inherently has. Clue images and per-city exterior art remain outstanding
(need sourced assets, not code).

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
