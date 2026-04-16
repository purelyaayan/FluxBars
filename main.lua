local device
local bars, smoothing, targets = {}, {}, {}

local settings = require("settings")

local numBars = settings.bars or 32
local bufferSize = 256

local fftTimer = 0
local fftInterval = 0.03

local barColorHex = settings.barColor
local backgroundColorHex = settings.backgroundColor

local gain = 10
local exponent = 1.4
local bassBoost = 1.5

local smoothUp = 16
local smoothDown = 8

local r,g,b = 1,1,1
local br,bg,bb = 0,0,0

-- UI
local showUI = false
local activeField = "bar"
local inputBar = barColorHex
local inputBg = backgroundColorHex
local inputBars = tostring(numBars)

-- toggles
local rgbMode = false
local borderlessMode = false

local winW, winH = 800,500

function resetBars()
    bars, smoothing, targets = {}, {}, {}
    for i=1,numBars do
        smoothing[i]=0
        targets[i]=0
    end
end

function hexToRGB(hex)
    hex = hex:gsub("#","")
    if #hex == 6 then
        return tonumber("0x"..hex:sub(1,2))/255,
               tonumber("0x"..hex:sub(3,4))/255,
               tonumber("0x"..hex:sub(5,6))/255
    end
    return 1,1,1
end

function applyColors()
    r,g,b = hexToRGB(barColorHex)
    br,bg,bb = hexToRGB(backgroundColorHex)
end

function saveSettings()
    love.filesystem.write("settings.lua",
        'return {\n'..
        'barColor="'..barColorHex..'",\n'..
        'backgroundColor="'..backgroundColorHex..'",\n'..
        'bars='..numBars..'\n}'
    )
end

function applyWindow()
    love.window.setMode(winW, winH, {
        resizable = true,
        borderless = borderlessMode
    })
end

function love.load()
    applyWindow()
    applyColors()

    local devices = love.audio.getRecordingDevices()
    device = devices[1]
    device:start(bufferSize)

    resetBars()
end

function fakeFFT(samples)
    local result = {}
    local chunkSize = math.floor(#samples / numBars)

    for i=1,numBars do
        local sum=0
        for j=1,chunkSize do
            local idx=(i-1)*chunkSize+j
            sum=sum+math.abs(samples[idx] or 0)
        end

        local value=(sum/chunkSize)*gain
        if i < numBars*0.3 then value=value*bassBoost end

        result[i]=value^exponent
    end

    return result
end

function love.update(dt)
    fftTimer = fftTimer + dt

    if fftTimer >= fftInterval then
        fftTimer = fftTimer - fftInterval

        local chunk=device:getData()
        if chunk then
            local raw={}
            for i=0,chunk:getSampleCount()-1 do
                raw[#raw+1]=chunk:getSample(i)
            end

            if #raw>=bufferSize then
                local rawBars=fakeFFT(raw)
                for i=1,numBars do
                    targets[i]=rawBars[i] or 0
                end
            end
        end
    end

    for i=1,numBars do
        local target=targets[i]
        local speed=(target>smoothing[i]) and smoothUp or smoothDown
        local factor=1-math.exp(-speed*dt)

        smoothing[i]=smoothing[i]+(target-smoothing[i])*factor
        bars[i]=smoothing[i]
    end
end

function drawBar(i,x,y,w,h,time)
    if rgbMode then
        local rr = math.sin(time*2+i*0.3)*0.5+0.5
        local gg = math.sin(time*2+i*0.3+2)*0.5+0.5
        local bb2= math.sin(time*2+i*0.3+4)*0.5+0.5
        love.graphics.setColor(rr,gg,bb2)
    else
        love.graphics.setColor(r,g,b)
    end
    love.graphics.rectangle("fill",x,y,w,h)
end

function love.draw()
    local w,h = love.graphics.getWidth(), love.graphics.getHeight()
    winW,winH = w,h

    love.graphics.clear(br,bg,bb)

    local time = love.timer.getTime()

    -- ALWAYS MIRROR MODE
    local halfBars = math.floor(numBars/2)
    local barWidth = (w/2)/halfBars

    for i=1,halfBars do
        local value=bars[i] or 0
        local height=math.min(value*12,h)
        local y=h-height

        local xR = w/2+(i-1)*barWidth
        local xL = w/2-i*barWidth

        drawBar(i,xR,y,barWidth-2,height,time)
        drawBar(i,xL,y,barWidth-2,height,time)
    end

    if showUI then
        love.graphics.setColor(0,0,0,0.85)
        love.graphics.rectangle("fill",50,50,w-100,h-100)

        love.graphics.setColor(1,1,1)
        love.graphics.print("Settings",60,60)

        love.graphics.print("Bar Color:",60,110)
        if activeField=="bar" then love.graphics.setColor(0,1,0) end
        love.graphics.print(inputBar,220,110)

        love.graphics.setColor(1,1,1)
        love.graphics.print("Background:",60,150)
        if activeField=="bg" then love.graphics.setColor(0,1,0) end
        love.graphics.print(inputBg,220,150)

        love.graphics.setColor(1,1,1)
        love.graphics.print("Bars:",60,190)
        if activeField=="bars" then love.graphics.setColor(0,1,0) end
        love.graphics.print(inputBars,220,190)

        love.graphics.setColor(1,1,1)
        love.graphics.print("TAB switch | ENTER apply | CTRL+R RGB | CTRL+B Border",60,230)
    end
end

function love.keypressed(key)
    if key=="s" and love.keyboard.isDown("lctrl") then
        showUI = not showUI
    end

    if key=="r" and love.keyboard.isDown("lctrl") then
        rgbMode = not rgbMode
    end

    if key=="b" and love.keyboard.isDown("lctrl") then
        borderlessMode = not borderlessMode
        applyWindow()
    end

    if showUI then
        if key=="tab" then
            if activeField=="bar" then activeField="bg"
            elseif activeField=="bg" then activeField="bars"
            else activeField="bar" end
        end

        if key=="return" then
            barColorHex=inputBar
            backgroundColorHex=inputBg

            local newBars = tonumber(inputBars)
            if newBars and newBars >= 4 and newBars <= 256 then
                numBars = math.floor(newBars)
                resetBars()
            end

            applyColors()
            saveSettings()
            showUI=false
        end

        if key=="backspace" then
            if activeField=="bar" then
                inputBar=inputBar:sub(1,-2)
            elseif activeField=="bg" then
                inputBg=inputBg:sub(1,-2)
            else
                inputBars=inputBars:sub(1,-2)
            end
        end

        -- PASTE
        if key=="v" and love.keyboard.isDown("lctrl") then
            local paste = love.system.getClipboardText()
            if paste then
                if activeField=="bar" then inputBar=paste
                elseif activeField=="bg" then inputBg=paste
                else inputBars=paste end
            end
        end
    end
end

function love.textinput(t)
    if showUI then
        if activeField=="bar" then
            inputBar = inputBar .. t
        elseif activeField=="bg" then
            inputBg = inputBg .. t
        else
            inputBars = inputBars .. t
        end
    end
end
