multidecor = {}

multidecor.S = minetest.get_translator("decor_api")

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

local modpath = minetest.get_modpath("decor_api")

dofile(modpath .. "/common_helpers.lua")
dofile(modpath .. "/connecting.lua")
dofile(modpath .. "/register.lua")


dofile(modpath .. "/banister.lua")
dofile(modpath .. "/clock.lua")
dofile(modpath .. "/curtains.lua")
dofile(modpath .. "/door.lua")
dofile(modpath .. "/bed.lua")
dofile(modpath .. "/hanging.lua")
dofile(modpath .. "/hedge.lua")
dofile(modpath .. "/lighting.lua")
dofile(modpath .. "/placement.lua")
dofile(modpath .. "/sitting.lua")
dofile(modpath .. "/seat.lua")
dofile(modpath .. "/shelves.lua")
dofile(modpath .. "/table.lua")
dofile(modpath .. "/tap.lua")
dofile(modpath .. "/tools_sounds.lua")
