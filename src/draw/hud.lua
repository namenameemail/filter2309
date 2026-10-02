local brushParamText = {}
brushParamText['lineSize'] = 'size'
brushParamText['lineType'] = 'line'
brushParamText['gradient'] = 'gradient'
brushParamText['curve'] = 'curve'
brushParamText['dash'] = 'dash'
brushParamText['gap'] = 'gap'
brushParamText['harmonics'] = 'harm'
brushParamText['stepHz'] = 'hz'
brushParamText['circleSize'] = 'size'
brushParamText['spectreState'] = 'state'
brushParamText['spectreMode'] = 'mode'

local function drawCurveIcon(x, baseline)
    local font = generalSettings["font"] or 1
    local w = 32 * font
    local h = 14 * font
    ofSetLineWidth(math.max(1, font))
    local prevx, prevy
    for i = 0, 16 do
        local t = i / 16
        local a = fadeAlong(t)
        if a < 0 then a = 0 elseif a > 1 then a = 1 end
        local px = x + t * w
        local py = baseline - a * h
        if prevx then
            ofDrawLine(prevx, prevy, px, py)
        end
        prevx, prevy = px, py
    end
end

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
            ofSetColor(0, 255, 255, 255) 
        else
            ofSetColor(0, 0, 255, 255)
        end

        local string = ''
        if type == 'type' then string = tostring(brushParameters[type]) end
        if type == 'lineSize' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'lineType' then string = tostring(brushParameters[type]) end
        if type == 'gradient' then string = tostring(brushParameters[type]) end
        if type == 'dash' or type == 'gap' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'harmonics' then string = tostring(math.floor(brushParameters[type] or 0)) end
        if type == 'stepHz' then string = tostring(math.floor(brushParameters[type] or 0)) end
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

        if type == 'curve' then
            drawCurveIcon(margin, wH - firstLine)
        else
            title:drawString(string, margin, wH - firstLine)
        end
        if (not activeSelectIndex) then
            smalltext:drawString(brushParamText[type] or type, margin, wH - secLine)
        end

        if type == 'type' then margin = margin + 70 * generalSettings["font"] end
        if type == 'lineSize' then margin = margin + 40 * generalSettings["font"] end
        if type == 'lineType' then margin = margin + 40 * generalSettings["font"] end
        if type == 'gradient' then margin = margin + 80 * generalSettings["font"] end
        if type == 'curve' then margin = margin + 46 * generalSettings["font"] end
        if type == 'dash' then margin = margin + 48 * generalSettings["font"] end
        if type == 'gap' then margin = margin + 42 * generalSettings["font"] end
        if type == 'harmonics' then margin = margin + 40 * generalSettings["font"] end
        if type == 'stepHz' then margin = margin + 55 * generalSettings["font"] end
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
        elseif previewParameter and previewParameter.type == 'setting' and previewParameter.param == type then
            ofSetColor(0, 255, 0, 255)
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
