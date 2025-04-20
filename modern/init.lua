local modpath = minetest.get_modpath("modern")
modern = {}
modern.S = minetest.get_translator("modern")

dofile(modpath .. "/bathroom.lua")
dofile(modpath .. "/bedroom.lua")
dofile(modpath .. "/chairs.lua")
dofile(modpath .. "/covering.lua")
dofile(modpath .. "/doors.lua")
dofile(modpath .. "/fences.lua")
dofile(modpath .. "/kitchen.lua")
dofile(modpath .. "/lamps.lua")
dofile(modpath .. "/living_room.lua")
dofile(modpath .. "/paintings.lua")
dofile(modpath .. "/shelves.lua")
dofile(modpath .. "/stairs.lua")
dofile(modpath .. "/tables.lua")
dofile(modpath .. "/wardrobes.lua")

if minetest.get_modpath("doclib") then
    dofile(modpath .. "/guide_paper.lua")
end
