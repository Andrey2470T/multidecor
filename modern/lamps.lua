local silvered_lamp_recipe
local gold_chandelier_recipe

if minetest.get_modpath("moreores") then
	silvered_lamp_recipe = {
		recipe = {
			{"moreores:silver_ingot", "multidecor:bulb", "moreores:silver_ingot"},
			{"moreores:silver_ingot", "multidecor:lampshade", "moreores:silver_ingot"},
			{"", "", ""}
		}
	}

	gold_chandelier_recipe = {
		recipe = {
			{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
			{"default:gold_ingot", "xpanes:pane_flat", "multidecor:four_bulbs_set"},
			{"moreores:silver_ingot", "multidecor:metal_chain", "multidecor:bulb"}
		}
	}
end

local silver_chain_bbox = {
	type = "fixed",
	fixed = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}
}

local silver_chain_on_construct = function(pos)
	local up_node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	local up_def = minetest.registered_nodes[up_node.name]

	if up_node.name ~= "multidecor:silver_chain_tip" and up_node.name ~= "multidecor:silver_chain" and
		not (up_def.drawtype == "airlike" or up_def.drawtype == "liquid" or
			up_def.drawtype == "flowingliquid") then
		minetest.set_node(pos, {name="multidecor:silver_chain_tip"})
	end
end

local silver_chandelier_on_construct = function(pos)
	local up_node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})

	if minetest.get_item_group(up_node.name, "multidecor_silver_chain") == 0 then
		minetest.remove_node(pos)
	end
end

minetest.register_node(":multidecor:silver_chain", {
	drawtype = "mesh",
	visual_scale = 0.5,
	paramtype = "light",
	paramtype2 = "facedir",
	description = "Silver Chain",
	mesh = "multidecor_silver_chain.b3d",
	tiles = {"multidecor_silver_material.png"},
	groups = {cracky=1.5, oddly_breakable_by_hand=0, multidecor_silver_chain=1},
	sounds = default.node_sound_metal_defaults(),
	collision_box = silver_chain_bbox,
    selection_box = silver_chain_bbox,
	on_construct = silver_chain_on_construct
})

minetest.register_node(":multidecor:silver_chain_tip", {
	drawtype = "mesh",
	visual_scale = 0.5,
	paramtype = "light",
	paramtype2 = "facedir",
	description = "Silver Chain",
	mesh = "multidecor_silver_chain_tip.b3d",
	tiles = {"multidecor_silver_material.png", "multidecor_gold_material.png"},
	groups = {cracky=1.5, oddly_breakable_by_hand=0, not_in_creative_inventory=1, multidecor_silver_chain=1},
	sounds = default.node_sound_metal_defaults(),
	collision_box = silver_chain_bbox,
	selection_box = silver_chain_bbox
})


