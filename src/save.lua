local json    = require("lib.json")
local ranking = require("src.ranking")

local M = {}

local _fs = nil  -- injectable filesystem; defaults to love.filesystem at runtime

function M.set_filesystem(fs)
    _fs = fs
end

local function get_fs()
    if _fs then return _fs end
    if love and love.filesystem then return love.filesystem end
    error("save: no filesystem available — call save.set_filesystem() first")
end

local function slot_path(slot)
    return "save_" .. tostring(slot) .. ".json"
end

-- Persists detective + ranking + the in-progress mission (if any) to a
-- save slot (1–3). mission_data is plain data (strings/tables/booleans
-- only, see src/mission.lua's M.new) so it round-trips through JSON as-is.
function M.write(slot, det_data, ranking_data, mission_data)
    local fs = get_fs()
    local payload = {
        version   = 2,
        detective = det_data,
        ranking   = ranking_data,
        mission   = mission_data,
    }
    fs.write(slot_path(slot), json.encode(payload))
end

-- Loads a save slot. Returns { detective = ..., ranking = ..., mission = ... }
-- or nil. mission is nil for saves written before v2 or with no mission.
function M.read(slot)
    local fs = get_fs()
    if not fs.getInfo(slot_path(slot)) then return nil end
    local ok, contents = pcall(fs.read, slot_path(slot))
    if not ok or not contents then return nil end
    local ok2, data = pcall(json.decode, contents)
    if not ok2 or type(data) ~= "table" then return nil end
    return {
        detective = data.detective,
        ranking   = ranking.from_table(data.ranking),
        mission   = data.mission,
    }
end

function M.exists(slot)
    local fs = get_fs()
    return fs.getInfo(slot_path(slot)) ~= nil
end

function M.delete(slot)
    local fs = get_fs()
    if fs.getInfo(slot_path(slot)) then
        fs.remove(slot_path(slot))
    end
end

return M
