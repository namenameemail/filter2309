
webcam = ofVideoGrabber()


W = 1280
H = 960
vW = 320
vH = 240
wW = ofGetWidth()
wH = ofGetHeight()

-- cameraScale = 1
-- fontsScale = 1


selects = ofTable()

selectParametersSettings = ofTable()

brushParameters = ofTable()
brushParametersSettings = ofTable()
sends = ofTable()

generalSettingsSettings = ofTable()
generalSettings = ofTable()
generalSettings["camera"] = 1
generalSettings["font"] = 1

pixels = ofPixels()
fbo = ofFbo()
fbo2 = ofFbo()
fboCam = ofFbo()


freqCursor = 0
freqW = 600
freqH = 300
fboFreq = ofFbo()

dynamicSpectres = ofTable()
dynSpectreIndex = 1
activeDynSpectreIndex = nil
SPCTR_CNT = 6

isCameraDraw = false

buttonsPressed = { false, false, false }
prevPointX = nil
prevPointY = nil

startPointX = nil
startPointY = nil
startButton = nil
prevPointX = nil
prevPointY = nil

selectIndex = 1
activeSelectIndex = nil
SEL_CNT = 6
cursors = ofTable(0, 0, 0, 0, 0, 0)

ZERO_FILTER = createCleanFilter()

title = ofTrueTypeFont()
smalltext = ofTrueTypeFont()

isSetting = false

button1PressedTime = nil 



function drawFreq() 
    local freqsArray = ofArray('freq')
	fboFreq:beginFbo()
    
        -- print(freqsArray[1], (1 - freqsArray[math.floor(1 / freqH * 255 / 2)]) * 255)
        for i = 1, freqH do


            local color = (1 - freqsArray[math.floor(i / freqH * 255 / 2)]) * 255

            ofSetColor(color, color, color, 255)

            ofFill()
            ofDrawRectangle(freqCursor, freqH - i, 1, 1)
        end


    fboFreq:endFbo()

    freqCursor = freqCursor + 1 
    
    if (freqCursor > freqW) then
        freqCursor = 1
    end


end


function pixelColumntToArray(n)
    local rgbData = ofTable()
    if not selects[n] then
        return ZERO_FILTER
    end
    fbo2:readToPixels(pixels)


    local sx = selects[n]["sx"]
    local sy = selects[n]["sy"]
    local w = selects[n]["w"]
    local h = selects[n]["h"]
    local frames = selects[n]["frames"]
    
    local x = sx + cursors[n] / frames * w
    local y = sy
    local width = 1
    local height = h
    
    local count = 0
    
    
    
    for i = 0, 255 do
        local xx = x
        local yy = y + (1 - math.min(1, math.max(0, i * 2 / 255))) * (height -1)
        
        
        table.insert(rgbData, (1 - pixels:getColor(xx, yy).r / 255) * 255)
    
    end
    
    return rgbData
end

function getIntersected(x, y)
    for j = 1, SEL_CNT do
        local i = SEL_CNT + 1 - j
        if selects[i] then
            local isW = math.abs(selects[i]['w']) > 0
            local isH = math.abs(selects[i]['h']) > 0
            local isX = (x > selects[i]['sx'] and x < selects[i]['sx'] + selects[i]['w']) or (x < selects[i]['sx'] and x > selects[i]['sx'] + selects[i]['w'])
            local isY = (y > selects[i]['sy'] and y < selects[i]['sy'] + selects[i]['h']) or (y < selects[i]['sy'] and y > selects[i]['sy'] + selects[i]['h'])
            local ddd = (isW and isX) and (isH and isY)

            -- print(i, isW, isH, isX, isY)
            if ddd then
                return i
            end

        end
    end
