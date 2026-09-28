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
    generic   = 1,
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

-- Localized venue name. Stable per (city, venue) so redraws don't
-- flicker; varied across cities via a hash so venues don't all share
-- the same handful of names.
function M.name_for(mission, city_id, venue_index)
    local category = M.category_for(mission, city_id, venue_index)
    local variants = VARIANTS[category] or 1
    local variant  = (hash(city_id .. ":" .. venue_index .. ":" .. category)
                       % variants) + 1
    return locale.t("venue_name." .. category .. "." .. variant)
end

return M
