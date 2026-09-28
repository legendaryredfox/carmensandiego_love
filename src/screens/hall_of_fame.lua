local SM     = require("src.state_machine")
local audio  = require("src.audio")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}
local timer = 0

function S.enter()
    timer = 0
    audio.crossfade("success")
end

function S.update(dt) timer = timer + dt end

function S.draw()
    local d = game.detective
    ui.title(0, 40, locale.t("hallfame.title"), ui.C.title)
    ui.panel(50, 90, ui.VIRTUAL_W - 100, 140)
    ui.text(60, 105, locale.t("hallfame.message", {
        leader = game.mission.thief.name,
        rank   = locale.t("rank." .. d.rank),
        name   = d.name,
    }), ui.C.title, "left", ui.VIRTUAL_W - 120)

    if timer > 2 then
        ui.text(0, 260, locale.t("hallfame.continue"), ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed(key)
    if timer < 2 then return end
    if key == "return" or key == "space" or key == "escape" then
        SM.switch(require("src.screens.menu"))
    end
end

function S.mousepressed() S.keypressed("return") end

return S
