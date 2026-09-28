local SM             = require("src.state_machine")
local ui             = require("src.ui")
local locale         = require("src.locale")
local game           = require("src.game")
local detective_mod  = require("src.detective")

local S = {}
S.venue_index = 1

local DURATION = 0.6
local elapsed, start_ts, end_ts = 0, 0, 0

function S.enter()
    elapsed  = 0
    start_ts = detective_mod.current_timestamp(game.detective)
    end_ts   = start_ts + detective_mod.INVESTIGATION_HOURS * 3600
end

local function finish()
    local venue_screen = require("src.screens.venue")
    venue_screen.venue_index = S.venue_index
    SM.switch(venue_screen)
end

function S.update(dt)
    elapsed = elapsed + dt
    if elapsed >= DURATION then finish() end
end

function S.draw()
    local lang = locale.get_lang()
    local t    = math.min(1, elapsed / DURATION)
    local ts   = start_ts + math.floor((end_ts - start_ts) * t)

    ui.title(0, ui.VIRTUAL_H / 2 - 20, locale.t("investigating.heading_over"))
    ui.text(0, ui.VIRTUAL_H / 2 + 6, detective_mod.format_datetime(ts, lang),
        ui.C.dim, "center", ui.VIRTUAL_W)
end

function S.keypressed() finish() end
function S.mousepressed() finish() end

return S
