local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node(":multidecor:wolfram_ore", {
    description = S("Wolfram Ore"),
    tiles = {"default_stone.png^multidecor_wolfram_mineral.png"},
    is_ground_content = true,
    paramtype = "light",
    drop = {
		max_items = 3,
		items = {
			{
				rarity = 1,
				items = {"multidecor:wolfram_lump"}
			}
		}
	},
    groups = {cracky=2.5},
    sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":multidecor:desert_wolfram_ore", {
    description = S("Desert Wolfram Ore"),
    tiles = {"default_desert_stone.png^multidecor_wolfram_mineral.png"},
    is_ground_content = true,
    paramtype = "light",
    drop = {
		max_items = 3,
		items = {
			{
				rarity = 1,
				items = {"multidecor:wolfram_lump"}
			}
		}
	},
    groups = {cracky=2.5},
    sounds = default.node_sound_stone_defaults()
})

minetest.register_ore({
    ore_type = "scatter",
    ore = "multidecor:wolfram_ore",
    wherein = "default:stone",
    clust_scarcity = 2200,
    clust_num_ores = 5,
    clust_size = 2,
    y_min = -31000,
    y_max = -400
})

minetest.register_ore({
    ore_type = "scatter",
    ore = "multidecor:desert_wolfram_ore",
    wherein = "default:desert_stone",
    clust_scarcity = 2200,
    clust_num_ores = 5,
    clust_size = 2,
    y_min = -31000,
    y_max = -400
})

minetest.register_craftitem(":multidecor:wolfram_lump",
{
	description = S("Wolfram Lump"),
	inventory_image = "multidecor_wolfram_lump.png"
})

minetest.register_craftitem(":multidecor:wolfram_ingot",
{
	description = S("Wolfram Ingot"),
	inventory_image = "multidecor_wolfram_ingot.png"
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:wolfram_ingot",
	recipe = "multidecor:wolfram_lump",
	cooktime = 8
})

minetest.register_node(":multidecor:zinc_ore", {
    description = S("Zinc Ore"),
    tiles = {"default_stone.png^multidecor_zinc_mineral.png"},
    is_ground_content = true,
    paramtype = "light",
    drop = {
		max_items = 5,
		items = {
			{
				rarity = 1,
				items = {"multidecor:zinc_fragment"}
			}
		}
	},
    groups = {cracky=3.5},
    sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":multidecor:desert_zinc_ore", {
    description = S("Desert Zinc Ore"),
    tiles = {"default_desert_stone.png^multidecor_zinc_mineral.png"},
    is_ground_content = true,
    paramtype = "light",
    drop = {
		max_items = 5,
		items = {
			{
				rarity = 1,
				items = {"multidecor:zinc_fragment"}
			}
		}
	},
    groups = {cracky=3.5},
    sounds = default.node_sound_stone_defaults()
})

minetest.register_ore({
    ore_type = "scatter",
    ore = "multidecor:zinc_ore",
    wherein = "default:stone",
    clust_scarcity = 1500,
    clust_num_ores = 7,
    clust_size = 5,
    y_min = -31000,
    y_max = -200
})

minetest.register_ore({
    ore_type = "scatter",
    ore = "multidecor:desert_zinc_ore",
    wherein = "default:desert_stone",
    clust_scarcity = 1500,
    clust_num_ores = 7,
    clust_size = 5,
    y_min = -31000,
    y_max = -200
})

minetest.register_craftitem(":multidecor:zinc_fragment",
{
	description = S("Zinc Fragment"),
	inventory_image = "multidecor_zinc_fragment.png"
})

minetest.register_craftitem(":multidecor:zinc_ingot",
{
	description = S("Zinc Ingot"),
	inventory_image = "multidecor_zinc_ingot.png"
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:zinc_ingot",
	recipe = "multidecor:zinc_fragment",
	cooktime = 5
})

minetest.register_node(":multidecor:granite_block", {
	description = S("Granite Block"),
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	tiles = {"multidecor_granite_material.png^[sheet:2x2:0,0"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "multidecor:granite_block",
    wherein = "default:stone",
    column_height_min = 5,
    column_height_max = 15,
    column_midpoint_factor = 0,
    y_min = -500,
    y_max = 0
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "multidecor:granite_block",
    wherein = "default:desert_stone",
    column_height_min = 5,
    column_height_max = 15,
    column_midpoint_factor = 0,
    y_min = -500,
    y_max = 0
})


minetest.register_node(":multidecor:consolidated_oil", {
    description = S("Consolidated Oil (use furnace to melt)"),
    tiles = {"multidecor_consolidated_oil.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2},
    sounds = default.node_sound_stone_defaults()
})

local oil_anim_def = {
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 15
    }
}

local oil_def = {
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = true,
	sunlight_propagates = false,
	drop = "",
	drowning = 1,
	liquid_alternative_flowing = "multidecor:oil_flowing",
	liquid_alternative_source = "multidecor:oil_source",
	liquid_viscosity = 4,
    liquid_range = 5,
    liquid_renewable = true,
	post_effect_color = "black",
	groups = {oil = 1, liquid = 3, not_in_creative_inventory=1}
}

local oil_src_def = table.copy(oil_def)

oil_src_def.description = S("Oil Source")
oil_src_def.drawtype = "liquid"
oil_src_def.tiles = {table.copy(oil_anim_def)}
oil_src_def.tiles[1].name = "multidecor_oil_source_animated.png"
oil_src_def.liquidtype = "source"

minetest.register_node(":multidecor:oil_source", oil_src_def)

local oil_flow_def = table.copy(oil_def)

oil_flow_def.description = S("Flowing Oil")
oil_flow_def.drawtype = "flowingliquid"
oil_flow_def.paramtype2 = "flowingliquid"
oil_flow_def.tiles = {"multidecor_oil_source.png"}
oil_flow_def.special_tiles = {table.copy(oil_anim_def), table.copy(oil_anim_def)}
oil_flow_def.special_tiles[1].name = "multidecor_oil_flowing_animated.png"
oil_flow_def.special_tiles[2].name = "multidecor_oil_flowing_animated.png"
oil_flow_def.liquidtype = "flowing"
oil_flow_def.on_rightclick = function (pos, node, player, itemstack, pointed_thing)
    if itemstack:get_name() == "bucket:bucket_empty" then
        minetest.remove_node(pos)
        itemstack:take_item()
        local stack = ItemStack("craft_ingredients:oil_bucket")
	    local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	    inv:add_item("main", stack)
    end

    return itemstack
end

minetest.register_node(":multidecor:oil_flowing", oil_flow_def)

minetest.register_ore({
    ore_type = "scatter",
    ore = "multidecor:consolidated_oil",
    wherein = {"default:stone", "default:desert_stone"},
    clust_scarcity = 1200,
    clust_num_ores = 20,
    clust_size = 3,
    y_min = -31000,
    y_max = -100
})

minetest.register_ore({
    ore_type = "blob",
    ore = "multidecor:oil_source",
    wherein = "multidecor:consolidated_oil",
    clust_scarcity = 1500,
    clust_num_ores = 3,
    clust_size = 2,
    y_min = -31000,
    y_max = -30
})
