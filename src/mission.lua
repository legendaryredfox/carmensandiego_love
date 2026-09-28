local M = {}

M.RANK_CONFIG = {
    rookie           = { route_length = 4, time_days = 7 },
    junior_detective = { route_length = 5, time_days = 7 },
    sleuth           = { route_length = 5, time_days = 6 },
    private_eye      = { route_length = 6, time_days = 6 },
    investigator     = { route_length = 7, time_days = 5 },
    ace_detective    = { route_length = 8, time_days = 5 },
}

-- Real landmark items, keyed by their actual home city — a briefing must
-- never claim, say, the Mona Lisa was stolen from Kathmandu. Cities without
-- a specific landmark in this table draw from GENERIC_ITEMS instead, which
-- describe something vague enough to be true of any city's museum.
local ITEM_BY_CITY = {
    paris       = { "item.mona_lisa", "item.eiffel_torch" },
    london      = { "item.crown_jewels", "item.magna_carta", "item.big_ben_bell" },
    mexico_city = { "item.aztec_calendar" },
    athens      = { "item.parthenon_frieze" },
    rome        = { "item.colosseum_stone" },
}

local GENERIC_ITEMS = {
    "item.generic_painting", "item.generic_gem", "item.generic_relic",
    "item.generic_document", "item.generic_statue",
}

M.ITEM_BY_CITY  = ITEM_BY_CITY
M.GENERIC_ITEMS = GENERIC_ITEMS

local TRAIT_ATTRS = { "sex", "hair", "hobby", "vehicle", "feature", "food" }

-- Cap on hideout re-picks before giving up and returning a shorter route.
-- Mirrors the original's "dead end rings the bell and restarts the case"
-- behavior below, but bounded so a pathological rng can't hang forever.
local MAX_ROUTE_ATTEMPTS = 200

