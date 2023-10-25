multidecor.register.register_bed("jungle_bed", {
	style = "modern",
	material = "wood",
	description = "Jungle Bed (single)",
	visual_scale = 0.4,
	mesh = "multidecor_jungle_bed.obj",
	tiles = {"multidecor_modern_jungle_bed.png"},
	inventory_image = "multidecor_jungle_bed_inv.png",
	bounding_boxes = {
		{-0.5, -0.5, -1.5, 0.5, 0, 0.3},
		{-0.5, -0.5, 0.3, 0.5, 0.5, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "pair")
		end,
		after_dig_node = function(pos, oldnode)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end
	}
},
{
	common_name = "jungle_bed",
	lay_pos1 = {x=0, y=0, z=1},
	lay_pos2 = {x=-1, y=0, z=1},
	double = {
		mutable_bounding_box_indices = {1, 2},
		description = "Jungle Bed (double)",
		inv_image = "multidecor_double_jungle_bed_inv.png",
		mesh = "multidecor_double_jungle_bed.obj"
	}
},
{
	recipe = {
		{"multidecor:jungleboard", "wool:white", "multidecor:jungleboard"},
		{"multidecor:jungleboard", "wool:white", "multidecor:jungleboard"},
		{"multidecor:jungleplank", "multidecor:jungleplank", "multidecor:jungleplank"}
	}
})

multidecor.register.register_bed("wooden_bed_with_legs", {
	style = "modern",
	material = "wood",
	description = "Wooden bed with legs (single)",
	visual_scale = 0.4,
	mesh = "multidecor_wooden_bed_with_legs.b3d",
	tiles = {"multidecor_wood.png", "multidecor_wool_material.png", "multidecor_wooden_bed_legs.png"},
	inventory_image = "multidecor_wooden_bed_inv.png",
	bounding_boxes = {
		{-0.5, -0.5, -1.5, 0.5, 0.35, -1.3},
		{-0.5, -0.5, -1.3, 0.5, 0.1, 0.3},
		{-0.5, -0.5, 0.3, 0.5, 0.55, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "pair")
		end,
		after_destruct = function(pos, oldnode)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end,
		after_dig_node = function(pos, oldnode)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end
	}
},
{
	common_name = "wooden_bed_with_legs",
	lay_pos1 = {x=0, y=0, z=1},
	lay_pos2 = {x=-1, y=0, z=1},
	double = {
		mutable_bounding_box_indices = {1, 2, 3},
		description = "Wooden bed with legs (double)",
		inv_image = "multidecor_double_wooden_bed_inv.png",
		mesh = "multidecor_double_wooden_bed_with_legs.b3d"
	}
},
{
	recipe = {
		{"multidecor:board", "wool:white", "multidecor:plank"},
		{"multidecor:board", "wool:white", "multidecor:plank"},
		{"multidecor:board", "multidecor:plank", ""}
	}
})

multidecor.register.register_table("dresser_with_mirror", {
	style = "modern",
	material = "wood",
	description = "Dresser With Mirror",
	mesh = "multidecor_dresser_with_mirror.b3d",
	tiles = {"multidecor_aspen_wood.png", "multidecor_gloss.png"},
	inventory_image = "multidecor_dresser_with_mirror_inv.png",
	use_texture_alpha = "blend",
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 1.5, 0.5, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.default_can_dig
	}
},
{
	shelves_data = {
		common_name = "dresser_with_mirror",
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-0.02, y=0.28, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-0.02, y=0, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-0.02, y=-0.28, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-1, y=0.28, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-1, y=0, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
		{
			type = "drawer",
			base_texture = "multidecor_aspen_wood.png",
			visual_size_adds = {x=1.5, y=1.5, z=1.2},
			pos = {x=-1, y=-0.28, z=0},
			object = "modern:wooden_drawer_with_round_handle",
			length = 0.5,
			inv_size = {w=6,h=1},
			sounds = {
				open = "multidecor_drawer_open",
				close = "multidecor_drawer_close"
			}
        },
	}
},
{
	recipe = {
		{"multidecor:aspen_board", "multidecor:aspen_drawer", "multidecor:aspen_drawer"},
		{"multidecor:aspen_board", "multidecor:aspen_drawer", "multidecor:aspen_drawer"},
		{"xpanes:pane_flat", "multidecor:aspen_drawer", "multidecor:aspen_drawer"}
	}
})

minetest.register_entity("modern:wooden_drawer_with_round_handle", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_wooden_drawer_with_round_handle.b3d",
	textures = {"multidecor_jungle_wood.png", "multidecor_metal_material.png"},
	physical = false,
	selectionbox = {-0.5, -0.16, -0.45, 0.525, 0.16, 0.575},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_drawer_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata,
	on_deactivate = multidecor.shelves.default_on_deactivate
})
