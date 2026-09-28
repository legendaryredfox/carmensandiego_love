local SM     = require("src.state_machine")
local ui     = require("src.ui")
local locale = require("src.locale")
local game   = require("src.game")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    ui.init()
    locale.set("en")
    game.init()
    SM.switch(require("src.screens.title"))
end

function love.quit()
    if game.detective and game.mission then
        game.save()
    end
end

function love.update(dt)
    SM.update(dt)
end

function love.draw()
    ui.begin_frame()
    SM.draw()
    ui.end_frame()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" and love.keyboard.isDown("lctrl") then
        love.event.quit()
        return
    end
    SM.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key)
    SM.keyreleased(key)
end

function love.mousepressed(x, y, button)
    local vx, vy = ui.to_virtual(x, y)
    SM.mousepressed(vx, vy, button)
end

function love.textinput(text)
    SM.textinput(text)
end
