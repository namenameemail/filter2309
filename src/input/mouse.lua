-- Функция для вычисления предварительного параметра
local function calculatePreviewParameter(x, y)
	local target = getActiveSelectIndex(x, y)
	return getNextParameter(target)
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
        previewParameter = calculatePreviewParameter(x, y)
	end

	if fractalPan and brushParameters["type"] == 'fractal' and buttonsPressed[0] then
		changeBrushParameter('offsetX' .. 'wheel', - x + prevPointX)
		changeBrushParameter('offsetY' .. 'wheel', - y + prevPointY)
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
					fboCam:draw(xx, H - yy, w, -h)

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
					fboCam:draw(xx, H - yy, w, -h)

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
