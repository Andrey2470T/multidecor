local cab_bboxes = {
	{-0.5, -0.5, -0.45, 0.5, 0.45, 0.5},
	{-0.5, 0.45, -0.5, 0.5, 0.5, 0.5}
}

local wall_cab_bbox = {{-0.5, -0.5, -0.45, 0.5, 0.5, 0.5}}


multidecor.register.register_garniture({
	type = "kitchen",
	style = "modern",
	material = "wood",
	tiles = {
		"multidecor_wood.png",
		"multidecor_granite_material.png",
		"multidecor_metal_material.png",
		"multidecor_sink_leakage.png",
		"multidecor_plastic_bucket.png"
	},
	groups = {choppy=1.5},
	modname = "modern",
	components = {
		["two_floor_drws"] = {
			description = "Kitchen Two Shelves Cabinet With Drawers",
			mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_lower = {x=0, y=-0.25, z=0},
				pos_upper = {x=0, y=0.25, z=0},
				inv_size = {w=8, h=2}
			}
		},
		["three_floor_drws"] = {
			description = "Kitchen Three Shelves Cabinet With Drawers",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_lower = {x=0, y=-0.3, z=0},
				pos_middle = {x=0, y=0, z=0},
				pos_upper = {x=0, y=0.3, z=0},
				inv_size = {w=8, h=1}
			}
		},
		["two_floor_doors"] = {
			description = "Kitchen Two Shelves Cabinet With Doors",
			mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_left = {x=-0.5, y=0, z=0.45},
				pos_upper = {x=0.5, y=0, z=0.45},
				inv_size = {w=8, h=3}
			}
		},
		["three_floor_doors"] = {
			description = "Kitchen Three Shelves Cabinet With Doors",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_left = {x=-0.5, y=0, z=0.45},
				pos_upper = {x=0.5, y=0, z=0.45},
				inv_size = {w=8, h=3}
			}
		},
		["three_floor_drw_door"] = {
			description = "Kitchen Three Shelves Cabinet With Drawer And Door",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_upper = {x=0, y=0.3, z=0},
				pos_left = {x=-0.5, y=0, z=0.45},
				pos_upper = {x=0.5, y=0, z=0.45},
				inv_size = {w=8, h=2}
			}
		},
		["two_wall_door"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Door",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos = {x=-0.5, y=0, z=0.45},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_hdoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=-0.5, y=0, z=0.45},
				pos_right = {x=0.5, y=0, z=0.45},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_hgldoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Glass Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=-0.5, y=0, z=0.45},
				pos_right = {x=0.5, y=0, z=0.45},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_crn_hgldoor"] = {
			description = "Kitchen Two Shelves Wall Corner Cabinet With Half Glass Doors",
			mesh = "multidecor_kitchen_wall_corner_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=0.8, y=0, z=1.2},
				pos_right = {x=1.2, y=0, z=0.8},
				inv_size = {w=8, h=4}
			}
		},
		["sink"] = {
			description = "Kitchen Sink",
			mesh = "multidecor_kitchen_sink_cabinet.b3d",
			bounding_boxes = cab_bboxes,
			tap_pos = {x=0, y=0.7, z=-0.1},
			shelves_data = {
				pos_trash = {x=-0.5, y=0, z=0.45},
				inv_size = {w=1, h=1}
			}
		},
	},
	move_parts = {
		["floor_door"] = "multidecor_kitchen_cabinet_door.b3d",
		["floor_half_door"] = "multidecor_kitchen_cabinet_half_door.b3d",
		["wall_door"] = "multidecor_kitchen_wall_cabinet_door.b3d",
		["wall_half_door"] = "multidecor_kitchen_wall_cabinet_half_door.b3d",
		["wall_half_glass_door"] = "multidecor_kitchen_wall_cabinet_half_glass_door.b3d",
		["large_drawer"] = "multidecor_kitchen_cabinet_two_shelves_drawer.b3d",
		["small_drawer"] = "multidecor_kitchen_cabinet_three_shelves_drawer"
	}
})


multidecor.register.register_furniture_unit("ceiling_fan", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = "Ceiling Fan",
	mesh = "multidecor_ceiling_fan.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_ceiling_fan.png"},
	bounding_boxes = {{-0.4, 0, -0.4, 0.4, 0.5, 0.4}}
})

multidecor.register.register_furniture_unit("kitchen_cooker", {
	type = "decoration",
	style = "modern",
	material = "steel",
	description = "Kitchen Cooker",
	mesh = "multidecor_kitchen_cooker.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_metal_material3.png",
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_kitchen_cooker_grid.png"
	}
})

multidecor.register.register_furniture_unit("kitchen_hood", {
	type = "decoration",
	style = "modern",
	material = "steel",
	description = "Kitchen Hood",
	mesh = "multidecor_kitchen_hood.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_kitchen_hood_body.png",
		"multidecor_kitchen_hood_net.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		{-0.3, 0, -0.3, 0.3, 0.5, 0.3}
	}
})

multidecor.register.register_furniture_unit("kitchen_fridge", {
	type = "decoration",
	style = "modern",
	material = "steel",
	description = "Kitchen Fridge",
	mesh = "multidecor_fridge.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_fridge_base.png",
		"multidecor_fridge_interior.png",
		"multidecor_plastic_material.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
	}
})
