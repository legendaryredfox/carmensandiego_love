local SM       = require("src.state_machine")
local locale   = require("src.locale")
local ui       = require("src.ui")
local audio    = require("src.audio")
local settings = require("src.settings")

local S = {}
local selected = 1

local VOLUME_STEP = 0.1
local SPEED_STEP  = 10
local SPEED_MIN, SPEED_MAX = 10, 100

local function pct(v) return math.floor(v * 100 + 0.5) .. "%" end

local function rows()
    local s = settings.get()
    return {
        {
            label = locale.t("settings.language"),
            value = locale.t("language." .. s.lang),
            left  = function() end,
            right = function() end,
            toggle = function()
                local next_lang = s.lang == "en" and "pt" or "en"
                settings.set_lang(next_lang)
                locale.set(next_lang)
            end,
        },
        {
            label = locale.t("settings.music_volume"),
            value = pct(s.music_volume),
            left  = function()
                settings.set_music_volume(s.music_volume - VOLUME_STEP)
                audio.set_music_volume(settings.get().music_volume)
            end,
            right = function()
                settings.set_music_volume(s.music_volume + VOLUME_STEP)
                audio.set_music_volume(settings.get().music_volume)
            end,
        },
        {
            label = locale.t("settings.sfx_volume"),
            value = pct(s.sfx_volume),
            left  = function()
                settings.set_sfx_volume(s.sfx_volume - VOLUME_STEP)
                audio.set_sfx_volume(settings.get().sfx_volume)
            end,
            right = function()
                settings.set_sfx_volume(s.sfx_volume + VOLUME_STEP)
                audio.set_sfx_volume(settings.get().sfx_volume)
            end,
        },
        {
            label = locale.t("settings.typewriter_speed"),
            value = tostring(s.typewriter_speed),
            left  = function()
                settings.set_typewriter_speed(
                    math.max(SPEED_MIN, s.typewriter_speed - SPEED_STEP))
            end,
            right = function()
                settings.set_typewriter_speed(
                    math.min(SPEED_MAX, s.typewriter_speed + SPEED_STEP))
            end,
        },
    }
end

function S.enter()
    selected = 1
end

function S.draw()
    ui.title(0, 16, locale.t("settings.title"))

    local list = rows()
    for i, row in ipairs(list) do
        local y   = 60 + (i - 1) * 26
        local sel = (i == selected)
        love.graphics.setColor(sel and ui.C.highlight or ui.C.text)
        love.graphics.print(row.label, 40, y)
        love.graphics.printf(row.value, 0, y, ui.VIRTUAL_W - 40, "right")
    end
    love.graphics.setColor(1, 1, 1, 1)

    ui.text(0, ui.VIRTUAL_H - 26,
        locale.t("settings.nav_hint"),
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    local list = rows()
    if key == "up" then
        selected = selected == 1 and #list or selected - 1
    elseif key == "down" then
        selected = selected == #list and 1 or selected + 1
    elseif key == "left" then
        list[selected].left()
    elseif key == "right" then
        list[selected].right()
    elseif key == "return" then
        if list[selected].toggle then list[selected].toggle() end
    elseif key == "escape" then
        SM.switch(require("src.screens.menu"))
    end
end

return S
