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

-- Dump warnings about all registered furniture items not having craft recipes

local exclusions = {
    "_on$",
    "_open$",
    "_activated$",
    "_corner$",
    "_edge$",
    "_middle$",
    "_left$",
    "_right$",
    "_double$",
    "_mirrored$",
    "_side$",
    "metal_banister_spiral",
    "terracotta_flowerpot_with_flower_geranium",
    "plastic_banister_spiral",
    "green_small_flowerpot_with_flower_geranium",
    "glass_vase_with_flower_viola",
    "consolidated_oil",
    "green_small_flowerpot_with_flower_rose",
    "green_small_flowerpot_with_flower_viola",
    "terracotta_flowerpot_with_flower_dandelion_white",
    "redwood_banister_spiral",
    "terracotta_flowerpot_with_flower_dandelion_yellow",
    "green_small_flowerpot_with_flower_tulip_black",
    "terracotta_flowerpot_with_flower_viola",
    "glass_vase_with_flower_tulip_black",
    "glass_vase_with_flower_dandelion_white",
    "glass_vase_with_flower_geranium",
    "glass_vase_with_flower_rose",
    "terracotta_flowerpot_with_flower_tulip_black",
    "terracotta_flowerpot_with_flower_tulip",
    "terracotta_flowerpot_with_flower_rose",
    "green_small_flowerpot_with_flower_dandelion_yellow",
    "green_small_flowerpot_with_flower_tulip",
    "green_small_flowerpot_with_flower_dandelion_white",
    "green_small_flowerpot_with_flower_chrysanthemum_green",
    "oil_flowing",
    "oil_source",
    "wolfram_lump",
    "wolfram_ore",
    "glass_vase_with_flower_chrysanthemum_green",
    "terracotta_flowerpot_with_flower_chrysanthemum_green",
    "glass_vase_with_flower_tulip",
    "glass_vase_with_flower_dandelion_yellow",
    "desert_wolfram_ore"
}

multidecor.register.check_craft_recipes(exclusions)
