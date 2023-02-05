local cab_bboxes = {
	{-0.5, -0.5, -0.425, 0.5, 0.45, 0.5},
	{-0.5, 0.45, -0.5, 0.5, 0.5, 0.5}
}

local wall_cab_bbox = {{-0.5, -0.5, -0.45, 0.5, 0.5, 0.5}}

local sink_bboxes = {
	{-0.5, -0.5, -0.425, 0.5, 0.2, 0.5},
	{-0.5, 0.2, -0.425, -0.35, 0.5, 0.5}, -- left box
	{0.35, 0.2, -0.425, 0.5, 0.5, 0.5},   -- right box
	{-0.35, 0.2, 0.35, 0.35, 0.5, 0.5},  -- back box
	{-0.35, 0.2, -0.425, 0.35, 0.5, -0.35},    -- forward box
	{-0.5, 0.4, -0.5, 0.5, 0.5, -0.425}
}

local tap_pos = vector.new(0, 0.75, 0.05)


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
	obj_tiles = {"multidecor_wood.png", "multidecor_metal_material.png", "multidecor_glass_material.png"},
	groups = {choppy=1.5},
	modname = "modern",
	components = {
		["two_floor_drws"] = {
			description = "Kitchen Two Shelves Cabinet With Drawers",
			mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_lower = {x=0, y=-0.15, z=0},
				pos_upper = {x=0, y=0.25, z=0},
				inv_size = {w=8, h=2}
			}
		},
		["three_floor_drws"] = {
			description = "Kitchen Three Shelves Cabinet With Drawers",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_lower = {x=0, y=-0.2, z=0},
				pos_middle = {x=0, y=0.05, z=0},
				pos_upper = {x=0, y=0.3, z=0},
				inv_size = {w=8, h=1}
			}
		},
		["two_floor_doors"] = {
			description = "Kitchen Two Shelves Cabinet With Doors",
			mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=3}
			}
		},
		["three_floor_doors"] = {
			description = "Kitchen Three Shelves Cabinet With Doors",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=3}
			}
		},
		["three_floor_drw_door"] = {
			description = "Kitchen Three Shelves Cabinet With Drawer And Door",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_upper = {x=0, y=0.3, z=0},
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=2}
			}
		},
		["two_wall_door"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Door",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos = {x=0.45, y=0, z=0.4},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_hdoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_hgldoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Glass Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=3}
			}
		},
		["two_wall_crn_hgldoor"] = {
			description = "Kitchen Two Shelves Wall Corner Cabinet With Half Glass Doors",
			mesh = "multidecor_kitchen_wall_corner_cabinet_two_shelves.b3d",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=1.25, y=0, z=0.65},
				pos_right = {x=0.65, y=0, z=1.25},
				inv_size = {w=8, h=4}
			}
		},
		["sink"] = {
			description = "Kitchen Sink",
			mesh = "multidecor_kitchen_sink_cabinet.b3d",
			bounding_boxes = sink_bboxes,
			tap_pos = tap_pos,
			shelves_data = {
				pos_trash = {x=0.45, y=0, z=0.4},
				inv_size = {w=1, h=1}
			},
			callbacks = {
				on_rightclick = function(pos, node, clicker)
					local meta = minetest.get_meta(pos)

					if meta:contains("water_stream_id") then
						minetest.delete_particlespawner(tonumber(meta:get_string("water_stream_id")))
						meta:set_string("water_stream_id", "")

						local sound_handle = minetest.deserialize(meta:get_string("sound_handle"))
						minetest.sound_stop(sound_handle)
					else
						local id = minetest.add_particlespawner({
							amount = 10,
							time = 0,
							collisiondetection = true,
							object_collision = true,
							texture = "multidecor_water_drop.png",
							minpos = pos+tap_pos+vector.new(-0.05, 0, -0.05),
							maxpos = pos+tap_pos+vector.new(0.05, 0, 0.05),
							minvel = {x=0, y=-1, z=0},
							maxvel = {x=0, y=-1, z=0},
							minsize = 0.8,
							maxsize = 2
						})

						meta:set_string("water_stream_id", tonumber(id))

						local sound_handle = minetest.sound_play("multidecor_tap", {max_hear_distance=12, loop=true})
						meta:set_string("sound_handle", minetest.serialize(sound_handle))
					end
				end
			}
		},
	},
	move_parts = {
		["floor_door"] = {type="door",mesh="multidecor_kitchen_cabinet_door.b3d",box={-0.9,-0.5,0.075,0,0.4,0}},
		["floor_half_door"] = {type="door",mesh="multidecor_kitchen_cabinet_half_door.b3d",box={-0.45,-0.5,0.075,0,0.4,0}},
		["wall_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_door.b3d",box={-0.5,-0.5,-0.1,0.4,0,0}},
		["wall_half_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_door.b3d",box={-0.5,-0.5,-0.1,-0.05,0,0}},
		["wall_half_glass_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_glass_door.b3d",box={-0.5,-0.5,-0.1,-0.05,0,0}},
		["large_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_two_shelves_drawer.b3d",box={-0.3,-0.2,-0.4,0.3,0.2,0.4}},
		["small_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_three_shelves_drawer.b3d",box={-0.3,-0.15,-0.4,0.3,0.15,0.4}}
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
	material = "metal",
	description = "Kitchen Cooker",
	mesh = "multidecor_kitchen_cooker.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_metal_material3.png",
		"multidecor_kitchen_cooker_grid.png"
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.default_can_dig
	},
	add_properties = {
		shelves_data = {
			{
				type = "door",
				object = "modern:kitchen_cooker_oven_door",
				pos = {x=0, y=-0.35, z=0.4},
				inv_size = {w=8, h=1},
				acc = 1,
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
})

minetest.register_entity("modern:kitchen_cooker_oven_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_kitchen_cooker_oven_door.b3d",
	textures = {"multidecor_kitchen_cooker_oven_door.png", "multidecor_metal_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-0.5, -0.5, 0.1, 0.5, 0, 0},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_door_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})

multidecor.register.register_light("kitchen_hood", {
	style = "modern",
	material = "metal",
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
},
{
	swap_light = {
		name = "kitchen_hood_on",
		light_level = 9
	}
})

multidecor.register.register_furniture_unit("kitchen_fridge", {
	type = "decoration",
	style = "modern",
	material = "metal",
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
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.default_can_dig
	},
	add_properties = {
		shelves_data = {
			{
				type = "door",
				object = "modern:kitchen_fridge_upper_door",
				pos = {x=-0.5, y=0.7, z=0.4},
				inv_size = {w=8, h=4},
				acc = 1,
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			},
			{
				type = "door",
				object = "modern:kitchen_fridge_lower_door",
				pos = {x=-0.5, y=0, z=0.4},
				inv_size = {w=8, h=2},
				acc = 1,
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
})

minetest.register_entity("modern:kitchen_fridge_upper_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_fridge_upper_door.b3d",
	textures = {"multidecor_fridge_interior.png", "multidecor_metal_material.png", "multidecor_plastic_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-1, -0.5, 0.1, 0, 0.2, 0},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_door_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})

minetest.register_entity("modern:kitchen_fridge_lower_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_fridge_lower_door.b3d",
	textures = {"multidecor_fridge_interior.png", "multidecor_metal_material.png", "multidecor_plastic_material.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-1, -0.5, 0.1, 0, -0.2, 0},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_door_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})