multidecor.register.register_light("silvered_desk_lamp_off", {
	style = "modern",
	material = "metal",
	description = "Silvered Desk Lamp",
	use_texture_alpha = "blend",
	mesh = "multidecor_silvered_desk_lamp.b3d",
	tiles = {"multidecor_silver_material.png", "multidecor_silvered_lampshade.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
},
{
	swap_light = {
		name = "silvered_desk_lamp_on",
		light_level = 10
	}
}, silvered_lamp_recipe)

multidecor.register.register_light("copper_wall_sconce_off", {
	style = "modern",
	material = "glass",
	description = "Copper Wall Sconce",
	paramtype2 = "wallmounted",
	mesh = "multidecor_copper_wall_sconce.b3d",
	tiles = {"multidecor_copper_material.png", "multidecor_bulb_surf.png"},
	bounding_boxes = {{-0.2, 0, 0.3, 0.2, 0.4, 0.5}},
},
{
	swap_light = {
		name = "copper_wall_sconce_on"
	}
},
{
	recipe = {
		{"default:copper_ingot", "multidecor:bulb", ""},
		{"default:copper_ingot", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_light("plastic_desk_lamp_off", {
	style = "modern",
	material = "plastic",
	description = "Plastic Desk Lamp",
	use_texture_alpha = "blend",
	mesh = "multidecor_plastic_desk_lamp.b3d",
	tiles = {"multidecor_plastic_material.png", "multidecor_plastic_desk_lampshade.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
},
{
	swap_light = {
		name = "plastic_desk_lamp_on",
		light_level = 10
	}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:lampshade", "multidecor:plastic_sheet"},
		{"multidecor:plastic_sheet", "multidecor:bulb", "multidecor:plastic_sheet"},
		{"", "multidecor:plastic_sheet", ""}
	}
})

multidecor.register.register_light("gold_chandelier_with_glass_candles_off", {
	style = "modern",
	material = "metal",
	description = "Gold Chandelier With Glass Candles",
	visual_scale = 0.5,
	wield_scale = {x=0.3, y=0.3, z=0.3},
	use_texture_alpha = "blend",
	mesh = "multidecor_gold_chandelier_with_glass_candles.b3d",
	tiles = {
		"multidecor_gold_material.png",
		"multidecor_gloss.png",
		"multidecor_silver_material.png",
		"multidecor_bulb_surf.png"
	},
	bounding_boxes = {
		{-0.15, 0, -0.15, 0.15, 0.5, 0.15},
		{-0.5, -0.5, -0.5, 0.5, 0, 0.5}
	},
	callbacks = {
		on_construct = silver_chandelier_on_construct
	}
},
{
	swap_light = {
		name = "gold_chandelier_with_glass_candles_on",
		light_level = 13
	}
}, gold_chandelier_recipe)

multidecor.register.register_light("metal_chandelier_with_plastic_plafonds_off", {
	style = "modern",
	material = "metal",
	description = "Metal Chandelier With Plastic Plafonds",
	inventory_image = "multidecor_metal_chandelier_inv.png",
	use_texture_alpha = "blend",
	mesh = "multidecor_metal_chandelier_with_plastic_plafonds.b3d",
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_plastic_material.png",
		"multidecor_bulb_surf.png"
	},
	bounding_boxes = {
		{-0.2, -0.1, -0.2, 0.2, 0.5, 0.2},
		{-0.5, -0.5, -0.5, 0.5, -0.1, 0.5}
	},
},
{
	swap_light = {
		name = "metal_chandelier_with_plastic_plafonds_on",
		light_level = 12
	}
},
{
	recipe = {
		{"multidecor:metal_bar", "multidecor:metal_bar", "multidecor:four_lampshades_set"},
		{"multidecor:metal_bar", "multidecor:metal_bar", "multidecor:four_bulbs_set"},
		{"multidecor:metal_bar", "", ""}
	}
})

multidecor.register.register_light("brass_candlestick", {
	style = "modern",
	material = "metal",
	description = "Brass Candlestick",
	visual_scale = 0.5,
	use_texture_alpha = "blend",
	light_source = 10,
	mesh = "multidecor_brass_candlestick.b3d",
	tiles = {
		"multidecor_brass_material.png",
		"multidecor_candle.png",
		{name="multidecor_flame_anim.png", animation={
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0
		}}
	},
	bounding_boxes = {
		{-0.25, -0.5, -0.25, 0.25, -0.4, 0.25},
		{-0.1, -0.4, -0.1, 0.1, 0.125, 0.1}
	},
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "multidecor:brass_ingot"},
		{"multidecor:wax_candle", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_light("ceiling_round_lamp", {
	style = "modern",
	material = "glass",
	description = "Ceiling Round Lamp",
	visual_scale = 0.5,
	light_source = 8,
	mesh = "multidecor_ceiling_round_lamp.b3d",
	tiles = {"multidecor_ceiling_round_lamp.png"},
	bounding_boxes = {{-0.375, 0.4, -0.375, 0.375, 0.5, 0.375}}
})

multidecor.register.register_light("ceiling_wooden_lamp", {
	style = "modern",
	material = "glass",
	description = "Ceiling Wooden Lamp",
	visual_scale = 0.5,
	light_source = 8,
	mesh = "multidecor_ceiling_wooden_lamp.b3d",
	tiles = {
		"multidecor_jungle_wood.png",
		"multidecor_ceiling_lamp_bottom.png"
	},
	bounding_boxes = {{-0.375, 0.4, -0.375, 0.375, 0.5, 0.375}}
})

multidecor.register.register_light("kitchen_chandelier", {
	style = "modern",
	material = "wood",
	description = "Kitchen Chandelier",
	visual_scale = 0.5,
	mesh = "multidecor_kitchen_chandelier.b3d",
	use_texture_alpha = "blend",
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_polished_jungle_wood.png",
		"multidecor_plastic_material.png",
		"multidecor_bulb_surf.png"
	},
	bounding_boxes = {
		{-0.4, -0.5, -0.4, 0.4, 0, 0.4},
		{-0.15, 0, -0.15, 0.15, 0.5, 0.15}
	}
},
{
	swap_light = {
		name = "kitchen_chandelier_on",
		light_level = 12
	}
})
