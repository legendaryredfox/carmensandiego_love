local M = {}

M.RANK_CONFIG = {
    rookie           = { route_length = 4, time_days = 7 },
    junior_detective = { route_length = 5, time_days = 7 },
    sleuth           = { route_length = 5, time_days = 6 },
    private_eye      = { route_length = 6, time_days = 6 },
    investigator     = { route_length = 7, time_days = 5 },
    ace_detective    = { route_length = 8, time_days = 5 },
}

local STOLEN_ITEMS = {
    "item.mona_lisa", "item.hope_diamond", "item.crown_jewels",
    "item.magna_carta", "item.aztec_calendar", "item.terracotta_army",
    "item.parthenon_frieze", "item.eiffel_torch", "item.colosseum_stone",
    "item.big_ben_bell",
}

local TRAIT_ATTRS = { "sex", "hair", "hobby", "vehicle", "feature", "food" }

-- Builds a route of `length` unique city ids following graph connections.
-- rng(n) must return an integer in [1, n].
function M._build_route(cities_by_id, graph, length, rng)
    local all_ids = {}
    for id in pairs(cities_by_id) do
        table.insert(all_ids, id)
    end
    table.sort(all_ids)

    local start   = all_ids[rng(#all_ids)]
    local route   = { start }
    local visited = { [start] = true }
    local current = start

    for _ = 2, length do
        local connections = graph[current] or {}
        local available   = {}
        for _, c in ipairs(connections) do
            if not visited[c] then
                table.insert(available, c)
            end
        end
        if #available == 0 then break end
        local next_city = available[rng(#available)]
        table.insert(route, next_city)
        visited[next_city] = true
        current = next_city
    end

    return route
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

-- Creates a new mission.
-- suspects: list of Suspect tables
-- cities_by_id: { [id] = City }
-- routes: the 8 route graphs (data/routes.lua)
-- rank_name: string key into RANK_CONFIG
-- rng: function(n) → integer in [1, n]
function M.new(suspects, cities_by_id, routes, rank_name, rng)
    local cfg    = M.RANK_CONFIG[rank_name]
    assert(cfg, "unknown rank: " .. tostring(rank_name))

    local thief       = suspects[rng(#suspects)]
    local graph_index = rng(8)
    local graph       = routes[graph_index]
    local item_key    = STOLEN_ITEMS[rng(#STOLEN_ITEMS)]

    local route = M._build_route(cities_by_id, graph, cfg.route_length, rng)
    local clues = M._generate_clues(route, thief, rng)

    return {
        thief             = thief,
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
