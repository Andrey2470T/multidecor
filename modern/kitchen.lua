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

local cmpnts = {
	["two_floor_drws"] = {
		description = "Kitchen %s Two Shelves Cabinet With Drawers",
		mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_two_drawers_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_lower = {x=0, y=-0.15, z=0},
			pos_upper = {x=0, y=0.25, z=0},
			inv_size = {w=8, h=2}
		}
	},
	["three_floor_drws"] = {
		description = "Kitchen %s Three Shelves Cabinet With Drawers",
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_three_drawers_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_lower = {x=0, y=-0.2, z=0},
			pos_middle = {x=0, y=0.05, z=0},
			pos_upper = {x=0, y=0.3, z=0},
			inv_size = {w=8, h=1}
		}
	},
	["two_floor_doors"] = {
		description = "Kitchen %s Two Shelves Cabinet With Doors",
		mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_doors_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_left = {x=0.425, y=0, z=0.4},
			pos_right = {x=-0.425, y=0, z=0.4},
			inv_size = {w=8, h=2}
		}
	},
	["three_floor_doors"] = {
		description = "Kitchen %s Three Shelves Cabinet With Doors",
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_doors_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_left = {x=0.425, y=0, z=0.4},
			pos_right = {x=-0.425, y=0, z=0.4},
			inv_size = {w=8, h=3}
		}
	},
	["three_floor_drw_door"] = {
		description = "Kitchen %s Three Shelves Cabinet With Drawer And Door",
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_door_and_drawer_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_upper = {x=0, y=0.3, z=0},
			pos_left = {x=0.425, y=0, z=0.4},
			pos_right = {x=-0.425, y=0, z=0.4},
			inv_size = {w=8, h=2}
		}
	},
	["sink"] = {
		description = "Kitchen %s Sink Cabinet",
		mesh = "multidecor_kitchen_sink_cabinet.b3d",
		inventory_image = "multidecor_kitchen_%s_sink_inv.png",
		bounding_boxes = sink_bboxes,
		tap_pos = tap_pos,
		shelves_data = {
			invlist_type = "trash",
			pos_trash = {x=0.45, y=0, z=0.4},
			side = "left"
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
					local dir = minetest.facedir_to_dir(node.param2)
					local yaw = vector.dir_to_rotation(dir).y

					local rot_tap_pos = table.copy(tap_pos)
					rot_tap_pos = vector.rotate_around_axis(rot_tap_pos, vector.new(0, 1, 0), yaw)
					local id = minetest.add_particlespawner({
						amount = 20,
						time = 0,
						collisiondetection = true,
						object_collision = true,
						texture = "multidecor_water_drop.png",
						minpos = pos+rot_tap_pos+vector.new(-0.05, 0, -0.05),
						maxpos = pos+rot_tap_pos+vector.new(0.05, 0, 0.05),
						minvel = {x=0, y=-1, z=0},
						maxvel = {x=0, y=-1, z=0},
						minsize = 0.8,
						maxsize = 2
					})

					meta:set_string("water_stream_id", tonumber(id))

					local sound_handle = minetest.sound_play("multidecor_tap", {pos=pos, max_hear_distance=12})
					meta:set_string("sound_handle", minetest.serialize(sound_handle))
				end
			end,
			on_destruct = function(pos)
				local meta = minetest.get_meta(pos)

				if meta:contains("water_stream_id") then
					minetest.delete_particlespawner(tonumber(meta:get_string("water_stream_id")))
					minetest.sound_stop(minetest.deserialize(meta:get_string("sound_handle")))
				end
			end
		}
	},
}

local garniture_def = {
	type = "kitchen",
	style = "modern",
	material = "wood",
	common_name = "kitchen_modern_%s_cabinet",
	objs_common_name = "kitchen_cabinet",
	tiles = {
		"multidecor_wood.png",
		"multidecor_%s_material.png",
		"multidecor_metal_material.png",
		"multidecor_sink_leakage.png",
		"multidecor_plastic_bucket.png"
	},
	--obj_tiles = {"multidecor_wood.png", "multidecor_metal_material.png", "multidecor_glass_material.png"},
	groups = {choppy=1.5},
	modname = "modern"
}

