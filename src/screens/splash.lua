local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")

local splash = {}

-- Blocky pixel heart, drawn with rectangles instead of an image so this
-- screen has no asset (and no licensing question) of its own.
local HEART = {
    "0110110",
    "1111111",
    "1111111",
    "0111110",
    "0011100",
    "0001000",
}
local BLOCK = 8

local DURATION = 2.2
local timer    = 0

function splash.enter()
    timer = 0
end

function splash.update(dt)
    timer = timer + dt
    if timer >= DURATION then
        SM.switch(require("src.screens.title"))
    end
end

function splash.draw()
    local cx = ui.VIRTUAL_W / 2
    local cy = ui.VIRTUAL_H / 2 - 20

    local pulse = 1 + 0.08 * math.sin(timer * 4)
    local w     = #HEART[1] * BLOCK
    local h     = #HEART * BLOCK

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(pulse, pulse)
    love.graphics.setColor(0.90, 0.20, 0.35, 1)
    for row = 1, #HEART do
        for col = 1, #HEART[row] do
            if HEART[row]:sub(col, col) == "1" then
                love.graphics.rectangle("fill",
                    (col - 1) * BLOCK - w / 2, (row - 1) * BLOCK - h / 2,
                    BLOCK, BLOCK)
            end
        end
    end
    love.graphics.pop()

    love.graphics.setColor(0.85, 0.85, 0.90, 1)
    love.graphics.printf(locale.t("splash.tagline"), 0, cy + h / 2 + 20,
        ui.VIRTUAL_W, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function splash.keypressed()
    SM.switch(require("src.screens.title"))
end

function splash.mousepressed()
    SM.switch(require("src.screens.title"))
end

return splash
