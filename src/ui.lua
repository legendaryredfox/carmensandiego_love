local utf8 = require("utf8")

local M = {}

M.VIRTUAL_W = 640
M.VIRTUAL_H = 360
M.SCALE     = 2

-- Where the scaled canvas lands inside the actual window — 0 unless
-- M.apply_window_mode letterboxed it (fullscreen at an aspect ratio that
-- isn't an exact multiple of VIRTUAL_W x VIRTUAL_H).
M.offset_x = 0
M.offset_y = 0

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

local FONT_PATH        = "assets/fonts/PressStart2P.ttf"
local LINE_HEIGHT       = 1.45 -- multiplier over the font's natural line height

local function load_font(size)
    local font
    if love.filesystem.getInfo(FONT_PATH) then
        local ok, f = pcall(love.graphics.newFont, FONT_PATH, size)
        if ok then font = f end
    end
    font = font or love.graphics.newFont(size)
    font:setLineHeight(LINE_HEIGHT)
    return font
end

local PANEL_PATH         = "assets/images/ui/panel.png"
local PANEL_PRESSED_PATH = "assets/images/ui/panel_pressed.png"
local NINE_SLICE_BORDER  = 3

-- Sprites are plain greyscale so they can be tinted to any palette color
-- via love.graphics.setColor before drawing (see draw_nine_slice).
local function load_nine_slice(path)
    if not love.filesystem.getInfo(path) then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    if not ok then return nil end
    local iw, ih = img:getDimensions()
    local b      = NINE_SLICE_BORDER
    return {
        image = img, border = b,
        center_w = iw - 2 * b, center_h = ih - 2 * b,
        quads = {
            tl     = love.graphics.newQuad(0,      0,      b,        b,        iw, ih),
            top    = love.graphics.newQuad(b,      0,      iw - 2*b, b,        iw, ih),
            tr     = love.graphics.newQuad(iw - b, 0,      b,        b,        iw, ih),
            left   = love.graphics.newQuad(0,      b,      b,        ih - 2*b, iw, ih),
            center = love.graphics.newQuad(b,      b,      iw - 2*b, ih - 2*b, iw, ih),
            right  = love.graphics.newQuad(iw - b, b,      b,        ih - 2*b, iw, ih),
            bl     = love.graphics.newQuad(0,      ih - b, b,        b,        iw, ih),
            bottom = love.graphics.newQuad(b,      ih - b, iw - 2*b, b,        iw, ih),
            br     = love.graphics.newQuad(iw - b, ih - b, b,        b,        iw, ih),
        },
    }
end

local function draw_nine_slice(sprite, x, y, w, h, color)
    local b   = sprite.border
    local q   = sprite.quads
    local img = sprite.image
    local cw  = math.max(w - 2 * b, 0) / sprite.center_w
    local ch  = math.max(h - 2 * b, 0) / sprite.center_h
    love.graphics.setColor(color)
    love.graphics.draw(img, q.tl, x, y)
    love.graphics.draw(img, q.tr, x + w - b, y)
    love.graphics.draw(img, q.bl, x, y + h - b)
    love.graphics.draw(img, q.br, x + w - b, y + h - b)
    love.graphics.draw(img, q.top,    x + b,     y,         0, cw, 1)
    love.graphics.draw(img, q.bottom, x + b,     y + h - b, 0, cw, 1)
    love.graphics.draw(img, q.left,   x,         y + b,     0, 1,  ch)
    love.graphics.draw(img, q.right,  x + w - b, y + b,     0, 1,  ch)
    love.graphics.draw(img, q.center, x + b,     y + b,     0, cw, ch)
    love.graphics.setColor(1, 1, 1, 1)
end

local panel_sprite, panel_pressed_sprite

function M.init()
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas  = love.graphics.newCanvas(M.VIRTUAL_W, M.VIRTUAL_H)
    font_sm = load_font(8)
    font_md = load_font(10)
    font_lg = load_font(14)
    love.graphics.setFont(font_sm)
    panel_sprite         = load_nine_slice(PANEL_PATH)
    panel_pressed_sprite = load_nine_slice(PANEL_PRESSED_PATH)
end

function M.begin_frame()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(M.C.bg)
    love.graphics.setFont(font_sm)
    love.graphics.setColor(1, 1, 1, 1)
end

function M.end_frame()
    love.graphics.setCanvas()
    -- Fullscreen at an aspect ratio that isn't an exact multiple of
    -- VIRTUAL_W x VIRTUAL_H letterboxes (M.offset_x/y > 0) — clear the
    -- whole window first so those bars don't show last frame's edges.
    love.graphics.clear(M.C.black)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, M.offset_x, M.offset_y, 0, M.SCALE, M.SCALE)
end