local granite_cmpnts = table.copy(cmpnts)

for name, data in pairs(granite_cmpnts) do
	data.description = data.description:format("Granite")
	data.inventory_image = data.inventory_image:format("granite")
end

granite_cmpnts.two_wall_door = {
	description = "Kitchen Two Shelves Wall Cabinet With Door",
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_door_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos = {x=0.45, y=0, z=0.4},
		inv_size = {w=8, h=2},
		side = "left"
	}
}

granite_cmpnts.two_wall_hdoor = {
	description = "Kitchen Two Shelves Wall Cabinet With Half Doors",
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_half_door_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=0.425, y=0, z=0.4},
		pos_right = {x=-0.425, y=0, z=0.4},
		inv_size = {w=8, h=2}
	}
}

granite_cmpnts.two_wall_hgldoor = {
	description = "Kitchen Two Shelves Wall Cabinet With Half Glass Doors",
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_half_glass_doors_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=0.425, y=0, z=0.4},
		pos_right = {x=-0.425, y=0, z=0.4},
		inv_size = {w=8, h=2}
	}
}

granite_cmpnts.two_wall_crn_hgldoor = {
	description = "Kitchen Two Shelves Wall Corner Cabinet With Half Glass Doors",
	mesh = "multidecor_kitchen_wall_corner_cabinet_two_shelves.b3d",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=1.25, y=0, z=0.65},
		pos_right = {x=0.65, y=0, z=1.25},
		inv_size = {w=8, h=4}
	}
}

local granite_garniture_def = table.copy(garniture_def)
granite_garniture_def.common_name = granite_garniture_def.common_name:format("granite")
granite_garniture_def.tiles[2] = granite_garniture_def.tiles[2]:format("granite")
granite_garniture_def.components = granite_cmpnts

multidecor.register.register_garniture(granite_garniture_def)


local marble_cmpnts = table.copy(cmpnts)

for name, data in pairs(marble_cmpnts) do
	data.description = data.description:format("Marble")
	data.inventory_image = data.inventory_image:format("marble")
end

local marble_garniture_def = table.copy(garniture_def)
marble_garniture_def.common_name = marble_garniture_def.common_name:format("marble")
marble_garniture_def.tiles[2] = marble_garniture_def.tiles[2]:format("marble")
marble_garniture_def.components = marble_cmpnts

multidecor.register.register_garniture(marble_garniture_def)


