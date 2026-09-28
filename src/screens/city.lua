-- TODO: implement city screen
local SM = require("src.state_machine")
local ui = require("src.ui")
local screen = {}
function screen.draw()
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.printf("city (not implemented)", 0, ui.VIRTUAL_H/2, ui.VIRTUAL_W, "center")
    love.graphics.setColor(1,1,1,1)
end
function screen.keypressed(key)
    if key == "escape" then SM.switch(require("src.screens.menu")) end
end
return screen
