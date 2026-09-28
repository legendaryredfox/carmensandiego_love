local city   = require("src.city")
local routes = require("data.routes")

local cities_by_id, cities_ordered = city.load("data/cities.csv")

describe("city.haversine", function()
    it("Nashville to Los Angeles ≈ 2887 km (Rosetta Code reference)", function()
        local km = city.haversine(36.12, -86.67, 33.94, -118.40)
        assert_near(km, 2887, 30, "Nashville→LA")
    end)

    it("Buenos Aires to Rio de Janeiro ≈ 1960 km", function()
        local km = city.haversine(-34.60, -58.38, -22.91, -43.17)
        assert_near(km, 1960, 50, "BA→RJ")
    end)

    it("same point returns 0", function()
        local km = city.haversine(48.85, 2.35, 48.85, 2.35)
        assert_near(km, 0, 0.001, "same point")
    end)

    it("is symmetric (A→B = B→A)", function()
        local ab = city.haversine(51.5, -0.13, 48.85, 2.35)
        local ba = city.haversine(48.85, 2.35, 51.5, -0.13)
        assert_near(ab, ba, 0.001, "symmetry")
    end)
end)

describe("city.load", function()
    it("loads all 30 cities", function()
        assert_eq(#cities_ordered, 30)
    end)

    it("each city has required fields", function()
        for _, c in ipairs(cities_ordered) do
            assert_not_nil(c.id,         "id missing for city")
            assert_not_nil(c.name_en,    "name_en missing: " .. c.id)
            assert_not_nil(c.lat,        "lat missing: " .. c.id)
            assert_not_nil(c.lon,        "lon missing: " .. c.id)
            assert_not_nil(c.population, "population missing: " .. c.id)
        end
    end)

    it("look up by id works", function()
        assert_not_nil(cities_by_id["london"])
        assert_eq(cities_by_id["london"].name_en, "London")
        assert_not_nil(cities_by_id["tokyo"])
        assert_not_nil(cities_by_id["buenos_aires"])
    end)

    it("coordinates are plausible (lat -90..90, lon -180..180)", function()
        for _, c in ipairs(cities_ordered) do
            assert_true(c.lat >= -90 and c.lat <= 90,
                "lat out of range: " .. c.id .. " = " .. tostring(c.lat))
            assert_true(c.lon >= -180 and c.lon <= 180,
                "lon out of range: " .. c.id .. " = " .. tostring(c.lon))
        end
    end)
end)

describe("city.distance", function()
    it("london to paris is roughly 340 km", function()
        local london = cities_by_id["london"]
        local paris  = cities_by_id["paris"]
        assert_near(city.distance(london, paris), 340, 20)
    end)

    it("tokyo to sydney is roughly 7820 km", function()
        local tokyo  = cities_by_id["tokyo"]
        local sydney = cities_by_id["sydney"]
        assert_near(city.distance(tokyo, sydney), 7820, 100)
    end)
end)

describe("city.travel_hours", function()
    it("london to paris returns at least 0.5h", function()
        local h = city.travel_hours(cities_by_id["london"], cities_by_id["paris"])
        assert_true(h >= 0.5, "expected >= 0.5h, got " .. h)
    end)

    it("returns multiple of 0.5", function()
        local h = city.travel_hours(cities_by_id["new_york"], cities_by_id["london"])
        assert_eq(h % 0.5, 0, "not a 0.5h multiple: " .. h)
    end)
end)

describe("city.connections (route graphs)", function()
    it("all 8 graphs have all 30 cities", function()
        for g = 1, 8 do
            local graph = routes[g]
            local count = 0
            for _ in pairs(graph) do count = count + 1 end
            assert_eq(count, 30, "graph " .. g .. " has " .. count .. " cities")
        end
    end)

    it("each city has at least 2 connections in every graph", function()
        for g = 1, 8 do
            local graph = routes[g]
            for cid, conns in pairs(graph) do
                assert_true(#conns >= 2,
                    "graph " .. g .. " city " .. cid .. " has " .. #conns .. " connections")
            end
        end
    end)

    it("city.connections returns the correct list", function()
        local graph = routes[1]
        local conns = city.connections("london", graph)
        assert_true(#conns > 0, "london should have connections in graph 1")
    end)

    it("unknown city returns empty table", function()
        local conns = city.connections("atlantis", routes[1])
        assert_eq(#conns, 0)
    end)

    it("all connection targets are valid city ids", function()
        for g = 1, 8 do
            local graph = routes[g]
            for cid, conns in pairs(graph) do
                for _, target in ipairs(conns) do
                    assert_not_nil(cities_by_id[target],
                        "graph " .. g .. ": " .. cid .. " -> unknown '" .. target .. "'")
                end
            end
        end
    end)
end)