local objects = {
	["floor_door"] = {type="door",mesh="multidecor_kitchen_cabinet_door.b3d",box={-0.9,-0.5,0,0,0.4,0.075}},
	["floor_half_door"] = {type="door",mesh="multidecor_kitchen_cabinet_half_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
	["wall_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_door.b3d",box={-0.9,-0.5,0,0,0.4,0.075}},
	["wall_half_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
	["wall_half_glass_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_glass_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
	["large_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_two_shelves_drawer.b3d",box={-0.3,-0.2,-0.4,0.3,0.2,0.4}},
	["small_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_three_shelves_drawer.b3d",box={-0.3,-0.15,-0.4,0.3,0.15,0.4}}
}

for name, props in pairs(objects) do
	minetest.register_entity("modern:kitchen_cabinet_" .. name, {
		visual = "mesh",
		visual_size = {x=5, y=5, z=5},
		mesh = props.mesh,
		textures = {"multidecor_wood.png", "multidecor_metal_material.png", "multidecor_glass_material.png"},
		backface_culling = false,
		use_texture_alpha = true,
		physical = false,
		selectionbox = props.box,
		on_activate = multidecor.shelves.default_on_activate,
		on_rightclick = multidecor.shelves.default_on_rightclick,
		on_step = props.type == "drawer" and multidecor.shelves.default_drawer_on_step or multidecor.shelves.default_door_on_step,
		get_staticdata = multidecor.shelves.default_get_staticdata
	})
end

--[[multidecor.register.register_garniture({
	type = "kitchen",
	style = "modern",
	material = "wood",
	common_name = "kitchen_modern_granite_cabinet",
	objs_common_name = "kitchen_cabinet"
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
			inventory_image = "multidecor_kitchen_cabinet_with_two_drawers_inv.png",
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
			inventory_image = "multidecor_kitchen_cabinet_with_three_drawers_inv.png",
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
			inventory_image = "multidecor_kitchen_cabinet_with_doors_inv.png",
			bounding_boxes = cab_bboxes,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=2}
			}
		},
		["three_floor_doors"] = {
			description = "Kitchen Three Shelves Cabinet With Doors",
			mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
			inventory_image = "multidecor_kitchen_cabinet_with_doors_inv.png",
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
			inventory_image = "multidecor_kitchen_cabinet_with_door_and_drawer_inv.png",
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
			inventory_image = "multidecor_kitchen_wall_cabinet_with_door_inv.png",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos = {x=0.45, y=0, z=0.4},
				inv_size = {w=8, h=2},
				side = "left"
			}
		},
		["two_wall_hdoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			inventory_image = "multidecor_kitchen_wall_cabinet_with_half_door_inv.png",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=2}
			}
		},
		["two_wall_hgldoor"] = {
			description = "Kitchen Two Shelves Wall Cabinet With Half Glass Doors",
			mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
			inventory_image = "multidecor_kitchen_wall_cabinet_with_half_glass_doors_inv.png",
			bounding_boxes = wall_cab_bbox,
			shelves_data = {
				pos_left = {x=0.425, y=0, z=0.4},
				pos_right = {x=-0.425, y=0, z=0.4},
				inv_size = {w=8, h=2}
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
			inventory_image = "multidecor_kitchen_sink_inv.png",
			bounding_boxes = sink_bboxes,
			tap_pos = tap_pos,
			shelves_data = {
				invlist_type = "trash",
				pos_trash = {x=0.45, y=0, z=0.4},
				side = "left"
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
						local dir = minetest.facedir_to_dir(node.param2)
						local yaw = vector.dir_to_rotation(dir).y

						local rot_tap_pos = table.copy(tap_pos)
						rot_tap_pos = vector.rotate_around_axis(rot_tap_pos, vector.new(0, 1, 0), yaw)
						local id = minetest.add_particlespawner({
							amount = 20,
							time = 0,
							collisiondetection = true,
							object_collision = true,
							texture = "multidecor_water_drop.png",
							minpos = pos+rot_tap_pos+vector.new(-0.05, 0, -0.05),
							maxpos = pos+rot_tap_pos+vector.new(0.05, 0, 0.05),
							minvel = {x=0, y=-1, z=0},
							maxvel = {x=0, y=-1, z=0},
							minsize = 0.8,
							maxsize = 2
						})

						meta:set_string("water_stream_id", tonumber(id))

						local sound_handle = minetest.sound_play("multidecor_tap", {pos=pos, max_hear_distance=12})
						meta:set_string("sound_handle", minetest.serialize(sound_handle))
					end
				end,
				on_destruct = function(pos)
					local meta = minetest.get_meta(pos)

					if meta:contains("water_stream_id") then
						minetest.delete_particlespawner(tonumber(meta:get_string("water_stream_id")))
						minetest.sound_stop(minetest.deserialize(meta:get_string("sound_handle")))
					end
				end
			}
		},
	},
	move_parts = {
		["floor_door"] = {type="door",mesh="multidecor_kitchen_cabinet_door.b3d",box={-0.9,-0.5,0,0,0.4,0.075}},
		["floor_half_door"] = {type="door",mesh="multidecor_kitchen_cabinet_half_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
		["wall_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_door.b3d",box={-0.9,-0.5,0,0,0.4,0.075}},
		["wall_half_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
		["wall_half_glass_door"] = {type="door",mesh="multidecor_kitchen_wall_cabinet_half_glass_door.b3d",box={-0.45,-0.5,0,0,0.4,0.075}},
		["large_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_two_shelves_drawer.b3d",box={-0.3,-0.2,-0.4,0.3,0.2,0.4}},
		["small_drawer"] = {type="drawer",mesh="multidecor_kitchen_cabinet_three_shelves_drawer.b3d",box={-0.3,-0.15,-0.4,0.3,0.15,0.4}}
	}
})]]

