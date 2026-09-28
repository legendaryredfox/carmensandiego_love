local SM     = require("src.state_machine")
local locale = require("src.locale")
local ui     = require("src.ui")
local game   = require("src.game")
local save   = require("src.save")

local S = {}
local selected = 1

-- A save whose detective already caught the organization leader has no
-- more mission to continue — Continue must be disabled, new game required.
local function continue_available()
    if not save.exists(1) then return false end
    local data = save.read(1)
    return data ~= nil and not (data.detective and data.detective.career_complete)
end

local function items()
    return {
        { label = locale.t("menu.new_game"),
          action = function() SM.switch(require("src.screens.name_entry")) end },
        { label = locale.t("menu.continue"),
          action = function()
              -- Resume in the field, not the mission intro — the player
              -- already saw this case's briefing and may have made progress.
              if game.load(1) then SM.switch(require("src.screens.city")) end
          end,
          disabled = not continue_available() },
        { label = locale.t("menu.leaderboard"),
          action = function() SM.switch(require("src.screens.leaderboard")) end },
        { label = locale.t("menu.settings"),
          action = function() SM.switch(require("src.screens.settings")) end },
        { label = locale.t("menu.quit"),
          action = function() love.event.quit() end },
    }
end

function S.enter() selected = 1 end

function S.draw()
    local list = items()
    ui.title(0, ui.VIRTUAL_H / 2 - 90, "DETECTIVE AGENCY")
    for i, item in ipairs(list) do
        local y   = ui.VIRTUAL_H / 2 - 30 + (i - 1) * 22
        local sel = (i == selected)
        local col = item.disabled and ui.C.dim or (sel and ui.C.bg or ui.C.text)
        ui.button(ui.VIRTUAL_W / 2 - 90, y, 180, 16, item.label, sel and not item.disabled)
    end
end

function S.keypressed(key)
    local list = items()
    if key == "up"   then
        repeat selected = selected == 1 and #list or selected - 1
        until not list[selected].disabled
    elseif key == "down" then
        repeat selected = selected == #list and 1 or selected + 1
        until not list[selected].disabled
    elseif key == "return" then
        if not list[selected].disabled then list[selected].action() end
    end
end

return S
