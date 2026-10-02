if type(window) ~= "userdata" then
	window = ofWindow()
end


local canvas = ofCanvas(this)
local clock = ofClock(this, "setup")
local shaderDir = canvas:getDir() .. "/src/shaders/"
local shader = ofShader()
local shaderFMB = ofShader()
local pixels = ofPixels()
local img = ofImage()
fontPath = canvas:getDir() .. "/src/fonts/Arial.ttf"

local function getTimeBasedFilename()
	local seconds = os.time()
	local base6Digits = ""
	local num = seconds
	
	while num > 0 do
		local remainder = num % 6
		base6Digits = tostring(remainder) .. base6Digits
		num = math.floor(num / 6)
	end
	
	local filename = base6Digits:gsub("0", "f"):gsub("1", "i"):gsub("2", "l"):gsub("3", "t"):gsub("4", "e"):gsub("5", "r")
	return filename
end

local lastSaveTime = 0
local saveInterval = 15 -- interval in seconds




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


-- Функция для вычисления предварительного параметра
local function calculatePreviewParameter(x, y)
	local target = getActiveSelectIndex(x, y)
	return getNextParameter(target)
end

local function saveFBO2()
	if ofGetTargetPlatform and ofGetTargetPlatform() == OF_TARGET_EMSCRIPTEN then
		return
	end
	local currentTime = os.time()
	print(currentTime - lastSaveTime, saveInterval)
	if currentTime - lastSaveTime >= saveInterval then
		fbo2:readToPixels(pixels)
		ofSaveImage(pixels, canvas:getDir() .. "/saves/" .. getTimeBasedFilename() .. ".png")
		lastSaveTime = currentTime
	end
end


function printtable(table)
	for k, v in pairs(table) do
		print('-----',k, v)
	end
end



function M.new()
	print("new1", W, H)
	print(getIntersected)
	ofWindow.addListener("setup", this)
	ofWindow.addListener("draw", this)
	ofWindow.addListener("update", this)
	ofWindow.addListener("mouseDragged", this)
	ofWindow.addListener("mouseMoved", this)
    ofWindow.addListener("keyPressed", this) 
	ofWindow.addListener("keyReleased", this)
	ofWindow.addListener("exit", this)
	window:setPosition(30, 100)
	window:setSize(W, H)
	if ofWindow.exists then
		clock:delay(0)
	else
		window:create()
	end
end

function M.free()
	print("free 2")
	window:destroy()
	ofWindow.removeListener("setup", this)
	ofWindow.removeListener("draw", this)
	ofWindow.removeListener("update", this)
	ofWindow.removeListener("exit", this)
	ofWindow.removeListener("mouseDragged", this)
	ofWindow.removeListener("mouseMoved", this)
    ofWindow.removeListener("keyPressed", this) 
	ofWindow.removeListener("keyReleased", this)
end

