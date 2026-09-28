local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")

local S = {}

function S.draw()
    ui.title(0, 8, locale.t("leaderboard.title"))
    ui.panel(20, 30, ui.VIRTUAL_W - 40, ui.VIRTUAL_H - 70)

    local entries = game.ranking and game.ranking.entries or {}
    if #entries == 0 then
        ui.text(0, ui.VIRTUAL_H / 2 - 10,
            locale.t("leaderboard.empty"), ui.C.dim, "center", ui.VIRTUAL_W)
    else
        local headers = { "#", "NAME", "RANK", "CASES", "SCORE" }
        local cols    = { 30, 60, 200, 330, 400 }
        for i, h in ipairs(headers) do
            ui.text(cols[i], 40, h, ui.C.dim)
        end
        love.graphics.setColor(ui.C.border)
        love.graphics.line(25, 52, ui.VIRTUAL_W - 25, 52)
        for i, e in ipairs(entries) do
            local y   = 56 + (i - 1) * 16
            local col = i == 1 and ui.C.title or ui.C.text
            ui.text(cols[1], y, tostring(i),          col)
            ui.text(cols[2], y, e.name:sub(1, 14),    col)
            ui.text(cols[3], y, locale.t("rank." .. (e.rank or "rookie")):sub(1,14), col)
            ui.text(cols[4], y, tostring(e.cases_solved or 0), col)
            ui.text(cols[5], y, tostring(e.score or 0),        col)
        end
    end
    ui.text(0, ui.VIRTUAL_H - 26,
        locale.t("leaderboard.back"), ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    if key == "escape" or key == "return" then
        SM.switch(require("src.screens.menu"))
    end
end

return S
