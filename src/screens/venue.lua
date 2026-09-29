local SM          = require("src.state_machine")
local locale      = require("src.locale")
local ui          = require("src.ui")
local game        = require("src.game")
local detective_mod = require("src.detective")
local clue_pool   = require("src.clue_pool")
local settings    = require("src.settings")
local venue_name_mod = require("src.venue_name")

local S = {}
S.venue_index = 1

local text_full, text_len, revealed, timer, done, clue = "", 0, 0, 0, false, nil

-- Witness portrait — generic pixel-art character art (never a specific
-- real person, see CLAUDE.md's IP rules), picked deterministically per
-- (city, venue) so the same witness doesn't change portrait on redraw.
-- No art exists yet (see assets/CREDITS.md); this falls back to the same
-- bordered "?" placeholder used for missing clue/city images elsewhere.
local WITNESS_VARIANTS = 6
local portrait_cache   = {}

local function get_portrait(n)
    if portrait_cache[n] == nil then
        local path = "assets/images/witnesses/witness_" .. n .. ".png"
        local ok, img = false, nil
        if love.filesystem.getInfo(path) then
            ok, img = pcall(love.graphics.newImage, path)
        end
        portrait_cache[n] = ok and img or false
    end
    return portrait_cache[n] or nil
end

local function witness_variant(city_id, venue_index)
    local s = city_id .. ":" .. venue_index
    local h = 0
    for i = 1, #s do h = (h * 31 + s:byte(i)) % 1000003 end
    return (h % WITNESS_VARIANTS) + 1
end

local PORTRAIT_X, PORTRAIT_Y, PORTRAIT_SIZE = 30, 44, 84
local TEXT_X = PORTRAIT_X + PORTRAIT_SIZE + 12

-- Verb-phrase trait text ("Plays tennis", "Has a tattoo") reads naturally
-- after a pronoun ("He plays tennis"); sex/hair are noun phrases ("Male",
-- "Brown hair") that a leading pronoun would misgrammar, so they keep the
-- plain venue.clue_trait quote instead.
local PRONOUN_SAFE_ATTRS = { hobby = true, vehicle = true, feature = true, food = true }

local function lower_first(s)
    return s:sub(1, 1):lower() .. s:sub(2)
end

-- Only the first byte is touched, so this stays safe on PT roles with
-- accented letters later in the string (Lua's string.upper is ASCII-only
-- and would mangle multi-byte UTF-8 sequences it doesn't recognize) — every
-- authored witness role happens to start with a plain ASCII letter.
local function upper_first(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

-- Speaker label shown above the quote — the clue's own witness role
-- ("SHIPPING BROKER") when one is authored, falling back to a generic
-- label for trait/terminal clues, which aren't tied to a specific witness.
local function witness_label(c)
    if c and c.type == "destination" then
        local w = clue_pool.witness_text(c)
        if w ~= "" then return w end
    end
    return locale.t("venue.unknown_witness")
end

local function clue_to_text(c)
    if not c then return locale.t("venue.nobody_suspicious") end
    if c.type == "terminal" then return locale.t("venue.nobody_suspicious") end
    if c.type == "destination" then
        local hint = clue_pool.clue_text(c)
        if hint == "" then hint = locale.t("clue.generic.destination") end
        return locale.t("venue.clue_destination", { hint = hint })
    end
    if c.type == "trait" then
        local trait = locale.t(c.text_key)
        if PRONOUN_SAFE_ATTRS[c.attr] then
            return locale.t("venue.clue_trait_" .. game.mission.thief.sex,
                { trait = lower_first(trait) })
        end
        return locale.t("venue.clue_trait", { trait = trait })
    end
    return locale.t("venue.nobody_suspicious")
end

function S.enter()
    -- travel() refuses a flight that would cross the deadline and sends the
    -- player to game_over; investigate() had no equivalent guard, letting a
    -- player who's already out of time keep re-entering venues for free
    -- clues forever instead of the case actually ending.
    if detective_mod.hours_remaining(game.detective) <= 0 then
        SM.switch(require("src.screens.game_over"))
        return
    end
    -- Trait clues are NOT auto-recorded into gathered_traits — the player
    -- reads the witness's description here and has to go enter it
    -- themselves on the crime computer, same as any other deduction.
    clue = detective_mod.investigate(game.detective, game.mission, S.venue_index)
    if game.venue_triggers_arrest(S.venue_index) then
        SM.switch(require("src.screens.arrest"))
        return
    end
    -- Speaker label + quote, not reported speech ("A witness says a
    -- shipping broker described the suspect...") — see the WHY comments on
    -- the venue.* locale keys in locales/en.lua/pt.lua.
    text_full = upper_first(witness_label(clue)) .. ":\n\n" ..
        "\"" .. clue_to_text(clue) .. "\""
    text_len  = ui.utf8_len(text_full)
    revealed  = 0
    timer     = 0
    done      = false
end

function S.update(dt)
    if done then return end
    timer    = timer + dt
    revealed = math.min(text_len, math.floor(timer * settings.get().typewriter_speed))
    if revealed >= text_len then done = true end
end

function S.draw()
    local venue_name = venue_name_mod.name_for(game.mission,
        game.detective.current_city_id, S.venue_index)
    ui.title(0, 8, venue_name)
    ui.panel(20, 30, ui.VIRTUAL_W - 40, ui.VIRTUAL_H - 80)

    local variant = witness_variant(game.detective.current_city_id, S.venue_index)
    local portrait = get_portrait(variant)
    if portrait then
        local scale = PORTRAIT_SIZE / math.max(portrait:getWidth(), portrait:getHeight())
        love.graphics.draw(portrait, PORTRAIT_X, PORTRAIT_Y, 0, scale, scale)
    else
        love.graphics.setColor(ui.C.border)
        love.graphics.rectangle("line", PORTRAIT_X, PORTRAIT_Y, PORTRAIT_SIZE, PORTRAIT_SIZE)
        love.graphics.setColor(1, 1, 1, 1)
        ui.text(PORTRAIT_X, PORTRAIT_Y + PORTRAIT_SIZE / 2 - 4, "?",
            ui.C.dim, "center", PORTRAIT_SIZE)
    end

    ui.text(TEXT_X, PORTRAIT_Y, ui.utf8_sub(text_full, revealed), ui.C.highlight,
        "left", ui.VIRTUAL_W - 40 - TEXT_X)

    if done then
        ui.button(ui.VIRTUAL_W / 2 - 50, ui.VIRTUAL_H - 40, 100, 16,
            locale.t("venue.back"), true)
    end
end

function S.keypressed(key)
    if not done then revealed = text_len; done = true; return end
    if key == "return" or key == "escape" or key == "space" then
        SM.switch(require("src.screens.city"))
    end
end

function S.mousepressed() S.keypressed("return") end

return S
