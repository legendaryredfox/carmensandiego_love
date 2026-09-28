local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}

local PHOTO_X, PHOTO_Y, PHOTO_W, PHOTO_H = 60, 30, 520, 190

-- Country photos are optional — the game runs fine without them (see
-- assets/CREDITS.md "Clue Images (planned)"). Missing files fall back to a
-- placeholder panel, same pattern as src/audio.lua uses for missing sound.
local photo_cache = {}

local function get_photo(city_id)
    if photo_cache[city_id] == nil then
        local path = "assets/images/cities/" .. city_id .. ".jpg"
        local ok, img = false, nil
        if love.filesystem.getInfo(path) then
            ok, img = pcall(love.graphics.newImage, path)
        end
        photo_cache[city_id] = ok and img or false
    end
    return photo_cache[city_id] or nil
end

function S.enter() end

function S.draw()
    local d        = game.detective
    local city     = game.cities_by_id[d.current_city_id]
    local lang     = locale.get_lang()
    local country  = lang == "pt" and city.country_pt or city.country_en

    ui.title(0, 8, game.city_name(d.current_city_id) .. " — " .. country)

    ui.panel(PHOTO_X, PHOTO_Y, PHOTO_W, PHOTO_H)
    local photo = get_photo(city.id)
    if photo then
        local sx = PHOTO_W / photo:getWidth()
        local sy = PHOTO_H / photo:getHeight()
        love.graphics.draw(photo, PHOTO_X, PHOTO_Y, 0, sx, sy)
    else
        ui.text(PHOTO_X, PHOTO_Y + PHOTO_H / 2 - 4,
            "[ " .. game.city_name(d.current_city_id) .. " ]",
            ui.C.dim, "center", PHOTO_W)
    end

    ui.text(PHOTO_X, PHOTO_Y + PHOTO_H + 10,
        locale.t("city_info." .. city.id), ui.C.text, "left", PHOTO_W)

    ui.text(0, ui.VIRTUAL_H - 20,
        locale.t("city_info.press_enter"), ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    if key == "return" or key == "space" or key == "escape" then
        SM.switch(require("src.screens.city"))
    end
end

function S.mousepressed() S.keypressed("return") end

return S
