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

### Known issues — next up (flagged 2026-09-28)

- **FIXED (2026-09-28)** — Volume control coarse + lowest step too loud.
  `VOLUME_STEP` cut to 0.05 (20 steps) in `src/screens/settings.lua`.
  `src/audio.lua` now squares the stored 0-1 setting (`to_gain`) before
  every `Source:setVolume()` call — music load, sfx load, sfx clone,
  crossfade fade-in target — so the perceptual curve matches linear
  loudness instead of linear gain. Stored setting stays linear 0-1
  (unchanged in `src/settings.lua`, still what the % display reads).
- **FIXED (2026-09-28)** — Venue card images were real photos (the clue's
  own Wikimedia photo shown on the city-screen card, spoiling the clue
  before investigation) instead of pixel-art-style icons. Rather than
  commissioning per-clue art, reframed the problem: the card only needs
  to represent the venue's *category* (10 fixed categories — landmark,
  currency, language, geography, wildlife, culture, industry, trait,
  terminal, generic — see `src/venue_name.lua`'s `category_for`), not the
  specific clue subject, so 10 reusable icons cover all cities instead of
  ~120 per-clue images. Sourced 10 flat single-color silhouette icons from
  game-icons.net (CC BY 3.0), stripped their black preview background,
  rasterized to 64x64 white-on-transparent PNGs
  (`assets/images/venues/<category>.png`), tinted at draw time via
  `ui.C.border` — same tintable-greyscale pattern as the existing panel
  sprites. `src/screens/city.lua`'s `draw_venue_card` now looks up the
  category icon instead of `clue.image`. See `assets/CREDITS.md`'s "Venue
  Category Icons" table for per-icon attribution. `clue.image` itself is
  now unused in-game (kept for a possible future rank-gated image reveal
  per SPEC.md); the 23 sourced clue photos and ~97 unsourced ones are no
  longer blocking — this issue is closed regardless of that backlog.

### Playtest feedback — next up (flagged 2026-09-28, first case solved)

Documentation only — nothing in this section has been implemented yet.
Facts below cite `references/apple2-carmen-sandiego-world-disasm/docs/reconstruction.md`
(the disassembly/reconstruction of the actual 1985 game) and its decoded
JSON assets, same as SPEC.md already does for the 29-case leader rule.

1. **FIXED (2026-09-28)** — First case was solved too fast. Root cause
   was item 4 below, not route length (`src/mission.lua`'s Rookie
   `route_length = 4` already matched the original's rank+3 formula).
   Fixed by implementing item 4's visit-gated arrest — see that entry.
   Route length itself is untouched and still available as a secondary
   knob if cases still feel short after playtesting this.

2. **FIXED (2026-09-28)** — Briefing was too concise and never stated the
   suspect's sex up front, unlike the original's opening "news flash"
   with gender-dependent pronoun substitution (`reconstruction.md:503-505,
   544-549`). `src/screens/briefing.lua`'s `build_text` now picks
   `"briefing.suspect_seen_" .. m.thief.sex` instead of one generic
   `briefing.suspect_seen` key, so the second line reads "He was seen
   fleeing the scene, and Interpol believes he's already crossed the
   border." / "She was..." (and PT equivalents with matching gender
   agreement) — stated immediately, not held back for the crime
   computer's SEX row. Also prefixed `briefing.stolen` with "NEWS FLASH:"
   ("ÚLTIMA HORA:" in PT) to read closer to the original's framing, and
   added a touch more flavor to the suspect-seen line so the whole
   briefing isn't four bare sentences. Note: PT's old comment explaining
   why it deliberately used gender-neutral "pessoa suspeita" (to avoid
   hinting at sex) is now the opposite of what's wanted — replaced with a
   comment noting the original states sex from the opening announcement
   onward. Test: `tests/locale_test.lua`'s interpolation fixture updated
   for the new `briefing.stolen` text.

