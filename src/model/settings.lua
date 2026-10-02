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
    
