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

function M.exit()
	print("exit")
	if webcamOk and webcam then
		webcam:close()
	end
	webcam = nil
	-- shader:unload()
end

function resizeCanvas(nw, nh)
	nw = math.floor(nw)
	nh = math.floor(nh)
	if nw < 1 or nh < 1 or (nw == W and nh == H) then
		return
	end
	local nextFbo = ofFbo()
	nextFbo:allocate(nw, nh, GL_RGBA)
	nextFbo:beginFbo()
		ofClear(255, 255, 255, 255)
		ofSetColor(255, 255, 255, 255)
		ofDisableAlphaBlending()
		fbo:draw(0, 0)
		ofEnableAlphaBlending()
	nextFbo:endFbo()
	fbo = nextFbo
	fbo2:allocate(nw, nh, GL_RGBA)
	fboCam:allocate(nw, nh, GL_RGBA)
	fboCam:beginFbo()
		ofClear(0, 0, 0, 0)
	fboCam:endFbo()
	W = nw
	H = nh
end

function M.update()
	local t0 = perfNowMs()
	if webcamOk and webcam then
		webcam:update()
	end

	if setupDone then
		local nw = ofGetWidth()
		local nh = ofGetHeight()
		if nw ~= W or nh ~= H then
			resizeCanvas(nw, nh)
		end
	end

	wW = ofGetWidth();
    wH = ofGetHeight();
	perfSince("update", t0)

		
end