function M.setup()
	print("setup 12", "fboSampleColumnR", fboSampleColumnR ~= nil) 
	-- ofSetWindowTitle("simple color quad") 
	-- ofBackground(255, 255, 255, 255) 
	-- local platform = ofGetTargetPlatform() 
	-- if platform == OF_TARGET_LINUXARMV6L or platform == OF_TARGET_LINUXARMV7L or platform == OF_TARGET_ANDROID or platform == OF_TARGET_IOS or platform == OF_TARGET_EMSCRIPTEN then 
	--   shader:load(shaderDir .. "shadersES2/shader") 
	-- elseif ofIsGLProgrammableRenderer() then 
	--   shader:load(shaderDir .. "shadersGL3/shader") 
	-- else 
	--   shader:load(shaderDir .. "shadersGL2/shader") 
	-- end

	-- font
	
	

	-- shaer
	local useES = false
	if ofGetTargetPlatform and ofGetTargetPlatform() == OF_TARGET_EMSCRIPTEN then
		useES = true
	elseif ofIsGLProgrammableRenderer and ofIsGLProgrammableRenderer() then
		useES = true
	end

	if useES then
		ofDisableArbTex()
		shader:load(shaderDir .. "shadersES2/shaderBW")
		shaderFMB:load(shaderDir .. "shadersES2/shaderFMB")
	else
		ofEnableArbTex()
		shader:load(shaderDir .. "shaderBW")
		shaderFMB:load(shaderDir .. "shaderFMB")
	end

	
	
	img:allocate(vW, vH, GL_RGBA)
	pixels:allocate(vW, vH, GL_RGBA)

	webcamOk = false
	local webcamSetupOk, webcamSetupErr = pcall(function()
		webcam:setup(vW, vH)
	end)
	if webcamSetupOk then
		webcamOk = true
	else
		print("webcam setup failed", webcamSetupErr)
	end

	fbo:allocate(W, H, GL_RGBA)
	fbo:beginFbo()
		ofClear(255, 255, 255, 255)
	fbo:endFbo()

	fbo2:allocate(W, H, GL_RGBA)
	fbo2:beginFbo()
		ofClear(0,0,0, 0)
	fbo2:endFbo()

	fboCam:allocate(W, H, GL_RGBA)
	fboCam:beginFbo()
		ofClear(0,0,0, 0)
	fboCam:endFbo()

	fboFreq:allocate(freqW, freqH, GL_RGBA)
	fboFreq:beginFbo()
		ofClear(0,0,0, 0)
	fboFreq:endFbo()

	generalSettings["current"] = "camera"
	generalSettingsSettings["current"] = createRadioParameterSettings(ofTable("camera", "font"))
	generalSettings["camera"] = 1
	generalSettingsSettings["camera"] = createNumberParameterSettings("camera", 0.5, 2)
	generalSettings["font"] = 1
	generalSettingsSettings["font"] = createNumberParameterSettings("font", 0.5, 25)
	generalSettings["spectrograph"] = 8
	generalSettingsSettings["spectrograph"] = createNumberParameterSettings("spectrograph", 0, 100)
	generalSettings["wheel"] = "up"
	generalSettingsSettings["wheel"] = createRadioParameterSettings(ofTable("up", "down"))

	-- platform
	local platform = ofGetTargetPlatform()
	-- print(222222, platform == OF_TARGET_OSX, OF_TARGET_LINUXARMV6L)
	if platform == OF_TARGET_OSX then 
		generalSettings["camera"] = 1
		generalSettings["font"] = 2
	else 
		generalSettings["camera"] = 1
		generalSettings["font"] = 1
	end

  
	local titleFontSettings = ofTrueTypeFontSettings(fontPath, 12 * generalSettings["font"])
	title:load(titleFontSettings)

	local smalltextFontSettings = ofTrueTypeFontSettings(fontPath, 10 * generalSettings["font"])
	-- smalltextFontSettings:addRanges(ofAlphabet(ofAlphabet.Cyrillic))
	smalltext:load(smalltextFontSettings)


	-- selects
	selectParametersSettings["current"] = createRadioParameterSettings(ofTable("speed", "volume", 'frames', 'osc'))
	selectParametersSettings["speed"] = createNumberParameterSettings("speed", 5, 200)
	selectParametersSettings["frames"] = createNumberParameterSettings("frames", 1, 1000)
	selectParametersSettings["volume"] = createNumberParameterSettings("volume", 0, 10)
	selectParametersSettings["osc"] = createRadioParameterSettings(ofTable(1, 2, 3, 4, 5), 'osc') --createNumberParameterSettings("osc", 1, 2)
	sends["speed"] = createSelectsSends("speed")
	sends["filter"] = createSelectsSends("filter")
	sends["volume"] = createSelectsSends("volume")
	sends["frames"] = createSelectsSends("frames")
	sends["osc"] = createSelectsSends("osc")
	sends["spectreOn"] = ofSend('spectreOn')

	
	-- brush
	brushParameters["current"] = "type"
	--?
	 brushParametersSettings["current"] = createRadioParameterSettings(ofTable("type", "lineSize", 'circleSize', "color", "opacity"))

	brushParameters["type"] = "line"
	brushParametersSettings["type"] = createRadioParameterSettings(ofTable("line", "circle", "camera", "fractal", "spectre", "clear"))

	brushParameters["color"] = "black"
	brushParametersSettings["color"] = createRadioParameterSettings(ofTable("black", "white"))

	brushParameters["lineSize"] = 1
	if platform == OF_TARGET_OSX then 
		brushParametersSettings["lineSize"] = createNumberParameterSettings("lineSize", 1, 12)
	else 
		brushParametersSettings["lineSize"] = createNumberParameterSettings("lineSize", 1, 1000)
	end

	brushParameters["circleSize"] = 1
	brushParametersSettings["circleSize"] = createNumberParameterSettings("circleSize", 1, 1000)

	brushParameters["opacity"] = 100
	brushParametersSettings["opacity"] = createNumberParameterSettings("opacity", 0, 100)

	brushParameters["light"] = 0
	brushParametersSettings["light"] = createNumberParameterSettings("light", -100, 100)

	brushParameters["fill"] = 'off'
	brushParametersSettings["fill"] = createRadioParameterSettings(ofTable("on", "off"))

	brushParameters["spectreState"] = 'on'
	brushParametersSettings["spectreState"] = createRadioParameterSettings(ofTable("on", "off"))
	
	brushParameters["spectreMode"] = 'static'
	brushParametersSettings["spectreMode"] = createRadioParameterSettings(ofTable("static", "dynamic"))
	
	-- brushParameters["spectreX"] = 0
	-- brushParameters["spectreY"] = 0
	-- brushParameters["spectreW"] = 0
	-- brushParameters["spectreH"] = 0

	--fractal 
	brushParameters["offsetX"] = -0.75
	brushParametersSettings["offsetX"] = createNumberParameterSettings("offsetX", -2, 2)
	brushParameters["offsetY"] = 0.0
	brushParametersSettings["offsetY"] = createNumberParameterSettings("offsetY",  -2, 2)
	brushParameters["scale"] = 1.0
	brushParametersSettings["scale"] = createNumberParameterSettings("scale", 0, 1)

	
	
