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
-- the same handful of names. When two venues in the same city land on
-- the same category (e.g. both picked a "landmark" clue), later venues
-- step to the next variant instead of repeating the same name.
function M.name_for(mission, city_id, venue_index)
    local category = M.category_for(mission, city_id, venue_index)
    local variants = VARIANTS[category] or 1
    local base     = hash(city_id .. ":" .. venue_index .. ":" .. category)
                      % variants

    for attempt = 0, variants - 1 do
        local variant = ((base + attempt) % variants) + 1
        local name    = locale.t("venue_name." .. category .. "." .. variant)
        local taken   = false
        for j = 1, venue_index - 1 do
            if M.name_for(mission, city_id, j) == name then
                taken = true
                break
            end
        end
        if not taken then return name end
    end
    return locale.t("venue_name." .. category .. "." .. (base + 1))
end

return M