local fans_blades = {}

multidecor.register.register_furniture_unit("ceiling_fan", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = "Ceiling Fan",
	mesh = "multidecor_ceiling_fan.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_ceiling_fan.png"},
	inventory_image = "multidecor_ceiling_fan_inv.png",
	bounding_boxes = {{-0.2, 0, -0.2, 0.2, 0.5, 0.2}},
	callbacks = {
		on_construct = function(pos)
			local blades = minetest.add_entity(pos, "modern:ceiling_fan_blades", vector.to_string(pos))
		end,
		on_destruct = function(pos)
			local strpos = vector.to_string(pos)

			if fans_blades[strpos] then
				fans_blades[strpos]:remove()
				fans_blades[strpos] = nil
			end
		end
	}
})

minetest.register_entity("modern:ceiling_fan_blades", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_ceiling_fan_blades.b3d",
	textures = {"multidecor_ceiling_fan.png"},
	physical = true,
	backface_culling = false,
	selectionbox = {-0.5, -0.2, -0.5, 0.5, 0, 0.5},
	static_save = true,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})

		if staticdata ~= "" then
			self.attached_to = staticdata

			if not fans_blades[self.attached_to] then
				fans_blades[self.attached_to] = self.object
				self.object:set_animation({x=1, y=40})
			end
		end
	end,
	get_staticdata = function(self)
		return self.attached_to
	end
})

multidecor.register.register_furniture_unit("kitchen_cooker", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = "Kitchen Cooker",
	mesh = "multidecor_kitchen_cooker.b3d",
	inventory_image = "multidecor_kitchen_cooker_inv.png",
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
			common_name = "kitchen_cooker",
			{
				type = "door",
				object = "modern:kitchen_cooker_oven_door",
				pos = {x=0, y=-0.35, z=0.4},
				invlist_type = "cooker",
				acc = 1,
				side = "centered",
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
})

