function love.conf(t)
    t.identity = nil

    t.window.title = "Aayan's Audio Visualiser cuz Cava won't work on my pc for some reason"
    t.window.width = 800
    t.window.height = 500
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 300

    -- 🔥 THIS replaces the LOVE logo
    t.window.icon = "icon.png"
end