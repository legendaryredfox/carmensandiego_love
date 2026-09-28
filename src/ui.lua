local M = {}

M.VIRTUAL_W = 640
M.VIRTUAL_H = 360
M.SCALE     = 2

-- Colors
M.C = {
    bg        = { 0.05, 0.05, 0.15, 1 },
    panel     = { 0.08, 0.08, 0.20, 1 },
    border    = { 0.25, 0.35, 0.55, 1 },
    text      = { 0.85, 0.85, 0.90, 1 },
    highlight = { 0.10, 0.75, 0.45, 1 },
    title     = { 1.00, 0.85, 0.10, 1 },
    dim       = { 0.45, 0.45, 0.50, 1 },
    danger    = { 0.90, 0.25, 0.20, 1 },
    success   = { 0.20, 0.90, 0.40, 1 },
    black     = { 0.00, 0.00, 0.00, 1 },
}

local canvas
local font_sm   -- 8px
local font_md   -- 10px
local font_lg   -- 14px

local FONT_PATH = "assets/fonts/PressStart2P.ttf"

local function load_font(size)
    if love.filesystem.getInfo(FONT_PATH) then
        local ok, font = pcall(love.graphics.newFont, FONT_PATH, size)
        if ok then return font end
    end
    return love.graphics.newFont(size)
end

function M.init()
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas  = love.graphics.newCanvas(M.VIRTUAL_W, M.VIRTUAL_H)
    font_sm = load_font(8)
    font_md = load_font(10)
    font_lg = load_font(14)
    love.graphics.setFont(font_sm)
end

function M.begin_frame()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(M.C.bg)
    love.graphics.setFont(font_sm)
    love.graphics.setColor(1, 1, 1, 1)
end

function M.end_frame()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, M.SCALE, M.SCALE)
end

function M.to_virtual(x, y)
    return math.floor(x / M.SCALE), math.floor(y / M.SCALE)
end

-- Draws a filled rectangle with a border.
function M.panel(x, y, w, h)
    love.graphics.setColor(M.C.panel)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(M.C.border)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draws a button; selected = highlight color. Returns bounding box for click detection.
function M.button(x, y, w, h, label, selected)
    h = h or 14
    if selected then
        love.graphics.setColor(M.C.highlight)
    else
        love.graphics.setColor(M.C.panel)
    end
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(M.C.border)
    love.graphics.rectangle("line", x, y, w, h)
    if selected then
        love.graphics.setColor(M.C.bg)
    else
        love.graphics.setColor(M.C.text)
    end
    love.graphics.setFont(font_sm)
    love.graphics.printf(label, x + 2, y + 3, w - 4, "center")
    love.graphics.setColor(1, 1, 1, 1)
    return { x = x, y = y, w = w, h = h }
end

function M.text(x, y, str, color, align, width)
    love.graphics.setFont(font_sm)
    love.graphics.setColor(color or M.C.text)
    if align and width then
        love.graphics.printf(str, x, y, width, align)
    else
        love.graphics.print(str, x, y)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function M.text_md(x, y, str, color, align, width)
    love.graphics.setFont(font_md)
    love.graphics.setColor(color or M.C.text)
    if align and width then
        love.graphics.printf(str, x, y, width, align)
    else
        love.graphics.print(str, x, y)
    end
    love.graphics.setFont(font_sm)
    love.graphics.setColor(1, 1, 1, 1)
end

function M.title(x, y, str, color)
    love.graphics.setFont(font_lg)
    love.graphics.setColor(color or M.C.title)
    love.graphics.printf(str, x, y, M.VIRTUAL_W - x * 2, "center")
    love.graphics.setFont(font_sm)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Full-screen black fade overlay.
function M.fade(alpha)
    if alpha <= 0 then return end
    love.graphics.setColor(0, 0, 0, math.min(alpha, 1))
    love.graphics.rectangle("fill", 0, 0, M.VIRTUAL_W, M.VIRTUAL_H)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Status bar drawn at the bottom of the screen.
function M.status_bar(city_name, days_str, rank_str)
    local y = M.VIRTUAL_H - 18
    love.graphics.setColor(M.C.panel)
    love.graphics.rectangle("fill", 0, y, M.VIRTUAL_W, 18)
    love.graphics.setColor(M.C.border)
    love.graphics.line(0, y, M.VIRTUAL_W, y)
    love.graphics.setFont(font_sm)
    love.graphics.setColor(M.C.text)
    love.graphics.print(city_name, 6, y + 5)
    love.graphics.printf(rank_str, 0, y + 5, M.VIRTUAL_W, "center")
    love.graphics.printf(days_str, 0, y + 5, M.VIRTUAL_W - 6, "right")
    love.graphics.setColor(1, 1, 1, 1)
end

-- Fade transition helper — returns a transition table.
function M.new_fade(duration, on_done)
    return { timer = 0, duration = duration or 0.4,
             alpha = 0, state = "in", on_done = on_done }
end

function M.update_fade(fade, dt)
    fade.timer = fade.timer + dt
    local t    = math.min(fade.timer / fade.duration, 1)
    if fade.state == "in" then
        fade.alpha = 1 - t
        if t >= 1 then fade.state = "done" end
    elseif fade.state == "out" then
        fade.alpha = t
        if t >= 1 then
            fade.state = "done"
            if fade.on_done then fade.on_done() end
        end
    end
end

function M.start_fade_out(fade, on_done)
    fade.timer   = 0
    fade.state   = "out"
    fade.on_done = on_done or fade.on_done
end

return M
