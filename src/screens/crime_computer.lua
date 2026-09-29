local SM     = require("src.state_machine")
local audio  = require("src.audio")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")
local detective_mod = require("src.detective")
local suspect_mod   = require("src.suspect")
local mission_mod   = require("src.mission")

local S = {}

-- sex first, then the same order mission.lua uses to decide which trait
-- clues to generate. sex is deliberately not in mission.TRAIT_ATTRS — the
-- briefing states it up front (see briefing.lua), so it's never clued at a
-- venue, but the player still needs a field to enter what they were told.
local ATTRS = { "sex" }
for _, a in ipairs(mission_mod.TRAIT_ATTRS) do ATTRS[#ATTRS + 1] = a end
local ATTR_VALUES = {
    sex     = { "", "male", "female" },
    hair    = { "", "brown", "blonde", "red", "black" },
    hobby   = { "", "tennis", "mountain_climbing", "croquet", "skydiving", "swimming" },
    vehicle = { "", "convertible", "limousine", "motorcycle", "racecar" },
    feature = { "", "tattoo", "ring", "jewelry", "scar" },
    food    = { "", "mexican", "seafood" },
}

local cursor, status_msg, match_list = 1, "", {}

local function get_filter()
    local f = {}
    for attr, val in pairs(game.detective.gathered_traits) do
        if val and val ~= "" then f[attr] = val end
    end
    return f
end

local function current_idx(attr)
    local val = game.detective.gathered_traits[attr] or ""
    local vals = ATTR_VALUES[attr]
    for i, v in ipairs(vals) do if v == val then return i end end
    return 1
end

local function cycle(attr, dir)
    local vals = ATTR_VALUES[attr]
    local idx  = current_idx(attr)
    idx        = ((idx - 1 + dir) % #vals) + 1
    -- vals[1] is always "" (unset). Storing "" as a real value (instead of
    -- clearing the key) made issue_warrant's raw gathered_traits filter
    -- treat it as "must equal empty string" and reject every suspect —
    -- get_filter() here already had to work around exactly this.
    detective_mod.add_trait(game.detective, attr, idx > 1 and vals[idx] or nil)
end

function S.enter()
    cursor     = 1
    status_msg = ""
    match_list = suspect_mod.filter(game.suspect_pool(), get_filter())
    audio.crossfade("computer")
end

function S.draw()
    ui.title(0, 6, locale.t("crime.title"))

    local row_h = 22
    local col_x = { 10, 160, 380 }

    for i, attr in ipairs(ATTRS) do
        local y   = 30 + (i - 1) * row_h
        local sel = (i == cursor)

        -- Label
        love.graphics.setColor(sel and ui.C.title or ui.C.dim)
        love.graphics.print(locale.t("crime." .. attr):upper(), col_x[1], y)

        -- Value with arrows
        local val     = game.detective.gathered_traits[attr] or ""
        local display = val ~= "" and locale.t("trait." .. attr .. "." .. val) or "----"
        ui.button(col_x[2], y - 2, 200, 16, "< " .. display .. " >", sel)
    end

    -- Match list
    love.graphics.setColor(ui.C.border)
    love.graphics.line(col_x[3] - 5, 28, col_x[3] - 5, 170)
    ui.text(col_x[3], 30, locale.t("crime.suspects_label", { count = #match_list }), ui.C.dim)
    for i, s in ipairs(match_list) do
        ui.text(col_x[3], 30 + i * 14, s.name,
            #match_list == 1 and ui.C.success or ui.C.text)
    end

    -- Buttons
    local by = 180
    ui.button(10, by, 120, 16, locale.t("crime.search"),        cursor == 7)
    ui.button(140, by, 150, 16, locale.t("crime.issue_warrant"), cursor == 8)

    -- Status message
    if status_msg ~= "" then
        ui.text(10, by + 24, status_msg, ui.C.highlight)
    end

    -- Warrant indicator
    if game.detective.warrant_id then
        local ws = suspect_mod.by_id(game.suspect_pool(), game.detective.warrant_id)
        if ws then
            ui.text(10, by + 40,
                locale.t("crime.warrant_label", { name = ws.name }), ui.C.success)
        end
    end

    ui.text(0, ui.VIRTUAL_H - 26,
        locale.t("crime.nav_hint"),
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed(key)
    if key == "up"    then cursor = math.max(1, cursor - 1)
    elseif key == "down"  then cursor = math.min(8, cursor + 1)
    elseif key == "left"  and cursor <= 6 then cycle(ATTRS[cursor], -1)
    elseif key == "right" and cursor <= 6 then cycle(ATTRS[cursor], 1)
    elseif key == "s" or (key == "return" and cursor == 7) then
        match_list = suspect_mod.filter(game.suspect_pool(), get_filter())
        status_msg = #match_list == 0 and locale.t("crime.no_match")
                  or (#match_list > 1  and locale.t("crime.multiple_match"))
                  or ""
    elseif key == "w" or (key == "return" and cursor == 8) then
        local result, match = detective_mod.issue_warrant(game.detective, game.suspect_pool())
        if result == "issued" then
            status_msg = locale.t("crime.warrant_issued", { name = match.name })
        elseif result == "multiple" then
            status_msg = locale.t("crime.multiple_match")
        else
            status_msg = locale.t("crime.no_match")
        end
    elseif key == "escape" then
        SM.switch(require("src.screens.city"))
    end
end

return S
