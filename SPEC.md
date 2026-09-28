# Game Specification

**Working title:** Carmen Sandiego — LÖVE2D Edition  
**Final title:** TBD (must not include "Carmen Sandiego" — see IP constraints in CLAUDE.md)  
**Platform:** Desktop (Linux, macOS, Windows) via LÖVE2D 11.5  
**Resolution:** 640×360 virtual canvas, 2× integer scale → 1280×720 window  
**Style:** Pixel art retro, inspired by 1985 EGA/Tandy aesthetic  
**Languages:** English (EN) and Portuguese PT-BR, selectable at title screen  

---

## 1. Game Overview

A globe-trotting detective game. A national treasure has been stolen by a member of a
criminal organization. The player is an Interpol detective who must travel between cities,
interview witnesses, gather clues, identify the suspect via the crime computer, issue an
arrest warrant, and make the arrest — before time runs out.

Inspired by "Where in the World is Carmen Sandiego?" (Broderbund, 1985). Extended with
real-world geography, save/load, and a local detective ranking leaderboard.

---

## 2. Core Mechanics

### 2.1 Mission Structure

Each mission:
1. A theft occurs in a starting city (randomized each game)
2. The thief is one of 10 suspects (randomized)
3. The thief's escape route spans 4–8 cities depending on detective rank
4. Detective starts in the first city and must follow the trail
5. Time limit: 6–7 in-game days (tightens at higher ranks)

### 2.2 City Actions (per city)

Each city has exactly **3 investigation venues** (e.g., museum, harbor, bazaar — varies by city).
From each city, the detective can:

- **Investigate venue** — interview a witness; receive a clue (destination or suspect trait)
- **Visit Crime Computer** — enter gathered suspect traits to narrow down the suspect list
- **Travel** — select a destination from 2–5 connected cities (consumes time)
- **Attempt arrest** — only if in the same city as the thief AND warrant is issued

### 2.3 Clue System

Two clue types:

**Destination clues** — point to the next city on the thief's route via cultural/geographic facts:
- Currency (image of coin/bill, vague text)
- Language fragment
- Geographic landmark (image, no label)
- Native animal (image, no label)
- Industry or agriculture
- Cultural practice or festival
- Flag (text description only — **never show flag image as clue**; describe colors/symbols: "the flag had horizontal red and white stripes with a blue canton")

**Suspect trait clues** — reveal one attribute of the thief:
- Sex (male/female)
- Hair color (brown/blonde/red/black)
- Hobby (tennis/mountain climbing/croquet/skydiving/swimming)
- Vehicle (convertible/limousine/motorcycle/racecar)
- Distinguishing feature (tattoo/ring/jewelry/scar)
- Food preference (Mexican/seafood)

Not every witness gives a trait clue. Some give only destination clues. Wrong cities yield
no useful clues ("nobody suspicious was seen here").

**Clue difficulty by rank:**

| Rank | Destination clue | Trait clue |
|---|---|---|
| Rookie | Text + image; text names the region | Always revealed if present |
| Sleuth | Text + image; text is vague | Always revealed |
| Private Eye | Image only for geographic clues | Revealed |
| Investigator | Image only; multiple valid cities possible | May be absent |
| Ace Detective | Image only; red herrings introduced | May be absent |

### 2.4 Crime Computer (Arrest Warrant)

The crime computer accepts up to 6 filter attributes:
`sex`, `hair`, `hobby`, `vehicle`, `feature`, `food`

- If filters match **exactly 1 suspect**: warrant issued for that suspect
- If filters match **2+ suspects**: list displayed, no warrant yet
- If filters match **0 suspects**: error — detective entered a contradictory clue

Warrant is required before arrest. Arresting without warrant = failure.
Arresting with warrant for wrong suspect = failure.

### 2.5 Travel

- City connections follow 8 pre-computed route graphs (cycling per mission for variety)
- Each graph defines which cities connect to which (2–5 connections per city)
- Travel time is calculated from Haversine distance (km) / 800 km/h ≈ flight hours
- Flight hours advance the in-game clock
- Investigating a venue costs 2 in-game hours
- Sleeping 8h per day is automatic at day transition (counts toward time limit)

### 2.6 Arrest

When the detective is in the same city as the thief:
- With correct warrant → **ARREST SUCCESS** → rank points awarded
- With wrong warrant → **WRONG ARREST** → mission failed (thief escapes)
- Without warrant → **NO WARRANT** → mission failed

### 2.7 Rank Progression

Cases-needed thresholds match the 1985 original exactly (its promotion
thresholds are 1, 5, 12, and 20 solved cases for these same five ranks —
see `references/apple2-carmen-sandiego-world-disasm/docs/reconstruction.md:59-61`).
Cities-in-trail also matches the original's rank+3 backward-walk formula
(`reconstruction.md:494-497`). Days limit is this project's own balance,
not ported.