end

function drawSelections()
    
	local lineHeight = 18 * generalSettings["font"];
    
	for i = 1, SEL_CNT do
		if selects[i] then
			ofNoFill()

			
			-- print(selects[i]["sx"], selects[i]["sy"], selects[i]["w"], selects[i]["h"])
			local x = scaledX(selects[i]["sx"])
			local y = scaledY(selects[i]["sy"])
			local w = scaledX(selects[i]["w"])
			local h = scaledY(selects[i]["h"])
			local frames = selects[i]["frames"]

			local baseX = x + (w < 0 and w or 0)
			local baseYTop = y + (h < 0 and h or 0)
			local baseY = y + (h > 0 and h or 0)

			ofSetColor(255, 0, 0, 255)
			title:drawString(tostring(i), baseX - 14 * generalSettings["font"], baseYTop + 12 * generalSettings["font"])

			if activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			end

			ofSetLineWidth(generalSettings['font'])

			ofDrawRectangle(x, y, w, h)
			ofFill()
			ofDrawRectangle(x - 3 * generalSettings['font'], y + h -3 * generalSettings['font'], 6 * generalSettings['font'],6 * generalSettings['font'])
			ofNoFill()

			


			local cursorX = x + cursors[i] / frames * w
			ofDrawLine(cursorX, y, cursorX, y + h)

		
			-- speed

			if selects[i]['current'] == 'speed' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'speed' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			local speed = tostring(math.floor(selects[i]["speed"] or 0))
			local speedX = baseX -- - 12 * 3
			local speedY = baseY + lineHeight * 1
			title:drawString(speed, speedX, speedY)
			
			if activeSelectIndex == i then
				smalltext:drawString('speed', speedX, speedY + 12 * generalSettings["font"])
			end

			--vol
			
			local vol = string.format("%.2f", selects[i]["volume"])
			local volX = baseX + 50 * generalSettings["font"] -- - 12 * 3
			local volY = baseY + lineHeight * 1

			


			-- white
			-- ofSetColor(255, 255, 255, 255)

			-- title:drawString(vol, volX, volY+1)
			-- if activeSelectIndex == i then
			-- 	smalltext:drawString('volume', volX, volY + 1)
			-- end

			-- color
			if selects[i]['current'] == 'volume' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'volume' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(vol, volX, volY)
			if activeSelectIndex == i then
				smalltext:drawString('volume', volX, volY + 12 * generalSettings["font"] )
			end



			--frmes
			
			local frames = string.format("%.0f", selects[i]["frames"])
			local framesX = baseX + 100 * generalSettings["font"] -- - 12 * 3
			local framesY = baseY + lineHeight * 1
			
			if selects[i]['current'] == 'frames' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'frames' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(frames, framesX, framesY)
			if activeSelectIndex == i then
				smalltext:drawString('frames', framesX, framesY + 12 * generalSettings["font"] )
			end



			--osc
			
			local osc = string.format("%.0f", selects[i]["osc"])
			local oscX = baseX + 150 * generalSettings["font"] -- - 12 * 3
			local oscY = baseY + lineHeight * 1
			
			if selects[i]['current'] == 'osc' and activeSelectIndex == i then
				ofSetColor(255, 0, 255, 255)
			elseif previewParameter and previewParameter.type == 'select' and previewParameter.target == i and previewParameter.param == 'osc' then
				ofSetColor(0, 255, 0, 255) -- Желтый цвет для предварительного просмотра
			else
				ofSetColor(255, 0, 0, 255)
			end

			title:drawString(osc, oscX, oscY)
			if activeSelectIndex == i then
				smalltext:drawString('osc', oscX, oscY + 12 * generalSettings["font"] )
			end

			


		end
	end
end

