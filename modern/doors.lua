multidecor.register.register_door("high_dark_rusty_gate", {
	style = "modern",
	material = "metal",
	description = modern.S("High Dark Rusty Gate"),
	mesh = "multidecor_high_dark_rusty_gate.b3d",
	tiles = {
		"multidecor_fence_chainlink.png",
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_wood.png",
		"multidecor_metal_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		vel = 90, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:high_dark_rusty_fence", "multidecor:steel_stripe", ""},
		{"multidecor:steel_scissors", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_door("dark_rusty_gate", {
	style = "modern",
	material = "metal",
	description = modern.S("Dark Rusty Gate"),
	mesh = "multidecor_dark_rusty_gate.b3d",
	tiles = {
		"multidecor_fence_chainlink.png",
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_wood.png",
		"multidecor_metal_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4}}
},
{
	door = {
		vel = 90, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	type = "shapeless",
	recipe = {"multidecor:high_dark_rusty_gate", "multidecor:high_dark_rusty_gate"}
})

local woods = {
	{name="wooden", texture="multidecor_wood"},
	{name="pine", texture="multidecor_pine_wood2"},
	{name="aspen", texture="multidecor_pine_wood"},
	{name="white_pine", texture="multidecor_white_pine_wood"}
}

local doors_hands_texs = {
	"multidecor_metal_material",
	"multidecor_copper_material",
	"multidecor_brass_material",
	"multidecor_gold_material",
	"multidecor_gold_material"
}

local doors_hands_metals = {
	"default:steel_ingot",
	"default:copper_ingot",
	"multidecor:brass_ingot",
	"default:gold_ingot",
	"default:gold_ingot"
}

if minetest.get_modpath("ethereal") then
	table.insert(woods, {name="redwood", texture="ethereal_redwood_wood"})
end

for i, wood in ipairs(woods) do
	local upper_name = multidecor.helpers.upper_first_letters(wood.name)

	local material_name = ""

	local white_dye = ""
	if wood.name == "white_pine" then
		material_name = "pine_"
		white_dye = "dye:white"
	elseif wood.name ~= "wooden" then
		material_name = wood.name .. "_"
	end


	local base_texture = wood.texture .. ".png"

	if wood.name == "redwood" then
		base_texture = base_texture .. "^[transform1"
	end

	local board = "multidecor:" .. material_name .. "board"
	multidecor.register.register_door("simple_" .. wood.name .. "_door", {
		style = "modern",
		material = "wood",
		description = modern.S("Simple " .. upper_name .. " Door"),
		mesh = "multidecor_modern_wooden_door.b3d",
		tiles = {
			base_texture .. "^multidecor_door_hinges.png",
			doors_hands_texs[i] .. ".png"
		},
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
	},
	{
		common_name = "simple_" .. wood.name .. "_door",
		door = {
			has_mirrored_counterpart = true,
			--vel = 100, -- degrees per sec
			sounds = {
				open = "multidecor_wooden_door_open",
				close = "multidecor_wooden_door_close"
			}
		}
	},
	{
		recipe = {
			{board, board, "multidecor:saw"},
			{doors_hands_metals[i], white_dye, ""},
			{"", "", ""}
		},
		replacements = {{"multidecor:saw", "multidecor:saw"}}
	})

	local plinth = "multidecor:" .. wood.name .. "_plinth"
	multidecor.register.register_furniture_unit(wood.name .. "_doorjamb", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Doorjamb"),
		mesh = "multidecor_wooden_doorjamb.b3d",
		tiles = {base_texture},
		bounding_boxes = {
			{-0.725, -0.5, 0.4, -0.5, 1.725, 0.5},-- left
			{0.725, -0.5, 0.4, 0.5, 1.725, 0.5},-- right
			{-0.5, 1.5, 0.4, 0.5, 1.725, 0.5}
		}
	},
	{
		recipe = {
			{plinth, plinth, plinth},
			{plinth, plinth, "multidecor:hammer"},
			{"", "", ""}
		},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	local plank = "multidecor:" .. material_name .. "plank"
	multidecor.register.register_furniture_unit(wood.name .. "_plinth", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Plinth"),
		mesh = "multidecor_wooden_plinth.b3d",
		tiles = {base_texture},
		bounding_boxes = {{-0.5, -0.5, 0.4, 0.5, -0.2, 0.5}}
	},
	{
		type = "shapeless",
		recipe = {plank, "multidecor:saw", white_dye},
		count = 2,
		replacements = {{"multidecor:saw", "multidecor:saw"}}
	})

	multidecor.register.register_furniture_unit(wood.name .. "_corner_plinth", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Corner Plinth"),
		mesh = "multidecor_wooden_corner_plinth.b3d",
		tiles = {base_texture},
		bounding_boxes = {
			{-0.5, -0.5, 0.4, 0.5, -0.2, 0.5},
			{0.4, -0.5, -0.5, 0.5, -0.2, 0.4}
		}
	},
	{
		type = "shapeless",
		recipe = {plinth, plinth, "multidecor:hammer"},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	multidecor.register.register_furniture_unit(wood.name .. "_window_segment", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Window Segment"),
		mesh = "multidecor_window_segment.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.38}}
	},
	{
		recipe = {
			{plank, plank, "multidecor:hammer"},
			{"xpanes:pane_flat", white_dye, ""},
			{"", "", ""}
		},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	-- TODO 'vertical' connection type is not workable currently, needs in a repair in next releases
	--[[multidecor.register.register_table(wood.name .. "_window_segment_connectable", {
		style = "modern",
		material = "wood",
		description = upper_name .. "Window Segment (Connectable)",
		mesh = "multidecor_window_segment.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.38}},
		callbacks = {
			on_construct = function(pos)
				multidecor.connecting.update_adjacent_nodes_connection(pos, "vertical")
			end,
			after_dig_node = function(pos, oldnode)
				multidecor.connecting.update_adjacent_nodes_connection(pos, "vertical", true, oldnode)
			end
		}
	},
	{
		common_name = wood.name .. "_window_segment_connectable",
		connect_parts = {
			["edge"] = "multidecor_window_segment_1.b3d",
			["corner"] = "multidecor_window_segment_2.b3d",
			["middle"] = "multidecor_window_segment_5.b3d",
			["edge_middle"] = "multidecor_window_segment_3.b3d",
			["off_edge"] = "multidecor_window_segment_4.b3d"
		}
	})]]

	multidecor.register.register_furniture_unit(wood.name .. "_window_segment_with_thick_slats", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Window Segment With Thick Slats"),
		mesh = "multidecor_window_segment_with_thick_slats.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.38}}
	},
	{
		recipe = {
			{plank, plank, "multidecor:hammer"},
			{"xpanes:pane_flat", plank, plank},
			{white_dye, "", ""}
		},
		count = 2,
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	multidecor.register.register_furniture_unit(wood.name .. "_window_segment_with_thin_slats", {
		type = "decoration",
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Window Segment With Thin Slats"),
		mesh = "multidecor_window_segment_with_thin_slats.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.38}}
	},
	{
		recipe = {
			{plank, plank, "multidecor:hammer"},
			{"xpanes:pane_flat", plank, white_dye},
			{"", "", ""}
		},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	local window = "multidecor:" .. wood.name .. "_window_segment"
	multidecor.register.register_door(wood.name .. "_window_door", {
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Window Door"),
		mesh = "multidecor_window_door.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.38}}
	},
	{
		door = {
			--vel = 100, -- degrees per sec
			sounds = {
				open = "multidecor_wooden_door_open",
				close = "multidecor_wooden_door_close"
			}
		}
	},
	{
		type = "shapeless",
		recipe = {window, window, plank, "multidecor:hammer", white_dye},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})

	local window_with_thin_slats = "multidecor:" .. wood.name .. "_window_segment_with_thin_slats"
	multidecor.register.register_door(wood.name .. "_window_door_with_thin_slats", {
		style = "modern",
		material = "wood",
		description = modern.S(upper_name .. "Window Door With Thin Slats"),
		mesh = "multidecor_window_door_with_thin_slats.b3d",
		tiles = {
			base_texture,
			"multidecor_glass_material.png"
		},
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.38}}
	},
	{
		door = {
			--vel = 100, -- degrees per sec
			sounds = {
				open = "multidecor_wooden_door_open",
				close = "multidecor_wooden_door_close"
			}
		}
	},
	{
		type = "shapeless",
		recipe = {window_with_thin_slats, window_with_thin_slats, plank, "multidecor:hammer", white_dye},
		replacements = {{"multidecor:hammer", "multidecor:hammer"}}
	})
end

multidecor.register.register_door("patterned_wooden_door", {
	style = "modern",
	material = "wood",
	description = modern.S("Patterned Wooden Door"),
	mesh = "multidecor_modern_wooden_door.b3d",
	tiles = {
		"multidecor_modern_wooden_door_base.png^multidecor_door_hinges.png",
		"multidecor_jungle_wood.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
},
{
	common_name = "patterned_wooden_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:board", "multidecor:plank", "multidecor:steel_stripe"},
		{"multidecor:board", "multidecor:plank", "multidecor:steel_scissors"},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_door("bathroom_door", {
	style = "modern",
	material = "wood",
	description = modern.S("Bathroom Door"),
	mesh = "multidecor_bathroom_door.b3d",
	tiles = {
		"multidecor_white_pine_wood.png^multidecor_door_hinges.png",
		"multidecor_pine_wood2.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
},
{
	common_name = "bathroom_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:pine_board", "multidecor:pine_plank", "multidecor:pine_plank"},
		{"multidecor:pine_board", "dye:white", "multidecor:saw"},
		{"", "", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
})

multidecor.register.register_door("white_pine_glass_door", {
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = modern.S("White Pine Glass Door"),
	mesh = "multidecor_white_pine_glass_door.b3d",
	tiles = {
		"multidecor_white_pine_wood.png^(multidecor_door_hinges.png^[transform2)",
		"multidecor_gold_material.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
},
{
	common_name = "white_pine_glass_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:pine_plank", "multidecor:pine_plank", "multidecor:pine_plank"},
		{"multidecor:pine_plank", "dye:white", "multidecor:hammer"},
		{"xpanes:pane_flat", "xpanes:pane_flat", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_door("patterned_aspen_glass_door", {
	style = "modern",
	material = "wood",
	description = modern.S("Patterned Aspen Glass Door"),
	mesh = "multidecor_pine_glass_door.b3d",
	tiles = {
		"multidecor_pine_glass_door_base2.png^multidecor_door_hinges.png",
		"multidecor_metal_material.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	common_name = "patterned_aspen_glass_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:aspen_board", "xpanes:pane_flat", "multidecor:aspen_plank"},
		{"multidecor:aspen_board", "xpanes:pane_flat", "multidecor:aspen_plank"},
		{"multidecor:steel_stripe", "multidecor:hammer", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_door("patterned_aspen_door", {
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = modern.S("Patterned Aspen Door"),
	mesh = "multidecor_pine_door.b3d",
	tiles = {
		"multidecor_pine_door.png^multidecor_door_hinges.png",
		"multidecor_metal_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	common_name = "patterned_aspen_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:aspen_board", "multidecor:aspen_plank", "multidecor:aspen_plank"},
		{"multidecor:aspen_board", "multidecor:steel_stripe", "multidecor:hammer"},
		{"", "", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_door("pine_glass_door", {
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = modern.S("Pine Glass Door"),
	mesh = "multidecor_dark_pine_glass_door.b3d",
	tiles = {
		"multidecor_dark_pine_door_base.png",
		"multidecor_metal_material.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	common_name = "pine_glass_door",
	door = {
		has_mirrored_counterpart = true,
		--vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:pine_board", "multidecor:pine_plank", "xpanes:pane_flat"},
		{"multidecor:pine_board", "multidecor:steel_stripe", "multidecor:hammer"},
		{"", "", ""}
	},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}}
})

multidecor.register.register_door("technical_locked_door", {
	style = "modern",
	material = "metal",
	description = modern.S("Technical Locked Door"),
	mesh = "multidecor_technical_door.b3d",
	use_texture_alpha = "blend",
	tiles = {
		"multidecor_metal_material2.png",
		"multidecor_metal_material.png",
		"multidecor_metal_door_chainlink.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		has_lock = true,
		vel = 70, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:chainlink", "multidecor:steel_scissors"},
		{"multidecor:steel_sheet", "multidecor:steel_sheet", ""},
		{"multidecor:steel_sheet", "multidecor:steel_sheet", ""}
	}
})

multidecor.register.register_door("metallic_locked_door", {
	style = "modern",
	material = "metal",
	description = modern.S("Metallic Locked Door"),
	mesh = "multidecor_door_with_lock.b3d",
	use_texture_alpha = "blend",
	tiles = {
		"multidecor_coarse_metal_material.png^multidecor_door_hinges.png",
		"multidecor_metal_material3.png",
		"multidecor_glass_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		has_lock = true,
		vel = 70, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:coarse_steel_sheet", "multidecor:coarse_steel_sheet", "multidecor:steel_scissors"},
		{"multidecor:steel_stripe", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

if minetest.get_modpath("ethereal") then
	multidecor.register.register_door("redwood_locked_door", {
		style = "modern",
		material = "metal",
		description = modern.S("Redwood Locked Door"),
		mesh = "multidecor_door_with_lock.b3d",
		use_texture_alpha = "blend",
		tiles = {
			"ethereal_redwood_wood.png^[transform1^multidecor_door_hinges.png",
			"multidecor_metal_material3.png",
			"multidecor_glass_material.png"
		},
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
	},
	{
		door = {
			has_lock = true,
			vel = 70, -- degrees per sec
			sounds = {
				open = "multidecor_metallic_door_open",
				close = "multidecor_metallic_door_close"
			}
		}
	},
	{
		recipe = {
			{"multidecor:redwood_board", "multidecor:redwood_board", "multidecor:steel_scissors"},
			{"multidecor:steel_stripe", "", ""},
			{"", "", ""}
		},
		replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
	})
end

local sliding_doors_bbox = {{-0.5, -0.5, -0.44, 0.5, 1.5, -0.31}}
local sliding_door_cornices_bbox = {{-0.5, -0.5, -0.5, 0.5, -0.125, -0.25}}

local sliding_doors_common_data = {
	format = "obj",
	type = "sliding",
	size = {x=10, y=10, z=10},
	object_offset = {x=0, y=0, z=0},
	vel = 1.2, -- metres per sec
	has_mirrored_counterpart = true,
	sounds = {
		open = "multidecor_drawer_open",
		close = "multidecor_drawer_close"
	}
}

local sliding_doors_data = {
	{
		craft_cmp = "multidecor:metal_bar",
		has_glass_cmp = true,
		doorname = "sliding_glass_door",
		cornicename = "sliding_door_metal_cornice",
		material =  "metallic",
		tiles = {
			"multidecor_metal_material5.png",
			"multidecor_glass_material.png"
		},
	},
	{
		craft_cmp = "multidecor:aspen_plank",
		doorname = "sliding_japanese_door",
		cornicename = "sliding_door_aspen_cornice",
		material =  "wood",
		tiles = {
			"multidecor_aspen_wood.png",
			"multidecor_cloth.png"
		},
	},
	{
		craft_cmp = "multidecor:plank",
		doorname = "sliding_slotted_door",
		cornicename = "sliding_door_wooden_cornice",
		material =  "wood",
		tiles = {
			"multidecor_wood.png"
		},
	}
}

local sliding_doors_recipe = {
	recipe = {
		{"", "", ""},
		{"", "", ""},
		{"", "multidecor:saw", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
}

local sliding_doors_cornices_recipe = {
	recipe = {
		{"", "", ""},
		{"", "multidecor:saw", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
}

for _, door_n in ipairs(sliding_doors_data) do
	local sliding_doors_recipe_copy = table.copy(sliding_doors_recipe)

	for cmps_row = 1, #sliding_doors_recipe_copy.recipe do
		for cmp_n = 1, #sliding_doors_recipe_copy.recipe[cmps_row] do
			if cmps_row == 2 and cmp_n == 2 then
				if door_n.has_glass_cmp then
					sliding_doors_recipe_copy.recipe[cmps_row][cmp_n] = "xpanes:pane_flat"
				end
			elseif cmps_row ~= 3 and cmp_n ~= 2 then
				sliding_doors_recipe_copy.recipe[cmps_row][cmp_n] = door_n.craft_cmp
			end
		end
	end
	multidecor.register.register_door(door_n.doorname, {
		style = "modern",
		material = door_n.material,
		visual_scale = 1.0,
		description = modern.S(hlpfuncs.upper_first_letters(door_n.doorname)),
		mesh = "multidecor_" .. door_n.doorname ..  ".obj",
		tiles = door_n.tiles,
		use_texture_alpha = "blend",
		bounding_boxes = sliding_doors_bbox
	},
	{
		common_name = door_n.doorname,
		door = sliding_doors_common_data
	}, sliding_doors_recipe_copy)

	local sliding_doors_cornices_recipe_copy = table.copy(sliding_doors_cornices_recipe)

	
	for cmp_n = 1, #sliding_doors_cornices_recipe_copy.recipe[1] do
		sliding_doors_cornices_recipe_copy.recipe[1][cmp_n] = door_n.craft_cmp
	end

	multidecor.register.register_furniture_unit(door_n.cornicename, {
		type = "decoration",
		style = "modern",
		material = door_n.material,
		visual_scale = 1.0,
		description = modern.S(hlpfuncs.upper_first_letters(door_n.cornicename)),
		mesh = "multidecor_sliding_door_cornice.obj",
		tiles = {door_n.tiles[1]},
		bounding_boxes = sliding_door_cornices_bbox
	}, sliding_doors_cornices_recipe_copy)
end

--[[multidecor.register.register_door("sliding_glass_door", {
	style = "modern",
	material = "metallic",
	visual_scale = 1.0,
	description = modern.S("Sliding Glass Door"),
	mesh = "multidecor_sliding_glass_door.obj",
	tiles = {
		"multidecor_metal_material5.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = sliding_doors_bbox
},
{
	common_name = "sliding_glass_door",
	door = sliding_doors_data
})

multidecor.register.register_door("sliding_japanese_door", {
	style = "modern",
	material = "wood",
	visual_scale = 1.0,
	description = modern.S("Sliding Japanese Door"),
	mesh = "multidecor_sliding_japanese_door.obj",
	tiles = {
		"multidecor_aspen_wood.png",
		"multidecor_cloth.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = sliding_doors_bbox
},
{
	common_name = "sliding_japanese_door",
	door = sliding_doors_data
})

multidecor.register.register_door("sliding_slotted_door", {
	style = "modern",
	material = "wood",
	visual_scale = 1.0,
	description = modern.S("Sliding Slotted Door"),
	mesh = "multidecor_sliding_slotted_door.obj",
	tiles = {
		"multidecor_wood.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = sliding_doors_bbox
},
{
	common_name = "sliding_slotted_door",
	door = sliding_doors_data
})

multidecor.register.register_furniture_unit("sliding_door_metal_cornice", {
	type = "decoration",
	style = "modern",
	material = "metal",
	visual_scale = 1.0,
	description = modern.S("Metal Cornice For Sliding Door"),
	mesh = "multidecor_sliding_door_cornice.obj",
	tiles = {"multidecor_metal_material5.png"},
	bounding_boxes = sliding_door_cornices_bbox
})

multidecor.register.register_furniture_unit("sliding_door_aspen_cornice", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 1.0,
	description = modern.S("Aspen Cornice For Sliding Door"),
	mesh = "multidecor_sliding_door_cornice.obj",
	tiles = {"multidecor_aspen_wood.png"},
	bounding_boxes = sliding_door_cornices_bbox
})

multidecor.register.register_furniture_unit("sliding_door_wooden_cornice", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 1.0,
	description = modern.S("Wooden Cornice For Sliding Door"),
	mesh = "multidecor_sliding_door_cornice.obj",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = sliding_door_cornices_bbox
})]]

minetest.register_alias("multidecor:wooden_door", "multidecor:patterned_wooden_door")
minetest.register_alias("multidecor:pine_door", "multidecor:patterned_aspen_door")
minetest.register_alias("multidecor:technical_door", "multidecor:technical_locked_door")

minetest.register_alias("multidecor:wooden_door_open", "multidecor:patterned_wooden_door_open")
minetest.register_alias("multidecor:pine_door_open", "multidecor:patterned_aspen_door_open")
minetest.register_alias("multidecor:technical_door_open", "multidecor:technical_locked_door_open")
