local function lineParams()
	local params = {"type", "lineType", "lineSize", "color", "opacity", "gradient"}
	if brushParameters["gradient"] == "1" then
		params[#params + 1] = "curve"
	end
	params[#params + 1] = "dash"
	params[#params + 1] = "gap"
	params[#params + 1] = "harmonics"
	params[#params + 1] = "stepHz"
	return params
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
    if name == 'lineType' then
        brushParameters['lineType'] = getNextRadioItem(delta, brushParameters['lineType'], brushParametersSettings['lineType'].items)
        local params = getBrushParamsByCurrentType()
        local ok = false
        for i = 1, #params do
            if params[i] == brushParameters['current'] then ok = true end
        end
        if not ok then brushParameters['current'] = 'lineType' end
    end
    if name == 'gradient' then
        brushParameters['gradient'] = getNextRadioItem(delta, brushParameters['gradient'], brushParametersSettings['gradient'].items)
        if brushParameters['gradient'] ~= '1' and brushParameters['current'] == 'curve' then
            brushParameters['current'] = 'gradient'
        end
    end
    if name == 'curve' then
        local min = brushParametersSettings['curve'].min
        local max = brushParametersSettings['curve'].max
        brushParameters['curve'] = math.max(min, math.min(max, (brushParameters['curve'] or 0) + delta))
    end
    if name == 'dash' or name == 'gap' then
        local min = brushParametersSettings[name].min
        local max = brushParametersSettings[name].max
        brushParameters[name] = math.max(min, math.min(max, (brushParameters[name] or 0) + delta))
    end
    if name == 'harmonics' then
        local min = brushParametersSettings['harmonics'].min
        local max = brushParametersSettings['harmonics'].max
        brushParameters['harmonics'] = math.max(min, math.min(max, brushParameters['harmonics'] + delta))
    end
    if name == 'stepHz' then
        local min = brushParametersSettings['stepHz'].min
        local max = brushParametersSettings['stepHz'].max
        brushParameters['stepHz'] = math.max(min, math.min(max, brushParameters['stepHz'] + delta * min))
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

function getBrushParamsByCurrentType() 

    local type = brushParameters['type']

    if type == "camera" then
        return {"type", "opacity", 'light'}
    end

    if type == "line" then
        return lineParams()
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
      return lineParams()
  end
  if type == 'circle' then
      return {"type", "circleSize", "color", "opacity", 'fill'}
  end
  if type == 'fractal' then
    return {"type", 'scale', "color", 'light', "opacity", 'offsetX', 'offsetY'}
  end
  if type == 'spectre' then
      return {"type", "spectreState", 'spectreMode'} 
  end
  if type == 'clear' then
      return {"type"}
  end

end
