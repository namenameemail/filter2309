KEY_MOUSE_BUTTONS = { [string.byte('q')] = 0, [string.byte('Q')] = 0, [string.byte('e')] = 2, [string.byte('E')] = 2 }
KEY_MOUSE_SCROLL = { [string.byte('s')] = -1, [string.byte('S')] = -1, [string.byte('w')] = 1, [string.byte('W')] = 1 }
KEY_PARAM_STEP = { [string.byte('a')] = -1, [string.byte('A')] = -1, [string.byte('d')] = 1, [string.byte('D')] = 1 }
keyMouseHeld = {}
keyParamHeld = {}
fractalPan = false

local function paramPreview(delta)
	local target = activeSelectIndex
	if target then
		return { type = 'select', target = target, param = getNextRadioItem(delta, selects[target]['current'], selectParametersSettings['current'].items) }
	end
	if isSetting then
		return { type = 'setting', param = getNextRadioItem(delta, generalSettings['current'], generalSettingsSettings['current'].items) }
	end
	return { type = 'brush', param = getNextRadioItem(delta, brushParameters['current'], getBrushParamsByCurrentType()) }
end

local function applyParamStep(delta)
	local target = activeSelectIndex
	if target then
		changeSelectParameter(target, 'current', delta)
	elseif isSetting then
		changeSetting('current', delta)
	else
		changeBrushParameter('current', delta)
	end
end

local function heldParamStep()
	for key, step in pairs(keyParamHeld) do
		return step
	end
end

function keyMouseEvent(button, scrollY)
	return { x = ofGetMouseX(), y = ofGetMouseY(), button = button, scrollX = 0, scrollY = scrollY }
end

function M.keyReleased(e)
	local button = KEY_MOUSE_BUTTONS[e.key]
	if button and keyMouseHeld[e.key] then
		keyMouseHeld[e.key] = nil
		M.mouseReleased(keyMouseEvent(button, 0))
	end

	if e.key == string.byte('f') or e.key == string.byte('F') then
		fractalPan = false
	end
	if e.key == string.byte('l') or e.key == string.byte('L') then
		legendKeyHeld = false
	end

	local step = keyParamHeld[e.key]
	if step then
		keyParamHeld[e.key] = nil
		applyParamStep(step)
		local still = heldParamStep()
		previewParameter = still and paramPreview(still) or nil
	end
end

function M.keyPressed(e)

	if e.key == string.byte('f') or e.key == string.byte('F') then
		fractalPan = true
		return
	end

	if e.key == string.byte('c') or e.key == string.byte('C') then
		fbo:beginFbo()
		ofClear(255, 255, 255, 255)
		fbo:endFbo()
		return
	end

	if e.key == string.byte('l') or e.key == string.byte('L') then
		if not legendKeyHeld then
			legendKeyHeld = true
			MouseHighlight.legendVisible = not MouseHighlight.legendVisible
		end
		return
	end

	local button = KEY_MOUSE_BUTTONS[e.key]
	if button then
		if not keyMouseHeld[e.key] then
			keyMouseHeld[e.key] = true
			M.mousePressed(keyMouseEvent(button, 0))
		end
		return
	end

	local scrollY = KEY_MOUSE_SCROLL[e.key]
	if scrollY then
		M.mouseScrolled(keyMouseEvent(0, scrollY))
		return
	end

	local target = activeSelectIndex

	if (e.key == OF_KEY_UP or e.key == OF_KEY_DOWN) then 
		local delta = 1

		if e.key == OF_KEY_UP then
			delta = 1
		elseif e.key == OF_KEY_DOWN then
			delta = -1
		end

		if target then
			changeSelectParameter(target, selects[target]['current'], delta)
		else
			if (isSetting) then
				changeSetting(generalSettings['current'], delta)
			else

				changeBrushParameter(brushParameters['current'], delta)

			end
		end
	end

	local paramStep = KEY_PARAM_STEP[e.key]
	if paramStep then
		if not keyParamHeld[e.key] then
			keyParamHeld[e.key] = paramStep
			previewParameter = paramPreview(paramStep)
		end
		return
	end

	if (e.key == OF_KEY_RIGHT or e.key == OF_KEY_LEFT) then

		local d = e.key == OF_KEY_RIGHT and 1 or -1;
		
		if target then
			changeSelectParameter(target, 'current', d)
		else
				if (isSetting) then
					changeSetting('current', d)
				else
					changeBrushParameter('current', d)
				end
			
		end
	end

  
	-- Проверяем, была ли нажата клавиша "P" (заглавная или строчная)
	if (e.key == string.byte('p')) then
      if not buttonsPressed[0] then 
        isSetting = not isSetting
      end
	end


	
end

