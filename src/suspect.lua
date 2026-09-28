local M = {}

function M.load()
    return require("data.suspects")
end

-- Returns all suspects whose traits match every entry in the filter table.
-- filter = { sex="female", hair="red", ... } — only set keys are checked.
function M.filter(suspects, traits)
    if not traits or next(traits) == nil then
        return suspects
    end

    local result = {}
    for _, s in ipairs(suspects) do
        local match = true
        for attr, value in pairs(traits) do
            -- "" means "not set" (the crime computer's blank dropdown
            -- state) — treat it the same as the key being absent, not as
            -- a literal value no suspect can ever match.
            if value ~= "" and s[attr] ~= value then
                match = false
                break
            end
        end
        if match then
            table.insert(result, s)
        end
    end
    return result
end

-- Picks a random suspect using the provided rng function (returns 1..n).
function M.random(suspects, rng)
    local n = #suspects
    if n == 0 then return nil end
    return suspects[rng(n)]
end

-- Returns suspect by id, or nil.
function M.by_id(suspects, id)
    for _, s in ipairs(suspects) do
        if s.id == id then return s end
    end
    return nil
end

return M
