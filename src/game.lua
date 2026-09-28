local detective_mod = require("src.detective")
local mission_mod   = require("src.mission")
local suspect_mod   = require("src.suspect")
local city_mod      = require("src.city")
local ranking_mod   = require("src.ranking")
local save_mod      = require("src.save")

local M = {}

-- Static data — loaded once
M.suspects       = nil
M.cities_by_id   = nil
M.cities_ordered = nil
M.routes         = nil

-- Per-session
M.detective  = nil
M.mission    = nil
M.ranking    = nil
M.save_slot  = 1

function M.init()
    if M.suspects then return end
    M.suspects                       = suspect_mod.load()
    M.cities_by_id, M.cities_ordered = city_mod.load("data/cities.csv")
    M.routes                         = require("data.routes")
    M.ranking                        = ranking_mod.new()
    save_mod.set_filesystem(love.filesystem)
end

local function make_rng()
    local s = os.time() + math.floor(love.timer.getTime() * 1000)
    return function(n)
        s = (s * 1103515245 + 12345) % (2 ^ 31)
        return (s % n) + 1
    end
end

function M.new_game(name)
    local rng    = make_rng()
    M.detective  = detective_mod.new(name)
    M.mission    = mission_mod.new(M.suspects, M.cities_by_id, M.routes,
                                    M.detective.rank, rng)
    detective_mod.begin_mission(M.detective, M.mission)
end

function M.next_mission()
    local rng   = make_rng()
    M.mission   = mission_mod.new(M.suspects, M.cities_by_id, M.routes,
                                   M.detective.rank, rng)
    detective_mod.begin_mission(M.detective, M.mission)
end

function M.current_city()
    return M.cities_by_id[M.detective.current_city_id]
end

function M.current_graph()
    return M.routes[M.mission.graph_index]
end

function M.connections_for(city_id)
    return city_mod.connections(city_id, M.current_graph())
end

function M.city_name(city_id)
    local c = M.cities_by_id[city_id]
    if not c then return city_id end
    local locale = require("src.locale")
    return locale.get_lang() == "pt" and c.name_pt or c.name_en
end

function M.save()
    save_mod.write(M.save_slot,
        detective_mod.serialize(M.detective),
        ranking_mod.to_table(M.ranking))
end

function M.load(slot)
    slot = slot or M.save_slot
    local data = save_mod.read(slot)
    if not data then return false end
    M.detective = detective_mod.deserialize(data.detective)
    M.ranking   = data.ranking
    return true
end

return M
