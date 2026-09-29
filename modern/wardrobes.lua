local wardrobe_wooden_glass_door_def = {
	mesh = "multidecor_wardrobe_wooden_glass_door.obj",
	textures = {"multidecor_metal_material.png", "multidecor_jungle_wood.png^[resize:32x32", "multidecor_glass_material.png"},
	use_texture_alpha = true,
	backface_culling = false,
	selectionbox = {-0.5, -0.53, 0, 0, 0.53, 0.075}
}

local wardrobe_wooden_door_def = {
	mesh = "multidecor_wardrobe_wooden_door.obj",
	textures = {"multidecor_metal_material.png", "multidecor_jungle_wood.png^[resize:32x32"},
	backface_culling = false,
	selectionbox = {-0.5, -0.53, 0, 0, 0.53, 0.075}
}

multidecor.register.register_table("modern_cupboard_with_glass_doors", {
	style = "modern",
	material = "wood",
	description = modern.S("Wooden cupboard with glass doors"),
	mesh = "multidecor_cupboard_with_glass_doors.obj",
	tiles = {"multidecor_jungle_wood.png", "multidecor_glass_material.png", "multidecor_metal_material.png"},
	inventory_image = "multidecor_cupboard_inv.png",
	bounding_boxes = {
		{-0.5, -0.5, -0.25, 0.5, 2.2, 0.5}
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
		common_name = "modern_cupboard_with_glass_doors",
		{
			type = "sym_doors",
			pos = {x=0.5, y=1.6625, z=0.25},
			pos2 = {x=-0.5, y=1.6625, z=0.25},
			def = wardrobe_wooden_glass_door_def,
			inv_size = {w=8,h=6},
			acc = 1,
			sounds = {
				open = "multidecor_squeaky_door_open",
				close = "multidecor_squeaky_door_close"
			}
		},
		{
			type = "sym_doors",
			pos = {x=0.5, y=0.2375, z=0.25},
			pos2 = {x=-0.5, y=0.2375, z=0.25},
			def = wardrobe_wooden_door_def,
			inv_size = {w=8,h=6},
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
		{"multidecor:jungleboard", "multidecor:jungleboard", "xpanes:pane_flat"},
		{"multidecor:jungleboard", "multidecor:jungleboard", "xpanes:pane_flat"},
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"}
	}
})


