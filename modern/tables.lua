local wooden_drawer_def = {
	mesh = "multidecor_wooden_drawer.obj",
	textures = {"multidecor_jungle_wood.png", "multidecor_metal_material.png"},
	selectionbox = {-0.35, -0.15, -0.4, 0.35, 0.15, 0.4}
}

local wooden_door_def = {
	mesh = "multidecor_wooden_door.obj",
	textures = {"multidecor_jungle_wood.png", "multidecor_metal_material.png"},
	selectionbox = {-0.65, -0.25, 0, 0, 0.25, 0.05}
}

multidecor.register.register_table("kitchen_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = modern.S("Kitchen Modern Wooden Table"),
	visual_scale = 0.4,
	mesh = "multidecor_kitchen_modern_wooden_table.obj",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "horizontal")
		end,
		after_dig_node = function(pos, oldnode)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "horizontal", true, oldnode)
		end
	}
},
{
	common_name = "kitchen_modern_wooden_table",
	connect_parts = {
		["edge"] = "multidecor_kitchen_modern_wooden_table_1.obj",
		["corner"] = "multidecor_kitchen_modern_wooden_table_2.obj",
		["middle"] = "multidecor_kitchen_modern_wooden_table_3.obj",
		["edge_middle"] = "multidecor_kitchen_modern_wooden_table_4.obj",
		["off_edge"] = "multidecor_kitchen_modern_wooden_table_5.obj"
	}
},
{
	recipe = {
		{"", "multidecor:board", ""},
		{"multidecor:plank", "", "multidecor:plank"},
		{"default:stick", "default:stick", "default:stick"}
	}
})

multidecor.register.register_table("kitchen_modern_wooden_table_with_cloth", {
	style = "modern",
	material = "wood",
	description = modern.S("Kitchen Modern Wooden Table With Cloth"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	mesh = "multidecor_kitchen_modern_wooden_table_with_cloth.obj",
	tiles = {
		{name="multidecor_wood.png", color=0xffffffff},
		"multidecor_wool_material.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	is_colorable = true,
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "horizontal")
		end,
		after_dig_node = function(pos, oldnode)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "horizontal", true, oldnode)
		end
	}
},
{
	common_name = "kitchen_modern_wooden_table_with_cloth",
	connect_parts = {
		["edge"] = "multidecor_kitchen_modern_wooden_table_with_cloth_1.obj",
		["corner"] = "multidecor_kitchen_modern_wooden_table_with_cloth_2.obj",
		["middle"] = "multidecor_kitchen_modern_wooden_table_with_cloth_3.obj",
		["edge_middle"] = "multidecor_kitchen_modern_wooden_table_with_cloth_4.obj",
		["off_edge"] = "multidecor_kitchen_modern_wooden_table_with_cloth_5.obj"
	}
},
{
	recipe = {
		{"", "multidecor:board", ""},
		{"multidecor:plank", "multidecor:wool_cloth", "multidecor:plank"},
		{"default:stick", "default:stick", "default:stick"}
	}
})

multidecor.register.register_table("round_modern_metallic_table", {
	style = "modern",
	material = "metal",
	description = modern.S("Round Modern Metallic Table"),
	visual_scale = 0.4,
	mesh = "multidecor_round_metallic_table.obj",
	tiles = {"multidecor_metal_material.png", "multidecor_aspen_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
},
{
	recipe = {
		{"", "multidecor:aspen_board", ""},
		{"multidecor:metal_bar", "multidecor:metal_bar", "multidecor:metal_bar"},
		{"", "multidecor:metal_bar", ""}
	}
})

multidecor.register.register_table("round_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = modern.S("Round Modern Wooden Table"),
	visual_scale = 0.4,
	mesh = "multidecor_round_wooden_table.obj",
	tiles = {"multidecor_jungle_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
},
{
	recipe = {
		{"multidecor:jungleboard", "", ""},
		{"multidecor:jungleplank", "multidecor:jungleplank", ""},
		{"default:stick", "", ""}
	}
})

multidecor.register.register_table("modern_wooden_desk", {
	style = "modern",
	material = "wood",
	description = modern.S("Modern Wooden Desk"),
	visual_scale = 0.4,
	mesh = "multidecor_wooden_desk.obj",
	tiles = {"multidecor_jungle_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 1.5, 0.5, 0.5}
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
		common_name = "modern_wooden_desk",
		{
			type = "drawer",
			pos = {x=-1.15, y=0.225, z=0.025},
			def = wooden_drawer_def,
			length = 0.8,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "door",
			pos = {x=-0.825, y=-0.15, z=0.4},
			def = wooden_door_def,
			side = "left",
			inv_size = {w=6,h=3},
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
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"multidecor:jungleboard", "multidecor:drawer", "multidecor:jungleboard"},
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"}
	}
})



multidecor.register.register_table("modern_wooden_table_with_metallic_legs", {
	style = "modern",
	material = "metal",
	description = modern.S("Modern Wooden Table With Metallic Legs"),
	visual_scale = 0.4,
	mesh = "multidecor_wooden_table_with_metallic_legs.obj",
	tiles = {"multidecor_aspen_wood.png", "multidecor_metal_material.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
},
{
	recipe = {
		{"", "multidecor:pine_board", ""},
		{"multidecor:metal_bar", "multidecor:pine_board", "multidecor:metal_bar"},
		{"multidecor:metal_bar", "", "multidecor:metal_bar"}
	}
})

multidecor.register.register_table("modern_bedside_table", {
	style = "modern",
	material = "wood",
	description = modern.S("Modern Bedside Table"),
	mesh = "multidecor_bedside_table.obj",
	tiles = {"multidecor_pine_wood2.png", "multidecor_hardboard.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
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
		common_name = "modern_bedside_table",
		{
			type = "drawer",
			base_texture = "multidecor_pine_wood2.png",
			visual_size_adds = {x=1.2*2.2, y=1.5*2.2, z=-0.8*2.2},
			pos = {x=0, y=-0.22, z=0.2375},
			def = wooden_drawer_def,
			length = 0.8,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_pine_wood2.png",
			visual_size_adds = {x=1.2*2.2, y=1.5*2.2, z=-0.8*2.2},
			pos = {x=0, y=0.205, z=0.2375},
			def = wooden_drawer_def,
			length = 0.8,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
		}
	}
},
{
	recipe = {
		{"multidecor:pine_board", "multidecor:pine_board", "multidecor:pine_board"},
		{"multidecor:pine_board", "multidecor:pine_drawer", "multidecor:pine_board"},
		{"multidecor:pine_board", "multidecor:pine_drawer", "multidecor:pine_board"}
	}
})
