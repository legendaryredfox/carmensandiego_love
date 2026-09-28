local SM     = require("src.state_machine")
local audio  = require("src.audio")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}
local timer = 0

function S.enter() timer = 0 end
function S.update(dt) timer = timer + dt end

function S.draw()
    ui.title(0, 60, locale.t("gameover.title"), ui.C.danger)
    ui.panel(60, 110, ui.VIRTUAL_W - 120, 80)
    ui.text(70, 125, locale.t("gameover.time"), ui.C.text)
    if timer > 2 then
        ui.text(0, 220, locale.t("gameover.retry"), ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed(key)
    if timer < 2 then return end
    if key == "return" or key == "escape" then
        SM.switch(require("src.screens.menu"))
    end
end

return S
