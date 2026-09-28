local map     = require("src.map")
local city    = require("src.city")

local cities_by_id = city.load("data/cities.csv")

describe("map.lat_lon_to_xy", function()
    it("maps (0,0) to the center of the rect", function()
        local x, y = map.lat_lon_to_xy(0, 0, 100, 200, 400, 300)
        assert_near(x, 100 + 400 / 2, 0.001)
        assert_near(y, 200 + 300 / 2, 0.001)
    end)

    it("maps the top-left corner (lat 90, lon -180)", function()
        local x, y = map.lat_lon_to_xy(90, -180, 0, 0, 1000, 500)
        assert_near(x, 0, 0.001)
        assert_near(y, 0, 0.001)
    end)

    it("maps the bottom-right corner (lat -90, lon 180)", function()
        local x, y = map.lat_lon_to_xy(-90, 180, 0, 0, 1000, 500)
        assert_near(x, 1000, 0.001)
        assert_near(y, 500, 0.001)
    end)
end)

describe("map.city_xy", function()
    it("matches lat_lon_to_xy for a city with no marker nudge", function()
        local paris = cities_by_id.paris
        local px, py = map.city_xy(paris, 0, 0, 1000, 500)
        local ex, ey = map.lat_lon_to_xy(paris.lat, paris.lon, 0, 0, 1000, 500)
        assert_near(px, ex, 0.001)
        assert_near(py, ey, 0.001)
    end)

    it("nudges a city that has a marker correction, scaled to the rect", function()
        -- tokyo's measured nudge is -27px/-27px on the source 1774x887
        -- image (see src/map.lua's MARKER_NUDGE_PX) — at a rect exactly
        -- that size, the nudge should apply as a plain -27,-27 pixel shift.
        local tokyo = cities_by_id.tokyo
        local nx, ny = map.city_xy(tokyo, 0, 0, 1774, 887)
        local ex, ey = map.lat_lon_to_xy(tokyo.lat, tokyo.lon, 0, 0, 1774, 887)
        assert_near(nx, ex - 27, 0.01)
        assert_near(ny, ey - 27, 0.01)
    end)

    it("scales the nudge proportionally at a different rect size", function()
        local tokyo = cities_by_id.tokyo
        local nx, ny = map.city_xy(tokyo, 0, 0, 887, 443.5) -- half size
        local ex, ey = map.lat_lon_to_xy(tokyo.lat, tokyo.lon, 0, 0, 887, 443.5)
        assert_near(nx, ex - 13.5, 0.1)
        assert_near(ny, ey - 13.5, 0.1)
    end)
end)
