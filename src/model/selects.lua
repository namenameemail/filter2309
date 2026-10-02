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
