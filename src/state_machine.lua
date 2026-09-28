local ui = require("src.ui")

local FADE_DURATION = 0.25

local SM = { current = nil, fade = nil }

function SM.switch(state, opts)
    opts = opts or {}
    if SM.current and SM.current.exit then
        SM.current.exit()
    end
    SM.current = state
    if state and state.enter then
        state.enter()
    end
    -- A nested SM.switch() called from state.enter() (e.g. auto-arrest)
    -- already owns SM.current/SM.fade by the time we get here — don't clobber it.
    if SM.current == state then
        SM.fade = opts.no_fade and nil or ui.new_fade(opts.fade_duration or FADE_DURATION)
    end
end

function SM.update(dt)
    if SM.fade then ui.update_fade(SM.fade, dt) end
    if SM.current and SM.current.update then
        SM.current.update(dt)
    end
end

function SM.draw()
    if SM.current and SM.current.draw then
        SM.current.draw()
    end
    if SM.fade then ui.fade(SM.fade.alpha) end
end

function SM.keypressed(key, scancode, isrepeat)
    if SM.current and SM.current.keypressed then
        SM.current.keypressed(key, scancode, isrepeat)
    end
end

function SM.keyreleased(key)
    if SM.current and SM.current.keyreleased then
        SM.current.keyreleased(key)
    end
end

function SM.mousepressed(x, y, button)
    if SM.current and SM.current.mousepressed then
        SM.current.mousepressed(x, y, button)
    end
end

function SM.textinput(text)
    if SM.current and SM.current.textinput then
        SM.current.textinput(text)
    end
end

return SM