multidecor.register.register_furniture_unit("kitchen_cooker_activated", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = "Kitchen Cooker",
	mesh = "multidecor_kitchen_cooker.b3d",
	inventory_image = "multidecor_kitchen_cooker_inv.png",
	light_source = 8,
	visual_scale = 0.5,
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_metal_material3.png",
		"multidecor_kitchen_cooker_grid.png"
	},
	groups = {not_in_creative_inventory=1},
	callbacks = {
		can_dig = multidecor.shelves.default_can_dig
	},
	add_properties = {
		shelves_data = {
			common_name = "kitchen_cooker",
			{
				type = "door",
				object = "modern:kitchen_cooker_oven_door",
				pos = {x=0, y=-0.35, z=0.4},
				invlist_type = "cooker",
				acc = 1,
				side = "centered",
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
	selectionbox = {-0.5, 0, 0.1, 0.5, 0.6, 0},
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
	inventory_image = "multidecor_fridge_inv.png",
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
			common_name = "kitchen_fridge",
			{
				type = "door",
				object = "modern:kitchen_fridge_upper_door",
				pos = {x=-0.5, y=0.7, z=0.4},
				inv_size = {w=8, h=4},
				acc = 1,
				side = "right",
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
				side = "right",
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
	selectionbox = {0, -0.5, 0, 1, 0.8, 0.1},
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
	selectionbox = {0, -0.5, 0, 1, 0.15, 0.1},
	static_save = true,
	on_activate = multidecor.shelves.default_on_activate,
	on_rightclick = multidecor.shelves.default_on_rightclick,
	on_step = multidecor.shelves.default_door_on_step,
	get_staticdata = multidecor.shelves.default_get_staticdata
})

multidecor.register.register_furniture_unit("porcelain_plate", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Plate",
	mesh = "multidecor_porcelain_plate.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_porcelain_material.png^multidecor_porcelain_plate_pattern.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, -0.4, 0.3}}
},
{
	recipe = {
		{"default:clay_lump", "multidecor:brass_stripe", "default:clay_lump"},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("porcelain_plate_with_fork_and_knife", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Plate With Fork And Knife",
	mesh = "multidecor_porcelain_plate_with_fork_and_knife.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_porcelain_material.png^multidecor_porcelain_plate_pattern.png",
		"multidecor_metal_material.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.3, -0.5, -0.3, 0.3, -0.4, 0.3},
		{-0.45, -0.5, -0.3, -0.35, -0.45, 0.3},
		{0.35, -0.5, -0.3, 0.45, -0.45, 0.3}
	}
},
{
	recipe = {
		{"default:stick", "", "multidecor:steel_sheet"},
		{"", "multidecor:porcelain_plate", "multidecor:steel_scissors"},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("porcelain_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Cup",
	mesh = "multidecor_porcelain_cup.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_porcelain_material.png"},
	bounding_boxes = {{-0.2, -0.5, -0.2, 0.2, -0.15, 0.2}}
},
{
	recipe = {
		{"default:clay_lump", "", ""},
		{"default:clay_lump", "", ""},
		{"" , "", ""}
	}
})

multidecor.register.register_furniture_unit("glass_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Glass Cup",
	mesh = "multidecor_porcelain_cup.b3d",
	use_texture_alpha = "blend",
	visual_scale = 0.5,
	tiles = {"multidecor_glass_material.png"},
	bounding_boxes = {{-0.2, -0.5, -0.2, 0.2, -0.15, 0.2}}
},
{
	recipe = {
		{"xpanes:pane_flat", "", ""},
		{"xpanes:pane_flat", "", ""},
		{"" , "", ""}
	},
	count = 2
})

multidecor.register.register_furniture_unit("napkins_rack", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = "Rack for paper napkins",
	mesh = "multidecor_napkins_rack.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_metal_material.png", "multidecor_paper_napkins.png"},
	bounding_boxes = {{-0.2, -0.5, -0.1, 0.2, -0.1, 0.1}}
},
{
	recipe = {
		{"multidecor:steel_sheet", "", ""},
		{"wool:white", "", ""},
		{"" , "", ""}
	},
	count = 3
})

multidecor.register.register_furniture_unit("saucepans_set", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = "Saucepans set (put it on the cooker top)",
	mesh = "multidecor_saucepans_set.b3d",
	use_texture_alpha = "blend",
	visual_scale = 0.5,
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_metal_material3.png",
		"multidecor_glass_material.png",
		"multidecor_kitchen_cooker_black_metal.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, 0, 0.1, -0.1, 0.5},
		{0, -0.5, -0.3, 0.4, -0.2, 0}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "xpanes:pane_flat", "dye:black"},
		{"multidecor:steel_sheet", "xpanes:pane_flat", "multidecor:plastic_sheet"},
		{"multidecor:steel_sheet" , "", ""}
	}
})

local cast_iron_pan_recipe
if minetest.get_modpath("technic_worldgen") then
	cast_iron_pan_recipe = {
		recipe = {
			{"technic:cast_iron_ingot", "multidecor:plank", ""},
			{"technic:cast_iron_ingot", "", ""},
			{"", "", ""}
		}
	}
end

multidecor.register.register_furniture_unit("cast_iron_pan", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = "Cast Iron Pan",
	mesh = "multidecor_cast_iron_pan.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_coarse_metal_material.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.25, -0.5, -0.25, 0.25, -0.35, 0.25}
	}
}, cast_iron_pan_recipe)

multidecor.register.register_furniture_unit("porcelain_saucer_with_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Saucer With Cup",
	mesh = "multidecor_porcelain_saucer_with_cup.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_porcelain_material.png^multidecor_porcelain_plate_pattern.png",
	},
	bounding_boxes = {
		{-0.3, -0.5, -0.3, 0.3, -0.4, 0.3},
		{-0.175, -0.4, -0.175, 0.175, -0.225, 0.175}
	}
},
{
	type = "shapeless",
	recipe = {"multidecor:porcelain_cup", "multidecor:porcelain_plate"}
})

