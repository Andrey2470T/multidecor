multidecor.register.register_seat("kitchen_modern_wooden_chair", {
	style = "modern",
	material = "wood",
	description = modern.S("Kitchen Modern Wooden Chair"),
	visual_scale = 0.4,
	mesh = "multidecor_kitchen_modern_wooden_chair.b3d",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {
		{-0.29, -0.5, -0.29, 0.29, 0.145, 0.21},
		{-0.29, -0.5, 0.21, 0.29, 0.9375, 0.285}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.15, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"multidecor:board", "multidecor:board", ""},
		{"default:stick", "default:stick", "default:stick"},
		{"", "default:stick", ""}
	}
})

multidecor.register.register_seat("soft_kitchen_modern_wooden_chair", {
	style = "modern",
	material = "wood",
	description = modern.S("Soft Kitchen Modern Wooden Chair"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	mesh = "multidecor_soft_kitchen_modern_wooden_chair.b3d",
	tiles = {{name="multidecor_wood.png", color=0xffffffff}, "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.29, -0.5, -0.29, 0.29, 0.145, 0.21},
		{-0.29, -0.5, 0.21, 0.29, 0.9375, 0.285},
		{-0.32, 0.145, -0.32, 0.32, 0.23, 0.21}
	},
	is_colorable = true
},
{
	seat_data = {
		pos = {x=0.0, y=0.225, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"multidecor:board", "multidecor:board", "wool:white"},
		{"default:stick", "default:stick", "default:stick"},
		{"", "default:stick", ""}
	}
})

multidecor.register.register_seat("soft_modern_jungle_chair", {
	style = "modern",
	material = "wood",
	description = modern.S("Soft Modern Jungle Chair"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	mesh = "multidecor_soft_modern_jungle_chair.b3d",
	tiles = {{name="multidecor_jungle_wood.png", color=0xffffffff}, "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.27, -0.5, -0.27, 0.27, 0.13, 0.225},
		{-0.27, -0.5, 0.225, 0.27, 0.825, 0.3}
	},
	is_colorable = true
},
{
	seat_data = {
		pos = {x=0.0, y=0.1, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "default:stick"},
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "default:stick", ""}
	}
})

multidecor.register.register_seat("soft_round_modern_metallic_chair", {
	style = "modern",
	material = "metal",
	description = modern.S("Soft Round Modern Metallic Chair"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	mesh = "multidecor_round_soft_metallic_chair.b3d",
	tiles = {"multidecor_wool_material.png", {name="multidecor_metal_material.png", color=0xffffffff}},
	bounding_boxes = {
		{-0.5, -0.5, -0.4, 0.5, 0.25, 0.2},
		{-0.5, -0.5, 0.2, 0.5, 0.8, 0.325}
	},
	is_colorable = true
},
{
	seat_data = {
		pos = {x=0.0, y=0.2, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"wool:white", "wool:white", ""},
		{"multidecor:metal_bar", "multidecor:metal_bar", ""},
		{"multidecor:metal_bar", "multidecor:metal_bar", ""}
	}
})

multidecor.register.register_seat("round_modern_metallic_stool", {
	style = "modern",
	material = "metal",
	description = modern.S("Round Modern Metallic Stool"),
	paramtype2 = "colorfacedir",
	visual_scale = 0.4,
	mesh = "multidecor_modern_round_metallic_stool.b3d",
	tiles = {"multidecor_wool_material.png", {name="multidecor_metal_material.png", color=0xffffffff}},
	bounding_boxes = {
		{-0.3, -0.5, -0.3, 0.3, 0.175, 0.3}
	},
	is_colorable = true
},
{
	seat_data = {
		pos = {x=0.0, y=0.15, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1"}
	}
},
{
	recipe = {
		{"wool:white", "", ""},
		{"multidecor:metal_bar", "multidecor:metal_bar", "multidecor:metal_bar"},
		{"multidecor:metal_bar", "multidecor:metal_bar", ""}
	}
})

multidecor.register.register_seat("armchair_with_wooden_legs", {
	style = "modern",
	material = "wood",
	description = modern.S("Armchair with wooden legs"),
	inventory_image = "multidecor_armchair_with_wooden_legs_inv.png",
	paramtype2 = "colorfacedir",
	mesh = "multidecor_armchair_with_wooden_legs.b3d",
	tiles = {
		{name="multidecor_pine_wood2.png", color=0xffffffff},
		"multidecor_wool_material.png",
		"multidecor_wool_material.png"
	},
	bounding_boxes = {
		{-0.3, -0.5, -0.45, 0.3, 0.15, 0.3},
		{-0.5, -0.5, -0.45, -0.3, 0.375, 0.3},
		{0.3, -0.5, -0.45, 0.5, 0.375, 0.3},
		{-0.5, -0.5, 0.3, 0.5, 0.85, 0.5}
	},
	is_colorable = true
},
{
	seat_data = {
		pos = {x=0.0, y=0.1, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1", "sit2", "sit3"}
	}
},
{
	recipe = {
		{"wool:white", "stairs:slab_pine_wood", "multidecor:pine_plank"},
		{"wool:white", "multidecor:pine_plank", ""},
		{"", "", ""}
	}
})

multidecor.register.register_seat("sofa", {
	style = "modern",
	material = "plastic",
	description = modern.S("Sofa"),
	paramtype2 = "colorfacedir",
	mesh = "multidecor_modern_sofa.b3d",
	tiles = {{name="multidecor_modern_sofa.png", color=0xffffffff}, "multidecor_cloth.png"},
	bounding_boxes = {
		{-0.4, -0.5, -0.325, 0.4, 0, 0.225},
		{-0.5, -0.5, -0.325, -0.4, 0.2, 0.225},
		{0.4, -0.5, -0.325, 0.5, 0.2, 0.225},
		{-0.5, -0.5, 0.225, 0.5, 0.6, 0.5}
	},
	is_colorable = true,
	callbacks = {
		on_construct = function(pos)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "directional")
		end,
		after_dig_node = function(pos, old_node)
			multidecor.connecting.update_adjacent_nodes_connection(pos, "directional", true, old_node)
		end
	}
},
{
	common_name = "sofa",
	connect_parts = {
		["left_side"] = "multidecor_modern_sofa_1.b3d",
		["right_side"] = "multidecor_modern_sofa_2.b3d",
		["middle"] = "multidecor_modern_sofa_3.b3d",
		["corner"] = "multidecor_modern_sofa_4.b3d"
	},
	seat_data = {
		pos = {x=0.0, y=-0.1, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1", "sit2", "sit3"}
	}
},
{
	recipe = {
		{"wool:white", "wool:white", "wool:white"},
		{"multidecor:plastic_sheet", "multidecor:plastic_sheet", ""},
		{"multidecor:plastic_sheet", "", ""}
	}
})
