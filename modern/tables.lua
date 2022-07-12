register.register_table("kitchen_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = "Kitchen Modern Wooden Table",
	mesh = "multidecor_kitchen_modern_wooden_table.obj",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			connecting.update_adjacent_nodes_connection(pos)
		end,
		after_dig_node = function(pos)
			connecting.update_adjacent_nodes_connection(pos, true)
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
})

register.register_table("round_modern_metallic_table", {
	style = "modern",
	material = "metal",
	description = "Round Modern Metallic Table",
	mesh = "multidecor_round_metallic_table.obj",
	tiles = {"multidecor_round_metallic_table.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
})

register.register_table("round_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = "Round Modern Wooden Table",
	mesh = "multidecor_round_wooden_table.obj",
	tiles = {"multidecor_jungle_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
})

register.register_table("modern_wooden_desk", {
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
			shelves.set_shelves(pos)
		end
	}
},
{
	shelves_data = {
		{
			type = "drawer",
			pos = {x=-1.15, y=0.225, z=0.025},
			object = "modern:wooden_desk_drawer",
			length = 0.8,
			inv_size = {w=6,h=1}
        },
		{
			type = "door",
			pos = {x=-0.825, y=-0.15, z=0.4},
			object = "modern:wooden_desk_door",
			side = "left",
			inv_size = {w=6,h=3}
		}
	}
})

minetest.register_entity("modern:wooden_desk_drawer", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_wooden_desk_drawer.obj",
	textures = {"multidecor_wooden_desk2.png"},
	physical = false,
	selection_box = {-0.2, -0.15, -0.25, 0.2, 0.15, 0.25},
	static_save = true,
	on_activate = shelves.default_on_activate,
	on_rightclick = shelves.default_on_rightclick,
	on_step = shelves.default_drawer_on_step,
	get_staticdata = shelves.default_get_staticdata
})

minetest.register_entity("modern:wooden_desk_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_wooden_desk_door.obj",
	textures = {"multidecor_wooden_desk2.png"},
	physical = false,
	selection_box = {-0.2, -0.2, -0.25, 0.2, 0.2, 0.25},
	static_save = true,
	on_activate = shelves.default_on_activate,
	on_rightclick = shelves.default_on_rightclick,
	on_step = shelves.default_door_on_step,
	get_staticdata = shelves.default_get_staticdata
})

register.register_table("modern_wooden_table_with_metallic_legs", {
	style = "modern",
	material = "metal",
	description = "Modern Wooden Table With Metallic Legs",
	mesh = "multidecor_wooden_table_with_metallic_legs.obj",
	tiles = {"multidecor_wooden_table_with_metallic_legs.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
})
