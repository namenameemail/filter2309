function perfNowMs()
    if ofGetElapsedTimeMicros then
        return ofGetElapsedTimeMicros() / 1000
    end
    return ofGetElapsedTimef() * 1000
end

function perfAdd(name, dt)
    local s = PERF.sec[name]
    if not s then
        s = ofTable()
        s.n = 0
        s.sum = 0
        s.max = 0
        PERF.sec[name] = s
    end
    s.n = s.n + 1
    s.sum = s.sum + dt
    if dt > s.max then
        s.max = dt
    end
end

function perfSection(name)
    if not PERF.on or not PERF._secT then
        return
    end
    local now = perfNowMs()
    perfAdd(name, now - PERF._secT)
    PERF._secT = now
end

function perfSince(name, t0)
    if PERF.on then
        perfAdd(name, perfNowMs() - t0)
    end
end

function perfFlushSections()
    local parts = {}
    for _, name in ipairs(PERF.secOrder) do
        local s = PERF.sec[name]
        if s and s.n > 0 then
            parts[#parts + 1] = string.format("%s=%.2f/%.1f", name, s.sum / s.n, s.max)
            s.n = 0
            s.sum = 0
            s.max = 0
        end
    end
    print("PERF sections avg/max ms: " .. table.concat(parts, " "))
    perfFlushStats()
end

function perfFlushStats()
    local s = perfStatsTake and perfStatsTake()
    if not s then
        return
    end
    local now = perfNowMs()
    local sec = math.max((now - (PERF._statsT or now - PERF.intervalMs)) / 1000, 0.001)
    PERF._statsT = now
    local sr = 44100
    local ticksNeeded = sr / 64 * sec
    local worklet = (s.worklet or 0) == 1
    local outputQueueFrames = worklet and 128 or s.bufferFrames * 2
    local estLatencyMs = (s.ringAvgFrames + outputQueueFrames) / sr * 1000 + math.max(s.baseLatencyMs, 0) + math.max(s.outputLatencyMs, 0)
    local realtimeX = s.dspMs > 0 and s.ticks * 64 / sr * 1000 / s.dspMs or 0
    print(string.format("PERF pd ticksPct=%.0f dsp=%.0fms/s lockWait=%.0fms/s realtimeX=%.2f", s.ticks / ticksNeeded * 100, s.dspMs / sec, s.lockWaitMs / sec, realtimeX))
    print(string.format("PERF out worklet=%d running=%d underruns=%d late=%d gapMax=%.1fms ring min/avg/target=%.0f/%.0f/%d frames base=%.1fms out=%.1fms estLatency=%.0fms", worklet and 1 or 0, s.audioRunning or -1, s.underruns, s.lateCallbacks, s.callbackGapMaxMs, s.ringMinFrames, s.ringAvgFrames, s.ringTargetFrames, s.baseLatencyMs or -1, s.outputLatencyMs or -1, estLatencyMs))
    print(string.format("PERF main pdLocks=%d pdWait=%.1fms/s pdHold=%.1fms/s pdHoldMax=%.2fms luaHold=%.0fms/s luaHoldMax=%.1fms longTasks=%d longTaskMax=%.0fms", s.mainLocks, s.mainLockWaitMs / sec, s.mainLockHoldMs / sec, s.mainLockHoldMaxMs, s.luaHoldMs / sec, s.luaHoldMaxMs, s.longTasks or -1, s.longTaskMaxMs or -1))
end

function perfCol(n)
    local c = PERF.col[n]
    if not c then
        c = ofTable()
        c.n = 0
        c.readSum = 0
        c.readMax = 0
        c.sampleSum = 0
        c.sampleMax = 0
        c.totalSum = 0
        c.totalMax = 0
        c.dtSum = 0
        c.dtMax = 0
        c.lastMs = nil
        c.lastCursor = nil
        c.passes = 0
        c.cursor = 0
        PERF.col[n] = c
    end
    return c
end

function perfBeginDraw()
    if not PERF.on then
        return
    end
    local now = perfNowMs()
    if PERF._lastDrawT0 then
        perfAdd("frame", now - PERF._lastDrawT0)
    end
    PERF._lastDrawT0 = now
    PERF._drawT0 = now
    PERF._secT = now
end

function perfEndDraw()
    if not PERF.on or not PERF._drawT0 then
        return
    end
    local dt = perfNowMs() - PERF._drawT0
    PERF.drawN = PERF.drawN + 1
    PERF.drawSumMs = PERF.drawSumMs + dt
    if dt > PERF.drawMaxMs then
        PERF.drawMaxMs = dt
    end
    PERF.drawLastMs = dt
    PERF._drawT0 = nil
    perfFlush()
end

function perfFlush()
    if not PERF.on then
        return
    end
    local now = perfNowMs()
    if PERF.startMs == nil then
        PERF.startMs = now
    end
    if now - PERF.lastLogMs < PERF.intervalMs then
        return
    end
    PERF.lastLogMs = now

    local mem = collectgarbage("count")
    local fps = 0
    if ofGetFrameRate then
        fps = ofGetFrameRate()
    end
    local drawAvg = 0
    if PERF.drawN > 0 then
        drawAvg = PERF.drawSumMs / PERF.drawN
    end
    local alive = 0
    for i = 1, SEL_CNT do
        if selects[i] then
            alive = alive + 1
        end
    end
    local pxW = -1
    local pxH = -1
    if pixels and pixels.getWidth then
        pxW = pixels:getWidth()
        pxH = pixels:getHeight()
    end
    print(string.format("PERF t=%.1fs fps=%.1f drawAvg=%.1fms drawMax=%.1fms drawLast=%.1fms mem=%.0fKB selects=%d pixels=%dx%d", (now - PERF.startMs) / 1000, fps, drawAvg, PERF.drawMaxMs, PERF.drawLastMs, mem, alive, pxW, pxH))

    for n = 1, SEL_CNT do
        local c = PERF.col[n]
        if c and c.n > 0 then
            print(string.format("PERF col%d calls=%d readAvg=%.1fms readMax=%.1fms sampleAvg=%.1fms sampleMax=%.1fms totalAvg=%.1fms totalMax=%.1fms dtAvg=%.1fms dtMax=%.1fms passes=%d cursor=%.0f", n, c.n, c.readSum / c.n, c.readMax, c.sampleSum / c.n, c.sampleMax, c.totalSum / c.n, c.totalMax, c.dtSum / c.n, c.dtMax, c.passes, c.cursor))
            c.n = 0
            c.readSum = 0
            c.readMax = 0
            c.sampleSum = 0
            c.sampleMax = 0
            c.totalSum = 0
            c.totalMax = 0
            c.dtSum = 0
            c.dtMax = 0
        end
    end

    perfFlushSections()

    PERF.drawN = 0
    PERF.drawSumMs = 0
    PERF.drawMaxMs = 0
end
