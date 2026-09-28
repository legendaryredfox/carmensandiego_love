local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}
local input, blink, cursor = "", 0, true
local MAX_LEN = 20

function S.enter() input = ""; blink = 0; cursor = true end

function S.update(dt)
    blink = blink + dt
    if blink >= 0.5 then blink = blink - 0.5; cursor = not cursor end
end

function S.draw()
    local cx, cy = ui.VIRTUAL_W / 2, ui.VIRTUAL_H / 2
    ui.title(0, cy - 80, locale.t("name.title"))
    ui.text(0, cy - 40, locale.t("name.prompt"), ui.C.text, "center", ui.VIRTUAL_W)
    local bw, bx, by = 260, cx - 130, cy - 10
    ui.panel(bx, by, bw, 20)
    ui.text_md(bx + 6, by + 4, input .. (cursor and "_" or " "), ui.C.highlight)
    ui.text(0, cy + 30, locale.t("name.confirm"), ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.textinput(text) if #input < MAX_LEN then input = input .. text:upper() end end

function S.keypressed(key)
    if key == "backspace" then
        input = input:sub(1, -2)
    elseif key == "return" and #input >= 1 then
        game.new_game(input)
        SM.switch(require("src.screens.briefing"))
    elseif key == "escape" then
        SM.switch(require("src.screens.menu"))
    end
end

return S
