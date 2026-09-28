local SM     = require("src.state_machine")
local audio  = require("src.audio")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")
local detective_mod = require("src.detective")
local mission_mod   = require("src.mission")

local S = {}

local ZONE_LABELS = { "CRIME\nCOMPUTER", "VENUE\n1", "VENUE\n2", "VENUE\n3", "AIRPORT" }
local ZONE_W      = 128
local selected    = 1

local function zone_x(i) return (i - 1) * ZONE_W end

local function check_auto_arrest()
    local d = game.detective
    local m = game.mission
    if d.warrant_id and d.current_city_id == mission_mod.thief_city(m) then
        SM.switch(require("src.screens.arrest"))
        return true
    end
    return false
end

function S.enter()
    selected = 1
    audio.crossfade("city")
    if check_auto_arrest() then return end
end

function S.draw()
    local d    = game.detective
    local lang = locale.get_lang()

    -- Zone areas
    for i = 1, 5 do
        local x   = zone_x(i)
        local sel = (i == selected)
        love.graphics.setColor(sel and ui.C.highlight or ui.C.panel)
        love.graphics.rectangle("fill", x, 30, ZONE_W, ui.VIRTUAL_H - 68)
        love.graphics.setColor(ui.C.border)
        love.graphics.rectangle("line", x, 30, ZONE_W, ui.VIRTUAL_H - 68)
        love.graphics.setColor(sel and ui.C.bg or ui.C.text)
        love.graphics.printf(ZONE_LABELS[i], x + 4, ui.VIRTUAL_H / 2 - 20, ZONE_W - 8, "center")
    end

    -- City name header
    ui.title(0, 8, game.city_name(d.current_city_id))

    -- Status bar: city | rank | current time + deadline
    local rank_str     = locale.t("rank." .. d.rank)
    local time_str     = locale.t("status.time",     { time = detective_mod.current_time_str(d, lang) })
    local deadline_str = locale.t("status.deadline",  { time = detective_mod.deadline_str(d, lang) })
    local right_str    = time_str .. "  " .. deadline_str

    local bar_y = ui.VIRTUAL_H - 18
    love.graphics.setColor(ui.C.panel)
    love.graphics.rectangle("fill", 0, bar_y, ui.VIRTUAL_W, 18)
    love.graphics.setColor(ui.C.border)
    love.graphics.line(0, bar_y, ui.VIRTUAL_W, bar_y)
    love.graphics.setColor(ui.C.text)
    love.graphics.print(game.city_name(d.current_city_id), 6, bar_y + 5)
    love.graphics.printf(rank_str, 0, bar_y + 5, ui.VIRTUAL_W, "center")
    love.graphics.printf(right_str, 0, bar_y + 5, ui.VIRTUAL_W - 6, "right")
    love.graphics.setColor(1, 1, 1, 1)

    -- Nav hint
    ui.text(0, ui.VIRTUAL_H - 30, "[ LEFT / RIGHT  ENTER ]",
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    if key == "left"  then selected = math.max(1, selected - 1) end
    if key == "right" then selected = math.min(5, selected + 1) end
    if key == "return" or key == "space" then S._activate(selected) end
end

function S.mousepressed(x, y, btn)
    if btn ~= 1 then return end
    for i = 1, 5 do
        local zx = zone_x(i)
        if x >= zx and x < zx + ZONE_W and y >= 30 and y < ui.VIRTUAL_H - 38 then
            selected = i; S._activate(i); return
        end
    end
end

function S._activate(zone)
    if zone == 1 then
        SM.switch(require("src.screens.crime_computer"))
    elseif zone >= 2 and zone <= 4 then
        local venue_screen = require("src.screens.venue")
        venue_screen.venue_index = zone - 1
        SM.switch(venue_screen)
    elseif zone == 5 then
        SM.switch(require("src.screens.travel"))
    end
end

return S
