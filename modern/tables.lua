multidecor.register.register_table("kitchen_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = "Kitchen Modern Wooden Table",
	mesh = "multidecor_kitchen_modern_wooden_table.b3d",
	tiles = {"multidecor_wood.png", "multidecor_wood.png", "multidecor_wood.png^[opacity:0"},
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
		["edge"] = "multidecor_kitchen_modern_wooden_table_1.b3d",
		["corner"] = "multidecor_kitchen_modern_wooden_table_2.b3d",
		["middle"] = "multidecor_kitchen_modern_wooden_table_3.b3d",
		["edge_middle"] = "multidecor_kitchen_modern_wooden_table_4.b3d",
		["off_edge"] = "multidecor_kitchen_modern_wooden_table_5.b3d"
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
	description = "Kitchen Modern Wooden Table With Cloth",
	mesh = "multidecor_kitchen_modern_wooden_table.b3d",
	tiles = {"multidecor_wood.png^[opacity:0", "multidecor_wood.png", "multidecor_wool_material.png"},
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
	common_name = "kitchen_modern_wooden_table_with_cloth",
	connect_parts = {
		["edge"] = "multidecor_kitchen_modern_wooden_table_1.b3d",
		["corner"] = "multidecor_kitchen_modern_wooden_table_2.b3d",
		["middle"] = "multidecor_kitchen_modern_wooden_table_3.b3d",
		["edge_middle"] = "multidecor_kitchen_modern_wooden_table_4.b3d",
		["off_edge"] = "multidecor_kitchen_modern_wooden_table_5.b3d"
	}
},
{
	recipe = {
		{"", "multidecor:board", ""},
		{"multidecor:plank", "", "multidecor:plank"},
		{"default:stick", "default:stick", "default:stick"}
	}
})

multidecor.register.register_table("round_modern_metallic_table", {
	style = "modern",
	material = "metal",
	description = "Round Modern Metallic Table",
	mesh = "multidecor_round_metallic_table.b3d",
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
	description = "Round Modern Wooden Table",
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
	description = "Modern Wooden Desk",
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
		{
			type = "drawer",
			pos = {x=-1.15, y=0.225, z=0.025},
			object = "modern:wooden_drawer",
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
			object = "modern:wooden_door",
			side = "left",
			inv_size = {w=6,h=3},
			acc = 1,
			sounds = {
				open = "multidecor_cabinet_door_open",
				close = "multidecor_cabinet_door_close"
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

minetest.register_entity("modern:wooden_drawer", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_wooden_drawer.b3d",
	textures = {"multidecor_jungle_wood.png", "multidecor_metal_material.png"},
	physical = false,
	selectionbox = {-0.35, -0.15, -0.4, 0.35, 0.15, 0.4},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_drawer_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})

minetest.register_entity("modern:wooden_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_wooden_door.b3d",
	textures = {"multidecor_jungle_wood.png", "multidecor_metal_material.png"},
	physical = false,
	selectionbox = {-0.65, -0.25, 0, 0, 0.25, 0.05},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_door_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})

multidecor.register.register_table("modern_wooden_table_with_metallic_legs", {
	style = "modern",
	material = "metal",
	description = "Modern Wooden Table With Metallic Legs",
	mesh = "multidecor_wooden_table_with_metallic_legs.b3d",
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
	description = "Modern Bedside Table",
	visual_scale = 0.5,
	mesh = "multidecor_bedside_table.b3d",
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
		{
			type = "drawer",
			base_texture = "multidecor_pine_wood2.png",
			visual_size_adds = {x=1.2*2.2, y=1.5*2.2, z=-0.8*2.2},
			pos = {x=0, y=-0.22, z=0.2375},
			object = "modern:wooden_drawer",
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
			object = "modern:wooden_drawer",
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