-- Applies a window mode and keeps scaling pixel-perfect (integer only, per
-- CLAUDE.md) either way:
--   windowed   — scale is exactly what's asked for, window sized to match.
--   fullscreen — scale is recomputed as the largest integer that still
--                fits the desktop, since a fixed scale could overflow an
--                arbitrary monitor resolution; any leftover space is
--                letterboxed via M.offset_x/y rather than stretched.
function M.apply_window_mode(scale, fullscreen)
    if fullscreen then
        love.window.setFullscreen(true, "desktop")
        local dw, dh = love.window.getDesktopDimensions()
        scale = math.max(1, math.min(
            math.floor(dw / M.VIRTUAL_W), math.floor(dh / M.VIRTUAL_H)))
    else
        love.window.setFullscreen(false)
        love.window.setMode(M.VIRTUAL_W * scale, M.VIRTUAL_H * scale,
            { resizable = false, vsync = 1 })
    end

    M.SCALE = scale
    local win_w, win_h = love.graphics.getDimensions()
    M.offset_x = math.floor((win_w - M.VIRTUAL_W * scale) / 2)
    M.offset_y = math.floor((win_h - M.VIRTUAL_H * scale) / 2)
end

function M.to_virtual(x, y)
    return math.floor((x - M.offset_x) / M.SCALE),
           math.floor((y - M.offset_y) / M.SCALE)
end

-- Draws a filled rectangle with a border, or a Kenney 9-slice panel when
-- the sprite is available (see assets/CREDITS.md).
function M.panel(x, y, w, h)
    if panel_sprite then
        draw_nine_slice(panel_sprite, x, y, w, h, M.C.panel)
        return
    end
    love.graphics.setColor(M.C.panel)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(M.C.border)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Draws a button; selected = highlight color. Returns bounding box for click detection.
function M.button(x, y, w, h, label, selected)
    h = h or 14
    if panel_sprite then
        local sprite = selected and (panel_pressed_sprite or panel_sprite) or panel_sprite
        draw_nine_slice(sprite, x, y, w, h, selected and M.C.highlight or M.C.panel)
    else
        love.graphics.setColor(selected and M.C.highlight or M.C.panel)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(M.C.border)
        love.graphics.rectangle("line", x, y, w, h)
    end
    love.graphics.setColor(selected and M.C.bg or M.C.text)
    love.graphics.setFont(font_sm)
    -- Vertically center regardless of h — a fixed offset only looked right
    -- for the original 14px-tall buttons and drifted to the top on taller
    -- ones. getWrap (not a manual "\n" count) is what actually determines
    -- how many lines printf below will draw — a label that's too long for
    -- w-4 wraps even with no explicit "\n" in it, and undercounting lines
    -- there left wrapped labels sitting off-center / spilling out of short
    -- buttons.
    local line_h = font_sm:getHeight() * font_sm:getLineHeight()
    local _, wrapped = font_sm:getWrap(label, w - 4)
    local lines  = math.max(1, #wrapped)
    local text_y = y + (h - line_h * lines) / 2
    love.graphics.printf(label, x + 2, text_y, w - 4, "center")
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

-- Character count (not byte count) — accented letters and — take several
-- bytes, so #str overcounts for typewriter reveal effects.
function M.utf8_len(str)
    return utf8.len(str) or #str
end

-- First `n` UTF-8 characters of str. Unlike str:sub(1, n), this never
-- splits a multi-byte codepoint in half (which corrupts the string and
-- crashes love.graphics.print with a UTF-8 decoding error).
function M.utf8_sub(str, n)
    if n <= 0 then return "" end
    local len = M.utf8_len(str)
    if n >= len then return str end
    return str:sub(1, utf8.offset(str, n + 1) - 1)
end

-- Full-screen black fade overlay.
function M.fade(alpha)
    if alpha <= 0 then return end
    love.graphics.setColor(0, 0, 0, math.min(alpha, 1))
    love.graphics.rectangle("fill", 0, 0, M.VIRTUAL_W, M.VIRTUAL_H)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Status bar drawn at the bottom of the screen. Left/center/right each get
-- a fixed, non-overlapping zone — three independent full-width printfs
-- used to just draw on top of each other once any string got long enough
-- (see the "Day N," time-string change that triggered this).
function M.status_bar(city_name, days_str, rank_str)
    local y = M.VIRTUAL_H - 18
    love.graphics.setColor(M.C.panel)
    love.graphics.rectangle("fill", 0, y, M.VIRTUAL_W, 18)
    love.graphics.setColor(M.C.border)
    love.graphics.line(0, y, M.VIRTUAL_W, y)
    love.graphics.setFont(font_sm)
    love.graphics.setColor(M.C.text)

    local left_w, center_w = 180, 140
    local right_x, right_w = left_w + center_w, M.VIRTUAL_W - (left_w + center_w) - 6

    love.graphics.printf(city_name, 6, y + 5, left_w - 10, "left")
    love.graphics.printf(rank_str, left_w, y + 5, center_w, "center")
    love.graphics.printf(days_str, right_x, y + 5, right_w, "right")
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

-- Smoothly-trailing scalar: value eases toward target via exponential
-- velocity damping rather than a snap or a fixed-duration lerp, so it
-- keeps moving naturally if the target changes mid-flight (e.g. the
-- player mashes left/right before the cursor settles).
function M.new_smooth(initial)
    return { value = initial, target = initial, vel = 0 }
end

function M.update_smooth(s, dt, damping)
    damping = damping or 0.1
    if s.value == s.target and s.vel == 0 then return end
    s.vel   = damping * s.vel + (1 - damping) * (s.target - s.value) * 35 * dt
    s.value = s.value + s.vel
    if math.abs(s.target - s.value) < 0.05 and math.abs(s.vel) < 0.05 then
        s.value = s.target
        s.vel   = 0
    end
end

return M
