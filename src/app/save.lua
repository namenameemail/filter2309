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

_G.saveFBO2 = saveFBO2
