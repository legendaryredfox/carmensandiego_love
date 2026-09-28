local M = {}

local CONTINENTS = require("data.continents")
local locale     = require("src.locale")

local function city_label(city)
    return locale.get_lang() == "pt" and city.name_pt or city.name_en
end

-- Sourced pixel-art world map (see assets/CREDITS.md), used when present.
-- A full-world equirectangular image (lon -180..180, lat -90..90, same
-- convention as M.lat_lon_to_xy) stretched independently on x and y to
-- exactly fill the map rect keeps every pixel's (lon,lat) fraction
-- aligned with city markers regardless of the rect's own aspect ratio —
-- non-uniform scaling doesn't break that, since both the image draw and
-- lat_lon_to_xy place things by the same fractional (nx, ny) alone.
-- Falls back to the procedural land_polygons() below if the file is
-- missing, same pattern as this project's other optional art.
local WORLD_MAP_PATH = "assets/images/map/world_map.png"
local _world_map_img, _world_map_tried = nil, false

local function get_world_map_image()
    if not _world_map_tried then
        _world_map_tried = true
        if love.filesystem.getInfo(WORLD_MAP_PATH) then
            local ok, img = pcall(love.graphics.newImage, WORLD_MAP_PATH)
            if ok then _world_map_img = img end
        end
    end
    return _world_map_img
end

-- Equirectangular projection: maps lat/lon to canvas x/y.
-- Map area covers full world: lat [-90,90], lon [-180,180].
function M.lat_lon_to_xy(lat, lon, map_x, map_y, map_w, map_h)
    local nx = (lon + 180) / 360
    local ny = (90 - lat) / 180
    return map_x + nx * map_w, map_y + ny * map_h
end

-- Projects a continent's {lat,lon} outline to a flat {x1,y1,x2,y2,...}
-- list, cached per (continent, map rect) since the rect is fixed per
-- screen and this would otherwise re-project ~100 points every frame.
local _land_cache = {}

