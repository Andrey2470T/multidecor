register.register_bed("jungle_bed", {
	style = "modern",
	material = "wood",
	description = "Jungle Bed (single)",
	mesh = "multidecor_jungle_bed.obj",
	tiles = {"multidecor_modern_jungle_bed.png"},
	inventory_image = "multidecor_jungle_bed_inv.png",
	bounding_boxes = {
		{-0.5, -0.5, -1.5, 0.5, 0, 0.3},
		{-0.5, -0.5, 0.3, 0.5, 0.5, 0.5}
	},
	callbacks = {
		on_construct = function(pos)
			connecting.update_adjacent_nodes_connection(pos, "pair")
		end,
		after_destruct = function(pos, oldnode)
			connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end,
		after_dig_node = function(pos, oldnode)
			connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end
	}
},
{
	common_name = "jungle_bed",
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

register.register_bed("wooden_bed_with_legs", {
	style = "modern",
	material = "wood",
	description = "Wooden bed with legs (single)",
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
			connecting.update_adjacent_nodes_connection(pos, "pair")
		end,
		after_destruct = function(pos, oldnode)
			connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end,
		after_dig_node = function(pos, oldnode)
			connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
		end
	}
},
{
	common_name = "wooden_bed_with_legs",
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
