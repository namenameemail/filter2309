function M.setup()
	if setupDone then
		return
	end
	setupDone = true
	print("setup 12", "fboSampleColumnR", fboSampleColumnR ~= nil) 
	collectgarbage("stop")
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
	local showCameraMode = false
	local typeItems = {"line", "circle", "camera", "fractal", "spectre", "clear"}
	local visibleTypes = {}
	for i = 1, #typeItems do
		if showCameraMode or typeItems[i] ~= "camera" then
			visibleTypes[#visibleTypes + 1] = typeItems[i]
		end
	end
	brushParametersSettings["type"] = createRadioParameterSettings(ofTable(table.unpack(visibleTypes)))

	brushParameters["color"] = "black"
	brushParametersSettings["color"] = createRadioParameterSettings(ofTable("black", "white"))

	brushParameters["lineType"] = "1"
	brushParametersSettings["lineType"] = createRadioParameterSettings(ofTable("1", "2"))

	brushParameters["gradient"] = "off"
	brushParametersSettings["gradient"] = createRadioParameterSettings(ofTable("off", "1", "2"))

	brushParameters["curve"] = 0
	brushParametersSettings["curve"] = createNumberParameterSettings("curve", -8, 8)

	brushParameters["dash"] = 1
	brushParametersSettings["dash"] = createNumberParameterSettings("dash", 0, 32)

	brushParameters["gap"] = 0
	brushParametersSettings["gap"] = createNumberParameterSettings("gap", 0, 32)

	brushParameters["harmonics"] = 0
	brushParametersSettings["harmonics"] = createNumberParameterSettings("harmonics", 0, 32)

	brushParameters["stepHz"] = 44100 / 512
	brushParametersSettings["stepHz"] = createNumberParameterSettings("stepHz", 44100 / 512, 22050)

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
