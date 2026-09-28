local SM = { current = nil }

function SM.switch(state)
    if SM.current and SM.current.exit then
        SM.current.exit()
    end
    SM.current = state
    if state and state.enter then
        state.enter()
    end
end

function SM.update(dt)
    if SM.current and SM.current.update then
        SM.current.update(dt)
    end
end

function SM.draw()
    if SM.current and SM.current.draw then
        SM.current.draw()
    end
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