function M.draw()
	if perfBeginDraw then
		perfBeginDraw()
	end
	-- print('draw')
	-- ofSetColor(255)
	-- shader:beginShader()
	-- ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight())
	-- shader:endShader()

	ofSetColor(0, 0, 0, 0)
	-- ofSetColor(255, 255, 255, 255)
	ofFill()
	ofDrawRectangle(0, 0, W, H)
	ofSetColor(255, 255, 255, 255)
	ofEnableAlphaBlending(); 


	-- сло с основным рисунком плюс временная камера, спектр и тд
	fbo2:beginFbo()

		ofClear(255, 255, 255, 255)
		
		ofFill()
		ofSetColor(255, 255, 255, 255)
		ofDrawRectangle(0, 0, W, H)

		ofSetColor(255, 255, 255, 255)

		-- 1111S
		ofDisableAlphaBlending();
		fbo:draw(0, 0)
		-- 1111E

		if buttonsPressed[0]  then

			if (brushParameters["type"] == "camera") and webcamOk then
				local x = buttonsPressed[0].sx
				local y = buttonsPressed[0].sy
				local w = prevPointX - buttonsPressed[0].sx
				local h = prevPointY - buttonsPressed[0].sy

				
				webcam:getTexture():bind()
				
				fboCam:beginFbo()
					shader:beginShader()
						shader:setUniformTexture("tex0", webcam:getTexture(), 0)
						shader:setUniform1f("W", W);
						shader:setUniform1f("H", H);
						shader:setUniform1f("vW", vW);
						shader:setUniform1f("vH", vH);
						shader:setUniform1f("light", brushParameters["light"]);
						shader:setUniform1f("cameraScale", generalSettings["camera"]);
						
						ofSetColor(255, 255, 255, 255)
						-- ofEnableAlphaBlending(); 
						ofDisableAlphaBlending(); 

						ofDrawRectangle(0,0,W, H)
					shader:endShader()
				fboCam:endFbo()

				webcam:getTexture():unbind()

				ofSetColor(255, 255, 255, brushParameters["opacity"] / 100 * 255)
				-- ofDisableAlphaBlending(); 
				ofEnableAlphaBlending(); 
				fboCam:draw(x, y, w, h)
			end

			
			if (brushParameters["type"] == "fractal") then
				local x = buttonsPressed[0].sx
				local y = buttonsPressed[0].sy
				local w = prevPointX - buttonsPressed[0].sx
				local h = prevPointY - buttonsPressed[0].sy

				-- if (buttonsPressed[1]) then
				-- 	x = buttonsPressed[0].sx
				-- 	y = buttonsPressed[0].sy
				-- 	w = buttonsPressed[1].sx- buttonsPressed[0].sx
				-- 	h = buttonsPressed[1].sy- buttonsPressed[0].sy
				-- end

				
				webcam:getTexture():bind()
				
				fboCam:beginFbo()
					shaderFMB:beginShader()
						shaderFMB:setUniform1f("W", W);
						shaderFMB:setUniform1f("H", H);
						shaderFMB:setUniform1f("offsetX", brushParameters["offsetX"] or 0);
						shaderFMB:setUniform1f("offsetY", brushParameters["offsetY"] or 0);
						shaderFMB:setUniform1f("scale", brushParameters["scale"]);
						shaderFMB:setUniform1f("light", brushParameters["light"]);
						shaderFMB:setUniform1f("isWhite", brushParameters["color"] == 'white' and 1 or 0);
						
						ofSetColor(255, 255, 255, 255)
						-- ofEnableAlphaBlending(); 
						ofDisableAlphaBlending(); 

						ofDrawRectangle(0,0,W, H)
					shaderFMB:endShader()
				fboCam:endFbo()

				webcam:getTexture():unbind()

				ofSetColor(255, 255, 255, brushParameters["opacity"] / 100 * 255)
				-- ofDisableAlphaBlending(); 
				ofEnableAlphaBlending(); 
				fboCam:draw(x, y, w, h)
			end
		end

		
		for i = 1, SPCTR_CNT + 1 do
			if (dynamicSpectres[i]) then
			-- if (generalSettings['spectrograph'] > 0) then
	
				local x = dynamicSpectres[i]['x'];
				local y = dynamicSpectres[i]['y'];
				local w = dynamicSpectres[i]['w'];
				local h = dynamicSpectres[i]['h'];
				-- local freqW = generalSettings['spectrograph'] * vW/2;
				-- local freqH = generalSettings['spectrograph'] * vH/4;
	
				ofEnableAlphaBlending(); 
				ofEnableBlendMode(OF_BLENDMODE_MULTIPLY)
				ofSetColor(255, 255, 255, 255)
				fboFreq:draw(x,y, w,h)
				ofEnableBlendMode(OF_BLENDMODE_DISABLED)
	
			end
		end
		

	fbo2:endFbo()
	perfSection("compose")

	if refreshActiveFilterCaches then
		refreshActiveFilterCaches()
	end
	perfSection("columns")

	ofDisableAlphaBlending(); 
	ofSetColor(255, 255, 255, 255)
	fbo2:draw(0, 0, wW, wH)
	perfSection("present")







	-- local red = {255, 0, 0, 255}
	-- local pink = {255, 0, 0, 255}

	local lineHeight = 18 * generalSettings["font"];
	-- print(555, activeSelectIndex);


	if not (buttonsPressed[0] and brushParameters['type'] == 'spectre' and brushParameters['spectreMode'] == 'static') then
		if dynamicSpectres[activeDynSpectreIndex] then

			ofNoFill()
			local x = scaledX(dynamicSpectres[activeDynSpectreIndex]["x"])
			local y = scaledY(dynamicSpectres[activeDynSpectreIndex]["y"])
			local w = scaledX(dynamicSpectres[activeDynSpectreIndex]["w"])
			local h = scaledY(dynamicSpectres[activeDynSpectreIndex]["h"])
			ofSetLineWidth(generalSettings['font'])

			ofSetColor(0, 0, 255, 255)
			ofDrawRectangle(x, y, w, h)
		
		end
	end


	perfSection("spectreBox")

	-- ВЫДЕЛЕНИЯ
	drawSelections()
	perfSection("selections")

	if (not isSetting) then
		drawBrushParams() 
	else
		drawGeneralSettings() 
	end 
	perfSection("ui")

	-- if (cursorPix) then
	-- 	ofSetColor(255, 0, 0, 255)

	-- 	title:drawString(cursorPix.r .. ' ' .. cursorPix.a, 20, 20)
	-- end

	-- ofSetColor(255, 0, 0, 255)
	-- ofNoFill()
	-- ofDrawRectangle(0,0,wW/2, wH/2)


	-- if selects[1] then 

	-- 	local x1 = scaledX(selects[1]["sx"])
	-- 	local y1 = scaledY(selects[1]["sy"])
	-- 		local w1 = scaledX(selects[1]["w"])
	-- 		local h1 = scaledY(selects[1]["h"])
	-- 		local frames1 = selects[1]["frames"]

			
	-- 	local cursorX2 = x1 + cursors[1] / frames1 * w1
		
	-- 	ofSetColor(225, 0, 255, 255)
	-- 	ofDrawRectangle(cursorX2- 2,0,4, wH)

	-- 	-- local cursorX = selects[1]['sx'] + cursors[1] / selects[1]['frames'] * selects[1]['w']
		
	-- 	-- ofSetColor(0, 0, 255, 255)
	-- 	-- ofDrawRectangle(cursorX- 2,0,4, wH)
	-- end


	
	-- if (activeDynSpectreIndex) then
	-- 	ofSetColor(255, 0, 0, 255)
	-- 	ofDisableAlphaBlending()

	-- 	title:drawString(activeDynSpectreIndex, 20, 20)
	-- end

	MouseHighlight.draw(smalltext)
	perfSection("highlight")
	if perfEndDraw then
		perfEndDraw()
	end