end
function getDynSpectreIntersected(x, y)
    
    for j = 1, SPCTR_CNT do
        local i = SPCTR_CNT + 1 - j
        local dynamicSpectre = dynamicSpectres[i]
        if dynamicSpectre then
            local isW = math.abs(dynamicSpectre['w']) > 0
            local isH = math.abs(dynamicSpectre['h']) > 0
            local isX = (x > dynamicSpectre['x'] and x < dynamicSpectre['x'] + dynamicSpectre['w']) or (x < dynamicSpectre['x'] and x > dynamicSpectre['x'] + dynamicSpectre['w'])
            local isY = (y > dynamicSpectre['y'] and y < dynamicSpectre['y'] + dynamicSpectre['h']) or (y < dynamicSpectre['y'] and y > dynamicSpectre['y'] + dynamicSpectre['h'])
            local ddd = (isW and isX) and (isH and isY)

            -- print('----', i, dynamicSpectre['x'], dynamicSpectre['y'], dynamicSpectre['w'], dynamicSpectre['h'])
            -- print(i, isW, isH, isX, isY)
            if ddd then
                return i
            end

        end
    end
end


function resendSelectsParameters(parameter)
    
    local parameterIndex = selectParametersSettings[parameter].index
    
    for index = 1, SEL_CNT do
        if selects[index] and sends[parameter][index] then
            sends[parameter][index]:sendFloat(selects[index][parameterIndex])
        end
    end
    
    
end
    

function clearSelect(index)
    
    
    selects[index] = nil
    
    local firstEmptyIndex = nil
    for i = 1, SEL_CNT do
        -- print(i, selects[i] and selects[i]['w'])
        if (not selects[i] or selects[i]['w'] == 0 and selects[i]['h'] == 0 and firstEmptyIndex == nil) then
            firstEmptyIndex = i
        end
    end
    selectIndex = firstEmptyIndex
    
    
end


function changeBrushParameter(name, delta)
    
    -- print(1, name == 'current', delta, brushParameters['type'])
    if name == 'type' then
        brushParameters['type'] = getNextRadioItem(delta, brushParameters['type'], brushParametersSettings['type'].items)
    end
    
    if name == 'current' then
        -- print(2, getNextRadioItem(delta, brushParameters['current'], brushParametersSettings['current'].items))
        brushParameters['current'] = getNextRadioItem(delta, brushParameters['current'],  getBrushParamsByCurrentType() )
    end
    
    if name == 'lineSize' then
        local min = brushParametersSettings['lineSize'].min
        local max = brushParametersSettings['lineSize'].max
        brushParameters['lineSize'] = math.max(min, math.min(max, brushParameters['lineSize'] + delta))
    end
    if name == 'circleSize' then
        local min = brushParametersSettings['circleSize'].min
        local max = brushParametersSettings['circleSize'].max
        brushParameters['circleSize'] = math.max(min, math.min(max, brushParameters['circleSize'] + delta))
    end
    
    if name == 'color' then
        brushParameters['color'] = getNextRadioItem(delta, brushParameters['color'], brushParametersSettings['color'].items)
    end
    
    if name == 'opacity' then
        local min = brushParametersSettings['opacity'].min
        local max = brushParametersSettings['opacity'].max
        brushParameters['opacity'] = math.max(min, math.min(max, brushParameters['opacity'] + delta))
    end
    if name == 'light' then
        local min = brushParametersSettings['light'].min
        local max = brushParametersSettings['light'].max
        brushParameters['light'] = math.max(min, math.min(max, brushParameters['light'] + delta))
    end
    if name == 'fill' then
        brushParameters['fill'] = getNextRadioItem(delta, brushParameters['fill'], brushParametersSettings['fill'].items)
    end


    
    if name == 'offsetX' then
        local min = brushParametersSettings['offsetX'].min
        local max = brushParametersSettings['offsetX'].max
        local d = delta / math.abs(delta) * brushParameters['scale'] / 10
        brushParameters['offsetX'] = math.max(min, math.min(max, brushParameters['offsetX'] + d))
    end
    if name == 'offsetY' then
        local min = brushParametersSettings['offsetY'].min
        local max = brushParametersSettings['offsetY'].max
        local d = delta / math.abs(delta) * brushParameters['scale'] / 10
        brushParameters['offsetY'] = math.max(min, math.min(max, brushParameters['offsetY'] + d))
    end

    if name == ('offsetX' .. 'wheel') then
        local min = brushParametersSettings['offsetX'].min
        local max = brushParametersSettings['offsetX'].max
        local d = delta / 100 * brushParameters['scale'] -- / math.abs(delta) * brushParameters['scale'] / 10
        brushParameters['offsetX'] = math.max(min, math.min(max, brushParameters['offsetX'] + d))
    end
    if name == ('offsetY' .. 'wheel') then
        local min = brushParametersSettings['offsetY'].min
        local max = brushParametersSettings['offsetY'].max
        local d = delta / 100 * brushParameters['scale'] -- / math.abs(delta) * brushParameters['scale'] / 10
        brushParameters['offsetY'] = math.max(min, math.min(max, brushParameters['offsetY'] + d))
    end

    if name == 'scale' then
        local min = brushParametersSettings['scale'].min
        local max = brushParametersSettings['scale'].max
        local d = delta / math.abs(delta) * brushParameters['scale'] / 10
        brushParameters['scale'] = math.max(min, math.min(max, brushParameters['scale'] + d))
    end
    
    if name == 'spectreState' then
        brushParameters['spectreState'] = getNextRadioItem(delta, brushParameters['spectreState'], brushParametersSettings['spectreState'].items)
        if (brushParameters['spectreState'] == 'on') then
            sends["spectreOn"]:sendFloat(1)
        else
            sends["spectreOn"]:sendFloat(0)
        end

    end
    
    if name == 'spectreMode' then
        brushParameters['spectreMode'] = getNextRadioItem(delta, brushParameters['spectreMode'], brushParametersSettings['spectreMode'].items)
    end
    
    
