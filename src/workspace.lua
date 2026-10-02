
webcam = ofVideoGrabber()
webcamOk = false


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

FILTER_CACHE = ofTable()
for fi = 1, SEL_CNT do
    FILTER_CACHE[fi] = createCleanFilter()
end
filterCursorSeen = ofTable()
for fi = 1, SEL_CNT do
    filterCursorSeen[fi] = -1
end

title = ofTrueTypeFont()
smalltext = ofTrueTypeFont()

isSetting = false

button1PressedTime = nil 

previewParameter = nil

PERF = ofTable()
PERF.on = PERF_REQUESTED == true
PERF.intervalMs = 5000
PERF.lastLogMs = 0
PERF.startMs = nil
PERF.col = ofTable()
PERF.drawN = 0
PERF.drawSumMs = 0
PERF.drawMaxMs = 0
PERF.drawLastMs = 0
PERF.sec = ofTable()
PERF.secOrder = { "frame", "compose", "columns", "present", "spectreBox", "selections", "ui", "highlight", "update", "freq" }

function perfNowMs()
    if ofGetElapsedTimeMicros then
        return ofGetElapsedTimeMicros() / 1000
    end
    return ofGetElapsedTimef() * 1000
end

function perfAdd(name, dt)
    local s = PERF.sec[name]
    if not s then
        s = ofTable()
        s.n = 0
        s.sum = 0
        s.max = 0
        PERF.sec[name] = s
    end
    s.n = s.n + 1
    s.sum = s.sum + dt
    if dt > s.max then
        s.max = dt
    end
end

function perfSection(name)
    if not PERF.on or not PERF._secT then
        return
    end
    local now = perfNowMs()
    perfAdd(name, now - PERF._secT)
    PERF._secT = now
end

function perfSince(name, t0)
    if PERF.on then
        perfAdd(name, perfNowMs() - t0)
    end
end

