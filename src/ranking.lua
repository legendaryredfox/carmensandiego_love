local M = {}

local MAX_ENTRIES = 10

function M.new()
    return { entries = {} }
end

-- Inserts an entry and keeps the list sorted by score descending, max 10.
-- entry = { name, rank, cases_solved, score, date }
function M.add(ranking, entry)
    table.insert(ranking.entries, entry)
    table.sort(ranking.entries, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        return a.cases_solved > b.cases_solved
    end)
    while #ranking.entries > MAX_ENTRIES do
        table.remove(ranking.entries)
    end
end

function M.from_table(t)
    local r = M.new()
    r.entries = t or {}
    return r
end

function M.to_table(ranking)
    return ranking.entries
end

return M
