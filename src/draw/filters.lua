local filterColumnX = {}

local function sampleSpan(pxW, pxH, x0, x1, sy, h, rgbData)
    local xa = math.floor(math.min(x0, x1))
    local xb = math.floor(math.max(x0, x1))
    if xa < 0 then xa = 0 end
    if xb >= pxW then xb = pxW - 1 end
    local maxInk = {}
    for i = 1, 256 do
        maxInk[i] = 0
    end
    local yLo = math.floor(sy + (h - 1) + 0.5)
    local yHi = math.floor(sy + 0.5)
    local ya = math.min(yLo, yHi)
    local yb = math.max(yLo, yHi)
    if ya < 0 then ya = 0 end
    if yb >= pxH then yb = pxH - 1 end
    local denom = h - 1
    local flat = math.abs(denom) <= 1e-4
    for yy = ya, yb do
        local bin = 0
        if not flat then
            local u = 1 - (yy - sy) / denom
            bin = math.floor(u * 255 / 2 + 0.5)
            if bin < 0 then bin = 0 end
            if bin > 127 then bin = 127 end
        end
        local ink = maxInk[bin + 1]
        for x = xa, xb do
            local col = pixels:getColor(pixels:getPixelIndex(x, yy))
            local v = 255 - col.r
            if v > ink then ink = v end
        end
        maxInk[bin + 1] = ink
    end
    if flat then
        for i = 2, 256 do
            maxInk[i] = maxInk[1]
        end
    else
        for i = 129, 256 do
            maxInk[i] = maxInk[128]
        end
    end
    for i = 1, 256 do
        rgbData[i] = maxInk[i]
    end
end

function fillFilterCache(n)
    local sel = selects[n]
    if not sel then
        return FILTER_CACHE[n]
    end
    local cursor = cursors[n]
    if filterCursorSeen[n] == cursor then
        return FILTER_CACHE[n]
    end

    local t0 = PERF.on and perfNowMs() or 0
    local sx = sel["sx"]
    local sy = sel["sy"]
    local w = sel["w"]
    local h = sel["h"]
    local frames = sel["frames"]
    local x = math.floor(sx + cursor / frames * w + 0.5)
    local x0 = x
    local prev = filterColumnX[n]
    if prev and cursor > filterCursorSeen[n] then
        local limit = math.abs(w) / math.max(frames, 1) * 8 + 2
        if math.abs(x - prev) <= limit then
            x0 = prev
        end
    end
    local rgbData = FILTER_CACHE[n]
    local readMs = 0
    local sampleMs = 0

    if fboSampleColumnR then
        local staged = fboSampleColumnR(fbo2, x0, x, sy, h, rgbData)
        if staged ~= false then
            filterColumnX[n] = x
        end
        if PERF.on then
            readMs = perfNowMs() - t0
        end
    else
        fbo2:readToPixels(pixels)
        local t1 = PERF.on and perfNowMs() or 0
        readMs = t1 - t0
        local pxW = pixels:getWidth()
        local pxH = pixels:getHeight()
        sampleSpan(pxW, pxH, x0, x, sy, h, rgbData)
        filterColumnX[n] = x
        if PERF.on then
            sampleMs = perfNowMs() - t1
        end
    end

    filterCursorSeen[n] = cursor

    if PERF.on then
        local t2 = perfNowMs()
        local totalMs = t2 - t0
        local c = perfCol(n)
        if c.lastMs then
            local dt = t2 - c.lastMs
            c.dtSum = c.dtSum + dt
            if dt > c.dtMax then
                c.dtMax = dt
            end
        end
        if c.lastCursor and cursor < c.lastCursor then
            c.passes = c.passes + 1
            local wrapDt = -1
            if c.lastMs then
                wrapDt = t2 - c.lastMs
            end
            print(string.format("PERF WRAP col%d pass=%d cursor=%.0f->%.0f total=%.1fms read=%.1fms sample=%.1fms dt=%.1fms mem=%.0fKB", n, c.passes, c.lastCursor, cursor, totalMs, readMs, sampleMs, wrapDt, collectgarbage("count")))
        end
        c.lastMs = t2
        c.lastCursor = cursor
        c.cursor = cursor
        c.n = c.n + 1
        c.readSum = c.readSum + readMs
        c.sampleSum = c.sampleSum + sampleMs
        c.totalSum = c.totalSum + totalMs
        if readMs > c.readMax then
            c.readMax = readMs
        end
        if sampleMs > c.sampleMax then
            c.sampleMax = sampleMs
        end
        if totalMs > c.totalMax then
            c.totalMax = totalMs
        end
    end

    return rgbData
end

function refreshActiveFilterCaches()
    local any = false
    for n = 1, SEL_CNT do
        if selects[n] and filterCursorSeen[n] ~= cursors[n] then
            any = true
            break
        end
    end
    if not any then
        if PERF.on then
            perfFlush()
        end
        return
    end
    for n = 1, SEL_CNT do
        if selects[n] then
            fillFilterCache(n)
        end
    end
    if PERF.on then
        perfFlush()
    end
end

function pixelColumntToArray(n)
    if not selects[n] then
        return ZERO_FILTER
    end
    return FILTER_CACHE[n]
end
