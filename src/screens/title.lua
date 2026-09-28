local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")

local title = {}

local blink_timer = 0
local blink_visible = true

function title.enter()
    blink_timer   = 0
    blink_visible = true
end

function title.update(dt)
    blink_timer = blink_timer + dt
    if blink_timer >= 0.6 then
        blink_timer   = blink_timer - 0.6
        blink_visible = not blink_visible
    end
end

function title.draw()
    local cx = ui.VIRTUAL_W / 2
    local cy = ui.VIRTUAL_H / 2

    love.graphics.setColor(1, 0.85, 0.1, 1)
    love.graphics.printf("DETECTIVE AGENCY", 0, cy - 60, ui.VIRTUAL_W, "center")

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf(locale.t("title.subtitle"), 0, cy - 30, ui.VIRTUAL_W, "center")

    if blink_visible then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(locale.t("title.press_any_key"), 0, cy + 40, ui.VIRTUAL_W, "center")
    end

    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    love.graphics.printf("(C) 2025 - LEGENDARYREDFOX", 0, ui.VIRTUAL_H - 20, ui.VIRTUAL_W, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function title.keypressed(key)
    SM.switch(require("src.screens.language"))
end

function title.mousepressed()
    SM.switch(require("src.screens.language"))
end

return title
