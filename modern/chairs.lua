--[[local models = {
	{
		mesh = "multidecor_character_sitting.b3d",
		anim = {range = {x=4, y=84}, speed = 1}
	},
	{
		mesh = "multidecor_character_sitting.b3d",
		anim = {range = {x=0, y=1}, speed = 1}
	},
	{
		mesh = "multidecor_character_sitting.b3d",
		anim = {range = {x=2, y=3}, speed = 1},
		is_near_block_required = true
	}
}]]

local model_name = "multidecor_character_sitting.b3d"

player_api.register_model(model_name, {
	animations = {
		sit1 = {
			x = 4,
			y = 84
		},
		sit2 = {
			x = 0,
			y = 1
		},
		sit3 = {
			x = 2,
			y = 3,
			is_near_block_required = true
		}
	}
})

multidecor.register.register_seat("kitchen_modern_wooden_chair", {
	style = "modern",
	material = "wood",
	description = "Kitchen Modern Wooden Chair",
	mesh = "multidecor_kitchen_modern_wooden_chair.b3d",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {
		{-0.36, -0.5, -0.36, 0.36, 0.3, 0.26},
		{-0.36, -0.5, 0.26, 0.36, 1.3, 0.36}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.35, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Soft Kitchen Modern Wooden Chair",
	mesh = "multidecor_soft_kitchen_modern_wooden_chair.b3d",
	tiles = {"multidecor_wood.png", "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.36, -0.5, -0.36, 0.36, 0.35, 0.26},
		{-0.36, -0.5, 0.26, 0.36, 1.3, 0.36}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.4, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Soft Modern Jungle Chair",
	mesh = "multidecor_soft_modern_jungle_chair.b3d",
	tiles = {"multidecor_jungle_wood.png", "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.35, -0.5, -0.35, 0.35, 0.25, 0.25},
		{-0.35, -0.5, 0.25, 0.35, 1.2, 0.35}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.3, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Soft Round Modern Metallic Chair",
	mesh = "multidecor_round_soft_metallic_chair.b3d",
	tiles = {"multidecor_wool_material.png", "multidecor_metal_material.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.25, 0.25},
		{-0.5, -0.5, 0.25, 0.5, 0.95, 0.5}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.3, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Round Modern Jungle Stool",
	mesh = "multidecor_modern_round_metallic_stool.b3d",
	tiles = {"multidecor_wool_material.png", "multidecor_metal_material.png"},
	bounding_boxes = {
		{-0.4, -0.5, -0.4, 0.4, 0.35, 0.4}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.4, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Armchair with wooden legs",
	inventory_image = "multidecor_armchair_with_wooden_legs_inv.png",
	visual_scale = 0.5,
	mesh = "multidecor_armchair_with_wooden_legs.b3d",
	tiles = {"multidecor_pine_wood2.png", "multidecor_wool_material.png", "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.3, -0.5, -0.45, 0.3, 0.15, 0.3},
		{-0.5, -0.5, -0.45, -0.3, 0.375, 0.3},
		{0.3, -0.5, -0.45, 0.5, 0.375, 0.3},
		{-0.5, -0.5, 0.3, 0.5, 0.85, 0.5}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.2, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
	description = "Sofa",
	visual_scale = 0.5,
	mesh = "multidecor_modern_sofa.b3d",
	tiles = {"multidecor_modern_sofa.png", "multidecor_cloth.png"},
	bounding_boxes = {
		{-0.4, -0.5, -0.325, 0.4, 0, 0.225},
		{-0.5, -0.5, -0.325, -0.4, 0.2, 0.225},
		{0.4, -0.5, -0.325, 0.5, 0.2, 0.225},
		{-0.5, -0.5, 0.225, 0.5, 0.6, 0.5}
	},
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
		pos = {x=0.0, y=0.1, z=0.0},
		rot = {x=0, y=0, z=0},
		model = model_name,
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
