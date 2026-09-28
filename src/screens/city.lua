local SM             = require("src.state_machine")
local audio          = require("src.audio")
local locale         = require("src.locale")
local ui             = require("src.ui")
local game           = require("src.game")
local detective_mod  = require("src.detective")
local mission_mod    = require("src.mission")
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

-- Cached venue images, keyed by clue image path (same fallback pattern as
-- src/screens/city_info.lua: missing files just fall back to a placeholder).
local image_cache = {}

local function get_image(path)
    if not path then return nil end
    if image_cache[path] == nil then
        local ok, img = false, nil
        if love.filesystem.getInfo(path) then
            ok, img = pcall(love.graphics.newImage, path)
        end
        image_cache[path] = ok and img or false
    end
    return image_cache[path] or nil
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
    selected   = 1
    local r    = zone_rect(selected)
    selector_x = ui.new_smooth(r.x)
    audio.crossfade("city")
    if check_auto_arrest() then return end
end

function S.update(dt)
    if selected <= 3 then
        selector_x.target = zone_rect(selected).x
        ui.update_smooth(selector_x, dt)
    end
end

local function draw_venue_card(i)
    local r       = zone_rect(i)
    local city_id = game.detective.current_city_id
    local name    = venue_name_mod.name_for(game.mission, city_id, i)
    local clue    = mission_mod.clue_at(game.mission, city_id, i)

    ui.panel(r.x, r.y, r.w, r.h)
    ui.text(r.x + 4, r.y + 6, name, ui.C.text, "center", r.w - 8)

    local img_y = r.y + 24
    local img_h = r.h - 30
    local img   = clue and get_image(clue.image)
    if img then
        local scale = math.min((r.w - 12) / img:getWidth(), img_h / img:getHeight())
        local iw, ih = img:getWidth() * scale, img:getHeight() * scale
        love.graphics.draw(img, r.x + (r.w - iw) / 2, img_y + (img_h - ih) / 2,
            0, scale, scale)
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
