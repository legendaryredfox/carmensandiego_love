local SM       = require("src.state_machine")
local audio    = require("src.audio")
local locale   = require("src.locale")
local ui       = require("src.ui")
local game     = require("src.game")
local det_mod  = require("src.detective")
local settings = require("src.settings")

local S = {}
local full_text, text_len, revealed, timer, done = "", 0, 0, 0, false

local function build_text()
    local d        = game.detective
    local m        = game.mission
    local l        = locale
    local lang     = l.get_lang()
    local item_name  = l.t(m.stolen_item)
    local city_name  = game.city_name(m.route[1])
    local rank_name  = l.t("rank." .. d.rank)
    local deadline   = det_mod.deadline_str(d, lang)
    -- The original's opening announcement states the suspect's sex from
    -- the start (via pronouns) rather than holding it back for the crime
    -- computer — see PLAN.md's "Playtest feedback" item 2.
    local suspect_seen_key = "briefing.suspect_seen_" .. m.thief.sex
    return
        l.t("briefing.title") .. "\n\n" ..
        l.t("briefing.stolen",   { item = item_name, city = city_name }) .. "\n" ..
        l.t(suspect_seen_key) .. "\n\n" ..
        l.t("briefing.deadline", { deadline = deadline }) .. "\n\n" ..
        l.t("briefing.good_luck", { rank = rank_name, name = d.name })
end

function S.enter()
    full_text = build_text()
    text_len  = ui.utf8_len(full_text)
    revealed  = 0
    timer     = 0
    done      = false
    audio.crossfade("briefing")
end

function S.update(dt)
    if done then return end
    timer    = timer + dt
    revealed = math.min(text_len, math.floor(timer * settings.get().typewriter_speed))
    if revealed >= text_len then done = true end
end

function S.draw()
    ui.panel(20, 15, ui.VIRTUAL_W - 40, ui.VIRTUAL_H - 50)
    ui.text(30, 25, ui.utf8_sub(full_text, revealed), ui.C.highlight, "left", ui.VIRTUAL_W - 60)
    if done then
        ui.text(0, ui.VIRTUAL_H - 26,
            locale.t("briefing.press_any_key"), ui.C.dim, "center", ui.VIRTUAL_W)
    end
end

function S.keypressed()
    if not done then revealed = text_len; done = true; return end
    SM.switch(require("src.screens.city_info"))
end

function S.mousepressed() S.keypressed() end

return S
