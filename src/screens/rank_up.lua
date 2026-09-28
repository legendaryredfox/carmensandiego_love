local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}
local timer = 0

function S.enter() timer = 0 end
function S.update(dt) timer = timer + dt end

function S.draw()
    local d = game.detective
    ui.title(0, 60, locale.t("rankup.title"), ui.C.success)
    ui.panel(60, 110, ui.VIRTUAL_W - 120, 80)
    ui.text(70, 130,
        locale.t("rankup.message", {
            name = d.name,
            rank = locale.t("rank." .. d.rank)
        }), ui.C.success)
    if timer > 2 then
        ui.text(0, 220, locale.t("rankup.press_enter"), ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed(key)
    if timer < 2 then return end
    if key == "return" or key == "space" then
        SM.switch(require("src.screens.briefing"))
    end
end

return S
