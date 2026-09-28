local SM       = require("src.state_machine")
local audio    = require("src.audio")
local locale   = require("src.locale")
local ui       = require("src.ui")
local game     = require("src.game")
local det_mod  = require("src.detective")
local settings = require("src.settings")

local S = {}
local full_text, text_len, revealed, timer, done = "", 0, 0, 0, false

-- Detective-office backdrop behind the dispatch panel (see assets/CREDITS.md
-- for source/license). Falls back to the plain background color if the
-- file is missing, same pattern as this project's other optional art.
local BG_PATH = "assets/images/ui/briefing_bg.png"
local bg_image, bg_tried = nil, false

local function get_bg_image()
    if not bg_tried then
        bg_tried = true
        if love.filesystem.getInfo(BG_PATH) then
            local ok, img = pcall(love.graphics.newImage, BG_PATH)
            if ok then bg_image = img end
        end
    end
    return bg_image
end

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

-- Panel sits in the upper 2/3 of the canvas, deliberately short of the
-- background image's furniture band (bottom ~140px) so the desk/file
-- cabinet/safe stay visible under the dispatch text instead of the panel
-- covering the whole screen and hiding the backdrop entirely.
local PANEL_X, PANEL_Y, PANEL_W, PANEL_H = 30, 15, ui.VIRTUAL_W - 60, 200

function S.draw()
    local bg = get_bg_image()
    if bg then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(bg, 0, 0)
    else
        love.graphics.setColor(ui.C.bg)
        love.graphics.rectangle("fill", 0, 0, ui.VIRTUAL_W, ui.VIRTUAL_H)
        love.graphics.setColor(1, 1, 1, 1)
    end

    ui.panel(PANEL_X, PANEL_Y, PANEL_W, PANEL_H)
    ui.text(PANEL_X + 10, PANEL_Y + 10, ui.utf8_sub(full_text, revealed),
        ui.C.highlight, "left", PANEL_W - 20)
    if done then
        -- Backdrop strip so the hint stays readable over the busy
        -- wood-paneled background instead of just floating on top of it.
        love.graphics.setColor(0, 0, 0, 0.55)
        love.graphics.rectangle("fill", 0, ui.VIRTUAL_H - 32, ui.VIRTUAL_W, 22)
        love.graphics.setColor(1, 1, 1, 1)
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
