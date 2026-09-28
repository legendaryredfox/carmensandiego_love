local SM       = require("src.state_machine")
local ui       = require("src.ui")
local locale   = require("src.locale")
local game     = require("src.game")
local audio    = require("src.audio")
local settings = require("src.settings")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    ui.init()
    settings.set_filesystem(love.filesystem)
    local s = settings.load()
    locale.set(s.lang)
    audio.set_music_volume(s.music_volume)
    audio.set_sfx_volume(s.sfx_volume)
    game.init()
    SM.switch(require("src.screens.title"))
    audio.play_music("title")
end

function love.quit()
    audio.stop_music()
    if game.detective and game.mission then
        game.save()
    end
end

function love.update(dt)
    audio.update()
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
