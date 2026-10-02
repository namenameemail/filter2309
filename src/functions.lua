

function printTable(table)
    print(#table)
    for i = 1, #table do
        print(table[i])
    end
end


function createRadioParameterSettings(items, index)
    local settings = ofTable()
    settings["items"] = items
    settings["index"] = index
    return settings
end

function getNextRadioItem(delta, item, items)
    local index = 0
    for i=1, #items do
        if (item == items[i]) then
            index = i
        end
    end
    index = delta > 0 and ((index + 1) % #items) or ((index - 1) % #items)
    index = index == 0 and  #items or index
    return items[index]
end

function createNumberParameterSettings(index, min, max)
    local settings = ofTable()
    settings["min"] = min
    settings["max"] = max
    settings["index"] = index
    return settings
end

function createCleanFilter()
    local rgbData = ofTable()
    for i = 0, 255 do
        table.insert(rgbData, 0)
    end
    return rgbData
end

function createSelectsSends(name)
    local sends = ofTable()
    for i = 1, SEL_CNT do
        sends[i] = ofSend(name..i)
    end
    return sends
end

function createNewSelect(sx, sy)
    local newSelect = ofTable()
    newSelect['sx'] = sx
    newSelect['sy'] = sy
    newSelect['w'] = 0
    newSelect['h'] = 0
    newSelect['current'] = 'speed'
    newSelect['speed'] = 25
    newSelect['frames'] = 200
    newSelect['volume'] = 1
    newSelect['osc'] = 1
    newSelect['isActive'] = 1
    return newSelect
end


function createNewDynSpectre(sx, sy)
    local newSelect = ofTable()
    newSelect['x'] = sx
    newSelect['y'] = sy
    newSelect['w'] = 0
    newSelect['h'] = 0
    return newSelect
end


    
-- draw

function drawString(string)

end