3. **FIXED (2026-09-28)** — Suspect names changed again. Old roster
   (Scarlet Vega, Marina Delacroix, Blaze Fontaine, Lady Constance, Kat
   Sterling, Red Malone, Victor Crain, Jack Moreau, Eddie Flash, Igor
   Volkov) replaced with: Ruby Steele, Vivian Cross, Coral Vance, Dame
   Odessa, Nadia Quill, Crimson Boyle, Duke Ashford, Wolf Delgado, Zippy
   Larkin, Boris Kessler (`data/suspects.lua`'s `name` field only — the
   `id` field each suspect is keyed/matched/saved by, e.g.
   `"scarlet_vega"`, is untouched, so this didn't need to touch
   `warrant_id` matching, save compatibility, or any test that references
   suspects by id). `sex`/`hair`/`hobby`/`vehicle`/`feature`/`food` per
   suspect are unchanged, so the trait-distinctness invariant still holds
   as before. Updated the one test asserting a literal name
   (`tests/suspect_test.lua`'s `suspect.by_id` case).

4. **FIXED (2026-09-28)** — Arrest required only arriving in the hideout
   city with a warrant, not entering the suspect's actual venue.
   `reconstruction.md:510-514`: at the hideout city, one of the three
   investigation slots is secretly marked as the suspect's location; if
   the player's *first* investigation there lands on an unmarked slot,
   the mark *moves* to a different slot (the suspect evades) instead of
   the case simply failing; a later visit to whichever slot currently
   holds the mark triggers the arrest sequence. Implemented that shape:
   `mission.new` now picks `mission.hideout_venue` (1-3) at case
   generation; `mission.is_hideout_venue`/`mission.evade_hideout`
   (`src/mission.lua`) read/move the mark; `detective.investigate`
   (`src/detective.lua`) calls `evade_hideout` exactly once per case, on
   the detective's first-ever investigation at the terminal city (guarded
   by a new `det.hideout_visited` flag, persisted through
   serialize/deserialize); `game.venue_triggers_arrest(venue_index)`
   (`src/game.lua`, replacing the old arrival-only
   `game.should_auto_arrest`) checks terminal city + current mark;
   `src/screens/venue.lua` calls it right after `investigate()` and jumps
   to `arrest.lua` instead of showing witness text when it matches. The
   old arrival-based checks in `src/screens/city.lua` and
   `src/screens/flying.lua` are gone — arriving in the city now always
   just shows the city screen. Deadline handling is unchanged: a correct
   venue visited after time's up is already unreachable, since
   `detective.travel`'s `"time_expired"` sends the player to game_over
   before another investigation is possible. Tests:
   `tests/mission_test.lua`'s new `mission.evade_hideout` block.

5. **FIXED (2026-09-28)** — Cases didn't have a deliberate in-game start
   time at all: `detective.begin_mission` set `det.start_timestamp =
   os.time()` (real wall-clock moment) and `format_datetime` derived the
   displayed weekday via `os.date(ts).wday` on that real epoch — whatever
   real day/time the player happened to launch the game. (For contrast,
   the original randomizes both weekday 0-6 and starting hour 08:00-17:00
   per case, `reconstruction.md:99-102` — the ask here is deliberately
   simpler and NOT ported from source: always Monday 08:00.) Fixed by
   decoupling the in-game clock from the real one entirely:
   `start_timestamp`/`current_timestamp`/`deadline_timestamp` are now
   plain "seconds since Monday 00:00" counters (`M.CASE_START_TIMESTAMP =
   8 * 3600`, used by both `detective.new` and `detective.begin_mission`
   instead of `os.time()`), and `format_datetime` computes weekday/hour
   arithmetically from that count instead of calling `os.date` — so
   display can no longer drift with the host's timezone/DST or whatever
   real day it happens to be, and every case reliably opens "Day 1, Mon
   08:00". Deadlines (`RANK_CONFIG.time_days`) untouched. Tests:
   `tests/detective_test.lua`'s new "case clock always starts Monday
   08:00" and `detective.begin_mission` cases.

