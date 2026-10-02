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
            ofSetColor(0, 255, 255, 255) 
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