end

function M.exit()
	print("exit")
	if webcamOk and webcam then
		webcam:close()
	end
	webcam = nil
	-- shader:unload()
end

function mouseDragged(e)
	-- print("drag")
	local x = unscaledX(e.x)
	local y = unscaledY(e.y)
	local button = e.button;
	-- print('mouseDragged', button)

	
	-- activeSelectIndex = (not (startButton == 0)) and (not isSetting) and getIntersected(x, y)
	getActiveSelectIndex(x, y)
	getActiveDynSpectreIndex(x, y)
	
	
	
	-- print('drag', not not buttonsPressed[0], not not buttonsPressed[2])
	-- if startButton == 0 then
	if buttonsPressed[0] then
		fbo:beginFbo()
			
		ofEnableAlphaBlending()

		if (brushParameters['type'] == 'circle') then
			local color = brushParameters['color'] == 'black' and 0 or 255
			ofSetColor(color, color, color, brushParameters['opacity'] / 100 * 255)
			if (brushParameters["fill"] == 'on') then ofFill() else ofNoFill() end

			ofDrawCircle(x, y, brushParameters['circleSize'])
		end
		
		if (brushParameters['type'] == 'camera') then
			-- local xx = buttonsPressed[0].sx
			-- local yy = buttonsPressed[0].sy
			-- local w = math.max(1, math.min(W - 1, x)) - buttonsPressed[0].sx
			-- local h = math.max(1, math.min(H - 1, y)) - buttonsPressed[0].sy
		end
		
		if (brushParameters['type'] == 'line') then
			local color = brushParameters['color'] == 'black' and 0 or 255
			ofSetColor(color, color, color, brushParameters['opacity'] / 100 * 255)
			ofSetLineWidth(brushParameters['lineSize'])
			
			ofDrawLine(x, y, prevPointX, prevPointY)
		end

		if (brushParameters['type'] == 'spectre') then

			if dynSpectreIndex <= SPCTR_CNT or brushParameters['spectreMode'] == 'static' then

				if (dynamicSpectres[dynSpectreIndex]) then
				
					local xx = math.max(1, math.min(W - 1, x))
					local yy = math.max(1, math.min(H - 1, y))
					dynamicSpectres[dynSpectreIndex]['w'] = xx - buttonsPressed[0].sx
					dynamicSpectres[dynSpectreIndex]['h'] = yy - buttonsPressed[0].sy
				end
			end

		end
		
		fbo:endFbo()
	end

	if buttonsPressed[1] then
        
        -- Обновляем предварительный параметр при перетаскивании средней кнопки
        previewParameter = calculatePreviewParameter(x, y)


		if (brushParameters["type"] == 'fractal') and buttonsPressed[0] then

			changeBrushParameter('offsetX' .. 'wheel', - x + prevPointX)
			changeBrushParameter('offsetY' .. 'wheel', - y + prevPointY)

			
		end

	end
	

	if buttonsPressed[2] and selectIndex <= SEL_CNT then
		local xx = math.max(1, math.min(W - 1, x))
		local yy = math.max(1, math.min(H - 1, y))
		selects[selectIndex]['w'] = xx - buttonsPressed[2].sx
		selects[selectIndex]['h'] = yy - buttonsPressed[2].sy


	end
	
	-- buttonsPressed[button] = {sx = buttonsPressed[button].sx, sy = buttonsPressed[button].sy, px = x, py = y}
	prevPointX = x
	prevPointY = y

	
	MouseHighlight.updateMousePosition(e.x, e.y)
