local M = {}

-- Equirectangular projection: maps lat/lon to canvas x/y.
-- Map area covers full world: lat [-90,90], lon [-180,180].
function M.lat_lon_to_xy(lat, lon, map_x, map_y, map_w, map_h)
    local nx = (lon + 180) / 360
    local ny = (90 - lat) / 180
    return map_x + nx * map_w, map_y + ny * map_h
end

-- Draws a placeholder world map background with city markers.
-- active_id: currently highlighted city id
-- connection_ids: list of city ids to draw lines to (for travel screen)
function M.draw(cities_ordered, cities_by_id, map_x, map_y, map_w, map_h,
                visited_ids, active_id, connection_ids)
    visited_ids    = visited_ids    or {}
    connection_ids = connection_ids or {}

    -- Background ocean
    love.graphics.setColor(0.05, 0.10, 0.25, 1)
    love.graphics.rectangle("fill", map_x, map_y, map_w, map_h)
    love.graphics.setColor(0.15, 0.20, 0.40, 1)
    love.graphics.rectangle("line", map_x, map_y, map_w, map_h)

    -- Draw connection lines first (below dots)
    if active_id and #connection_ids > 0 then
        local ac = cities_by_id[active_id]
        if ac then
            local ax, ay = M.lat_lon_to_xy(ac.lat, ac.lon, map_x, map_y, map_w, map_h)
            love.graphics.setColor(0.30, 0.60, 0.35, 0.6)
            for _, cid in ipairs(connection_ids) do
                local cc = cities_by_id[cid]
                if cc then
                    local cx, cy = M.lat_lon_to_xy(cc.lat, cc.lon,
                                                    map_x, map_y, map_w, map_h)
                    love.graphics.line(ax, ay, cx, cy)
                end
            end
        end
    end

    -- City dots
    for _, city in ipairs(cities_ordered) do
        local px, py = M.lat_lon_to_xy(city.lat, city.lon, map_x, map_y, map_w, map_h)
        local r = 2

        if city.id == active_id then
            love.graphics.setColor(1.0, 0.85, 0.10, 1)
            r = 3
        elseif visited_ids[city.id] then
            love.graphics.setColor(0.25, 0.80, 0.45, 1)
        else
            love.graphics.setColor(0.55, 0.55, 0.65, 1)
        end

        love.graphics.circle("fill", px, py, r)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return M
