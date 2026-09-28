local M = {}

local EARTH_RADIUS_KM = 6371
local CRUISE_SPEED_KMH = 800

local function parse_csv_line(line)
    local fields = {}
    for field in (line .. ";"):gmatch("([^;]*);") do
        table.insert(fields, field)
    end
    return fields
end

-- Loads cities from a semicolon-delimited CSV file.
-- Returns { [id] = city_table, ... } and an ordered list { city_table, ... }.
function M.load(path)
    local by_id = {}
    local ordered = {}
    local header_skipped = false

    for raw_line in io.lines(path) do
        local line = raw_line:gsub("\r", "")
        if not header_skipped then
            header_skipped = true
        else
            local f = parse_csv_line(line)
            if #f >= 8 then
                local city = {
                    id         = f[1],
                    name_en    = f[2],
                    name_pt    = f[3],
                    country_en = f[4],
                    country_pt = f[5],
                    lat        = tonumber(f[6]),
                    lon        = tonumber(f[7]),
                    population = tonumber(f[8]),
                }
                by_id[city.id] = city
                table.insert(ordered, city)
            end
        end
    end

    return by_id, ordered
end

-- Haversine formula — returns distance in km between two lat/lon points.
function M.haversine(lat1, lon1, lat2, lon2)
    local rad = math.pi / 180
    local dlat = (lat2 - lat1) * rad
    local dlon = (lon2 - lon1) * rad
    lat1 = lat1 * rad
    lat2 = lat2 * rad

    local a = math.sin(dlat / 2) ^ 2
            + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ^ 2
    local c = 2 * math.asin(math.sqrt(a))
    return EARTH_RADIUS_KM * c
end

function M.distance(city_a, city_b)
    return M.haversine(city_a.lat, city_a.lon, city_b.lat, city_b.lon)
end

-- Returns flight duration in hours (rounded to nearest 0.5h).
function M.travel_hours(city_a, city_b)
    local km = M.distance(city_a, city_b)
    local raw = km / CRUISE_SPEED_KMH
    return math.floor(raw * 2 + 0.5) / 2
end

-- Returns connected city ids for a city in a given route graph table.
function M.connections(city_id, graph)
    return graph[city_id] or {}
end

return M