end


function M.mouseDragged(e)
	mouseDragged(e)
end

function M.mousePressed(e)

	-- for k, v in pairs(e) do
	-- 	print('---',k)
	-- end

	-- print("press", e.x,e.y, e.button)

	local x = unscaledX(e.x)
	local y = unscaledY(e.y)
	local button = e.button
	
	-- print('mousePressed', button);
	-- startPointX = x
	-- startPointY = y
	-- startButton = button
	
	prevPointX = x
	prevPointY = y

	---
	buttonsPressed[button] = { sx = x, sy = y, px = x, py = y }



	if button == 1 then
		MouseHighlight.setCircle('green', true)
		
		-- Вычисляем предварительный параметр при нажатии
		previewParameter = calculatePreviewParameter(x, y)

		button1PressedTime = os.clock()

	end
	
	if button == 2 then
		MouseHighlight.setCircle('red', true)

		if selectIndex <=6 then
			local newSelect = createNewSelect(buttonsPressed[button].sx, buttonsPressed[button].sy)
			selects[selectIndex] = newSelect
			-- print('press', selectIndex)
			resendSelectsParameters('speed')
			resendSelectsParameters('volume')
			resendSelectsParameters('frames')
			resendSelectsParameters('osc')
		end
	end

	if button == 0 then
		MouseHighlight.setCircle('blue', true)

		saveFBO2()
	
		if (buttonsPressed[2]) then
			getActiveSelectIndex(x, y)
		end

		if (brushParameters['type'] == 'spectre') then 
			print(dynSpectreIndex <=6 or brushParameters['spectreMode'] == 'static')
			if dynSpectreIndex <=6 or brushParameters['spectreMode'] == 'static' then
				local newDynSpectre = createNewDynSpectre(buttonsPressed[button].sx, buttonsPressed[button].sy)
				dynamicSpectres[dynSpectreIndex] = newDynSpectre
				getActiveDynSpectreIndex(x, y)
			end
		end
		if (brushParameters['type'] == 'clear') then 
			-- fbo.clear()
			-- fbo2.clear()

			fbo:beginFbo()
				ofClear(255, 255, 255, 255)
			fbo:endFbo()
		end


	end

	
end


