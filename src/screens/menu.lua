local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")

local menu = {}

local items = {
    { key = "menu.new_game",    action = function() SM.switch(require("src.screens.name_entry")) end },
    { key = "menu.continue",    action = function() end }, -- TODO: load save
    { key = "menu.leaderboard", action = function() SM.switch(require("src.screens.leaderboard")) end },
    { key = "menu.quit",        action = function() love.event.quit() end },
}

local selected = 1

function menu.enter()
    selected = 1
end

function menu.draw()
    local cx = ui.VIRTUAL_W / 2
    local cy = ui.VIRTUAL_H / 2

    love.graphics.setColor(1, 0.85, 0.1, 1)
    love.graphics.printf("DETECTIVE AGENCY", 0, cy - 80, ui.VIRTUAL_W, "center")

    for i, item in ipairs(items) do
        local label = locale.t(item.key)
        local y     = cy - 20 + (i - 1) * 22
        if i == selected then
            love.graphics.setColor(0, 1, 0.5, 1)
            love.graphics.printf("> " .. label, 0, y, ui.VIRTUAL_W, "center")
        else
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            love.graphics.printf(label, 0, y, ui.VIRTUAL_W, "center")
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function menu.keypressed(key)
    if key == "up" then
        selected = selected == 1 and #items or selected - 1
    elseif key == "down" then
        selected = selected == #items and 1 or selected + 1
    elseif key == "return" then
        items[selected].action()
    end
end

return menu
