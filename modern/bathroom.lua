local bathtub_def = {{
	style = "modern",
	material = "stone",
	description = modern.S("Bathtub"),
	mesh = "multidecor_bathtub.b3d",
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_bathroom_leakage.png",
		"multidecor_coarse_metal_material.png"
	},
	groups = {sink=1},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 1.5, -0.1, 0.5},
		{-0.5, -0.1, -0.35, -0.35, 0.5, 0.35},
		{1.35, -0.1, -0.35, 1.5, 0.5, 0.35},
		{-0.5, -0.1, -0.5, 1.5, 0.5, -0.35},
		{-0.5, -0.1, 0.35, 1.5, 0.5, 0.5}
	}
},
{
	seat_data = {
		pos = {x=1.0, y=0.1, z=0.0},
		rot = {x=0, y=-math.pi/2, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1", "sit2"}
	}
}}

multidecor.register.register_seat("bathtub", bathtub_def[1], bathtub_def[2],
{
	recipe = {
		{"multidecor:marble_sheet", "multidecor:marble_sheet", "multidecor:coarse_steel_sheet"},
		{"multidecor:marble_sheet", "multidecor:marble_sheet", "multidecor:steel_stripe"},
		{"multidecor:marble_sheet", "multidecor:hammer", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

local ceramic_tiles = {
	{"darkceladon", {"dye:dark_green"}},
	{"darksea", {"dye:blue"}},
	{"light", {"dye:white", "dye:yellow"}},
	{"sand", {"dye:yellow", "dye:grey"}},
	{"red", {"dye:red"}},
	{"green_mosaic", {"dye:green"}},
	{"brown_flowers", {"dye:brown", "dye:orange"}},
	{"brown_dandelion", {"dye:brown", "dye:orange", "dye:orange"}},
	{"darkceladon_patterned", {"dye:dark_green", "dye:cyan"}},
	{"darksea_patterned", {"dye:blue", "dye:cyan"}},
	{"grey", {"dye:grey"}}
}

local tile_bboxes = {
	type = "wallmounted",
	wall_top = {-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
	wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	wall_side = {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5}

}

minetest.register_node(":multidecor:ceramic_tile", {
	description = modern.S("Ceramic Tile"),
	drawtype = "nodebox",
	visual_scale = 1.0,
	paramtype = "light",
	paramtype2 = "wallmounted",
	tiles = {"default_clay.png"},
	groups = {cracky=3.5},
	node_box = tile_bboxes,
	selection_box = tile_bboxes,
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:ceramic_tile",
	recipe = {"default:clay_lump", "default:clay_lump"}
})

for _, tile in ipairs(ceramic_tiles) do
	local tile_name = "multidecor:bathroom_ceramic_" .. tile[1] .. "_tile"
	local tex_name = "multidecor_bathroom_ceramic_" .. tile[1] .. "_tile.png"
	local upper_tile = multidecor.helpers.upper_first_letters(tile[1])

	minetest.register_node(":" .. tile_name, {
		description = modern.S("Bathroom Ceramic " .. upper_tile .. " Tile"),
		drawtype = "nodebox",
		visual_scale = 1.0,
		paramtype = "light",
		paramtype2 = "wallmounted",
		tiles = {tex_name},
		groups = {cracky=3.5},
		node_box = tile_bboxes,
		selection_box = tile_bboxes,
		sounds = default.node_sound_stone_defaults()
	})

	local recipe = {"multidecor:ceramic_tile"}
	table.copy_to(tile[2], recipe)
	table.insert(recipe, "multidecor:paint_brush")

	minetest.register_craft({
		type = "shapeless",
		output = tile_name,
		recipe = recipe,
		replacements = {{"multidecor:paint_brush", "multidecor:paint_brush"}}
	})

	local block_name = "multidecor:bathroom_ceramic_" .. tile[1] .. "_tiles_block"
	minetest.register_node(":" .. block_name, {
		description = modern.S("Bathroom Ceramic " .. upper_tile .. " Tiles Block"),
		visual_scale = 0.5,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {tex_name},
		groups = {cracky=2.5},
		sounds = default.node_sound_stone_defaults()
	})

	minetest.register_craft({
		type = "shapeless",
		output = block_name,
		recipe = {tile_name, tile_name, tile_name, tile_name, tile_name, tile_name}
	})
end

minetest.register_alias("multidecor:bathroom_ceramic_darkceladon_marble_tile", "multidecor:bathroom_ceramic_darkceladon_patterned_tile")
minetest.register_alias("multidecor:bathroom_ceramic_darkceladon_marble_tiles_block", "multidecor:bathroom_ceramic_darkceladon_patterned_tiles_block")
minetest.register_alias("multidecor:bathroom_ceramic_darksea_marble_tile", "multidecor:bathroom_ceramic_darksea_patterned_tile")
minetest.register_alias("multidecor:bathroom_ceramic_darksea_marble_tiles_block", "multidecor:bathroom_ceramic_darksea_patterned_tiles_block")
minetest.register_alias("multidecor:bathroom_ceramic_marble_tile", "multidecor:bathroom_ceramic_grey_tile")
minetest.register_alias("multidecor:bathroom_ceramic_marble_tiles_block", "multidecor:bathroom_ceramic_grey_tiles_block")


local bathroom_styles = {1, 2, 3, 4, 5, 6}

for _, style in ipairs(bathroom_styles) do
	local style_name = ceramic_tiles[style][1]
	local craft = ceramic_tiles[style][2]
	local tex_name = "multidecor_bathroom_" .. style_name .. "_material.png"
	local upper_tile = multidecor.helpers.upper_first_letters(style_name)

	local panel_name = "multidecor:bathroom_wooden_" .. style_name .. "_panel"
	minetest.register_craftitem(":" .. panel_name, {
		description = modern.S("Bathroom Wooden " .. upper_tile .. " Panel"),
		inventory_image = tex_name
	})

	local panel_craft = {"multidecor:pine_board"}
	table.copy_to(craft, panel_craft)
	table.insert(panel_craft, "multidecor:paint_brush")

	minetest.register_craft({
		type = "shapeless",
		output = panel_name,
		recipe = panel_craft,
		replacements = {{"multidecor:paint_brush", "multidecor:paint_brush"}}
	})

	local bathtub_with_shields_def = table.copy(bathtub_def)
	bathtub_with_shields_def[1].description = modern.S("Bathtub With " .. upper_tile .. " Shields")
	bathtub_with_shields_def[1].mesh = "multidecor_bathtub_with_shields.b3d"
	table.insert(bathtub_with_shields_def[1].tiles, tex_name)

	multidecor.register.register_seat("bathtub_with_shields_" .. style_name,
		bathtub_with_shields_def[1],
		bathtub_with_shields_def[2],
		{
			type = "shapeless",
			recipe = {"multidecor:bathtub", panel_name, panel_name}
		}
	)

	multidecor.register.register_table("bathroom_washbasin_" .. style_name, {
		style = "modern",
		material = "stone",
		description = modern.S("Bathroom Washbasin With " .. upper_tile .. " Doors"),
		mesh = "multidecor_bathroom_washbasin.b3d",
		inventory_image = "multidecor_bathroom_" .. style_name .. "_washbasin_inv.png",
		tiles = {
			"multidecor_marble_material.png",
			"multidecor_metal_material.png",
			"multidecor_coarse_metal_material.png",
			"multidecor_bathroom_leakage.png",
			tex_name,
		},
		groups = {sink=1},
		bounding_boxes = {
			{-0.375, -0.5, -0.075, 0.375, 0.25, 0.5},
			{-0.5, 0.25, -0.4, -0.4, 0.5, 0.5}, 		-- left
			{0.4, 0.25, -0.4, 0.5, 0.5, 0.5},			-- right
			{-0.4, 0.25, -0.4, 0.4, 0.5, -0.2},			-- front
			{-0.4, 0.25, 0.3, 0.4, 0.5, 0.5}			-- back
		},
		callbacks = {
			on_construct = function(pos)
				multidecor.shelves.set_shelves(pos)

				--multidecor.tap.register_water_stream(pos, {x=0.0, y=0.65, z=-0.1}, {x=0.0, y=0.65, z=-0.1}, 30, 2, {x=0, y=-1, z=0}, "multidecor_tap", false)
			end,
			can_dig = multidecor.shelves.can_dig,
			on_rightclick = multidecor.tap.on_rightclick,
			on_destruct = multidecor.tap.on_destruct
		}
	},
	{
		shelves_data = {
			common_name = "bathroom_washbasin_" .. style_name,
			{
				type = "sym_doors",
				pos = {x=0.35, y=-0.2, z=0.08},
				pos2 = {x=-0.35, y=-0.2, z=0.08},
				base_texture = tex_name,
				object = "modern:bathroom_washbasin_door",
				inv_size = {w=5,h=3},
				acc = 1,
				sounds = {
					open = "multidecor_squeaky_door_open",
					close = "multidecor_squeaky_door_close"
				}
			}
		},
		tap_data = {
			min_pos = {x=0.0, y=0.65, z=-0.1},
			max_pos = {x=0.0, y=0.65, z=-0.1},
			amount = 30,
			velocity = 2,
			direction = {x=0, y=-1, z=0},
			sound = "multidecor_tap",
			check_for_sink = false
		}
	},
	{
		recipe = {
			{"multidecor:bathroom_sink", "multidecor:bathroom_tap_with_cap_flap", "multidecor:syphon"},
			{panel_name, panel_name, panel_name},
			{"multidecor:saw", "multidecor:steel_stripe", ""}
		},
		replacements = {{"multidecor:saw", "multidecor:saw"}}
	})

	multidecor.register.register_table("bathroom_wall_cabinet_" .. style_name, {
		style = "modern",
		material = "wood",
		description = modern.S("Bathroom Wall Cabinet With " .. upper_tile .. " Doors"),
		mesh = "multidecor_bathroom_wall_cabinet.b3d",
		tiles = {"multidecor_white_pine_wood.png"},
		inventory_image = "multidecor_bathroom_" .. style_name .. "_wall_cabinet_inv.png",
		bounding_boxes = {
			{-0.5, -0.5, -0.1, 0.5, 0.5, 0.5}
		},
		callbacks = {
			on_construct = function(pos)
				multidecor.shelves.set_shelves(pos)
			end,
			can_dig = multidecor.shelves.can_dig
		}
	},
	{
		shelves_data = {
			common_name = "bathroom_wall_cabinet_" .. style_name,
			{
				type = "sym_doors",
				pos = {x=0.5, y=0, z=0.1},
				pos2 = {x=-0.5, y=0, z=0.1},
				base_texture = tex_name,
				object = "modern:bathroom_wall_cabinet_door",
				inv_size = {w=6,h=4},
				acc = 1,
				sounds = {
					open = "multidecor_squeaky_door_open",
					close = "multidecor_squeaky_door_close"
				}
			}
		}
	},
	{
		recipe = {
			{"multidecor:pine_board", "multidecor:pine_board", "multidecor:pine_board"},
			{"multidecor:pine_board", "dye:white", "multidecor:steel_stripe"},
			{panel_name, "multidecor:saw", ""}
		},
		replacements = {{"multidecor:saw", "multidecor:saw"}}
	})

	multidecor.register.register_table("bathroom_wall_set_with_mirror_" .. style_name, {
		style = "modern",
		material = "wood",
		description = modern.S("Bathroom " .. upper_tile .. "Wall Set With Mirror"),
		mesh = "multidecor_bathroom_wall_set_with_mirror.b3d",
		tiles = {
			"multidecor_white_pine_wood.png",
			"multidecor_gloss.png",
			"multidecor_plastic_material.png",
			"multidecor_metal_material.png",
			"multidecor_bathroom_set.png",
			"multidecor_shred.png"
		},
		inventory_image = "multidecor_bathroom_" .. style_name .. "_wall_set_with_mirror_inv.png",
		bounding_boxes = {{-0.5, -1.0, -0.125, 0.5, 0.5, 0.5}},
		callbacks = {
			on_construct = function(pos)
				multidecor.shelves.set_shelves(pos)
			end,
			can_dig = multidecor.shelves.can_dig
		}
	},
	{
		shelves_data = {
			common_name = "bathroom_wall_set_with_mirror_" .. style_name,
			{
				type = "door",
				pos = {x=0.5, y=-0.25, z=0.05},
				base_texture = tex_name,
				object = "modern:bathroom_wall_set_with_mirror_door",
				inv_size = {w=5,h=2},
				side = "left",
				acc = 1,
				sounds = {
					open = "multidecor_squeaky_door_open",
					close = "multidecor_squeaky_door_close"
				}
			}
		}
	},
	{
		recipe = {
			{"multidecor:pine_board", "multidecor:pine_board", "xpanes:pane_flat"},
			{"multidecor:pine_plank", panel_name, "multidecor:plastic_sheet"},
			{"multidecor:steel_stripe", "multidecor:saw", ""}
		},
		replacements = {{"multidecor:saw", "multidecor:saw"}}
	})
end

multidecor.register.register_furniture_unit("bathroom_fluffy_rug", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Bathroom Fluffy Rug"),
	mesh = "multidecor_bathroom_fluffy_rug.b3d",
	tiles = {
		"multidecor_fluff_material.png"
	},
	bounding_boxes = {{-0.45, -0.5, -0.3, 0.45, -0.4, 0.3}}
},
{
	type = "shapeless",
	recipe = {"multidecor:wool_cloth", "multidecor:wool_cloth", "multidecor:steel_scissors"},
	count = 2,
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("bathroom_sink", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = modern.S("Bathroom Sink"),
	mesh = "multidecor_bathroom_sink.b3d",
	groups = {sink=1},
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_coarse_metal_material.png",
		"multidecor_bathroom_leakage.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.4, 0.5, 0.25, 0.5},
		{-0.5, 0.25, -0.4, -0.4, 0.5, 0.5}, 		-- left
		{0.4, 0.25, -0.4, 0.5, 0.5, 0.5},			-- right
		{-0.4, 0.25, -0.4, 0.4, 0.5, -0.3},			-- front
		{-0.4, 0.25, 0.4, 0.3, 0.5, 0.5}			-- back
	}
},
{
	recipe = {
		{"multidecor:marble_sheet", "multidecor:marble_sheet", "multidecor:steel_sheet"},
		{"multidecor:syphon", "multidecor:marble_sheet", "multidecor:hammer"},
		{"", "", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_furniture_unit("bathroom_shower_base", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = modern.S("Bathroom Shower Base"),
	mesh = "multidecor_shower_base.b3d",
	groups = {sink=1},
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_shower_base.png",
		"multidecor_bathroom_leakage.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
		{-0.5, -0.4, -0.5, -0.425, -0.3, 0.5},
		{0.425, -0.4, -0.5, 0.5, -0.3, 0.5},
		{-0.425, -0.4, 0.425, 0.425, -0.3, 0.5},
		{-0.425, -0.4, -0.5, 0.425, -0.3, -0.425}
	}
},
{
	recipe = {
		{"multidecor:marble_sheet", "multidecor:steel_stripe", "multidecor:hammer"},
		{"multidecor:marble_sheet", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_furniture_unit("bathroom_slatted_ceiling", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Bathroom Slatted Ceiling"),
	mesh = "multidecor_slatted_ceiling.b3d",
	groups = {sink=1},
	tiles = {"multidecor_bathroom_slatted_ceiling.png"},
	bounding_boxes = {{-0.5, 0.35, -0.5, 0.5, 0.5, 0.5}}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "", ""},
		{"multidecor:plastic_sheet", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("bathroom_slatted_ceiling_with_lamp", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	light_source = 12,
	description = modern.S("Bathroom Slatted Ceiling With Lamp"),
	mesh = "multidecor_slatted_ceiling_with_lamp.b3d",
	groups = {sink=1},
	tiles = {
		"multidecor_bathroom_slatted_ceiling.png",
		"multidecor_metal_material.png",
		"multidecor_ceiling_lamp_bottom.png"
	},
	bounding_boxes = {
		{-0.5, 0.35, -0.5, 0.5, 0.5, 0.5},
		{-0.25, 0.25, -0.25, 0.25, 0.35, 0.25}
	}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:bulb", "multidecor:steel_stripe"},
		{"multidecor:plastic_sheet", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_seat("toilet", {
	style = "modern",
	material = "stone",
	description = modern.S("Toilet"),
	mesh = "multidecor_toilet.b3d",
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_water.png"
	},
	bounding_boxes = {
		{-0.3, -0.5, -0.4, 0.3, -0.4, 0.5},		-- down
		{-0.3, -0.4, -0.4, -0.2, -0.1, 0.3},	-- left
		{0.2, -0.4, -0.4, 0.3, -0.1, 0.3},		-- right
		{-0.2, -0.4, -0.4, 0.2, -0.1, -0.3},	-- front
		{-0.3, -0.1, 0.3, 0.3, 0.475, 0.5}		-- back
	},
	callbacks = {
		on_punch = function(pos, node, puncher)
			local dir = multidecor.helpers.get_dir(pos)
			local rel_pos_min = multidecor.helpers.rotate_to_node_dir(pos, vector.new(-0.125, -0.2, 0.05))
			local rel_pos_max = multidecor.helpers.rotate_to_node_dir(pos, vector.new(0.125, -0.2, -0.175))

			minetest.add_particlespawner({
				amount = 40,
				time = 0.1,
				minexptime = 3,
				maxexptime = 5,
				collisiondetection = true,
				object_collision = true,
				collision_removal = true,
				texture = "multidecor_water_drop.png",
				minpos = pos+rel_pos_min,
				maxpos = pos+rel_pos_max,
				minvel = dir*0.5,
				maxvel = dir*0.5,
				minacc = vector.new(0, -9.8, 0),
				maxacc = vector.new(0, -9.8, 0),
				minsize = 0.8,
				maxsize = 1.5
			})

			minetest.sound_play("multidecor_toilet_flush", {gain=1.0, pitch=1.0, pos=pos, max_hear_distance=15})
		end
	}
},
{
	seat_data = {
		pos = {x=0.0, y=-0.1, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"multidecor:marble_sheet", "multidecor:marble_sheet", "bucket:bucket_water"},
		{"multidecor:marble_sheet", "multidecor:metal_bar", "multidecor:hammer"},
		{"", "", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
}
)

multidecor.register.register_curtain("bathroom_curtain", {
	style = "modern",
	material = "plastic",
	paramtype2 = "colorfacedir",
	bounding_boxes = {
		{-0.5, -0.5, -0.1, 0.5, 0.5, 0.1}
	},
	is_colorable = true
},
{
	common_name = "bathroom_curtain",
	curtains_data = {
		sound = "multidecor_curtain_sliding",
		curtain_with_rings = {
			name = "bathroom_curtain_with_rings",
			description = modern.S("Bathroom Curtain With Rings"),
			mesh = "multidecor_curtain_with_rings.b3d",
			tiles = {"multidecor_cloth.png", {name="multidecor_metal_material.png",color=0xffffffff}},
			craft = {
				recipe = {
					{"multidecor:wool_cloth", "multidecor:metal_bar", "multidecor:steel_scissors"},
					{"", "", ""},
					{"", "", ""}
				},
				replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
			}
		},
		curtain = {
			name = "bathroom_curtain",
			description = modern.S("Bathroom Curtain"),
			mesh = "multidecor_curtain.b3d",
			tiles = {"multidecor_cloth.png"},
			craft = {
				recipe = {
					{"multidecor:wool_cloth", "multidecor:steel_scissors", ""},
					{"", "", ""},
					{"", "", ""}
				},
				replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
			}
		}
	}
})

multidecor.register.register_table("plastic_quadratic_cornice", {
	style = "modern",
	material = "plastic",
	description = modern.S("Plastic Quadratic Cornice"),
	mesh = "multidecor_quadratic_cornice.b3d",
	tiles = {"multidecor_plastic_material.png"},
	groups = {hanger=1},
	bounding_boxes = {
		{-0.5, -0.45, -0.1, 0.5, -0.25, 0.1}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "directional")
		end,
		after_dig_node = function(pos, old_node, oldmetadata, digger)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "directional", true, old_node)

			multidecor.curtains.after_dig_node(pos, nil, nil, digger)
		end
	}
},
{
	common_name = "plastic_quadratic_cornice",
	connect_parts = {
		["left_side"] = "multidecor_quadratic_cornice_1.b3d",
		["right_side"] = "multidecor_quadratic_cornice_2.b3d",
		["middle"] = "multidecor_quadratic_cornice_3.b3d",
		["corner"] = "multidecor_quadratic_cornice_4.b3d"
	},
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:steel_scissors"}
	},
	count = 5,
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("bathroom_tap_with_cap_flap", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Bathroom Tap With Cap Flap"),
	mesh = "multidecor_bathroom_tap_with_cap_flap.b3d",
	tiles = {"multidecor_metal_material.png"},
	bounding_boxes = {{-0.3, -0.1, 0.0, 0.3, 0.2, 0.5}},
	callbacks = {
		on_construct = function(pos)
			--multidecor.tap.register_water_stream(pos, {x=0.0, y=-0.15, z=0.0}, {x=0.0, y=-0.15, z=0.0}, 80, 2, {x=0, y=-1, z=0}, "multidecor_tap", true)

			minetest.get_node_timer(pos):start(1)
		end,
		on_rightclick = multidecor.tap.on_rightclick,
		on_destruct = multidecor.tap.on_destruct,
		on_timer = multidecor.tap.on_timer
	},
	add_properties = {
		tap_data = {
			min_pos = {x=0.0, y=-0.15, z=0.0},
			max_pos = {x=0.0, y=-0.15, z=0.0},
			amount = 80,
			velocity = 2,
			direction = {x=0, y=-1, z=0},
			sound = "multidecor_tap",
			check_for_sink = true
		}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:metal_bar", "multidecor:steel_sheet"},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("bathroom_tap_with_side_flaps", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Bathroom Tap With Side Flaps"),
	mesh = "multidecor_bathroom_tap_with_side_flaps.b3d",
	tiles = {"multidecor_metal_material.png"},
	bounding_boxes = {{-0.3, -0.2, 0.0, 0.3, 0.1, 0.5}},
	callbacks = {
		on_construct = function(pos)
			--multidecor.tap.register_water_stream(pos, {x=0.0, y=-0.275, z=-0.025}, {x=0.0, y=-0.275, z=-0.025}, 80, 2, {x=0, y=-1, z=0}, "multidecor_tap", true)

			minetest.get_node_timer(pos):start(1)
		end,
		on_rightclick = multidecor.tap.on_rightclick,
		on_destruct = multidecor.tap.on_destruct,
		on_timer = multidecor.tap.on_timer
	},
	add_properties = {
		tap_data = {
			min_pos = {x=0.0, y=-0.275, z=-0.025},
			max_pos = {x=0.0, y=-0.275, z=-0.025},
			amount = 80,
			velocity = 2,
			direction = {x=0, y=-1, z=0},
			sound = "multidecor_tap",
			check_for_sink = true
		}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:metal_bar", "multidecor:metal_bar"},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("shower_head", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Shower Head"),
	mesh = "multidecor_shower_head.b3d",
	tiles = {"multidecor_metal_material5.png", "multidecor_shower_head.png"},
	bounding_boxes = {{-0.2, -0.5, -0.2, 0.2, 0.35, 0.5}},
	callbacks = {
		on_construct = function(pos)
			--multidecor.tap.register_water_stream(pos, {x=-0.15, y=0.05, z=0.0}, {x=0.15, y=0.2, z=0.0}, 150, 2,
			--	vector.rotate_around_axis(vector.new(0, 1, 0), vector.new(1, 0, 0), -math.pi/3), "multidecor_tap", true)

			minetest.get_node_timer(pos):start(1)
		end,
		on_rightclick = multidecor.tap.on_rightclick,
		on_destruct = multidecor.tap.on_destruct,
		on_timer = multidecor.tap.on_timer
	},
	add_properties = {
		tap_data = {
			min_pos = {x=-0.15, y=0.05, z=0.0},
			max_pos = {x=0.15, y=0.2, z=0.0},
			amount = 150,
			velocity = 2,
			direction = vector.rotate_around_axis(vector.new(0, 1, 0), vector.new(1, 0, 0), -math.pi/3),
			sound = "multidecor_tap",
			check_for_sink = true
		}
	}
},
{
	recipe = {
		{"multidecor:metal_bar", "multidecor:plastic_sheet", ""},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("crooked_shower_head", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Crooked Shower Head"),
	mesh = "multidecor_crooked_shower_head.b3d",
	tiles = {"multidecor_coarse_metal_material.png", "multidecor_crooked_shower_head.png"},
	bounding_boxes = {{-0.2, -0.3, -0.3, 0.2, 0.3, 0.5}},
	callbacks = {
		on_construct = function(pos)
			--multidecor.tap.register_water_stream(pos, {x=-0.25, y=-0.35, z=-0.25}, {x=0.25, y=-0.35, z=0.25}, 250, 2, {x=0, y=-1, z=0}, "multidecor_tap", true)

			minetest.get_node_timer(pos):start(1)
		end,
		on_rightclick = multidecor.tap.on_rightclick,
		on_destruct = multidecor.tap.on_destruct,
		on_timer = multidecor.tap.on_timer
	},
	add_properties = {
		tap_data = {
			min_pos = {x=-0.25, y=-0.35, z=-0.25},
			max_pos = {x=0.25, y=-0.35, z=0.25},
			amount = 250,
			velocity = 2,
			direction = {x=0, y=-1, z=0},
			sound = "multidecor_tap",
			check_for_sink = true
		}
	}
},
{
	recipe = {
		{"multidecor:coarse_steel_sheet", "multidecor:coarse_steel_sheet", "multidecor:plastic_sheet"},
		{"multidecor:coarse_steel_sheet", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("bathroom_mirror", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = modern.S("Bathroom Mirror"),
	mesh = "multidecor_bathroom_mirror.b3d",
	tiles = {"multidecor_gloss.png"},
	bounding_boxes = {{-0.4, -0.5, 0.4, 0.4, 0.5, 0.5}}
},
{
	type = "shapeless",
	recipe = {"stairs:slab_glass", "multidecor:hammer"},
	count = 2,
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_furniture_unit("toilet_paper_reel", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Toilet Paper Reel"),
	mesh = "multidecor_toilet_paper_reel.b3d",
	tiles = {"multidecor_metal_material5.png", "multidecor_wool_material.png"},
	bounding_boxes = {{-0.3, 0, 0.1, 0.3, 0.35, 0.5}}
},
{
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"multidecor:metal_bar", "", ""},
		{"", "", ""}
	}
}
)

multidecor.register.register_furniture_unit("underwear_tank", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Underwear Tank"),
	mesh = "multidecor_underwear_tank.b3d",
	tiles = {"multidecor_shred.png"},
	bounding_boxes = {{-0.4, -0.5, -0.3, 0.4, 0.35, 0.3}},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.can_dig
	},
	add_properties = {
		shelves_data = {
			common_name = "underwear_tank",
			{
				type = "door",
				object = "modern:underwear_tank_cover",
				pos = {x=0, y=0.225, z=-0.3},
				acc = 1,
				inv_size = {w=5,h=4},
				side = "up",
				sounds = {
					open = "multidecor_plastic_open",
					close = "multidecor_plastic_close"
				}
			}
		}
	}
},
{
	recipe = {
		{"multidecor:wool_cloth", "multidecor:wool_cloth", "dye:yellow"},
		{"multidecor:wool_cloth", "multidecor:plastic_sheet", "dye:cyan"},
		{"", "", ""}
	}
})


minetest.register_entity("modern:bathroom_washbasin_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_bathroom_washbasin_door.b3d",
	textures = {"multidecor_" .. ceramic_tiles[1][1] .. ".png", "multidecor_metal_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-0.35, -0.3, -0.05, 0.0, 0.3, 0.0},
	static_save = true,
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})

minetest.register_entity("modern:bathroom_wall_cabinet_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_bathroom_wall_cabinet_door.b3d",
	textures = {"multidecor_" .. ceramic_tiles[1][1] .. ".png", "multidecor_metal_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-0.5, -0.53, 0.0, 0, 0.53, 0.05},
	static_save = true,
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})

minetest.register_entity("modern:bathroom_wall_set_with_mirror_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_bathroom_wall_set_with_mirror_door.b3d",
	textures = {"multidecor_" .. ceramic_tiles[1][1] .. ".png", "multidecor_metal_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-0.35, -0.8, 0, 0, 0.7, 0.075},
	static_save = true,
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})

minetest.register_entity("modern:underwear_tank_cover", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_underwear_tank_cover.b3d",
	textures = {"multidecor_shred.png", "multidecor_metal_material.png"},
	physical = false,
	backface_culling = false,
	selectionbox = {-0.4, 0.0, 0.05, 0.4, 0.15, 0.55},
	static_save = true,
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})
