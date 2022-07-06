register.register_seat("kitchen_modern_wooden_chair", {
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
		models = {
			{
				mesh = "multidecor_character_sitting.b3d",
				anim = {range = {x=1, y=80}, speed = 15}
			}
		}
	}
})

register.register_seat("soft_kitchen_modern_wooden_chair", {
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
		models = {
			{
				mesh = "multidecor_character_sitting.b3d",
				anim = {range = {x=1, y=80}, speed = 15}
			}
		}
	}
})

register.register_seat("soft_modern_jungle_chair", {
	style = "modern",
	material = "wood",
	description = "Soft Modern Jungle Chair",
	mesh = "multidecor_soft_modern_jungle_chair.b3d",
	tiles = {"multidecor_modern_jungle_chair.png"},
	bounding_boxes = {
		{-0.35, -0.5, -0.35, 0.35, 0.25, 0.25},
		{-0.35, -0.5, 0.25, 0.35, 1.2, 0.35}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.3, z=0.0},
		rot = {x=0, y=0, z=0},
		models = {
			{
				mesh = "multidecor_character_sitting.b3d",
				anim = {range = {x=1, y=80}, speed = 15}
			}
		}
	}
})

register.register_seat("soft_round_modern_metallic_chair", {
	style = "modern",
	material = "metal",
	description = "Soft Round Modern Metallic Chair",
	mesh = "multidecor_round_soft_metallic_chair.b3d",
	tiles = {"multidecor_round_soft_metallic_chair.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.25, 0.25},
		{-0.5, -0.5, 0.25, 0.5, 0.95, 0.5}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.3, z=0.0},
		rot = {x=0, y=0, z=0},
		models = {
			{
				mesh = "multidecor_character_sitting.b3d",
				anim = {range = {x=1, y=80}, speed = 15}
			}
		}
	}
})

register.register_seat("round_modern_metallic_stool", {
	style = "modern",
	material = "metal",
	description = "Round Modern Jungle Stool",
	mesh = "multidecor_modern_round_metallic_stool.b3d",
	tiles = {"multidecor_modern_round_metallic_stool.png"},
	bounding_boxes = {
		{-0.4, -0.5, -0.4, 0.4, 0.35, 0.4}
	}
},
{
	seat_data = {
		pos = {x=0.0, y=0.4, z=0.0},
		rot = {x=0, y=0, z=0},
		models = {
			{
				mesh = "multidecor_character_sitting.b3d",
				anim = {range = {x=1, y=80}, speed = 15}
			}
		}
	}
})

register.register_table("kitchen_modern_wooden_table", {
	style = "modern",
	material = "wood",
	description = "Kitchen Modern Wooden Table",
	mesh = "multidecor_kitchen_modern_wooden_table.obj",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
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

for _, wood_n in ipairs({"", "jungle", "pine", "birch"}) do
	local tex = "multidecor_" .. wood_n .. (wood_n ~= "" and "_" or "") .. "wood.png^[sheet:2x2:0,0"

	register.register_table("modern_wooden_" .. wood_n .. (wood_n ~= "" and "_" or "") .. "closed_shelf", {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2) .. " Closed Shelf (without back)",
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}			-- Top side
		}
	})

	register.register_table("modern_wooden_" .. wood_n .. (wood_n ~= "" and "_" or "") .. "closed_shelf_with_back", {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2) .. " Closed Shelf (with back)",
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},			-- Top side
			{-0.4, -0.4, 0.4, 0.4, 0.4, 0.5}			-- Back side
		}
	})
end
