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