-- Builds a route of `length` unique city ids, mirroring the 1985 original's
-- N_BEGIN_CASE: pick the hideout city first (it ends up last in the route,
-- see M.thief_city), then walk backward from it over the connectivity graph
-- — each city's route graph entry is symmetric (see data/routes.lua), so
-- walking backward and forward draw from the same adjacency lists. A dead
-- end (no unused connection left) discards the whole attempt and re-picks
-- a fresh hideout, rather than just truncating the route short.
-- rng(n) must return an integer in [1, n].
function M._build_route(cities_by_id, graph, length, rng)
    local all_ids = {}
    for id in pairs(cities_by_id) do
        table.insert(all_ids, id)
    end
    table.sort(all_ids)

    local best_route = nil

    for _ = 1, MAX_ROUTE_ATTEMPTS do
        local hideout = all_ids[rng(#all_ids)]
        local route   = { hideout }
        local visited = { [hideout] = true }
        local current = hideout
        local dead_end = false

        for _ = 2, length do
            local connections = graph[current] or {}
            local available   = {}
            for _, c in ipairs(connections) do
                if not visited[c] then
                    table.insert(available, c)
                end
            end
            if #available == 0 then
                dead_end = true
                break
            end
            local prev_city = available[rng(#available)]
            table.insert(route, 1, prev_city) -- prepend: walking backward
            visited[prev_city] = true
            current = prev_city
        end

        if not dead_end then
            return route
        end
        if not best_route or #route > #best_route then
            best_route = route
        end
    end

    return best_route
end

-- Generates clue tables per city in route.
-- rng is optional; if nil, first pool entry is used (for tests).
-- Returns { [city_id] = { clue, clue, clue }, ... }
function M._generate_clues(route, thief, rng)
    local pool_mod = require("src.clue_pool")
    local clues    = {}

    for i = 1, #route - 1 do
        local city_id      = route[i]
        local next_city_id = route[i + 1]
        local city_clues   = {}
        local dest_pool    = pool_mod.load(next_city_id)

        -- Venues 1 and 2: distinct destination clues from the next city's
        -- pool — picking independently could return the same clue twice.
        local picks = pool_mod.pick_many(dest_pool, 2, rng)
        for slot = 1, 2 do
            local raw = picks[slot]
            if raw then
                table.insert(city_clues, {
                    type         = "destination",
                    next_city_id = next_city_id,
                    category     = raw.category,
                    text         = raw.text,
                    image        = raw.image,
                    verified     = raw.verified,
                })
            else
                table.insert(city_clues, {
                    type         = "destination",
                    next_city_id = next_city_id,
                    category     = "generic",
                    text_key     = "clue.generic.destination",
                    verified     = false,
                })
            end
        end

        -- Venue 3: one suspect trait clue, cycling through attributes per city
        local attr = TRAIT_ATTRS[((i - 1) % #TRAIT_ATTRS) + 1]
        table.insert(city_clues, {
            type     = "trait",
            attr     = attr,
            value    = thief[attr],
            category = "trait",
            text_key = "clue.trait." .. attr .. "." .. thief[attr],
            image    = nil,
        })

        clues[city_id] = city_clues
    end

    -- Terminal city: three "no leads" clues — thief is here
    local terminal    = route[#route]
    clues[terminal]   = {
        { type = "terminal", text_key = "clue.terminal", image = nil },
        { type = "terminal", text_key = "clue.terminal", image = nil },
        { type = "terminal", text_key = "clue.terminal", image = nil },
    }

    return clues
end

-- Cases needed (at Ace Detective) before the next case is the organization
-- leader's — see SPEC.md §2.7. Matches the 1985 original exactly: N_BEGIN_CASE
-- (references/apple2-carmen-sandiego-world-disasm src/disk1/N.s:330-338)
-- requires top rank AND cases_solved >= $1D (29) before forcing the leader as
-- suspect — the rank-up threshold alone (15, in RANK_CONFIG.ace_detective)
-- isn't enough on its own, matching the original's separate, higher gate.
M.FINAL_CASE_CASES_SOLVED = 29

-- Creates a new mission.
-- suspects: list of Suspect tables (the regular 10-suspect roster)
-- cities_by_id: { [id] = City }
-- routes: the 8 route graphs (data/routes.lua)
-- rank_name: string key into RANK_CONFIG
-- rng: function(n) → integer in [1, n]
-- leader: the organization-leader Suspect table (data/leader.lua), or nil
--   for a regular case. Pass it once the detective has reached
--   M.FINAL_CASE_CASES_SOLVED to make this the career-capping final case.
function M.new(suspects, cities_by_id, routes, rank_name, rng, leader)
    local cfg    = M.RANK_CONFIG[rank_name]
    assert(cfg, "unknown rank: " .. tostring(rank_name))

    local is_final    = leader ~= nil
    local thief       = is_final and leader or suspects[rng(#suspects)]
    local graph_index = rng(8)
    local graph       = routes[graph_index]

    local route     = M._build_route(cities_by_id, graph, cfg.route_length, rng)
    local clues     = M._generate_clues(route, thief, rng)
    local item_pool = ITEM_BY_CITY[route[1]] or GENERIC_ITEMS
    local item_key  = item_pool[rng(#item_pool)]

    return {
        thief             = thief,
        is_final          = is_final,
        stolen_item       = item_key,
        graph_index       = graph_index,
        route             = route,
        time_limit_hours  = cfg.time_days * 24,
        clues             = clues,
    }
end

-- Returns the clue at a venue (1–3) for a city, or nil if city has no clues.
function M.clue_at(mission, city_id, venue_index)
    local city_clues = mission.clues[city_id]
    if not city_clues then return nil end
    return city_clues[venue_index]
end

-- Returns true if city_id is the thief's hiding spot.
function M.is_terminal(mission, city_id)
    return mission.route[#mission.route] == city_id
end

-- Returns the city id where the thief is hiding.
function M.thief_city(mission)
    return mission.route[#mission.route]
end

-- Returns true if city_id is on the thief's route.
function M.on_route(mission, city_id)
    for _, id in ipairs(mission.route) do
        if id == city_id then return true end
    end
    return false
end

return M
