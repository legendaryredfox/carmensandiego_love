local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")
local detective_mod = require("src.detective")
local mission_mod   = require("src.mission")

local S = {}

-- Zones: 1=Interpol, 2=Venue1, 3=Venue2, 4=Venue3, 5=Airport
local ZONE_LABELS = { "CRIME\nCOMPUTER", "VENUE\n1", "VENUE\n2", "VENUE\n3", "AIRPORT" }
local ZONE_W      = 128
local ZONE_H      = ui and ui.VIRTUAL_H - 40 or 320
local selected    = 1
local fade        = nil

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
    fade     = ui.new_fade(0.35)
    if check_auto_arrest() then return end
end

function S.update(dt)
    if fade then ui.update_fade(fade, dt) end
end

function S.draw()
    local d    = game.detective
    local m    = game.mission
    local on   = mission_mod.on_route(m, d.current_city_id)

    -- Zone areas
    for i = 1, 5 do
        local x   = zone_x(i)
        local sel = (i == selected)
        if sel then
            love.graphics.setColor(ui.C.highlight)
        else
            love.graphics.setColor(ui.C.panel)
        end
        love.graphics.rectangle("fill", x, 30, ZONE_W, ui.VIRTUAL_H - 68)
        love.graphics.setColor(ui.C.border)
        love.graphics.rectangle("line", x, 30, ZONE_W, ui.VIRTUAL_H - 68)

        local label_color = sel and ui.C.bg or ui.C.text
        love.graphics.setColor(label_color)
        love.graphics.printf(ZONE_LABELS[i], x + 4, ui.VIRTUAL_H / 2 - 20, ZONE_W - 8, "center")
    end

    -- Location header
    local city_name = game.city_name(d.current_city_id)
    ui.title(0, 8, city_name)

    -- Clue indicator (show venue status)
    if on then
        love.graphics.setColor(ui.C.success)
        love.graphics.printf("TRAIL IS HOT", 0, 12, ui.VIRTUAL_W, "right")
    end

    -- Status bar
    local days_str = string.format("DAYS: %.1f", detective_mod.days_remaining(d))
    local rank_str = locale.t("rank." .. d.rank)
    ui.status_bar(city_name, days_str, rank_str)

    -- Nav hint
    ui.text(0, ui.VIRTUAL_H - 30, "[ LEFT / RIGHT  ENTER ]",
        ui.C.dim, "center", ui.VIRTUAL_W)

    if fade then ui.fade(fade.alpha) end
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
            selected = i
            S._activate(i)
            return
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