function M.mouseReleased(e)



	-- print("release12", startPointX, e.x, getIntersected(e.x, e.y), "111")
	
	local x = unscaledX(e.x)
	local y = unscaledY(e.y)
	local button = e.button

	-- print('mouseReleased', button);
	
	if button == 2 then
		MouseHighlight.setCircle('red', false)
	-- if startButton == 2 then
		-- print('startButton == 2')
	
	
		if math.abs(x - buttonsPressed[2].sx) < 25 or math.abs(y - buttonsPressed[2].sy) < 25 then
			-- print('smal')
		
			selects[selectIndex] = nil
			local toDelete = getIntersected(x, y)
			-- print('del', toDelete)
		
			if not (toDelete == nil) then
				-- print('have target', toDelete)
				
				selects[selectIndex] = nil
				selectIndex = selectIndex - 1
				table.remove(selects, toDelete)
				table.insert(selects, nil)
				resendSelectsParameters('speed')
				resendSelectsParameters('volume')
				resendSelectsParameters('frames')
				resendSelectsParameters('osc')
			
			end
		
		else
			-- print('not small')
		
			if selectIndex <= SEL_CNT then
				selectIndex = selectIndex + 1
			end
		
		end


		buttonsPressed[2] = false

		
		getActiveSelectIndex(x, y)
	
		-- print('buttonsPressed[2] = false', not(not buttonsPressed[2]), not(not buttonsPressed[0]))
	
	end
	
	
	
	if button == 1 then
		MouseHighlight.setCircle('green', false)
		
		-- Очищаем предварительный параметр при отпускании кнопки
		previewParameter = nil

		local target = getActiveSelectIndex(x, y)
	
		if target then
			changeSelectParameter(target, 'current', 1)
		else
			-- local isLong = (os.clock() - button1PressedTime) > 0.5;
			-- local isShort = (os.clock() - button1PressedTime) < 0.5;
			
			-- if isLong then
			-- 	if not buttonsPressed[0] then 
			-- 		isSetting = not isSetting
			-- 	end
			-- else
			-- 	if (isSetting) then
			-- 		changeSetting('current', 1)
			-- 	else
			-- 		if (isShort) then
			-- 			changeBrushParameter('current', 1)
			-- 		end
			-- 	end
				
			-- end

			if (isSetting) then
        changeSetting('current', 1)
      else
        if buttonsPressed[0] and brushParameters['type'] == 'fractal' then
        else
          changeBrushParameter('current', 1)
        end
      end
			
		end
		
		buttonsPressed[1] = false
	end
	
	
	
	
	if button == 0 then 
		MouseHighlight.setCircle('blue', false)
		
		
		if brushParameters['type'] == 'camera' and webcamOk then

			fbo:beginFbo()

				-- ofClear(255, 255, 255, 0)

				-- ofSetColor(255, 255, 255, 255)
				-- ofEnableAlphaBlending(); 
				-- fbo:draw(0, 0)

				-- if startPointX then
				if buttonsPressed[0] then
					local xx = buttonsPressed[0].sx
					local yy = buttonsPressed[0].sy
					local w = prevPointX - buttonsPressed[0].sx
					local h = prevPointY - buttonsPressed[0].sy

					
					webcam:getTexture():bind()
					
					fboCam:beginFbo()
						shader:beginShader()
							shader:setUniformTexture("tex0", webcam:getTexture(), 0)
							shader:setUniform1f("W", W);
							shader:setUniform1f("H", H);
							shader:setUniform1f("vW", vW);
							shader:setUniform1f("vH", vH);
							shader:setUniform1f("light", brushParameters["light"]);
							shader:setUniform1f("cameraScale", generalSettings["camera"]);
							
							ofSetColor(255, 255, 255, 255)
							-- ofEnableAlphaBlending(); 
							ofDisableAlphaBlending(); 

							ofDrawRectangle(0,0,W, H)
						shader:endShader()
					fboCam:endFbo()

					webcam:getTexture():unbind()

					ofSetColor(255, 255, 255, brushParameters["opacity"] / 100 * 255)
					-- ofDisableAlphaBlending(); 
					ofEnableAlphaBlending(); 
					fboCam:draw(xx, yy, w, h)

				end

			fbo:endFbo()
			ofDisableAlphaBlending(); 
		
		end 

		if brushParameters['type'] == 'fractal' then

			fbo:beginFbo()

				-- ofClear(255, 255, 255, 0)

				-- ofSetColor(255, 255, 255, 255)
				-- ofEnableAlphaBlending(); 
				-- fbo:draw(0, 0)

				-- if startPointX then
				if buttonsPressed[0] then
					local xx = buttonsPressed[0].sx
					local yy = buttonsPressed[0].sy
					local w = prevPointX - buttonsPressed[0].sx
					local h = prevPointY - buttonsPressed[0].sy

					
					webcam:getTexture():bind()
					
					fboCam:beginFbo()
						shaderFMB:beginShader()
							
							shaderFMB:setUniform1f("W", W);
							shaderFMB:setUniform1f("H", H);
							shaderFMB:setUniform1f("offsetX", brushParameters["offsetX"]);
							shaderFMB:setUniform1f("offsetY", brushParameters["offsetY"]);
							shaderFMB:setUniform1f("scale", brushParameters["scale"]);
							shaderFMB:setUniform1f("light", brushParameters["light"]);
							shaderFMB:setUniform1f("isWhite", brushParameters["color"] == 'white' and 1 or 0);
							
							ofSetColor(255, 255, 255, 255)
							-- ofEnableAlphaBlending(); 
							ofDisableAlphaBlending(); 

							ofDrawRectangle(0,0,W, H)
						shaderFMB:endShader()
					fboCam:endFbo()

					webcam:getTexture():unbind()

					ofSetColor(255, 255, 255, brushParameters["opacity"] / 100 * 255)
					-- ofDisableAlphaBlending(); 
					ofEnableAlphaBlending(); 
					fboCam:draw(xx, yy, w, h)

				end

			fbo:endFbo()
			ofDisableAlphaBlending(); 
		
		end 

		if brushParameters['type'] == 'spectre' then
			if math.abs(x - buttonsPressed[0].sx) < 5 or math.abs(y - buttonsPressed[0].sy) < 5 then
				dynamicSpectres[dynSpectreIndex] = nil
				local toDelete = getDynSpectreIntersected(x, y)
				-- print('del', toDelete)
			
				if not (toDelete == nil) then
					-- print('have target', toDelete)
					
					dynamicSpectres[dynSpectreIndex] = nil
					dynSpectreIndex = dynSpectreIndex - 1
					table.remove(dynamicSpectres, toDelete)
					table.insert(dynamicSpectres, nil)
					
				
				end
			
			else

				if (brushParameters['spectreMode'] == 'static') then

					if (dynamicSpectres[dynSpectreIndex]) then
						local x = dynamicSpectres[dynSpectreIndex].x
						local y = dynamicSpectres[dynSpectreIndex].y
						local w = dynamicSpectres[dynSpectreIndex].w
						local h = dynamicSpectres[dynSpectreIndex].h
						fbo:beginFbo()
							
							ofEnableAlphaBlending(); 
							ofEnableBlendMode(OF_BLENDMODE_MULTIPLY)
							ofSetColor(255, 255, 255, 255)
							fboFreq:draw(x,y, w,h)
							ofEnableBlendMode(OF_BLENDMODE_DISABLED)
						fbo:endFbo()
					end

					
					table.remove(dynamicSpectres, dynSpectreIndex)
					table.insert(dynamicSpectres, nil)


				else
					if dynSpectreIndex <= SPCTR_CNT then
						dynSpectreIndex = dynSpectreIndex + 1
					else
						table.remove(dynamicSpectres, dynSpectreIndex)
						table.insert(dynamicSpectres, nil)
					end
				end
				
			
				
			
			end
	
			
			getActiveDynSpectreIndex(x, y)
		end
		
		buttonsPressed[0] = false


		if (buttonsPressed[2]) then
			getActiveSelectIndex(x, y)
		end
	end
	
	
	-- startPointX = nil
	-- startPointY = nil
	-- startButton = nil
	
	if ((not buttonsPressed[0]) and (not buttonsPressed[1]) and (not buttonsPressed[2])) then
		prevPointX = nil
		prevPointY = nil
	end

	
