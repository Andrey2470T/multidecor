multidecor = {}

multidecor.S = core.get_translator("decor_api")

multidecor.colors = {
	"white",
	"red",
	"blue",
	"yellow",
	"green",
	"cyan",
	"magenta",
	"grey"
}

local modpath = core.get_modpath("decor_api")

-- Helpers
dofile(modpath .. "/helpers/common_helpers.lua")

-- Common
dofile(modpath .. "/common/animation.lua")
dofile(modpath .. "/common/connecting.lua")
dofile(modpath .. "/common/placement.lua")
dofile(modpath .. "/common/register.lua")
dofile(modpath .. "/common/shelves.lua")
dofile(modpath .. "/common/sitting.lua")
dofile(modpath .. "/common/tools_sounds.lua")

-- Furniture
dofile(modpath .. "/furniture/banister.lua")
dofile(modpath .. "/furniture/clock.lua")
dofile(modpath .. "/furniture/curtains.lua")
dofile(modpath .. "/furniture/door.lua")
dofile(modpath .. "/furniture/bed.lua")
dofile(modpath .. "/furniture/hanging.lua")
dofile(modpath .. "/furniture/hedge.lua")
dofile(modpath .. "/furniture/lighting.lua")
dofile(modpath .. "/furniture/seat.lua")
dofile(modpath .. "/furniture/table.lua")
dofile(modpath .. "/furniture/tap.lua")
