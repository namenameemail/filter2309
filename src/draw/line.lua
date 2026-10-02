local lineMesh

local function addEnd(mesh, x, y, nx, ny, c, a)
	mesh:addVertex(ofVec3f(x + nx, y + ny, 0):vec3())
	mesh:addColor(ofFloatColor(c, c, c, a))
	mesh:addVertex(ofVec3f(x - nx, y - ny, 0):vec3())
	mesh:addColor(ofFloatColor(c, c, c, a))
end

function drawStraightLine(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local len2 = dx * dx + dy * dy
	if len2 < 0.01 then return end
	local len = math.sqrt(len2)
	local w = (brushParameters['lineSize'] or 1) / 2
	local nx = -dy / len * w
	local ny = dx / len * w
	local c = brushParameters['color'] == 'black' and 0 or 1
	local a0 = (brushParameters['opacity'] or 0) / 100
	local a1 = brushParameters['gradient'] == 'on' and 0 or a0
	if not lineMesh then lineMesh = ofMesh() end
	lineMesh:clear()
	lineMesh:setMode(OF_PRIMITIVE_TRIANGLE_STRIP)
	addEnd(lineMesh, x1, y1, nx, ny, c, a0)
	addEnd(lineMesh, x2, y2, nx, ny, c, a1)
	ofEnableAlphaBlending()
	ofSetColor(255, 255, 255, 255)
	lineMesh:draw()
end