6. **Witness clue text should be direct speech, not reported speech —
   scope turned out bigger than the two wrapper strings.** Original
   estimate was just `locale.t("venue.witness_says")` = "A witness
   reports:" + "The informant mentioned {hint}." / "The suspect was
   described as {trait}." (`locales/en.lua:52-55`). Investigated further
   before touching it: `{hint}` isn't a short phrase — `clue_pool.clue_text`
   (`src/clue_pool.lua:58-69`) returns each clue's full `text.en`/`text.pt`
   sentence straight from `data/clues/<city_id>.lua`, and every one of
   those (108 clue entries across 30 cities, so 216 strings counting both
   languages) is already written in third-person reported form — e.g.
   Paris's landmark clue: "A metalworker described the suspect gazing up
   at an iron lattice tower...". So wrapping `{hint}` in quotes without
   rewriting the underlying sentences would just produce an odd
   double-reported quote, not real direct speech. Separately,
   `{trait}` (`venue.clue_trait`) pulls from the 18 `trait.*.*` locale
   values (`locales/en.lua:159-179`), which are inconsistent grammatical
   fragments — noun phrases ("Brown hair"), and verb phrases with mixed
   implicit subjects ("Plays tennis", "Drives a convertible", "Has a
   tattoo") — so even that template can't cleanly become a first-person
   quote without rewriting those 18 values too. Left untouched rather
   than ship awkward/broken-grammar text. Real next step is a proper
   content pass: rewrite the 18 trait values into a uniform quotable
   form, rewrite all 108 clue sentences (`data/clues/*.lua`, en+pt) into
   actual first-person witness quotes, then simplify the
   `venue.witness_says`/`venue.clue_destination`/`venue.clue_trait`
   wrapper templates to fit. Budget this as its own content pass, not a
   quick locale edit.

7. **FIXED (2026-09-28), then REDONE same day** — Detective-office
   background for the dispatch/briefing screen. First attempt composed
   `assets/images/ui/briefing_bg.png` from four CC-licensed pixel-art
   furniture sprites (Croomfolk's "Vintage Office Interiors", OGA-BY
   3.0) — tiled wood wainscot, desk, file cabinet, safe. User tried it
   and called it out as looking bad, and said a real photo was fine too
   (didn't need to stay pixel art for this one asset). Replaced it with
   an actual 1929 public-domain photo from Wikimedia Commons/Spaarnestad
   Photo (full credit in `assets/CREDITS.md`): the director's desk at a
   Dutch private-investigation bureau, cropped to the cluttered desk
   surface only (papers, books, inkwell) with both people's faces
   deliberately cropped out, composited onto a flat sepia fill sampled
   from the photo's own wallpaper tone. Same panel layout as before
   (shrunk to the upper ~200px so the photo band shows below it) — kept
   after confirming it still worked with the new image via the same
   `love .` + `xvfb-run` + `SDL_AUDIODRIVER=dummy` screenshot check.
   Lesson: rendering out a composited image and eyeballing it in
   isolation isn't the same as it actually being good — get the actual
   opinion (here, the user's) before considering an art task done.

8. **FIXED (2026-09-28)**, via option (b) below — World map city markers
   sometimes don't line up with real lat/lon. Verified with a script
   (Pillow, not committed) that projects every one of the 30 cities in
   `data/cities.csv` through `src/map.lua`'s exact `lat_lon_to_xy` formula
   and samples `assets/images/map/world_map.png` at that pixel, checking
   whether it landed on the image's green "land" color or blue "ocean"
   color. Result: the projection math itself is fine — no letterboxing/
   padding/wrong-projection issue (checked top/bottom/left/right edges
   too, all plain ocean as expected for full -180..180/-90..90 bleed),
   and 22 of 30 cities land exactly on land, 2 more (cairo, london) are
   within 2px (sub-pixel rounding at this image's ~4.9px/degree
   resolution, not a real bug). The other 8 are genuinely off, and by
   inconsistent, non-uniform offsets (no single dx/dy correction fixes
   more than one of them — ruling out a global bug):
   `rio_de_janeiro` (38px), `reykjavik` (32px), `moroni` (30px), `tokyo`
   (27px), `port_moresby` (17px), `kigali` (9px), `mexico_city` (7px),
   `sydney` (7px), `bangkok` (5px). The common thread is small islands
   (Reykjavik/Iceland, Moroni/Comoros, Port Moresby/New Guinea) and
   complex bay/delta coastlines (Tokyo Bay, Rio's Guanabara Bay, Sydney
   Harbour, Bangkok's river delta) — exactly where a compact 1774×887
   hand-drawn coastline is most likely to be simplified or drawn slightly
   off from real coordinates. So this is a content accuracy issue in the
   map art for those 8-9 specific cities, not a code bug — two ways to
   fix it: (a) touch up the coastline art near those specific pixel
   coordinates, needing an artist/tool pass; or (b) a per-city pixel-nudge
   override applied only where city markers are drawn. Went with (b) for
   now since it's a quick, low-risk code-only fix — `src/map.lua`'s new
   `MARKER_NUDGE_PX` table (the measured dx/dy above, as fractions of the
   source image's 1774x887) plus `M.city_xy(city, ...)`, a
   `lat_lon_to_xy` wrapper that applies the nudge when a city has one.
   Replaced every place a *city's* marker position gets computed (dots,
   connection lines, the flying screen's plane start/end in
   `src/screens/flying.lua`) with `city_xy` so the plane still visibly
   lands exactly on its destination's dot — `lat_lon_to_xy` itself stays
   untouched and is still what the continent-polygon fallback uses
   (coastline points aren't cities, don't need the nudge). This still
   doesn't fix the art itself — option (a) remains open for whoever wants
   the coastline to actually be accurate there, not just the dot. Tests:
   new `tests/map_test.lua` (`lat_lon_to_xy` corner cases, `city_xy`
   no-op vs. nudged vs. nudge scaling with rect size).

### Rank promotion thresholds — should match the original (flagged 2026-09-28)

**FIXED (2026-09-28)** — `reconstruction.md:59-61`: the original's
promotion thresholds are 1, 5, 12, and 20 cases solved (cumulative) to
advance through its first five ranks (Rookie → Sleuth → Private Eye →
Investigator → Ace Detective); the remaining table entries are `$FF`
(unused) because the sixth rank, Super Sleuth, isn't reached by a plain
solved-case count — see the existing 29-case organization-leader gate
already documented in SPEC.md (§ "Once the detective is Ace Detective
**and** has solved 29 cases total").

This project's thresholds were **0, 1, 3, 6, 10, 15** across six ranks
named Rookie, Junior Detective, Sleuth, Private Eye, Investigator, Ace
Detective — "Junior Detective" wasn't one of the original's six rank
names at all (original: Rookie, Sleuth, Private Eye, Investigator, Ace
Detective, Super Sleuth). Dropped it: `src/detective.lua`'s `RANKS` and
`src/mission.lua`'s `RANK_CONFIG` now both have exactly the original's
five ranks (Rookie, Sleuth, Private Eye, Investigator, Ace Detective) at
thresholds 0/1/5/12/20, matching source exactly — this project's
"Ace Detective" stays the top rank either way (matches SPEC.md's
leader-case design, which already folds the original's separate "Super
Sleuth" tier into "solve the leader case while at Ace Detective" rather
than adding a 7th rank). Bonus: dropping the extra rank also made
`mission.lua`'s per-rank `route_length` table (4/5/6/7/8) line up exactly
with the original's rank+3 backward-walk formula
(`reconstruction.md:494-497`) for the first time — it only looked
approximately right before because Junior Detective's route_length (5)
happened to collide with Sleuth's. Removed the `rank.junior_detective`
locale key from both `locales/en.lua` and `locales/pt.lua` together.
Tests: `tests/detective_test.lua`'s threshold table and "stays
ace_detective beyond" case updated to the new numbers.

---

## Technical Decisions

| Decision           | Choice               | Reason                                              |
| ------------------ | -------------------- | --------------------------------------------------- |
| State machine      | Custom (no lib)      | Simple, zero deps, fits the project scope           |
| JSON               | rxi/json.lua         | Single file, no LuaRocks, proven in production      |
| Camera             | None (map is static) | World map is not panned; no camera lib needed       |
| Animation          | Manual quads         | Simple frame-based, no overdependence on libs       |
| Virtual resolution | Manual canvas        | push lib is overkill for a fixed 2× scale           |
| CSV parsing        | Pure Lua             | Semicolon-delimited, no quoted fields in cities.csv |
| Route graphs       | Lua tables           | Loaded once, no runtime modification                |
| Clue data          | Per-city Lua files   | Easier to author and review than CSV                |

---

## Libraries (copy into `lib/`, no LuaRocks)

| Lib          | File           | Why                     |
| ------------ | -------------- | ----------------------- |
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
