local M = {}

M.VIRTUAL_W = 640
M.VIRTUAL_H = 360
M.SCALE     = 2

local canvas

function M.init()
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(M.VIRTUAL_W, M.VIRTUAL_H)
end

function M.begin_frame()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
end

function M.end_frame()
    love.graphics.setCanvas()
    love.graphics.draw(canvas, 0, 0, 0, M.SCALE, M.SCALE)
end

-- Converts real window coords to virtual canvas coords.
function M.to_virtual(x, y)
    return math.floor(x / M.SCALE), math.floor(y / M.SCALE)
end

return M
