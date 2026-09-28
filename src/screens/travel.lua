local SM       = require("src.state_machine")
local audio    = require("src.audio")
local locale   = require("src.locale")
local ui       = require("src.ui")
local game     = require("src.game")
local city_mod = require("src.city")
local det_mod  = require("src.detective")
local map_mod  = require("src.map")

local S = {}
local destinations, conn_ids, selected = {}, {}, 1

-- map_mod.draw only reads visited_ids, never mutates it — no destination
-- is ever marked "visited" on this screen, so one shared empty table
-- beats a fresh allocation every frame.
local NO_VISITED = {}

local function build_destinations()
    local d     = game.detective
    local conns = game.connections_for(d.current_city_id)
    local list  = {}
    for _, cid in ipairs(conns) do
        local c     = game.cities_by_id[cid]
        local cur   = game.cities_by_id[d.current_city_id]
        local hours = city_mod.travel_hours(cur, c)
        local km    = math.floor(city_mod.distance(cur, c))
        table.insert(list, { id = cid, city = c, hours = hours, km = km })
    end
    table.sort(list, function(a, b) return a.km < b.km end)
    return list
end

function S.enter()
    destinations = build_destinations()
    conn_ids     = {}
    for _, dest in ipairs(destinations) do table.insert(conn_ids, dest.id) end
    selected     = 1
    audio.crossfade("travel")
end

function S.draw()
    local d    = game.detective
    local lang = locale.get_lang()

    -- Mini map (right half) — the selected destination's route is drawn
    -- brighter/thicker than the others so it's clear which one Enter picks.
    local mx, my, mw, mh = 320, 30, 310, 200
    local selected_id = destinations[selected] and destinations[selected].id
    map_mod.draw(game.cities_ordered, game.cities_by_id,
                 mx, my, mw, mh, NO_VISITED, d.current_city_id, conn_ids, selected_id)

    -- Destination list (left half)
    ui.title(0, 6, locale.t("travel.title"))
    ui.text(10, 30, locale.t("travel.select"), ui.C.dim)

    for i, dest in ipairs(destinations) do
        local y   = 44 + (i - 1) * 20
        local sel = (i == selected)
        ui.button(10, y, 290, 18,
            game.city_name(dest.id) ..
            "  " .. dest.km .. "km  " ..
            dest.hours .. "h",
            sel)
    end

    -- Time warning
    local d_hours = det_mod.hours_remaining(d)
    if #destinations > 0 and selected <= #destinations then
        local dest   = destinations[selected]
        local remain = d_hours - dest.hours
        if remain <= 24 then
            ui.text(10, 240, locale.t("travel.low_on_time"), ui.C.danger)
        end
    end

    -- Current time + deadline (not a countdown — matches the city screen's
    -- status bar so "when am I" reads the same everywhere)
    local time_str     = locale.t("status.time",    { time = det_mod.current_time_str(d, lang) })
    local deadline_str = locale.t("status.deadline", { time = det_mod.deadline_str(d, lang) })
    ui.text(10, 256, time_str .. "  " .. deadline_str, ui.C.dim)

    ui.text(0, ui.VIRTUAL_H - 26,
        locale.t("travel.nav_hint"),
        ui.C.dim, "center", ui.VIRTUAL_W)

    ui.status_bar(game.city_name(d.current_city_id),
        deadline_str,
        locale.t("rank." .. d.rank))
end

function S.keypressed(key)
    if key == "up"   then selected = math.max(1, selected - 1)
    elseif key == "down" then selected = math.min(#destinations, selected + 1)
    elseif key == "return" and #destinations > 0 then
        local flying = require("src.screens.flying")
        flying.dest  = destinations[selected]
        SM.switch(flying)
    elseif key == "escape" then
        SM.switch(require("src.screens.city"))
    end
end

return S
