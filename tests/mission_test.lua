local mission    = require("src.mission")
local city_mod   = require("src.city")
local suspect_mod = require("src.suspect")
local routes     = require("data.routes")

local cities_by_id = city_mod.load("data/cities.csv")
local suspects     = suspect_mod.load()

-- Deterministic rng: cycles through fixed values
local function make_rng(sequence)
    local i = 0
    return function(n)
        i = i + 1
        local v = sequence[i] or 1
        return math.max(1, math.min(n, v))
    end
end

-- Simple seeded rng for repeatability
local function make_seed_rng(seed)
    local s = seed
    return function(n)
        s = (s * 1103515245 + 12345) % (2^31)
        return (s % n) + 1
    end
end

describe("mission._build_route", function()
    it("builds route of requested length", function()
        local rng   = make_seed_rng(42)
        local graph = routes[1]
        local route = mission._build_route(cities_by_id, graph, 5, rng)
        assert_eq(#route, 5)
    end)

    it("all cities in route exist in cities_by_id", function()
        local rng   = make_seed_rng(7)
        local graph = routes[2]
        local route = mission._build_route(cities_by_id, graph, 6, rng)
        for _, id in ipairs(route) do
            assert_not_nil(cities_by_id[id], "unknown city in route: " .. id)
        end
    end)

    it("no city is repeated in route", function()
        local rng   = make_seed_rng(99)
        local graph = routes[3]
        local route = mission._build_route(cities_by_id, graph, 6, rng)
        local seen  = {}
        for _, id in ipairs(route) do
            assert_nil(seen[id], "duplicate city in route: " .. id)
            seen[id] = true
        end
    end)

    it("each consecutive pair is connected in the graph", function()
        local rng   = make_seed_rng(13)
        local graph = routes[1]
        local route = mission._build_route(cities_by_id, graph, 5, rng)
        for i = 1, #route - 1 do
            local from   = route[i]
            local to     = route[i + 1]
            local conns  = graph[from] or {}
            local found  = false
            for _, c in ipairs(conns) do
                if c == to then found = true; break end
            end
            assert_true(found, "no connection: " .. from .. " -> " .. to)
        end
    end)

    it("same seed produces same route (determinism)", function()
        local graph  = routes[4]
        local route1 = mission._build_route(cities_by_id, graph, 5, make_seed_rng(55))
        local route2 = mission._build_route(cities_by_id, graph, 5, make_seed_rng(55))
        assert_eq(#route1, #route2)
        for i = 1, #route1 do
            assert_eq(route1[i], route2[i])
        end
    end)
end)

describe("mission._distinguishing_attrs", function()
    it("finds a subset that actually distinguishes two near-identical suspects", function()
        -- Regression: marina_delacroix and kat_sterling share sex/hair/hobby
        -- (exactly what the old blind sex->hair->hobby->... cycle revealed
        -- at Rookie's 3-non-terminal-city route) and differ only on
        -- vehicle/feature/food — a Rookie case with either as thief was
        -- permanently undeducible via clues alone.
        local suspect_mod = require("src.suspect")
        local suspects     = suspect_mod.load()
        local marina        = suspect_mod.by_id(suspects, "marina_delacroix")
        local kat            = suspect_mod.by_id(suspects, "kat_sterling")
        assert_not_nil(marina)
        assert_not_nil(kat)

        local attrs = mission._distinguishing_attrs(marina, suspects)
        -- Whatever subset was picked, it must actually rule kat out —
        -- i.e. at least one chosen attribute differs between the two.
        local rules_out_kat = false
        for _, attr in ipairs(attrs) do
            if marina[attr] ~= kat[attr] then rules_out_kat = true end
        end
        assert_true(rules_out_kat,
            "distinguishing_attrs for marina_delacroix doesn't rule out kat_sterling")
    end)

    it("every rank's route length reveals enough trait clues to deduce any thief", function()
        -- End-to-end regression for the bug above: simulate every possible
        -- thief at every rank, gather exactly the trait clues that route
        -- length would reveal, and confirm the crime computer's filter
        -- narrows to exactly one suspect.
        local suspect_mod = require("src.suspect")
        local roster       = suspect_mod.load()
        for _, cfg in pairs(mission.RANK_CONFIG) do
            local non_terminal = cfg.route_length - 1
            for _, thief in ipairs(roster) do
                local route = {}
                for i = 1, cfg.route_length do route[i] = "city" .. i end
                local clues = mission._generate_clues(route, thief, roster, nil)
                local gathered = {}
                for i = 1, non_terminal do
                    local c = clues[route[i]][3]
                    gathered[c.attr] = c.value
                end
                local matches = suspect_mod.filter(roster, gathered)
                assert_eq(#matches, 1,
                    "thief " .. thief.id .. " undeducible at route_length=" ..
                    cfg.route_length .. " (" .. #matches .. " matches)")
            end
        end
    end)
end)

describe("mission._generate_clues", function()
    local thief = suspects[1]
    local route = {"london", "paris", "tokyo", "moscow"}

    it("generates clues for all non-terminal cities", function()
        local clues = mission._generate_clues(route, thief)
        assert_not_nil(clues["london"])
        assert_not_nil(clues["paris"])
        assert_not_nil(clues["tokyo"])
    end)

    it("each non-terminal city has 3 clues", function()
        local clues = mission._generate_clues(route, thief)
        for i = 1, #route - 1 do
            local city_clues = clues[route[i]]
            assert_eq(#city_clues, 3)
        end
    end)

    it("venues 1-2 are destination clues pointing to next city", function()
        local clues = mission._generate_clues(route, thief)
        for i = 1, #route - 1 do
            local c1 = clues[route[i]][1]
            local c2 = clues[route[i]][2]
            assert_eq(c1.type, "destination")
            assert_eq(c2.type, "destination")
            assert_eq(c1.next_city_id, route[i + 1])
            assert_eq(c2.next_city_id, route[i + 1])
        end
    end)

    it("venues 1-2 never share the same clue when the pool has enough entries", function()
        local pool_mod = require("src.clue_pool")
        for seed = 1, 20 do
            local clues = mission._generate_clues(route, thief, suspects, make_seed_rng(seed))
            for i = 1, #route - 1 do
                local pool = pool_mod.load(route[i + 1])
                if #pool >= 2 then
                    local c1 = clues[route[i]][1]
                    local c2 = clues[route[i]][2]
                    assert_true(c1.text ~= c2.text or c1.category ~= c2.category,
                        "duplicate destination clue for " .. route[i] ..
                        " (seed " .. seed .. ")")
                end
            end
        end
    end)

    it("venue 3 is a trait clue with correct suspect value", function()
        local clues = mission._generate_clues(route, thief)
        for i = 1, #route - 1 do
            local c3 = clues[route[i]][3]
            assert_eq(c3.type, "trait")
            assert_not_nil(c3.attr)
            assert_eq(c3.value, thief[c3.attr])
        end
    end)

    it("terminal city has 3 terminal clues", function()
        local clues    = mission._generate_clues(route, thief)
        local terminal = clues[route[#route]]
        assert_eq(#terminal, 3)
        for _, c in ipairs(terminal) do
            assert_eq(c.type, "terminal")
        end
    end)
end)

describe("mission.new", function()
    it("creates a mission with all required fields", function()
        local rng = make_seed_rng(1)
        local m   = mission.new(suspects, cities_by_id, routes, "rookie", rng)
        assert_not_nil(m.thief)
        assert_not_nil(m.stolen_item)
        assert_not_nil(m.route)
        assert_not_nil(m.clues)
        assert_not_nil(m.time_limit_hours)
        assert_not_nil(m.graph_index)
    end)

    it("rookie mission has 4-city route and 168h limit", function()
        local rng = make_seed_rng(2)
        local m   = mission.new(suspects, cities_by_id, routes, "rookie", rng)
        assert_eq(#m.route, 4)
        assert_eq(m.time_limit_hours, 7 * 24)
    end)

    it("ace_detective mission has 8-city route and 120h limit", function()
        local rng = make_seed_rng(3)
        local m   = mission.new(suspects, cities_by_id, routes, "ace_detective", rng)
        assert_eq(#m.route, 8)
        assert_eq(m.time_limit_hours, 5 * 24)
    end)

    it("stolen item matches the starting city's real landmark, when it has one", function()
        -- Regression: a briefing once claimed the Mona Lisa was stolen from
        -- Kathmandu because the item was picked independently of the route.
        for seed = 1, 200 do
            local m       = mission.new(suspects, cities_by_id, routes, "rookie", make_seed_rng(seed))
            local city_id = m.route[1]
            local pool    = mission.ITEM_BY_CITY[city_id] or mission.GENERIC_ITEMS
            local found   = false
            for _, item in ipairs(pool) do
                if item == m.stolen_item then found = true; break end
            end
            assert_true(found, "stolen_item " .. m.stolen_item ..
                " is not valid for starting city " .. city_id)
        end
    end)

    it("same seed produces identical mission (determinism)", function()
        local m1 = mission.new(suspects, cities_by_id, routes, "sleuth", make_seed_rng(77))
        local m2 = mission.new(suspects, cities_by_id, routes, "sleuth", make_seed_rng(77))
        assert_eq(m1.thief.id, m2.thief.id)
        assert_eq(m1.stolen_item, m2.stolen_item)
        assert_eq(#m1.route, #m2.route)
        for i = 1, #m1.route do
            assert_eq(m1.route[i], m2.route[i])
        end
    end)

    it("regular case (no leader passed) never selects the leader as thief", function()
        for seed = 1, 100 do
            local m = mission.new(suspects, cities_by_id, routes, "ace_detective", make_seed_rng(seed))
            assert_false(m.thief.is_leader == true,
                "leader picked as thief without being passed in, seed " .. seed)
            assert_false(m.is_final)
        end
    end)

    it("passing a leader forces her as thief and marks the mission final", function()
        local leader = require("data.leader")
        local m = mission.new(suspects, cities_by_id, routes, "ace_detective",
            make_seed_rng(3), leader)
        assert_eq(m.thief.id, leader.id)
        assert_true(m.is_final)
    end)
end)

describe("mission helpers", function()
    local rng = make_seed_rng(42)
    local m   = mission.new(suspects, cities_by_id, routes, "rookie", rng)

    it("is_terminal returns true for last city in route", function()
        local last = m.route[#m.route]
        assert_true(mission.is_terminal(m, last))
    end)

    it("is_terminal returns false for non-terminal cities", function()
        assert_false(mission.is_terminal(m, m.route[1]))
    end)

    it("thief_city returns the last route city", function()
        assert_eq(mission.thief_city(m), m.route[#m.route])
    end)

    it("on_route returns true for cities in route", function()
        for _, id in ipairs(m.route) do
            assert_true(mission.on_route(m, id))
        end
    end)

    it("on_route returns false for cities not in route", function()
        -- find a city not in the route
        local all_ids = {}
        for id in pairs(cities_by_id) do table.insert(all_ids, id) end
        for _, id in ipairs(all_ids) do
            local in_route = false
            for _, rid in ipairs(m.route) do
                if rid == id then in_route = true; break end
            end
            if not in_route then
                assert_false(mission.on_route(m, id))
                break
            end
        end
    end)

    it("clue_at returns nil for city not in mission", function()
        assert_nil(mission.clue_at(m, "atlantis", 1))
    end)

    it("clue_at returns correct clue for first venue", function()
        local first = m.route[1]
        local clue  = mission.clue_at(m, first, 1)
        assert_not_nil(clue)
        assert_eq(clue.type, "destination")
    end)
end)
