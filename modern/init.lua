register.register_seat("kitchen_modern_wooden_chair", {
	type = "seat",
	style = "modern",
	material = "wood",
	visual_scale = 0.4,
	description = "Kitchen Modern Wooden Chair",
	mesh = "multidecor_kitchen_modern_wooden_chair.b3d",
	tiles = {"multidecor_wooden_material.png"},
	bounding_boxes = {
		{-0.36, -0.5, -0.36, 0.36, 0.3, 0.26},
		{-0.36, -0.5, 0.26, 0.36, 1.3, 0.36}
	},
	groups = {choppy=1.5}
},
{
	pos = {x=0.0, y=0.35, z=0.0},
	rot = {x=0, y=0, z=0},
	models = {
		{
			mesh = "multidecor_character_sitting.b3d",
			anim = {range = {x=1, y=80}, speed = 15}
		}
	}
})

register.register_seat("soft_kitchen_modern_wooden_chair", {
	type = "seat",
	style = "modern",
	material = "wood",
	visual_scale = 0.4,
	description = "Soft Kitchen Modern Wooden Chair",
	mesh = "multidecor_soft_kitchen_modern_wooden_chair.b3d",
	tiles = {"multidecor_wooden_material.png", "multidecor_wool_material.png"},
	bounding_boxes = {
		{-0.36, -0.5, -0.36, 0.36, 0.35, 0.26},
		{-0.36, -0.5, 0.26, 0.36, 1.3, 0.36}
	},
	groups = {choppy=1.5}
},
{
	pos = {x=0.0, y=0.4, z=0.0},
	rot = {x=0, y=0, z=0},
	models = {
		{
			mesh = "multidecor_character_sitting.b3d",
			anim = {range = {x=1, y=80}, speed = 15}
		}
	}
})

register.register_seat("soft_modern_jungle_chair", {
	type = "seat",
	style = "modern",
	material = "wood",
	visual_scale = 0.4,
	description = "Soft Modern Jungle Chair",
	mesh = "multidecor_soft_modern_jungle_chair.b3d",
	tiles = {"multidecor_modern_jungle_chair.png"},
	bounding_boxes = {
		{-0.35, -0.5, -0.35, 0.35, 0.25, 0.25},
		{-0.35, -0.5, 0.25, 0.35, 1.2, 0.35}
	},
	groups = {choppy=1.5}
},
{
	pos = {x=0.0, y=0.3, z=0.0},
	rot = {x=0, y=0, z=0},
	models = {
		{
			mesh = "multidecor_character_sitting.b3d",
			anim = {range = {x=1, y=80}, speed = 15}
		}
	}
})

register.register_seat("soft_round_modern_metallic_chair", {
	type = "seat",
	style = "modern",
	material = "metal",
	visual_scale = 0.4,
	description = "Soft Round Modern Metallic Chair",
	mesh = "multidecor_round_soft_metallic_chair.b3d",
	tiles = {"multidecor_round_soft_metallic_chair.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.25, 0.25},
		{-0.5, -0.5, 0.25, 0.5, 0.95, 0.5}
	},
	groups = {choppy=1.5}
},
{
	pos = {x=0.0, y=0.3, z=0.0},
	rot = {x=0, y=0, z=0},
	models = {
		{
			mesh = "multidecor_character_sitting.b3d",
			anim = {range = {x=1, y=80}, speed = 15}
		}
	}
})

register.register_seat("round_modern_metallic_stool", {
	type = "seat",
	style = "modern",
	material = "metal",
	visual_scale = 0.4,
	description = "Round Modern Jungle Stool",
	mesh = "multidecor_modern_round_metallic_stool.b3d",
	tiles = {"multidecor_modern_round_metallic_stool.png"},
	bounding_boxes = {
		{-0.4, -0.5, -0.4, 0.4, 0.35, 0.4}
	},
	groups = {choppy=1.5}
},
{
	pos = {x=0.0, y=0.4, z=0.0},
	rot = {x=0, y=0, z=0},
	models = {
		{
			mesh = "multidecor_character_sitting.b3d",
			anim = {range = {x=1, y=80}, speed = 15}
		}
	}
})