| Rank | Cases needed | Cities in trail | Days limit |
|---|---|---|---|
| Rookie | 0 | 4 | 7 |
| Sleuth | 1 | 5 | 6 |
| Private Eye | 5 | 6 | 6 |
| Investigator | 12 | 7 | 5 |
| Ace Detective | 20 | 8 | 5 |

Once the detective is Ace Detective **and** has solved 29 cases total, the
next case's thief is always the organization leader — a separate, higher
gate than the rank-up threshold itself, matching the 1985 original exactly
(N_BEGIN_CASE checks rank ≥ top AND cases_solved ≥ 29 as two conditions, not
one; see `references/apple2-carmen-sandiego-world-disasm`). The briefing
never announces this in advance — it reads like any other dispatch, no
thief name, no special hint. The player only discovers it's the leader mid
case, the same way they'd discover any other suspect's identity.
Catching the leader ends the detective's career → Hall of Fame entry → new game required.

---

## 3. Extended Mechanics

### 3.1 Real-World Geography

- 30 cities with real lat/lon coordinates from `data/cities.csv`
- Haversine formula computes distances in km
- Travel time in-game = `distance_km / 800` hours (rounded to nearest half-hour)
- City markers on the world map show at actual geographic positions

### 3.2 Save / Load

- 3 save slots
- Each slot stores: detective name, rank, cases solved, current mission state, leaderboard
- Saved via `love.filesystem` as JSON (`save_slot_1.json`, etc.)
- Auto-save on city arrival and on quit (`love.quit` callback)
- Load on game start if save file exists

### 3.3 Detective Ranking (Leaderboard)

- Local leaderboard, top 10 entries
- Score formula: `(rank_multiplier × cases_solved) / total_days_elapsed`
- Displayed on leaderboard screen and after each successful arrest
- Stored in save file

---

## 4. Visual Design

### 4.1 Resolution & Scaling

- Virtual canvas: **640×360** pixels
- Window: **1280×720** (2× integer scale)
- `love.graphics.setDefaultFilter("nearest", "nearest")` — no blur
- Canvas rendered via `love.graphics.newCanvas(640, 360)` then scaled

### 4.2 Color Palette

16-color EGA-inspired palette. Exact hex values TBD during asset creation.
Key colors: deep navy background, amber text, green UI accents, red danger/alert.

### 4.3 World Map Screen

- Base world map image (CC0 tileset or flat projection image)
- City markers: pixel dot + name label (hidden until visited)
- Thief trail shown only after arrest (retrospective)
- Current detective position highlighted
- Connections shown as dotted lines when travel menu is open

### 4.4 City Screen

Layout (left→right): Interpol booth | Venue 1 | Venue 2 | Venue 3 | Airport
- Each venue has a distinct pixel art icon
- Status bar at bottom: city name | days remaining | rank

### 4.5 Screens & State Flow

```
TitleScreen
  └── LanguageSelectScreen
        └── MainMenuScreen
              ├── NewGameScreen (name entry)
              │     └── BriefingScreen
              │           └── CityScreen ←──────────────────┐
              │                 ├── VenueScreen              │
              │                 │     └── CityScreen ────────┤
              │                 ├── CrimeComputerScreen       │
              │                 │     └── CityScreen ────────┤
              │                 ├── TravelScreen              │
              │                 │     └── CityScreen (new) ──┤
              │                 └── ArrestScreen              │
              │                       ├── RankUpScreen ───────┘ (next mission)
              │                       └── GameOverScreen
              ├── ContinueScreen (load slot)
              └── LeaderboardScreen
```

Transitions: black fade-in/fade-out between all screen changes (0.4s duration).

---

## 5. Audio Design

### 5.1 Music

| Screen | Track style |
|---|---|
| Title / Main Menu | Mystery/adventure chiptune, looping |
| City (investigation) | Ambient city-specific chiptune, looping |
| Crime Computer | Tense, staccato chiptune |
| Travel | Upbeat travel/flight chiptune |
| Arrest success | Short victory fanfare |
| Game over | Short failure sting |

Source: OpenGameArt CC0 chiptune packs (see CREDITS.md).

### 5.2 SFX

Button clicks, menu navigation, clue reveal, warrant issue, arrest, travel departure.
Source: 512 Sound Effects 8-bit (OpenGameArt, CC0).

---

## 6. Localization

Language selected once at startup, stored in save file.

All player-visible text accessed via `locale.t("key")`:

```lua
-- locales/en.lua
return {
  ["title.new_game"] = "New Game",
  ["briefing.stolen"] = "A {item} was stolen from {city}.",
  -- ...
}
```

