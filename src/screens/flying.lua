local SM             = require("src.state_machine")
local audio          = require("src.audio")
local ui             = require("src.ui")
local locale         = require("src.locale")
local game           = require("src.game")
local detective_mod  = require("src.detective")
local map_mod        = require("src.map")

local S = {}
-- Set by src/screens/travel.lua before switching in:
-- { id = city_id, hours = number, km = number }
S.dest = nil

local DURATION = 1.2
local MAP_X, MAP_Y, MAP_W, MAP_H = 40, 60, ui.VIRTUAL_W - 80, ui.VIRTUAL_H - 130

-- map_mod.draw only reads visited_ids/connection_ids, never mutates them —
-- one shared empty table instead of two fresh allocations every frame.
local NO_IDS = {}

local elapsed, origin_id, start_ts, end_ts = 0, nil, 0, 0
local dest_id_list = {}

function S.enter()
    elapsed      = 0
    origin_id    = game.detective.current_city_id
    dest_id_list = { S.dest.id }
    start_ts     = detective_mod.current_timestamp(game.detective)
    end_ts       = start_ts + S.dest.hours * 3600
    audio.crossfade("travel")
end

local function finish()
    local dest   = S.dest
    local result = detective_mod.travel(game.detective, dest.id, dest.hours)
    if result == "time_expired" then
        SM.switch(require("src.screens.game_over"))
        return
    end

    -- Arriving in the thief's city is no longer enough to arrest on its
    -- own; the detective still has to investigate the right venue there
    -- (see game.venue_triggers_arrest, checked from src/screens/venue.lua).
    SM.switch(require("src.screens.city_info"))
end

function S.update(dt)
    elapsed = elapsed + dt
    if elapsed >= DURATION then finish() end
end

function S.draw()
    -- active_id/connection_ids drive which cities map_mod labels — origin
    -- and the destination being flown to, same as the travel screen only
    -- ever labels the current city and its reachable destinations.
    map_mod.draw(game.cities_ordered, game.cities_by_id,
        MAP_X, MAP_Y, MAP_W, MAP_H, NO_IDS, origin_id, dest_id_list)

    local origin = game.cities_by_id[origin_id]
    local dest   = game.cities_by_id[S.dest.id]
    local ox, oy = map_mod.lat_lon_to_xy(origin.lat, origin.lon, MAP_X, MAP_Y, MAP_W, MAP_H)
    local dx, dy = map_mod.lat_lon_to_xy(dest.lat, dest.lon, MAP_X, MAP_Y, MAP_W, MAP_H)

    love.graphics.setColor(0.30, 0.60, 0.35, 0.6)
    love.graphics.line(ox, oy, dx, dy)

    local t  = math.min(1, elapsed / DURATION)
    local px = ox + (dx - ox) * t
    local py = oy + (dy - oy) * t

    -- Simple triangle "plane" — no sprite dependency, matches this
    -- project's manual-quad animation approach (see PLAN.md).
    local angle = math.atan2(dy - oy, dx - ox)
    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.rotate(angle)
    love.graphics.setColor(ui.C.title)
    love.graphics.polygon("fill", 6, 0, -4, -3, -4, 3)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)

    ui.title(0, 8, locale.t("travel.departing", { city = game.city_name(S.dest.id) }))

    local ts = start_ts + math.floor((end_ts - start_ts) * t)
    ui.text(0, ui.VIRTUAL_H - 26, detective_mod.format_datetime(ts, locale.get_lang()),
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed() finish() end
function S.mousepressed() finish() end

return S
