local _src = ofCanvas(this):getDir() .. "/src/"
local function include(name) dofile(_src .. name) end
include("app/state.lua")
include("app/perf.lua")
include("draw/freq.lua")
include("draw/filters.lua")
include("model/hit.lua")
include("model/selects.lua")
include("model/brush.lua")
include("model/settings.lua")
include("draw/hud.lua")
include("app/coords.lua")
