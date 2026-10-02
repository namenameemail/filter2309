freqPendingColumns = 0
FREQ_MAX_PENDING_COLUMNS = 4

function drawFreq()
    freqPendingColumns = math.min(freqPendingColumns + 1, FREQ_MAX_PENDING_COLUMNS)
end

function drawPendingFreq()
    if freqPendingColumns == 0 then
        return
    end
    local t0 = perfNowMs()
    local freqs = ofArray('freq'):get(0)
    local lastFreq = #freqs
    fboFreq:beginFbo()
    ofFill()
    for _ = 1, freqPendingColumns do
        for i = 1, freqH do
            local color = (1 - freqs[math.min(math.floor(i / freqH * 255 / 2) + 1, lastFreq)]) * 255
            ofSetColor(color, color, color, 255)
            ofDrawRectangle(freqCursor, freqH - i, 1, 1)
        end
        freqCursor = freqCursor + 1
        if freqCursor > freqW then
            freqCursor = 1
        end
    end
    fboFreq:endFbo()
    freqPendingColumns = 0
    perfSince("freq", t0)
end