multidecor.register.register_furniture_unit("porcelain_saucer_with_tea_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Saucer With Tea Cup",
	mesh = "multidecor_porcelain_saucer_with_tea_cup.b3d",
	visual_scale = 0.5,
	tiles = {
		"multidecor_porcelain_material.png^multidecor_porcelain_plate_pattern.png",
		"multidecor_tea.png"
	},
	bounding_boxes = {
		{-0.3, -0.5, -0.3, 0.3, -0.4, 0.3},
		{-0.175, -0.4, -0.175, 0.175, -0.225, 0.175}
	}
},
{
	type = "shapeless",
	recipe = {"multidecor:porcelain_saucer_with_cup", "bucket:bucket_water", "default:grass_1"},
	replacements = {{"bucker:bucker_water", "bucket:bucket_empty"}}
})

minetest.register_abm({
	label = "tea steam",
	nodenames = "multidecor:porcelain_saucer_with_tea_cup",
	interval = 2,
	chance = 1,
	action = function(pos)
		minetest.add_particlespawner({
			amount = 1,
			time = 1,
			minpos = {x=pos.x-0.075, y=pos.y-0.2, z=pos.z-0.075},
			maxpos = {x=pos.x+0.075, y=pos.y-0.15, z=pos.z+0.075},
			minvel = {x=-0.003, y=0.01, z=-0.003},
			maxvel = {x=0.003, y=0.01, z=-0.003},
			minacc = {x=0.0,y=-0.0,z=-0.0},
			maxacc = {x=0.0,y=0.003,z=-0.0},
			minexptime = 2,
			maxexptime = 5,
			minsize = 2,
			maxsize = 2.4,
			collisiondetection = false,
			texture = "multidecor_steam.png",
		})
	end
})

multidecor.register.register_furniture_unit("faceted_glass", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Faceted Glass",
	mesh = "multidecor_faceted_glass.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_glass_material.png"},
	use_texture_alpha = "blend",
	bounding_boxes = {
		{-0.15, -0.5, -0.15, 0.15, 0, 0.15}
	}
},
{
	type = "shapeless",
	recipe = {"xpanes:pane_flat", "multidecor:hammer"},
	replacements = {{"multidecor:hammer", "multidecor:hammer"}},
	count = 2
})

multidecor.register.register_furniture_unit("porcelain_teapot", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = "Porcelain Teapot",
	mesh = "multidecor_porcelain_teapot.b3d",
	visual_scale = 0.5,
	tiles = {"multidecor_porcelain_material.png", "multidecor_porcelain_plate_pattern.png"},
	bounding_boxes = {
		{-0.25, -0.5, -0.25, 0.25, -0.15, 0.25}
	}
},
{
	recipe = {
		{"default:clay_lump", "default:clay_lump", "bucket:bucket_water"},
		{"default:clay_lump", "default:grass_1", ""},
		{"", "", ""}
	},
	replacements = {{"bucker:bucker_water", "bucket:bucket_empty"}}
})

multidecor.register.register_furniture_unit("kitchen_ceramic_tile_1", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = "Kitchen Wall Ceramic Tile",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {"multidecor_kitchen_ceramic_tile1.png"},
	bounding_boxes = {{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5}}
})

multidecor.register.register_furniture_unit("kitchen_ceramic_tile_2", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = "Kitchen Wall Ceramic Tile",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {"multidecor_kitchen_ceramic_tile2.png"},
	bounding_boxes = {{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5}}
})

multidecor.register.register_furniture_unit("kitchen_marble_tile", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = "Kitchen Wall Marble Tile",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {"multidecor_kitchen_marble_tile.png"},
	bounding_boxes = {{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5}}
})

multidecor.register.register_furniture_unit("kitchen_floor_white_tile", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = "Kitchen Floor White Tile",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {"multidecor_kitchen_floor_white_tile.png"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}}
})

multidecor.register.register_furniture_unit("kitchen_floor_black_tile", {
	type = "decoration",
	style = "modern",
	material = "stone",
	description = "Kitchen Floor Black Tile",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {"multidecor_kitchen_floor_black_tile.png"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}}
})


