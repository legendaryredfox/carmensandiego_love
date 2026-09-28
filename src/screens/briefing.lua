local SM       = require("src.state_machine")
local audio    = require("src.audio")
local locale   = require("src.locale")
local ui       = require("src.ui")
local game     = require("src.game")
local det_mod  = require("src.detective")
local settings = require("src.settings")

local S = {}
local full_text, revealed, timer, done = "", 0, 0, false

local function build_text()
    local d        = game.detective
    local m        = game.mission
    local l        = locale
    local lang     = l.get_lang()
    local item_name  = l.t(m.stolen_item)
    local city_name  = game.city_name(m.route[1])
    local rank_name  = l.t("rank." .. d.rank)
    local deadline   = det_mod.deadline_str(d, lang)
    return
        l.t("briefing.title") .. "\n\n" ..
        l.t("briefing.stolen",   { item = item_name, city = city_name }) .. "\n" ..
        l.t("briefing.suspect_seen") .. "\n\n" ..
        l.t("briefing.deadline", { deadline = deadline }) .. "\n\n" ..
        l.t("briefing.good_luck", { rank = rank_name, name = d.name })
end

function S.enter()
    full_text = build_text()
    revealed  = 0
    timer     = 0
    done      = false
    audio.crossfade("briefing")
end

function S.update(dt)
    if done then return end
    timer    = timer + dt
    revealed = math.min(#full_text, math.floor(timer * settings.get().typewriter_speed))
    if revealed >= #full_text then done = true end
end

function S.draw()
    ui.panel(20, 15, ui.VIRTUAL_W - 40, ui.VIRTUAL_H - 50)
    ui.text(30, 25, full_text:sub(1, revealed), ui.C.highlight, "left", ui.VIRTUAL_W - 60)
    if done then
        ui.text(0, ui.VIRTUAL_H - 26,
            "[ PRESS ANY KEY ]", ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed()
    if not done then revealed = #full_text; done = true; return end
    SM.switch(require("src.screens.city_info"))
end

function S.mousepressed() S.keypressed() end

return S