print(111)
	
	-- print('->', selectIndex)
	
end

function M.mouseScrolled(e)
	
	-- for k, v in pairs(e) do
	-- 	print('---',k, v)
	-- end
	-- print("scrol", e.x, e.y, a[3], a[4], getIntersected(e.x, e.y), "111")

	
	local x = unscaledX(e.x)
	local y = unscaledY(e.y)
	
	-- local target = (not (startButton == 0)) and (not isSetting) and getIntersected(x, y)
	local target = getActiveSelectIndex(x, y)
	
	if target then
		changeSelectParameter(target, selects[target]['current'], e.scrollY)
	else
		if (isSetting) then
			changeSetting(generalSettings['current'], e.scrollY)
		else

			changeBrushParameter(brushParameters['current'], e.scrollY)

		end
	end

	MouseHighlight.showDiameters(e.scrollY > 0 and 1 or -1)
	
end


KEY_MOUSE_BUTTONS = { [49] = 0, [50] = 1, [51] = 2 }
KEY_MOUSE_SCROLL = { [52] = -1, [53] = 1 }
keyMouseHeld = {}

function keyMouseEvent(button, scrollY)
	return { x = ofGetMouseX(), y = ofGetMouseY(), button = button, scrollX = 0, scrollY = scrollY }
end

function M.keyReleased(e)
	local button = KEY_MOUSE_BUTTONS[e.key]
	if button and keyMouseHeld[e.key] then
		keyMouseHeld[e.key] = nil
		M.mouseReleased(keyMouseEvent(button, 0))
	end
end

function M.keyPressed(e)

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

	if e.key == 112 or e.key == 80 then
		if PERF then
			PERF.on = not PERF.on
			print("PERF", PERF.on and "on" or "off")
			if PERF.on then
				PERF.lastLogMs = 0
				perfFlush()
			end
		end
	end

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

cursorPix = nil
function M.mouseMoved(e)
	-- print("mouseMoved", e.x, e.y)
	
	local x = unscaledX(e.x)
	local y = unscaledY(e.y)

	-- print(221,startButton, not (startButton == 0))
	-- activeSelectIndex = (not (startButton == 0)) and (not isSetting) and getIntersected(x, y)
	getActiveSelectIndex(x, y);
	getActiveDynSpectreIndex(x, y);

	
    -- fbo2:readToPixels(pixels)
	-- if (x > 0 and y >0 and x < wW and y < wH) then
	-- 	cursorPix = pixels:getColor(x, y)
	-- end

	if (buttonsPressed[0] or buttonsPressed[1] or buttonsPressed[2]) then 
		mouseDragged(e)
	end


	MouseHighlight.updateMousePosition(e.x, e.y)

end

function M.update()
	local t0 = perfNowMs()
	if webcamOk and webcam then
		webcam:update()
	end

	
	wW = ofGetWidth();
    wH = ofGetHeight();
	perfSince("update", t0)

		
end
