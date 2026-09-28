local SM          = require("src.state_machine")
local locale      = require("src.locale")
local ui          = require("src.ui")
local game        = require("src.game")
local detective_mod = require("src.detective")
local mission_mod   = require("src.mission")
local clue_pool   = require("src.clue_pool")
local settings    = require("src.settings")

local S = {}
S.venue_index = 1

local text_full, revealed, timer, done, clue = "", 0, 0, false, nil

local function clue_to_text(c)
    if not c then return locale.t("venue.nobody_suspicious") end
    if c.type == "terminal" then return locale.t("venue.nobody_suspicious") end
    if c.type == "destination" then
        local hint = clue_pool.clue_text(c)
        if hint == "" then hint = locale.t("clue.generic.destination") end
        return locale.t("venue.clue_destination", { hint = hint })
    end
    if c.type == "trait" then
        return locale.t("venue.clue_trait",
            { trait = locale.t(c.text_key) })
    end
    return locale.t("venue.nobody_suspicious")
end

function S.enter()
    clue      = detective_mod.investigate(game.detective, game.mission, S.venue_index)
    -- Auto-record trait clues
    if clue and clue.type == "trait" then
        detective_mod.add_trait(game.detective, clue.attr, clue.value)
    end
    text_full = locale.t("venue.witness_says") .. "\n\n" .. clue_to_text(clue)
    revealed  = 0
    timer     = 0
    done      = false
end

function S.update(dt)
    if done then return end
    timer    = timer + dt
    revealed = math.min(#text_full, math.floor(timer * settings.get().typewriter_speed))
    if revealed >= #text_full then done = true end
end

function S.draw()
    local venue_name = "VENUE " .. tostring(S.venue_index)
    ui.title(0, 8, venue_name)
    ui.panel(20, 30, ui.VIRTUAL_W - 40, ui.VIRTUAL_H - 80)
    ui.text(30, 44, text_full:sub(1, revealed), ui.C.highlight, "left", ui.VIRTUAL_W - 60)

    if done then
        ui.button(ui.VIRTUAL_W / 2 - 50, ui.VIRTUAL_H - 40, 100, 16,
            locale.t("venue.back"), true)
    end
end

function S.keypressed(key)
    if not done then revealed = #text_full; done = true; return end
    if key == "return" or key == "escape" or key == "space" then
        SM.switch(require("src.screens.city"))
    end
end

function S.mousepressed() S.keypressed("return") end

return S
