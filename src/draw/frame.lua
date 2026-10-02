function M.draw()
	if perfBeginDraw then
		perfBeginDraw()
	end
	drawPendingFreq()
	collectgarbage("step")
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
				fboCam:draw(x, H - y, w, -h)
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
				fboCam:draw(x, H - y, w, -h)
			end

			if brushParameters["type"] == "line" and brushParameters["lineType"] == "2" then
				drawType2Line(buttonsPressed[0].sx, buttonsPressed[0].sy, prevPointX, prevPointY)
			end
			if brushParameters["type"] == "line" and (brushParameters["lineType"] or "1") == "1" then
				drawLineStroke()
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
	drawHarmonicMarks()
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
