
webcam = ofVideoGrabber()
webcamOk = false


W = 1280
H = 960
vW = 320
vH = 240
wW = ofGetWidth()
wH = ofGetHeight()

-- cameraScale = 1
-- fontsScale = 1


selects = ofTable()

selectParametersSettings = ofTable()

brushParameters = ofTable()
brushParametersSettings = ofTable()
sends = ofTable()

generalSettingsSettings = ofTable()
generalSettings = ofTable()
generalSettings["camera"] = 1
generalSettings["font"] = 1

pixels = ofPixels()
fbo = ofFbo()
fbo2 = ofFbo()
fboCam = ofFbo()


freqCursor = 0
freqW = 600
freqH = 300
fboFreq = ofFbo()

dynamicSpectres = ofTable()
dynSpectreIndex = 1
activeDynSpectreIndex = nil
SPCTR_CNT = 6

isCameraDraw = false

buttonsPressed = { false, false, false }
prevPointX = nil
prevPointY = nil

startPointX = nil
startPointY = nil
startButton = nil
prevPointX = nil
prevPointY = nil

selectIndex = 1
activeSelectIndex = nil
SEL_CNT = 6
cursors = ofTable(0, 0, 0, 0, 0, 0)

ZERO_FILTER = createCleanFilter()

FILTER_CACHE = ofTable()
for fi = 1, SEL_CNT do
    FILTER_CACHE[fi] = createCleanFilter()
end
filterCursorSeen = ofTable()
for fi = 1, SEL_CNT do
    filterCursorSeen[fi] = -1
end

title = ofTrueTypeFont()
smalltext = ofTrueTypeFont()

isSetting = false

button1PressedTime = nil 

previewParameter = nil

PERF = ofTable()
PERF.on = PERF_REQUESTED == true
PERF.intervalMs = 5000
PERF.lastLogMs = 0
PERF.startMs = nil
PERF.col = ofTable()
PERF.drawN = 0
PERF.drawSumMs = 0
PERF.drawMaxMs = 0
PERF.drawLastMs = 0
PERF.sec = ofTable()
PERF.secOrder = { "frame", "compose", "columns", "present", "spectreBox", "selections", "ui", "highlight", "update", "freq" }