function perfFlushSections()
    local parts = {}
    for _, name in ipairs(PERF.secOrder) do
        local s = PERF.sec[name]
        if s and s.n > 0 then
            parts[#parts + 1] = string.format("%s=%.2f/%.1f", name, s.sum / s.n, s.max)
            s.n = 0
            s.sum = 0
            s.max = 0
        end
    end
    print("PERF sections avg/max ms: " .. table.concat(parts, " "))
    perfFlushStats()
end

function perfFlushStats()
    local s = perfStatsTake and perfStatsTake()
    if not s then
        return
    end
    local now = perfNowMs()
    local sec = math.max((now - (PERF._statsT or now - PERF.intervalMs)) / 1000, 0.001)
    PERF._statsT = now
    local sr = 44100
    local ticksNeeded = sr / 64 * sec
    local worklet = (s.worklet or 0) == 1
    local outputQueueFrames = worklet and 128 or s.bufferFrames * 2
    local estLatencyMs = (s.ringAvgFrames + outputQueueFrames) / sr * 1000 + math.max(s.baseLatencyMs, 0) + math.max(s.outputLatencyMs, 0)
    local realtimeX = s.dspMs > 0 and s.ticks * 64 / sr * 1000 / s.dspMs or 0
    print(string.format("PERF pd ticksPct=%.0f dsp=%.0fms/s lockWait=%.0fms/s realtimeX=%.2f", s.ticks / ticksNeeded * 100, s.dspMs / sec, s.lockWaitMs / sec, realtimeX))
    print(string.format("PERF out worklet=%d running=%d underruns=%d late=%d gapMax=%.1fms ring min/avg/target=%.0f/%.0f/%d frames base=%.1fms out=%.1fms estLatency=%.0fms", worklet and 1 or 0, s.audioRunning or -1, s.underruns, s.lateCallbacks, s.callbackGapMaxMs, s.ringMinFrames, s.ringAvgFrames, s.ringTargetFrames, s.baseLatencyMs or -1, s.outputLatencyMs or -1, estLatencyMs))
    print(string.format("PERF main pdLocks=%d pdWait=%.1fms/s pdHold=%.1fms/s pdHoldMax=%.2fms luaHold=%.0fms/s luaHoldMax=%.1fms longTasks=%d longTaskMax=%.0fms", s.mainLocks, s.mainLockWaitMs / sec, s.mainLockHoldMs / sec, s.mainLockHoldMaxMs, s.luaHoldMs / sec, s.luaHoldMaxMs, s.longTasks or -1, s.longTaskMaxMs or -1))
end

function perfCol(n)
    local c = PERF.col[n]
    if not c then
        c = ofTable()
        c.n = 0
        c.readSum = 0
        c.readMax = 0
        c.sampleSum = 0
        c.sampleMax = 0
        c.totalSum = 0
        c.totalMax = 0
        c.dtSum = 0
        c.dtMax = 0
        c.lastMs = nil
        c.lastCursor = nil
        c.passes = 0
        c.cursor = 0
        PERF.col[n] = c
    end
    return c
end

function perfBeginDraw()
    if not PERF.on then
        return
    end
    local now = perfNowMs()
    if PERF._lastDrawT0 then
        perfAdd("frame", now - PERF._lastDrawT0)
    end
    PERF._lastDrawT0 = now
    PERF._drawT0 = now
    PERF._secT = now
end

function perfEndDraw()
    if not PERF.on or not PERF._drawT0 then
        return
    end
    local dt = perfNowMs() - PERF._drawT0
    PERF.drawN = PERF.drawN + 1
    PERF.drawSumMs = PERF.drawSumMs + dt
    if dt > PERF.drawMaxMs then
        PERF.drawMaxMs = dt
    end
    PERF.drawLastMs = dt
    PERF._drawT0 = nil
    perfFlush()
end

function perfFlush()
    if not PERF.on then
        return
    end
    local now = perfNowMs()
    if PERF.startMs == nil then
        PERF.startMs = now
    end
    if now - PERF.lastLogMs < PERF.intervalMs then
        return
    end
    PERF.lastLogMs = now

    local mem = collectgarbage("count")
    local fps = 0
    if ofGetFrameRate then
        fps = ofGetFrameRate()
    end
    local drawAvg = 0
    if PERF.drawN > 0 then
        drawAvg = PERF.drawSumMs / PERF.drawN
    end
    local alive = 0
    for i = 1, SEL_CNT do
        if selects[i] then
            alive = alive + 1
        end
    end
    local pxW = -1
    local pxH = -1
    if pixels and pixels.getWidth then
        pxW = pixels:getWidth()
        pxH = pixels:getHeight()
    end
    print(string.format("PERF t=%.1fs fps=%.1f drawAvg=%.1fms drawMax=%.1fms drawLast=%.1fms mem=%.0fKB selects=%d pixels=%dx%d", (now - PERF.startMs) / 1000, fps, drawAvg, PERF.drawMaxMs, PERF.drawLastMs, mem, alive, pxW, pxH))

    for n = 1, SEL_CNT do
        local c = PERF.col[n]
        if c and c.n > 0 then
            print(string.format("PERF col%d calls=%d readAvg=%.1fms readMax=%.1fms sampleAvg=%.1fms sampleMax=%.1fms totalAvg=%.1fms totalMax=%.1fms dtAvg=%.1fms dtMax=%.1fms passes=%d cursor=%.0f", n, c.n, c.readSum / c.n, c.readMax, c.sampleSum / c.n, c.sampleMax, c.totalSum / c.n, c.totalMax, c.dtSum / c.n, c.dtMax, c.passes, c.cursor))
            c.n = 0
            c.readSum = 0
            c.readMax = 0
            c.sampleSum = 0
            c.sampleMax = 0
            c.totalSum = 0
            c.totalMax = 0
            c.dtSum = 0
            c.dtMax = 0
        end
    end

    perfFlushSections()

    PERF.drawN = 0
    PERF.drawSumMs = 0
    PERF.drawMaxMs = 0
end

freqPendingColumns = 0
FREQ_MAX_PENDING_COLUMNS = 4

function drawFreq()
    freqPendingColumns = math.min(freqPendingColumns + 1, FREQ_MAX_PENDING_COLUMNS)
end

function drawPendingFreq()
    if freqPendingColumns == 0 then
        return
    end
    local t0 = perfNowMs()
    local freqs = ofArray('freq'):get(0)
    local lastFreq = #freqs
    fboFreq:beginFbo()
    ofFill()
    for _ = 1, freqPendingColumns do
        for i = 1, freqH do
            local color = (1 - freqs[math.min(math.floor(i / freqH * 255 / 2) + 1, lastFreq)]) * 255
            ofSetColor(color, color, color, 255)
            ofDrawRectangle(freqCursor, freqH - i, 1, 1)
        end
        freqCursor = freqCursor + 1
        if freqCursor > freqW then
            freqCursor = 1
        end
    end
    fboFreq:endFbo()
    freqPendingColumns = 0
    perfSince("freq", t0)
end


function fillFilterCache(n)
    local sel = selects[n]
    if not sel then
        return FILTER_CACHE[n]
    end
    local cursor = cursors[n]
    if filterCursorSeen[n] == cursor then
        return FILTER_CACHE[n]
    end

    local t0 = PERF.on and perfNowMs() or 0
    local sx = sel["sx"]
    local sy = sel["sy"]
    local w = sel["w"]
    local h = sel["h"]
    local frames = sel["frames"]
    local x = math.floor(sx + cursor / frames * w + 0.5)
    local rgbData = FILTER_CACHE[n]
    local readMs = 0
    local sampleMs = 0

    if fboSampleColumnR then
        fboSampleColumnR(fbo2, x, sy, h, rgbData)
        if PERF.on then
            readMs = perfNowMs() - t0
        end
    else
        fbo2:readToPixels(pixels)
        local t1 = PERF.on and perfNowMs() or 0
        readMs = t1 - t0
        local pxW = pixels:getWidth()
        local pxH = pixels:getHeight()
        if x < 0 then
            x = 0
        elseif x >= pxW then
            x = pxW - 1
        end
        for i = 0, 255 do
            local yy = math.floor(sy + (1 - math.min(1, math.max(0, i * 2 / 255))) * (h - 1) + 0.5)
            if yy < 0 then
                yy = 0
            elseif yy >= pxH then
                yy = pxH - 1
            end
            local col = pixels:getColor(pixels:getPixelIndex(x, yy))
            rgbData[i + 1] = 255 - col.r
        end
        if PERF.on then
            sampleMs = perfNowMs() - t1
        end
    end

    filterCursorSeen[n] = cursor

    if PERF.on then
        local t2 = perfNowMs()
        local totalMs = t2 - t0
        local c = perfCol(n)
        if c.lastMs then
            local dt = t2 - c.lastMs
            c.dtSum = c.dtSum + dt
            if dt > c.dtMax then
                c.dtMax = dt
            end
        end
        if c.lastCursor and cursor < c.lastCursor then
            c.passes = c.passes + 1
            local wrapDt = -1
            if c.lastMs then
                wrapDt = t2 - c.lastMs
            end
            print(string.format("PERF WRAP col%d pass=%d cursor=%.0f->%.0f total=%.1fms read=%.1fms sample=%.1fms dt=%.1fms mem=%.0fKB", n, c.passes, c.lastCursor, cursor, totalMs, readMs, sampleMs, wrapDt, collectgarbage("count")))
        end
        c.lastMs = t2
        c.lastCursor = cursor
        c.cursor = cursor
        c.n = c.n + 1
        c.readSum = c.readSum + readMs
        c.sampleSum = c.sampleSum + sampleMs
        c.totalSum = c.totalSum + totalMs
        if readMs > c.readMax then
            c.readMax = readMs
        end
        if sampleMs > c.sampleMax then
            c.sampleMax = sampleMs
        end
        if totalMs > c.totalMax then
            c.totalMax = totalMs
        end
    end

    return rgbData
end

function refreshActiveFilterCaches()
    local any = false
    for n = 1, SEL_CNT do
        if selects[n] and filterCursorSeen[n] ~= cursors[n] then
            any = true
            break
        end
    end
    if not any then
        if PERF.on then
            perfFlush()
        end
        return
    end
    for n = 1, SEL_CNT do
        if selects[n] then
            fillFilterCache(n)
        end
    end
    if PERF.on then
        perfFlush()
    end
end

function pixelColumntToArray(n)
    if not selects[n] then
        return ZERO_FILTER
    end
    return FILTER_CACHE[n]
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


function getVisualBrushParamsByCurrentType() 

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
    if buttonsPressed[0]  then
      return {"type", 'scale', "color", 'light', "opacity", 'offsetX', 'offsetY'}
    else
      return {"type", 'scale', "color", 'light', "opacity"}
    end
  end
  if type == 'spectre' then
      return {"type", "spectreState", 'spectreMode'} 
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

    local params = getVisualBrushParamsByCurrentType()

    local margin = 10 * generalSettings["font"]
    local firstLine = 8 * generalSettings["font"]
    local secLine = 25 * generalSettings["font"]

    for i, type in ipairs(params) do

        if not activeSelectIndex and brushParameters["current"] == type then
            ofSetColor(255, 0, 255, 255)
        elseif previewParameter and previewParameter.type == 'brush' and previewParameter.param == type then
            ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
        elseif type == 'offsetX' or type == 'offsetY' then
            ofSetColor(0, 255, 0, 255) 
        else
            ofSetColor(0, 0, 255, 255)
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