end


function changeSetting(name, delta)
    
   
    
    if name == 'current' then
        -- print(2, getNextRadioItem(delta, brushParameters['current'], brushParametersSettings['current'].items))
        generalSettings['current'] = getNextRadioItem(delta, generalSettings['current'],  generalSettingsSettings['current'].items )
    end
    
    if name == 'camera' then
        local min = generalSettingsSettings['camera'].min
        local max = generalSettingsSettings['camera'].max
        local d = delta / math.abs(delta) * 0.5
        generalSettings['camera'] = math.max(min, math.min(max, generalSettings['camera'] + d))
    end
    
    if name == 'font' then
        local min = generalSettingsSettings['font'].min
        local max = generalSettingsSettings['font'].max
        local d = delta / math.abs(delta) * 0.5
        generalSettings['font'] = math.max(min, math.min(max, generalSettings['font'] + d))

        title:load(ofTrueTypeFontSettings(fontPath, 12 * generalSettings["font"]))
        smalltext:load(ofTrueTypeFontSettings(fontPath, 10 * generalSettings["font"]))
    end

    
    if name == 'spectrograph' then
        local min = generalSettingsSettings['spectrograph'].min
        local max = generalSettingsSettings['spectrograph'].max
        local d = delta / math.abs(delta) * 1
        generalSettings['spectrograph'] = math.max(min, math.min(max, generalSettings['spectrograph'] + d))
    end
end
    