local function land_polygons(map_x, map_y, map_w, map_h)
    local rect_key = table.concat({ map_x, map_y, map_w, map_h }, ":")
    local cached = _land_cache[rect_key]
    if cached then return cached end

    local polygons = {}
    for _, continent in ipairs(CONTINENTS) do
        -- A few landmasses (e.g. eastern Siberia, near the Bering Strait)
        -- genuinely cross the antimeridian. Projecting lon -179 and +179
        -- straight through would draw a line clear across the map, so
        -- split into a new sub-polygon wherever consecutive points jump
        -- more than 180° — the real coastline never does that.
        local points = {}
        local prev_lon = nil
        for _, ll in ipairs(continent) do
            local lat, lon = ll[1], ll[2]
            if prev_lon and math.abs(lon - prev_lon) > 180 then
                if #points >= 6 then polygons[#polygons + 1] = points end
                points = {}
            end
            local x, y = M.lat_lon_to_xy(lat, lon, map_x, map_y, map_w, map_h)
            points[#points + 1] = x
            points[#points + 1] = y
            prev_lon = lon
        end
        if #points >= 6 then polygons[#polygons + 1] = points end
    end
    _land_cache[rect_key] = polygons
    return polygons
end

-- Draws the world map background with city markers. Only active_id (the
-- detective's current city) and connection_ids (places actually reachable
-- from here) get a marker — every one of the 30 cities cluttered the map
-- with dots for places nobody could act on from this screen.
-- active_id: currently highlighted city id
-- connection_ids: list of city ids to draw lines to (for travel screen)
-- selected_id: one connection_ids entry to draw brighter/thicker than the
--   rest (the destination currently highlighted in the travel list)
function M.draw(cities_ordered, cities_by_id, map_x, map_y, map_w, map_h,
                visited_ids, active_id, connection_ids, selected_id)
    visited_ids    = visited_ids    or {}
    connection_ids = connection_ids or {}

    local world_map = get_world_map_image()
    if world_map then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(world_map, map_x, map_y, 0,
            map_w / world_map:getWidth(), map_h / world_map:getHeight())
    else
        -- Background ocean — bright enough to actually read against the
        -- near-black game background (the old 0.05/0.10/0.25 was nearly
        -- indistinguishable from it).
        love.graphics.setColor(0.10, 0.22, 0.42, 1)
        love.graphics.rectangle("fill", map_x, map_y, map_w, map_h)

        -- Landmasses — procedural outlines (see data/continents.lua), used
        -- only when the sourced map image above is missing. Clipped to the
        -- map rect since a couple of continent polygons dip slightly
        -- outside their bounding box at this simplification level.
        love.graphics.setScissor(map_x, map_y, map_w, map_h)
        love.graphics.setColor(0.16, 0.32, 0.20, 1)
        for _, points in ipairs(land_polygons(map_x, map_y, map_w, map_h)) do
            -- love.graphics.polygon requires a simple (non-self-intersecting)
            -- polygon to triangulate; these are hand-approximated coastlines,
            -- not verified simple, so a bad one skips instead of crashing the
            -- whole map.
            pcall(love.graphics.polygon, "fill", points)
        end
        love.graphics.setScissor()

        love.graphics.setColor(0.35, 0.50, 0.75, 1)
        love.graphics.rectangle("line", map_x, map_y, map_w, map_h)
    end

    -- Draw connection lines first (below dots). The selected destination's
    -- line is drawn last, brighter and thicker, so it reads as "this one"
    -- against the rest instead of all routes looking identical.
    if active_id and #connection_ids > 0 then
        local ac = cities_by_id[active_id]
        if ac then
            local ax, ay = M.lat_lon_to_xy(ac.lat, ac.lon, map_x, map_y, map_w, map_h)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.45, 0.75, 0.55, 0.55)
            for _, cid in ipairs(connection_ids) do
                if cid ~= selected_id then
                    local cc = cities_by_id[cid]
                    if cc then
                        local cx, cy = M.lat_lon_to_xy(cc.lat, cc.lon,
                                                        map_x, map_y, map_w, map_h)
                        love.graphics.line(ax, ay, cx, cy)
                    end
                end
            end
            if selected_id and cities_by_id[selected_id] then
                local sc = cities_by_id[selected_id]
                local sx, sy = M.lat_lon_to_xy(sc.lat, sc.lon, map_x, map_y, map_w, map_h)
                love.graphics.setLineWidth(2)
                love.graphics.setColor(1.0, 0.85, 0.10, 0.95)
                love.graphics.line(ax, ay, sx, sy)
            end
            love.graphics.setLineWidth(1)
        end
    end

    -- Only the current city and its actual destinations get a marker.
    local shown_ids = {}
    if active_id then shown_ids[#shown_ids + 1] = active_id end
    for _, cid in ipairs(connection_ids) do
        if cid ~= active_id then shown_ids[#shown_ids + 1] = cid end
    end

    for _, cid in ipairs(shown_ids) do
        local city = cities_by_id[cid]
        if city then
            local px, py = M.lat_lon_to_xy(city.lat, city.lon, map_x, map_y, map_w, map_h)
            local r = 3

            if cid == active_id then
                love.graphics.setColor(1.0, 0.85, 0.10, 1)
                r = 5
            elseif cid == selected_id then
                love.graphics.setColor(1.0, 0.85, 0.10, 1)
                r = 4
            elseif visited_ids[cid] then
                love.graphics.setColor(0.35, 0.95, 0.55, 1)
                r = 4
            else
                love.graphics.setColor(0.80, 0.83, 0.92, 1)
            end

            love.graphics.circle("fill", px, py, r)
            love.graphics.setColor(0.05, 0.08, 0.15, 1)
            love.graphics.circle("line", px, py, r)

            -- Name label — flipped to the dot's left once past the map's
            -- horizontal midpoint so it doesn't run off the right edge.
            local label = city_label(city)
            local font  = love.graphics.getFont()
            local lw    = font and font:getWidth(label) or 0
            local lx    = (px > map_x + map_w / 2) and (px - r - 3 - lw) or (px + r + 3)
            local ly    = py - 4

            love.graphics.setColor(0.05, 0.06, 0.10, 0.9)
            love.graphics.print(label, lx + 1, ly + 1)
            love.graphics.setColor(0.95, 0.95, 1.0, 1)
            love.graphics.print(label, lx, ly)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return M
