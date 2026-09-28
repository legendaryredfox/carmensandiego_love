function love.conf(t)
    t.identity        = "carmensandiego_love"
    t.version         = "11.5"
    t.window.title    = "Carmen Sandiego — LÖVE2D Edition"
    t.window.width    = 1280
    t.window.height   = 720
    t.window.resizable = false
    t.window.vsync    = 1

    t.modules.audio   = true
    t.modules.data    = true
    t.modules.event   = true
    t.modules.font    = true
    t.modules.graphics = true
    t.modules.image   = true
    t.modules.keyboard = true
    t.modules.math    = true
    t.modules.mouse   = true
    t.modules.sound   = true
    t.modules.system  = true
    t.modules.timer   = true
    t.modules.window  = true

    t.modules.joystick = false
    t.modules.physics  = false
    t.modules.thread   = false
    t.modules.touch    = false
    t.modules.video    = false
end