function changeSelectParameter(target, name, delta)
    
    local index = target
    local parameterIndex = selectParametersSettings[name].index

    if name == 'current' then
        selects[index]['current'] = getNextRadioItem(delta, selects[index]['current'], selectParametersSettings['current'].items)
    end

    if name == 'speed' then
        
        local min = selectParametersSettings['speed'].min
        local max = selectParametersSettings['speed'].max
        
        selects[index][parameterIndex] = math.max(min, math.min(max, selects[index][parameterIndex] + delta))
        local value = selects[index][parameterIndex]
        
        sends[name][target]:sendFloat(value)
    end

    if name == 'volume' then
        local min = selectParametersSettings['volume'].min
        local max = selectParametersSettings['volume'].max
        
        selects[index][parameterIndex] = math.max(min, math.min(max,  selects[index][parameterIndex] + delta * 0.05))
        local value = selects[index][parameterIndex]
        
        sends[name][target]:sendFloat(value)
    end
    
    if name == 'frames' then

        local min = selectParametersSettings["frames"].min
        local max = selectParametersSettings['frames'].max
        
        local d = delta / math.abs(delta);
        selects[index][parameterIndex] = math.max(min, math.min(max,  selects[index][parameterIndex] + d))
        local value = selects[index][parameterIndex]
        -- print('min', max)
        
        sends[name][target]:sendFloat(value)
    end

    if name == 'osc' then


        print('osc', index, parameterIndex,  selects[index][parameterIndex])
        selects[index][parameterIndex] = getNextRadioItem(delta, selects[index][parameterIndex], selectParametersSettings[parameterIndex].items)
        local value = selects[index][parameterIndex]
        
        
        sends[name][target]:sendFloat(value)
    end
    
    
end


function getNextParameter(target, name)

    local delta = 1
    
    local index = target
    local parameterIndex = selectParametersSettings[name].index

    if name == 'current' then
        selects[index]['current'] = getNextRadioItem(delta, selects[index]['current'], selectParametersSettings['current'].items)
    end

    if name == 'speed' then
        
        local min = selectParametersSettings['speed'].min
        local max = selectParametersSettings['speed'].max
        
        selects[index][parameterIndex] = math.max(min, math.min(max, selects[index][parameterIndex] + delta))
        local value = selects[index][parameterIndex]
        
        sends[name][target]:sendFloat(value)
    end

    if name == 'volume' then
        local min = selectParametersSettings['volume'].min
        local max = selectParametersSettings['volume'].max
        
        selects[index][parameterIndex] = math.max(min, math.min(max,  selects[index][parameterIndex] + delta * 0.05))
        local value = selects[index][parameterIndex]
        
        sends[name][target]:sendFloat(value)
    end
    
    if name == 'frames' then

        local min = selectParametersSettings["frames"].min
        local max = selectParametersSettings['frames'].max
        
        local d = delta / math.abs(delta);
        selects[index][parameterIndex] = math.max(min, math.min(max,  selects[index][parameterIndex] + d))
        local value = selects[index][parameterIndex]
        -- print('min', max)
        
        sends[name][target]:sendFloat(value)
    end

    if name == 'osc' then


        print('osc', index, parameterIndex,  selects[index][parameterIndex])
        selects[index][parameterIndex] = getNextRadioItem(delta, selects[index][parameterIndex], selectParametersSettings[parameterIndex].items)
        local value = selects[index][parameterIndex]
        
        
        sends[name][target]:sendFloat(value)
    end
    
    
end




function getBrushParamsByCurrentType() 

    local type = brushParameters['type']

    if type == "camera" then
        return {"type", "opacity", 'light'}
    end

    if type == "line" then
        return {"type", "lineSize", "color", "opacity"}
    end
    if type == 'circle' then
        return {"type", "circleSize", "color", "opacity", 'fill'}
    end
    if type == 'fractal' then
        return {"type", 'scale', "color", 'light', "opacity"} --, 'offsetX', 'offsetY'}
    end
    if type == 'spectre' then
        return {"type", "spectreState", 'spectreMode'} --, 'offsetX', 'offsetY'}
    end
    if type == 'clear' then
        return {"type"}
    end

end

local brushParamText = {}
brushParamText['lineSize'] = 'size'
brushParamText['circleSize'] = 'size'
brushParamText['spectreState'] = 'state'
brushParamText['spectreMode'] = 'mode'

