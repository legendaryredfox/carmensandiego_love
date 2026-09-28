local detective_mod = require("src.detective")
local mission_mod   = require("src.mission")
local suspect_mod   = require("src.suspect")
local city_mod      = require("src.city")
local ranking_mod   = require("src.ranking")
local save_mod      = require("src.save")

local M = {}

-- Static data — loaded once
M.suspects       = nil
M.leader         = nil
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
    M.leader                         = require("data.leader")
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

-- Returns the organization leader if the detective's next case should be
-- the career-capping final one (see SPEC.md §2.7), else nil.
local function leader_for(detective)
    if detective.cases_solved >= mission_mod.FINAL_CASE_CASES_SOLVED then
        return M.leader
    end
    return nil
end

-- Suspects searchable via the crime computer for the current mission: the
-- regular 10-suspect roster, plus the leader herself once she's the thief,
-- so deduction still narrows down to exactly one match on the final case.
function M.suspect_pool()
    if not (M.mission and M.mission.is_final) then
        return M.suspects
    end
    local pool = { M.leader }
    for _, s in ipairs(M.suspects) do table.insert(pool, s) end
    return pool
end

function M.new_game(name)
    local rng    = make_rng()
    M.detective  = detective_mod.new(name)
    M.mission    = mission_mod.new(M.suspects, M.cities_by_id, M.routes,
                                    M.detective.rank, rng, leader_for(M.detective))
    detective_mod.begin_mission(M.detective, M.mission)
end

function M.next_mission()
    local rng   = make_rng()
    M.mission   = mission_mod.new(M.suspects, M.cities_by_id, M.routes,
                                   M.detective.rank, rng, leader_for(M.detective))
    detective_mod.begin_mission(M.detective, M.mission)
end

-- True when investigating venue_index just found the thief's marked
-- venue at the terminal city — src/screens/venue.lua checks this right
-- after detective_mod.investigate() to jump to the arrest screen instead
-- of showing the usual witness/clue text. Deliberately doesn't check
-- warrant_id here: entering the right venue without a warrant yet still
-- triggers the arrest sequence in the 1985 original (it just fails with
-- a "no warrant" report — see detective_mod.attempt_arrest), same as a
-- wrong warrant. Merely arriving in the city is no longer enough on its
-- own (see PLAN.md's "arrest requires entering correct venue" note).
function M.venue_triggers_arrest(venue_index)
    return mission_mod.is_terminal(M.mission, M.detective.current_city_id)
        and mission_mod.is_hideout_venue(M.mission, venue_index)
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

-- Whether Continue should be offered for this slot: a save must exist and
-- its detective must not have already completed their career (caught the
-- organization leader) — there'd be no case left to resume. The menu used
-- to parse save.read(slot) itself, separately from M.load's own parsing of
-- the exact same payload; kept in one place so they can't disagree about
-- what a given save means.
function M.can_continue(slot)
    slot = slot or M.save_slot
    if not save_mod.exists(slot) then return false end
    local data = save_mod.read(slot)
    return data ~= nil and not (data.detective and data.detective.career_complete)
end

function M.save()
    save_mod.write(M.save_slot,
        detective_mod.serialize(M.detective),
        ranking_mod.to_table(M.ranking),
        M.mission)
end

function M.load(slot)
    slot = slot or M.save_slot
    local data = save_mod.read(slot)
    if not data then return false end
    M.detective = detective_mod.deserialize(data.detective)
    M.ranking   = data.ranking
    if data.mission then
        -- Resume the in-progress case exactly as saved — must not call
        -- detective_mod.begin_mission here, it would reset the current
        -- city, elapsed hours, gathered traits and warrant we just restored.
        M.mission = data.mission
    else
        -- Save predates persisted missions (or was written with none) —
        -- there's nothing to resume, so start a fresh case instead of
        -- leaving game.mission nil (every screen after the menu assumes
        -- it's set).
        M.next_mission()
    end
    return true
end

return M
