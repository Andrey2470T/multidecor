local silvered_lamp_recipe
local gold_chandelier_recipe
local silver_candlestick_recipe
local silver_chain_recipe

if minetest.get_modpath("moreores") then
	silvered_lamp_recipe = {
		recipe = {
			{"multidecor:silver_sheet", "multidecor:bulb", ""},
			{"multidecor:silver_sheet", "multidecor:lampshade", ""},
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

	silver_candlestick_recipe = {
		recipe = {
			{"multidecor:silver_sheet", "multidecor:steel_scissors", ""},
			{"multidecor:wax_candle", "", ""},
			{"", "", ""}
		}
	}

	silver_chain_recipe = {
		recipe = {
			{"multidecor:metal_chain", "default:gold_ingot", ""},
			{"", "", ""},
			{"", "", ""}
		}
	}
end

local silver_chain_bbox = {
	{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}
}

multidecor.hanging.hangers["silver_chain"] = {
	["top"] = "multidecor:silver_chain_tip",
	["medium"] = "multidecor:silver_chain"
}

multidecor.register.register_furniture_unit("silver_chain", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Silver Chain"),
	mesh = "multidecor_silver_chain.b3d",
	tiles = {"multidecor_silver_material.png"},
	groups = {cracky=1.5, not_in_creative_inventory=1, hanger_medium=1},
	bounding_boxes = silver_chain_bbox,
	callbacks = {
		after_place_node = multidecor.hanging.after_place_node
	},
	add_properties = {
		common_name = "silver_chain"
	}
})

multidecor.register.register_furniture_unit("silver_chain_tip", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Silver Chain Tip"),
	mesh = "multidecor_silver_chain_tip.b3d",
	tiles = {"multidecor_silver_material.png", "multidecor_gold_material.png"},
	groups = {cracky=1.5, hanger_top=1},
	bounding_boxes = silver_chain_bbox,
	callbacks = {
		after_place_node = multidecor.hanging.after_place_node
	},
	add_properties = {
		common_name = "silver_chain"
	}
}, silver_chain_recipe)


multidecor.register.register_light("silvered_desk_lamp_off", {
	style = "modern",
	material = "metal",
	description = modern.S("Silvered Desk Lamp"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	use_texture_alpha = "blend",
	mesh = "multidecor_silvered_desk_lamp.b3d",
	tiles = {{name="multidecor_silver_material.png", color=0xffffffff}, "multidecor_silvered_lampshade.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
	is_colorable = true
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
	description = modern.S("Copper Wall Sconce"),
	visual_scale = 0.4,
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
	description = modern.S("Plastic Desk Lamp"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	use_texture_alpha = "blend",
	mesh = "multidecor_plastic_desk_lamp.b3d",
	tiles = {
		{name="multidecor_plastic_material.png", color=0xffffffff},
		"multidecor_plastic_desk_lampshade.png",
		{name="multidecor_bulb_surf.png", color=0xffffffff}
	},
	is_colorable = true,
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
	description = modern.S("Gold Chandelier With Glass Candles"),
	wield_scale = {x=0.3, y=0.3, z=0.3},
	use_texture_alpha = "blend",
	groups = {hanger_bottom=1},
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
		after_place_node = multidecor.hanging.after_place_node
	}
},
{
	common_name = "silver_chain",
	swap_light = {
		name = "gold_chandelier_with_glass_candles_on",
		light_level = 13
	}
}, gold_chandelier_recipe)

multidecor.register.register_light("metal_chandelier_with_plastic_plafonds_off", {
	style = "modern",
	material = "metal",
	description = modern.S("Metal Chandelier With Plastic Plafonds"),
	visual_scale = 0.4,
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
	description = modern.S("Brass Candlestick"),
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
		{"multidecor:brass_sheet", "multidecor:steel_scissors", ""},
		{"multidecor:wax_candle", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_light("silver_candlestick", {
	style = "modern",
	material = "metal",
	description = modern.S("Silver Candlestick"),
	use_texture_alpha = "blend",
	light_source = 10,
	mesh = "multidecor_brass_candlestick.b3d",
	tiles = {
		"multidecor_silver_material.png",
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
}, silver_candlestick_recipe)

multidecor.register.register_light("ceiling_round_lamp", {
	style = "modern",
	material = "glass",
	description = modern.S("Ceiling Round Lamp"),
	light_source = 12,
	mesh = "multidecor_ceiling_round_lamp.b3d",
	tiles = {"multidecor_ceiling_round_lamp.png"},
	bounding_boxes = {{-0.375, 0.4, -0.375, 0.375, 0.5, 0.375}}
},
{
	recipe = {
		{"multidecor:steel_stripe", "xpanes:pane_flat", ""},
		{"multidecor:wolfram_wire", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_light("ceiling_wooden_lamp", {
	style = "modern",
	material = "glass",
	description = modern.S("Ceiling Wooden Lamp"),
	light_source = 12,
	mesh = "multidecor_ceiling_wooden_lamp.b3d",
	tiles = {
		"multidecor_jungle_wood.png",
		"multidecor_ceiling_lamp_bottom.png"
	},
	bounding_boxes = {{-0.375, 0.4, -0.375, 0.375, 0.5, 0.375}}
},
{
	recipe = {
		{"multidecor:jungleplank", "xpanes:pane_flat", ""},
		{"multidecor:wolfram_wire", "multidecor:saw", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
})

multidecor.register.register_light("kitchen_chandelier", {
	style = "modern",
	material = "wood",
	description = modern.S("Kitchen Chandelier"),
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
},
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:metal_wire"},
		{"multidecor:plastic_sheet", "multidecor:bulb", "multidecor:saw"},
		{"", "", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
})