function drawBrushParams() 

    local params = getBrushParamsByCurrentType()

    local margin = 10 * generalSettings["font"]
	local firstLine = 8 * generalSettings["font"]
	local secLine = 25 * generalSettings["font"]

    for i, type in ipairs(params) do

        if not activeSelectIndex and brushParameters["current"] == type then
            ofSetColor(255, 0, 255, 255)
        else
            ofSetColor(255, 0, 0, 255)
        end

        local string = ''
        if type == 'type' then string = tostring(brushParameters[type]) end
        if type == 'lineSize' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'circleSize' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'color' then string = tostring(brushParameters[type]) end
        if type == 'opacity' then string = string.format("%.2f", (brushParameters[type] or 0) / 100) end
        if type == 'light' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'fill' then string = tostring(brushParameters[type]) end
        
        if type == 'offsetX' then string = string.format("%.6f", brushParameters[type] or 0) end
        if type == 'offsetY' then string = string.format("%.6f", brushParameters[type] or 0) end
        if type == 'scale' then string = string.format("%.7f", brushParameters[type] or 0) end
        if type == 'spectreState' then string = tostring(brushParameters[type]) end
        if type == 'spectreMode' then string = tostring(brushParameters[type]) end

        title:drawString(string, margin, wH - firstLine)
        if (not activeSelectIndex) then
            smalltext:drawString(brushParamText[type] or type, margin, wH - secLine)
        end

        if type == 'type' then margin = margin + 70 * generalSettings["font"] end
        if type == 'lineSize' then margin = margin + 40 * generalSettings["font"] end
        if type == 'circleSize' then margin = margin + 40 * generalSettings["font"] end
        if type == 'color' then margin = margin + 50 * generalSettings["font"] end
        if type == 'opacity' then margin = margin + 50 * generalSettings["font"] end
        if type == 'light' then margin = margin + 50 * generalSettings["font"] end
        if type == 'fill' then margin = margin + 50 * generalSettings["font"] end

        if type == 'offsetX' then margin = margin + 80 * generalSettings["font"] end
        if type == 'offsetY' then margin = margin + 80 * generalSettings["font"] end
        if type == 'scale' then margin = margin + 85 * generalSettings["font"] end
        if type == 'spectreState' then margin = margin + 60 * generalSettings["font"] end
        if type == 'spectreMode' then margin = margin + 70 * generalSettings["font"] end
    end

end



function drawGeneralSettings() 


    
    local params = {'font', 'camera'}

    local margin = 10 * generalSettings["font"]
	local firstLine = 8 * generalSettings["font"]
	local secLine = 25 * generalSettings["font"]

    for i, type in ipairs(params) do

        -- print(generalSettings["current"], type)
        if generalSettings["current"] == type then
            ofSetColor(255, 0, 255, 255)
        else
            ofSetColor(255, 0, 0, 255)
        end

        local string = ''
        if type == 'camera' then string = tostring(generalSettings[type] or 0) end
        if type == 'font' then string = tostring(generalSettings[type] or 0) end
        if type == 'spectrograph' then string = tostring(generalSettings[type] or 0) end
        
        title:drawString(string, margin, wH - firstLine)
        smalltext:drawString(type, margin, wH - secLine)

        if type == 'camera' then margin = margin + 50 * generalSettings["font"] end
        if type == 'font' then margin = margin + 50 * generalSettings["font"] end
        if type == 'spectrograph' then margin = margin + 110 * generalSettings["font"] end
        
    end

end

function getActiveSelectIndex(x, y)
    if (buttonsPressed[0]) then
        activeSelectIndex = nil
    elseif (buttonsPressed[2]) then 
        activeSelectIndex = selectIndex
    else
	    activeSelectIndex = (not isSetting) and getIntersected(x, y)
    end
    return activeSelectIndex
end


function getActiveDynSpectreIndex(x, y)
    if (buttonsPressed[0]) then
        activeDynSpectreIndex = dynSpectreIndex
    elseif (buttonsPressed[2]) then 
        activeDynSpectreIndex = nil
    else
	    activeDynSpectreIndex = (not isSetting) and getDynSpectreIntersected(x, y)
    end
    return activeDynSpectreIndex
end


--                             coord scale
function unscaledX(sx)
    return sx / wW * W
end
function unscaledY(sy)
    return sy / wH * H
end
function scaledX(ux)
    return ux / W * wW
end
function scaledY(uy)
    return uy / H * wH
end