Interpolation: `locale.t("briefing.stolen", {item="Mona Lisa", city="Paris"})`.

Clue text keys follow pattern: `"clue.<city_id>.<index>"`.

---

## 7. Data Model

### City
```
id: string             -- "buenos_aires"
name_en: string
name_pt: string
country_en: string
country_pt: string
lat: number
lon: number
population: number
venues: string[3]      -- venue type keys (locale keys)
```

### Suspect
```
id: string
name: string           -- original-inspired but renamed (IP constraint)
sex: "male"|"female"
hair: "brown"|"blonde"|"red"|"black"
hobby: string          -- locale key
vehicle: string        -- locale key
feature: string        -- locale key
food: string           -- locale key
```

### Clue
```
type: "destination"|"trait"
category: string       -- "currency","animal","landmark","language","sex","hair",...
value: string          -- the actual value (e.g. "drachma")
text_key: string       -- locale key for vague clue text
image: string|nil      -- asset path (optional visual clue)
verified: boolean      -- geographic fact is current-verified
```

### Mission
```
suspect: Suspect
stolen_item: string    -- locale key
start_city: City
route: City[]          -- thief's path (detective must follow)
time_limit_hours: number
clues: { [city_id]: Clue[3] }
```

### Detective (save state)
```
name: string
rank: string
cases_solved: number
current_mission: Mission|nil
current_city_id: string
hours_elapsed: number
gathered_traits: { [attr]: string }
warrant: string|nil    -- suspect id
```

---

## 8. Cities (30 — from 1985 original)

Athens, Baghdad, Bamako, Bangkok, Budapest, Buenos Aires, Cairo, Colombo,
Istanbul, Kathmandu, Kigali, Lima, London, Mexico City, Montreal, Moroni,
Moscow, New Delhi, New York, Oslo, Paris, Beijing, Port Moresby, Reykjavik,
Rio de Janeiro, Rome, San Marino, Singapore, Sydney, Tokyo

All geographic facts (currency, language, landmarks, animals) must be **current** —
not from 1985. Unverified facts marked `-- TODO: verify` in clue data files.

---

## 9. Suspects (10 — renamed from originals)

Original 1985 suspect traits are reference only. Final names must be original.
Trait distribution must preserve deduction logic (unique combinations per trait set).

Trait categories:
- Sex: Male (5), Female (5)
- Hair: Brown (3), Blonde (2), Red (2), Black (3)
- Hobby: Tennis (3), Mountain Climbing (4), Croquet (3)
- Vehicle: Convertible (3–4), Limousine (4), Motorcycle (2)
- Feature: Jewelry (2), Ring (3), Tattoo (4), Scar (1)
- Food: Mexican (6), Seafood (4)

---

## 10. Test Requirements

- `tests/runner.lua` discovers and runs all `*_test.lua` files via `lua tests/runner.lua`
- No `love.*` calls in any test — pure Lua only
- Required test coverage:
  - `city_test.lua`: CSV loading, Haversine accuracy (< 1% error), connection graph
  - `suspect_test.lua`: trait filter search, edge cases (0 matches, 1 match, many matches)
  - `mission_test.lua`: mission generation determinism (fixed seed), route validity
  - `detective_test.lua`: rank progression thresholds, time tracking, clue accumulation
  - `locale_test.lua`: key lookup, missing key fallback, interpolation
  - `save_test.lua`: serialize/deserialize round-trip, slot isolation

---

## 11. Asset Sources

All assets free for commercial use. Full credits in `assets/CREDITS.md`.

| Asset | Source | License |
|---|---|---|
| UI sprites | Kenney Pixel UI Pack | CC0 |
| Character sprites | Kenney Roguelike Characters | CC0 |
| Map icons | Kenney Board Game Icons | CC0 |
| Travel icon | Kenney Pixel Shmup (airplane) | CC0 |
| Music | OpenGameArt — 15 Melodic RPG Chiptunes | CC0 |
| Music (alt) | OpenGameArt — 4 Chiptunes Adventure | CC0 |
| SFX | OpenGameArt — 512 Sound Effects 8-bit | CC0 |
| Font | Press Start 2P (Google Fonts) | OFL |
| Font (alt) | Dogica (DaFont) | OFL |
| Country images | Wikimedia Commons (per item) | CC0/CC-BY |
| Clue images | Wikimedia Commons + OpenGameArt | CC0/CC-BY |
| Flags | flagicons (CSS repo, SVG/PNG) or Wikimedia | Public domain |

---

## 12. Out of Scope (v1.0)

- Multiplayer
- Mobile/touch controls
- Online leaderboard
- Procedural clue generation from live data (CIA Factbook API, etc.)
- More than 30 cities
- Animated city backgrounds
- Voice acting
