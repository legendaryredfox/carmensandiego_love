local locale      = require("src.locale")
local mission_mod = require("src.mission")

local M = {}

local VARIANTS = {
    landmark  = 3,
    currency  = 3,
    language  = 3,
    geography = 3,
    wildlife  = 3,
    culture   = 3,
    industry  = 3,
    trait     = 3,
    terminal  = 2,
    generic   = 3,
}

-- djb2 — deterministic, no external dependency.
local function hash(s)
    local h = 5381
    for i = 1, #s do
        h = (h * 33 + s:byte(i)) % 2147483647
    end
    return h
end

-- Category driving a venue's name: the clue's own category for
-- destination clues, "terminal" for the thief's hideout, "generic"
-- when the city has no clue data for that venue.
function M.category_for(mission, city_id, venue_index)
    local clue = mission_mod.clue_at(mission, city_id, venue_index)
    if not clue then return "generic" end
    if clue.type == "terminal" then return "terminal" end
    return clue.category or "generic"
end

-- Per-mission caches — city.lua and venue.lua both call these every single
-- draw() frame for the same, unchanging (mission, city, venue) triple,
-- which otherwise re-hashes and re-resolves 2-3 locale lookups 60 times a
-- second for text that cannot change until the player leaves the screen.
-- Keyed by the mission table itself (a fresh table per case, see
-- mission.lua's M.new), so old entries just stop being reachable once a
-- case ends rather than needing explicit invalidation.
local _variant_cache = {}
local _name_cache    = {}

-- Which name variant (1..N) a venue landed on. Stable per (city, venue) so
-- redraws don't flicker; varied across cities via a hash so venues don't
-- all share the same handful of names. When two venues in the same city
-- land on the same category (e.g. both picked a "landmark" clue, or both
-- fell back to "generic" on an off-route city), later venues step to the
-- next variant instead of repeating the same one — city.lua's venue-card
-- icon is keyed off this too, so those venues no longer just differ in
-- name but in icon as well (see get_venue_icon's generic special-case).
function M.variant_for(mission, city_id, venue_index)
    local cache = _variant_cache[mission]
    if not cache then
        cache = {}
        _variant_cache[mission] = cache
    end
    local key = city_id .. ":" .. venue_index
    if cache[key] then return cache[key] end

    local category = M.category_for(mission, city_id, venue_index)
    local variants = VARIANTS[category] or 1
    local base     = hash(city_id .. ":" .. venue_index .. ":" .. category)
                      % variants

    local chosen
    for attempt = 0, variants - 1 do
        local variant = ((base + attempt) % variants) + 1
        local taken   = false
        for j = 1, venue_index - 1 do
            if M.category_for(mission, city_id, j) == category
               and M.variant_for(mission, city_id, j) == variant then
                taken = true
                break
            end
        end
        if not taken then chosen = variant; break end
    end
    chosen = chosen or (base + 1)

    cache[key] = chosen
    return chosen
end

-- Localized venue name for the variant M.variant_for resolved.
function M.name_for(mission, city_id, venue_index)
    local lang  = locale.get_lang()
    local cache = _name_cache[mission]
    if not cache then
        cache = {}
        _name_cache[mission] = cache
    end
    local key = city_id .. ":" .. venue_index .. ":" .. lang
    if cache[key] then return cache[key] end

    local category = M.category_for(mission, city_id, venue_index)
    local variant  = M.variant_for(mission, city_id, venue_index)
    local name     = locale.t("venue_name." .. category .. "." .. variant)

    cache[key] = name
    return name
end

return M
