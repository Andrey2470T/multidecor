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
		mesh_open = "multidecor_high_dark_rusty_gate_open.b3d",
		mesh_activated = "multidecor_high_dark_rusty_gate_activated.b3d",
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
		mesh_open = "multidecor_dark_rusty_gate_open.b3d",
		mesh_activated = "multidecor_dark_rusty_gate_activated.b3d",
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
			mesh_open = "multidecor_modern_wooden_door_open.b3d",
			mesh_activated = "multidecor_modern_wooden_door_activated.b3d",
			vel = 100, -- degrees per sec
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
			mesh_open = "multidecor_window_door_open.b3d",
			mesh_activated = "multidecor_window_door_activated.b3d",
			vel = 100, -- degrees per sec
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
			mesh_open = "multidecor_window_door_with_thin_slats_open.b3d",
			mesh_activated = "multidecor_window_door_with_thin_slats_activated.b3d",
			vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_modern_wooden_door_open.b3d",
		mesh_activated = "multidecor_modern_wooden_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_bathroom_door_open.b3d",
		mesh_activated = "multidecor_bathroom_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_white_pine_glass_door_open.b3d",
		mesh_activated = "multidecor_white_pine_glass_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_pine_glass_door_open.b3d",
		mesh_activated = "multidecor_pine_glass_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_pine_door_open.b3d",
		mesh_activated = "multidecor_pine_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_dark_pine_glass_door_open.b3d",
		mesh_activated = "multidecor_dark_pine_glass_door_activated.b3d",
		vel = 100, -- degrees per sec
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
		mesh_open = "multidecor_technical_door_open.b3d",
		mesh_activated = "multidecor_technical_door_activated.b3d",
		vel = 80, -- degrees per sec
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
		mesh_open = "multidecor_door_with_lock_open.b3d",
		mesh_activated = "multidecor_door_with_lock_activated.b3d",
		vel = 80, -- degrees per sec
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
			mesh_open = "multidecor_door_with_lock_open.b3d",
			mesh_activated = "multidecor_door_with_lock_activated.b3d",
			vel = 80, -- degrees per sec
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

minetest.register_alias("multidecor:wooden_door", "multidecor:patterned_wooden_door")
minetest.register_alias("multidecor:pine_door", "multidecor:patterned_aspen_door")
minetest.register_alias("multidecor:technical_door", "multidecor:technical_locked_door")

minetest.register_alias("multidecor:wooden_door_open", "multidecor:patterned_wooden_door_open")
minetest.register_alias("multidecor:pine_door_open", "multidecor:patterned_aspen_door_open")
minetest.register_alias("multidecor:technical_door_open", "multidecor:technical_locked_door_open")
