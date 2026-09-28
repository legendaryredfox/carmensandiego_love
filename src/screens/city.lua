local SM             = require("src.state_machine")
local audio          = require("src.audio")
local locale         = require("src.locale")
local ui             = require("src.ui")
local game           = require("src.game")
local detective_mod  = require("src.detective")
local venue_name_mod = require("src.venue_name")

local S = {}

local MARGIN    = 10
local GAP       = 10
local VENUE_Y   = 24
local VENUE_W   = (ui.VIRTUAL_W - 2 * MARGIN - 2 * GAP) / 3
local VENUE_H   = 190
local ACTION_Y  = VENUE_Y + VENUE_H + 10
local ACTION_W  = (ui.VIRTUAL_W - 2 * MARGIN - GAP) / 2
local ACTION_H  = 30

local selected   = 1
local selector_x = nil

-- Venue cards show a generic icon for the clue's category, not the clue's
-- own image — the actual clue art/text is a spoiler until the player
-- investigates (see src/screens/venue.lua). One icon per category, shared
-- across every city (see assets/CREDITS.md for source/license).
local VENUE_ICON_PATH = "assets/images/venues/"
local icon_cache = {}

local function get_venue_icon(category)
    if icon_cache[category] == nil then
        local path = VENUE_ICON_PATH .. category .. ".png"
        local ok, img = false, nil
        if love.filesystem.getInfo(path) then
            ok, img = pcall(love.graphics.newImage, path)
        end
        icon_cache[category] = ok and img or false
    end
    return icon_cache[category] or nil
end

-- Zone layout: 1-3 are the venue cards (top row), 4 is the crime computer
-- and 5 is the airport (bottom row).
local function zone_rect(i)
    if i <= 3 then
        return { x = MARGIN + (i - 1) * (VENUE_W + GAP), y = VENUE_Y,
                 w = VENUE_W, h = VENUE_H }
    end
    return { x = MARGIN + (i - 4) * (ACTION_W + GAP), y = ACTION_Y,
             w = ACTION_W, h = ACTION_H }
end

-- Picks whichever zone in `indices` sits closest (horizontally) to x —
-- used so up/down jump to the nearest zone in the other row rather than
-- always landing on the first one.
local function nearest_zone(indices, x)
    local best, best_dist = indices[1], math.huge
    for _, i in ipairs(indices) do
        local r    = zone_rect(i)
        local dist = math.abs((r.x + r.w / 2) - x)
        if dist < best_dist then best_dist = dist; best = i end
    end
    return best
end

function S.enter()
    selected   = 1
    local r    = zone_rect(selected)
    selector_x = ui.new_smooth(r.x)
    audio.crossfade("city")
end

function S.update(dt)
    if selected <= 3 then
        selector_x.target = zone_rect(selected).x
        ui.update_smooth(selector_x, dt)
    end
end

local function draw_venue_card(i)
    local r        = zone_rect(i)
    local city_id  = game.detective.current_city_id
    local name     = venue_name_mod.name_for(game.mission, city_id, i)
    local category = venue_name_mod.category_for(game.mission, city_id, i)

    ui.panel(r.x, r.y, r.w, r.h)
    ui.text(r.x + 4, r.y + 6, name, ui.C.text, "center", r.w - 8)

    local img_y = r.y + 24
    local img_h = r.h - 30
    local img   = get_venue_icon(category)
    if img then
        local scale = math.min((r.w - 12) / img:getWidth(), img_h / img:getHeight())
        local iw, ih = img:getWidth() * scale, img:getHeight() * scale
        love.graphics.setColor(ui.C.border)
        love.graphics.draw(img, r.x + (r.w - iw) / 2, img_y + (img_h - ih) / 2,
            0, scale, scale)
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.setColor(ui.C.border)
        love.graphics.rectangle("line", r.x + 6, img_y, r.w - 12, img_h)
        love.graphics.setColor(1, 1, 1, 1)
        ui.text(r.x + 4, img_y + img_h / 2 - 4, "?", ui.C.dim, "center", r.w - 8)
    end
end

function S.draw()
    local d    = game.detective
    local lang = locale.get_lang()

    for i = 1, 3 do draw_venue_card(i) end

    local computer_r = zone_rect(4)
    ui.button(computer_r.x, computer_r.y, computer_r.w, computer_r.h,
        locale.t("city.interpol"), selected == 4)

    local airport_r = zone_rect(5)
    ui.button(airport_r.x, airport_r.y, airport_r.w, airport_r.h,
        locale.t("city.airport"), selected == 5)

    -- Sliding cursor highlights the venue row only; the action buttons
    -- already show their own selected state.
    if selected <= 3 then
        love.graphics.setColor(ui.C.highlight)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", selector_x.value, VENUE_Y, VENUE_W, VENUE_H)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- City name header
    ui.title(0, 6, game.city_name(d.current_city_id))

    -- Status bar: city | rank | deadline. Current time alone would fit
    -- too, but showing both combined overflowed this 18px-tall bar and
    -- overlapped the centered rank text — same fix as travel.lua's bar.
    local rank_str     = locale.t("rank." .. d.rank)
    local deadline_str = locale.t("status.deadline", { time = detective_mod.deadline_str(d, lang) })
    ui.status_bar(game.city_name(d.current_city_id), deadline_str, rank_str)

    -- Nav hint
    ui.text(0, ui.VIRTUAL_H - 30, locale.t("city.nav_hint"),
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    if key == "left"  then selected = math.max(1, selected - 1) end
    if key == "right" then selected = math.min(5, selected + 1) end
    if key == "down" and selected <= 3 then
        local r = zone_rect(selected)
        selected = nearest_zone({ 4, 5 }, r.x + r.w / 2)
    end
    if key == "up" and selected >= 4 then
        local r = zone_rect(selected)
        selected = nearest_zone({ 1, 2, 3 }, r.x + r.w / 2)
    end
    if key == "return" or key == "space" then S._activate(selected) end
end

function S.mousepressed(x, y, btn)
    if btn ~= 1 then return end
    for i = 1, 5 do
        local r = zone_rect(i)
        if x >= r.x and x < r.x + r.w and y >= r.y and y < r.y + r.h then
            selected = i; S._activate(i); return
        end
    end
end

function S._activate(zone)
    if zone >= 1 and zone <= 3 then
        local investigating = require("src.screens.investigating")
        investigating.venue_index = zone
        SM.switch(investigating)
    elseif zone == 4 then
        SM.switch(require("src.screens.crime_computer"))
    elseif zone == 5 then
        SM.switch(require("src.screens.travel"))
    end
end

return S
