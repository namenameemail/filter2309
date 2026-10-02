if type(window) ~= "userdata" then window = ofWindow() end
local canvas = ofCanvas(this)
local _src = canvas:getDir() .. "/src/"
local env = setmetatable({}, { __index = _G, __newindex = _G })
env.pixels = ofPixels()
env.M = M
env.this = this
env.canvas = canvas
local function include(name) local chunk, err = loadfile(_src .. name, "t", env) if not chunk then error(err) end chunk() end
include("app/boot.lua")
include("app/save.lua")
include("input/preview.lua")
include("util/printtable.lua")
include("app/setup.lua")
include("draw/selections.lua")
include("draw/frame.lua")
include("input/mouse.lua")
include("input/keys.lua")
include("app/lifecycle.lua")
