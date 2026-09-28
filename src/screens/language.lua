local SM       = require("src.state_machine")
local locale   = require("src.locale")
local ui       = require("src.ui")
local settings = require("src.settings")

local lang_screen = {}

local options    = { { lang = "en", label = "ENGLISH" }, { lang = "pt", label = "PORTUGUES" } }
local selected   = 1

function lang_screen.enter()
    selected = 1
end

function lang_screen.draw()
    local cx = ui.VIRTUAL_W / 2
    local cy = ui.VIRTUAL_H / 2

    love.graphics.setColor(1, 0.85, 0.1, 1)
    love.graphics.printf("CHOOSE YOUR LANGUAGE", 0, cy - 60, ui.VIRTUAL_W, "center")

    for i, opt in ipairs(options) do
        if i == selected then
            love.graphics.setColor(0, 1, 0.5, 1)
            love.graphics.printf("> " .. opt.label .. " <", 0, cy - 10 + (i - 1) * 24, ui.VIRTUAL_W, "center")
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.printf(opt.label, 0, cy - 10 + (i - 1) * 24, ui.VIRTUAL_W, "center")
        end
    end

    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.printf("UP/DOWN  ENTER", 0, cy + 60, ui.VIRTUAL_W, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function lang_screen.keypressed(key)
    if key == "up" then
        selected = selected == 1 and #options or selected - 1
    elseif key == "down" then
        selected = selected == #options and 1 or selected + 1
    elseif key == "return" then
        settings.set_lang(options[selected].lang)
        locale.set(options[selected].lang)
        SM.switch(require("src.screens.menu"))
    end
end

return lang_screen
