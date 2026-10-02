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
    local rgbData = FILTER_CACHE[n]
    local readMs = 0
    local sampleMs = 0

    if fboSampleColumnR then
        fboSampleColumnR(fbo2, x, sy, h, rgbData)
        if PERF.on then
            readMs = perfNowMs() - t0
        end
    else
        fbo2:readToPixels(pixels)
        local t1 = PERF.on and perfNowMs() or 0
        readMs = t1 - t0
        local pxW = pixels:getWidth()
        local pxH = pixels:getHeight()
        if x < 0 then
            x = 0
        elseif x >= pxW then
            x = pxW - 1
        end
        for i = 0, 255 do
            local yy = math.floor(sy + (1 - math.min(1, math.max(0, i * 2 / 255))) * (h - 1) + 0.5)
            if yy < 0 then
                yy = 0
            elseif yy >= pxH then
                yy = pxH - 1
            end
            local col = pixels:getColor(pixels:getPixelIndex(x, yy))
            rgbData[i + 1] = 255 - col.r
        end
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
