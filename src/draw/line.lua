local lineMesh

local function addEnd(mesh, x, y, nx, ny, c, a)
	mesh:addVertex(ofVec3f(x + nx, y + ny, 0):vec3())
	mesh:addColor(ofFloatColor(c, c, c, a))
	mesh:addVertex(ofVec3f(x - nx, y - ny, 0):vec3())
	mesh:addColor(ofFloatColor(c, c, c, a))
end

local SAMPLE_RATE = 44100
local FFT_SIZE = 512

local function aboveSelectionTop(sel, y)
	if sel['h'] >= 0 then
		return y < sel['sy']
	end
	return y > sel['sy']
end

function harmonicDy(sel)
	local step = brushParameters['stepHz'] or 0
	return -step * FFT_SIZE / SAMPLE_RATE * 2 / 255 * (sel['h'] - 1)
end

local stroke = {}

function beginLineStroke(x, y)
	stroke = { { x, y } }
end

function extendLineStroke(x, y)
	local last = stroke[#stroke]
	if not last then
		stroke[1] = { x, y }
		return
	end
	local dx = x - last[1]
	local dy = y - last[2]
	if dx * dx + dy * dy < 0.01 then return end
	stroke[#stroke + 1] = { x, y }
end

local function unitPerp(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 0.01 then return nil end
	return -dy / len, dx / len
end

function fadeAlong(t)
	local k = brushParameters['curve'] or 0
	if k > 8 then k = 8 elseif k < -8 then k = -8 end
	if k == 0 then return 1 - t end
	local p = 2 ^ (math.abs(k) * 0.75)
	if k > 0 then return 1 - t ^ p end
	return (1 - t) ^ p
end

local function strokeAlpha(g, a0, t)
	if g == '1' then return a0 * fadeAlong(t) end
	if g == '2' then return a0 * (1 - math.abs(t * 2 - 1)) end
	return a0
end

local function pathCum(pts)
	local cum = { 0 }
	local total = 0
	for i = 2, #pts do
		local dx = pts[i][1] - pts[i - 1][1]
		local dy = pts[i][2] - pts[i - 1][2]
		total = total + math.sqrt(dx * dx + dy * dy)
		cum[i] = total
	end
	return cum, total
end

local function pointOn(pts, cum, dist)
	if dist <= 0 then return pts[1][1], pts[1][2] end
	local n = #pts
	if dist >= cum[n] then return pts[n][1], pts[n][2] end
	local i = 2
	while cum[i] < dist do i = i + 1 end
	local span = cum[i] - cum[i - 1]
	local u = span < 1e-6 and 0 or (dist - cum[i - 1]) / span
	return pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * u,
		pts[i - 1][2] + (pts[i][2] - pts[i - 1][2]) * u
end

local function slicePath(pts, cum, d0, d1)
	local x, y = pointOn(pts, cum, d0)
	local out = { { x, y } }
	for i = 2, #pts - 1 do
		if cum[i] > d0 + 0.01 and cum[i] < d1 - 0.01 then
			out[#out + 1] = pts[i]
		end
	end
	x, y = pointOn(pts, cum, d1)
	local last = out[#out]
	local dx = last[1] - x
	local dy = last[2] - y
	if dx * dx + dy * dy > 0.01 then
		out[#out + 1] = { x, y }
	end
	return out
end

local function dashLengths()
	local gap = brushParameters['gap'] or 0
	if gap <= 0 then return nil end
	local size = brushParameters['lineSize'] or 1
	if size < 1 then size = 1 end
	local on = brushParameters['dash'] or 1
	if on < 0 then on = 0 end
	return on * size, gap * size
end

local function drawPolyline(pts, yShift, origin, span)
	local n = #pts
	if n < 2 then return end
	local w = (brushParameters['lineSize'] or 1) / 2
	local c = brushParameters['color'] == 'black' and 0 or 1
	local a0 = (brushParameters['opacity'] or 0) / 100
	local g = brushParameters['gradient']
	local cum = { 0 }
	local total = 0
	for i = 2, n do
		local dx = pts[i][1] - pts[i - 1][1]
		local dy = pts[i][2] - pts[i - 1][2]
		total = total + math.sqrt(dx * dx + dy * dy)
		cum[i] = total
	end
	if total < 0.01 then return end
	origin = origin or 0
	if not span or span < 0.01 then span = total end
	local function at(dist)
		return (origin + dist) / span
	end
	local perp = {}
	for i = 1, n - 1 do
		local px, py = unitPerp(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2])
		perp[i] = px and { px, py } or nil
	end
	if not lineMesh then lineMesh = ofMesh() end
	lineMesh:clear()
	lineMesh:setMode(OF_PRIMITIVE_TRIANGLE_STRIP)
	for i = 1, n do
		local nx, ny
		if i == 1 then
			local p = perp[1]
			if not p then return end
			nx, ny = p[1], p[2]
		elseif i == n then
			local p = perp[n - 1]
			if not p then return end
			nx, ny = p[1], p[2]
		else
			local a = perp[i - 1]
			local b = perp[i]
			if a and b then
				nx, ny = a[1] + b[1], a[2] + b[2]
				local len = math.sqrt(nx * nx + ny * ny)
				if len < 0.01 then
					nx, ny = a[1], a[2]
				else
					nx, ny = nx / len, ny / len
				end
			elseif a then
				nx, ny = a[1], a[2]
			elseif b then
				nx, ny = b[1], b[2]
			else
				return
			end
		end
		if g == '2' and i > 1 then
			local mid = span * 0.5
			local d0 = origin + cum[i - 1]
			local d1 = origin + cum[i]
			if d0 < mid and mid < d1 then
				local u = (mid - d0) / (d1 - d0)
				local qx, qy = unitPerp(pts[i - 1][1], pts[i - 1][2], pts[i][1], pts[i][2])
				if qx then
					addEnd(lineMesh,
						pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * u,
						pts[i - 1][2] + (pts[i][2] - pts[i - 1][2]) * u + yShift,
						qx * w, qy * w, c, strokeAlpha(g, a0, 0.5))
				end
			end
		end
		if g == '1' and i > 1 then
			local t0 = at(cum[i - 1])
			local t1 = at(cum[i])
			local steps = math.ceil((t1 - t0) * 32)
			local px, py = unitPerp(pts[i - 1][1], pts[i - 1][2], pts[i][1], pts[i][2])
			if px and steps > 1 then
				for s = 1, steps - 1 do
					local u = s / steps
					addEnd(lineMesh,
						pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * u,
						pts[i - 1][2] + (pts[i][2] - pts[i - 1][2]) * u + yShift,
						px * w, py * w, c, strokeAlpha(g, a0, t0 + (t1 - t0) * u))
				end
			end
		end
		addEnd(lineMesh, pts[i][1], pts[i][2] + yShift, nx * w, ny * w, c, strokeAlpha(g, a0, at(cum[i])))
	end
	ofEnableAlphaBlending()
	ofSetColor(255, 255, 255, 255)
	lineMesh:draw()
end

local function drawPath(pts, yShift)
	local cum, total = pathCum(pts)
	if total < 0.01 then return end
	local onLen, offLen = dashLengths()
	if not onLen then
		drawPolyline(pts, yShift, 0, total)
		return
	end
	if onLen <= 0 then return end
	local period = onLen + offLen
	local d = 0
	while d < total - 0.01 do
		local d1 = math.min(total, d + onLen)
		if d1 - d > 0.5 then
			drawPolyline(slicePath(pts, cum, d, d1), yShift, d, total)
		end
		d = d + period
	end
end

function drawLineStroke()
	if #stroke < 2 then return end
	drawPath(stroke, 0)
	local count = math.floor(brushParameters['harmonics'] or 0)
	if count < 1 then return end
	local last = stroke[#stroke]
	local index = getIntersected(last[1], last[2])
	if not index then return end
	local sel = selects[index]
	local dy = harmonicDy(sel)
	if math.abs(dy) < 0.5 then return end
	for i = 1, count do
		local shift = dy * i
		local fit = true
		for p = 1, #stroke do
			if aboveSelectionTop(sel, stroke[p][2] + shift) then
				fit = false
				break
			end
		end
		if not fit then break end
		drawPath(stroke, shift)
	end
end

function drawStraightLine(x1, y1, x2, y2)
	drawPath({ { x1, y1 }, { x2, y2 } }, 0)
end

function drawType2Line(x1, y1, x2, y2)
	drawStraightLine(x1, y1, x2, y2)
	local count = math.floor(brushParameters['harmonics'] or 0)
	if count < 1 then return end
	local index = getIntersected(x2, y2)
	if not index then return end
	local sel = selects[index]
	local dy = harmonicDy(sel)
	if math.abs(dy) < 0.5 then return end
	for i = 1, count do
		local ay = y1 + dy * i
		local by = y2 + dy * i
		if aboveSelectionTop(sel, ay) or aboveSelectionTop(sel, by) then
			break
		end
		drawStraightLine(x1, ay, x2, by)
	end
end

function drawHarmonicMarks()
	if brushParameters['type'] ~= 'line' then return end
	if buttonsPressed[0] or buttonsPressed[1] or buttonsPressed[2] then return end
	local count = math.floor(brushParameters['harmonics'] or 0)
	if count < 1 then return end
	local x = unscaledX(ofGetMouseX())
	local y = unscaledY(ofGetMouseY())
	local index = getIntersected(x, y)
	if not index then return end
	local sel = selects[index]
	local dy = harmonicDy(sel)
	if math.abs(dy) < 0.5 then return end
	local arm = 4 * (generalSettings['font'] or 1)
	ofEnableAlphaBlending()
	ofSetColor(140, 140, 140, 110)
	ofSetLineWidth(1)
	for i = 1, count do
		local yy = y + dy * i
		if aboveSelectionTop(sel, yy) then break end
		local sx = scaledX(x)
		local sy = scaledY(yy)
		ofDrawLine(sx - arm, sy, sx + arm, sy)
		ofDrawLine(sx, sy - arm, sx, sy + arm)
	end
end
