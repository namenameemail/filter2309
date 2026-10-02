function getNextParameter(target)
    local delta = 1
    
    if target then
        -- Если находимся над выделением, переключаем параметр выделения
        local currentParam = selects[target]['current']
        local paramSettings = selectParametersSettings[currentParam]
        
        if paramSettings then
            -- Используем getNextRadioItem для правильного вычисления следующего значения
            local nextValue = getNextRadioItem(delta, selects[target]['current'], selectParametersSettings['current'].items)
            
            if buttonsPressed[0] and brushParameters['current'] == 'scale' then
              return nil
            else
              return {type = 'select', target = target, param = nextValue}
            end
        end
    else
        -- Если не над выделением, переключаем параметр кисти
        local currentParam = brushParameters['current']
        local paramSettings = brushParametersSettings[currentParam]
        
        print(11)
        if paramSettings then
            
          
          
            -- Используем getNextRadioItem для правильного вычисления следующего значения
            local nextValue = getNextRadioItem(1, brushParameters['current'],  getBrushParamsByCurrentType() )
            
            if buttonsPressed[0] and brushParameters['type'] == 'fractal' then
              return nil
            else
              return {type = 'brush', param = nextValue}
            end
        end
    end
    
    return nil
end
