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

local tile_bboxes = {
	type = "wallmounted",
	wall_top = {-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
	wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	wall_side = {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5}

}

local tap_pos = vector.new(0, 0.75, -0.05)

local cmpnts = {
	["two_floor_drws"] = {
		description = modern.S("Kitchen %s Two Shelves Cabinet With Drawers"),
		mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_two_drawers_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_lower = {x=0, y=-0.15, z=0},
			pos_upper = {x=0, y=0.25, z=0},
			inv_size = {w=8, h=2}
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:drawer", "multidecor:drawer"},
			{"multidecor:hammer", "", ""}
		}
	},
	["three_floor_drws"] = {
		description = modern.S("Kitchen %s Three Shelves Cabinet With Drawers"),
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_three_drawers_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_lower = {x=0, y=-0.2, z=0},
			pos_middle = {x=0, y=0.05, z=0},
			pos_upper = {x=0, y=0.3, z=0},
			inv_size = {w=8, h=1}
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:drawer", "multidecor:drawer"},
			{"multidecor:drawer", "multidecor:hammer", ""}
		}
	},
	["two_floor_doors"] = {
		description = modern.S("Kitchen %s Two Shelves Cabinet With Doors"),
		mesh = "multidecor_kitchen_cabinet_two_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_doors_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_left = {x=0.425, y=0, z=0.4},
			pos_right = {x=-0.425, y=0, z=0.4},
			inv_size = {w=8, h=2}
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:cabinet_half_door", "multidecor:cabinet_half_door"},
			{"multidecor:hammer", "", ""}
		}
	},
	["three_floor_doors"] = {
		description = modern.S("Kitchen %s Three Shelves Cabinet With Doors"),
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_doors_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_left = {x=0.425, y=0, z=0.4},
			pos_right = {x=-0.425, y=0, z=0.4},
			inv_size = {w=8, h=3}
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:board", "multidecor:cabinet_half_door"},
			{"multidecor:cabinet_half_door", "multidecor:hammer", ""}
		}
	},
	["three_floor_drw_door"] = {
		description = modern.S("Kitchen %s Three Shelves Cabinet With Drawer And Door"),
		mesh = "multidecor_kitchen_cabinet_three_shelves.b3d",
		inventory_image = "multidecor_kitchen_%s_cabinet_with_door_and_drawer_inv.png",
		bounding_boxes = cab_bboxes,
		shelves_data = {
			pos_upper = {x=0, y=0.3, z=0},
			pos_left = {x=0.425, y=-0.125, z=0.4},
			pos_right = {x=-0.425, y=-0.125, z=0.4},
			inv_size = {w=8, h=2}
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:cabinet_door", ""},
			{"multidecor:drawer", "multidecor:hammer", ""}
		}
	},
	["sink"] = {
		description = modern.S("Kitchen %s Sink Cabinet"),
		mesh = "multidecor_kitchen_sink_cabinet.b3d",
		inventory_image = "multidecor_kitchen_%s_sink_inv.png",
		bounding_boxes = sink_bboxes,
		tap_pos = tap_pos,
		shelves_data = {
			invlist_type = "trash",
			pos_trash = {x=0.45, y=0, z=0.4},
			side = "left"
		},
		tap_data = {
			min_pos = tap_pos,
			max_pos = tap_pos,
			amount = 80,
			velocity = 2,
			direction = {x=0, y=-1, z=0},
			sound = "multidecor_tap",
			check_for_sink = false
		},
		craft = {
			{"multidecor:board", "multidecor:board", "multidecor:board"},
			{"multidecor:board", "multidecor:cabinet_door", "multidecor:bathroom_tap_with_cap_flap"},
			{"multidecor:syphon", "multidecor:hammer", ""}
		},
		callbacks = {
			on_construct = function(pos)
				multidecor.shelves.set_shelves(pos)
				--multidecor.tap.register_water_stream(pos, tap_pos, tap_pos, 80, 2, {x=0, y=-1, z=0}, "multidecor_tap", false)
			end,
			on_rightclick = multidecor.tap.on_rightclick,
			on_destruct = multidecor.tap.on_destruct
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


--Since there`s no granite material yet, it is replaced temporarily to the default stone
granite_cmpnts.two_floor_drws.craft[3][2] = "stairs:slab_granite"
granite_cmpnts.three_floor_drws.craft[3][3] = "stairs:slab_granite"
granite_cmpnts.two_floor_doors.craft[3][2] = "stairs:slab_granite"
granite_cmpnts.three_floor_doors.craft[3][3] = "stairs:slab_granite"
granite_cmpnts.three_floor_drw_door.craft[3][3] = "stairs:slab_granite"
granite_cmpnts.sink.craft[3][3] = "stairs:slab_granite"

granite_cmpnts.two_wall_door = {
	description = modern.S("Kitchen Two Shelves Wall Cabinet With Door"),
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_door_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos = {x=0.45, y=0, z=0.4},
		inv_size = {w=8, h=2},
		side = "left"
	},
	craft = {
		{"multidecor:board", "multidecor:board", "multidecor:board"},
		{"multidecor:board", "multidecor:cabinet_door", "multidecor:hammer"},
		{"", "", ""}
	}
}

granite_cmpnts.two_wall_hdoor = {
	description = modern.S("Kitchen Two Shelves Wall Cabinet With Half Doors"),
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_half_door_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=0.425, y=0, z=0.4},
		pos_right = {x=-0.425, y=0, z=0.4},
		inv_size = {w=8, h=2}
	},
	craft = {
		{"multidecor:board", "multidecor:board", "multidecor:board"},
		{"multidecor:board", "multidecor:cabinet_half_door", "multidecor:cabinet_half_door"},
		{"multidecor:hammer", "", ""}
	}
}

granite_cmpnts.two_wall_hgldoor = {
	description = modern.S("Kitchen Two Shelves Wall Cabinet With Half Glass Doors"),
	mesh = "multidecor_kitchen_wall_cabinet_two_shelves.b3d",
	inventory_image = "multidecor_kitchen_wall_cabinet_with_half_glass_doors_inv.png",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=0.425, y=0, z=0.4},
		pos_right = {x=-0.425, y=0, z=0.4},
		inv_size = {w=8, h=2}
	},
	craft = {
		{"multidecor:board", "multidecor:board", "multidecor:board"},
		{"multidecor:board", "multidecor:cabinet_half_glass_door", "multidecor:cabinet_half_glass_door"},
		{"multidecor:hammer", "", ""}
	}
}

granite_cmpnts.two_wall_crn_hgldoor = {
	description = modern.S("Kitchen Two Shelves Wall Corner Cabinet With Half Glass Doors"),
	mesh = "multidecor_kitchen_wall_corner_cabinet_two_shelves.b3d",
	bounding_boxes = wall_cab_bbox,
	shelves_data = {
		pos_left = {x=1.25, y=0, z=0.65},
		pos_right = {x=0.65, y=0, z=1.25},
		inv_size = {w=8, h=4}
	},
	craft = {
		{"multidecor:board", "multidecor:board", "multidecor:board"},
		{"multidecor:board", "multidecor:board", "multidecor:board"},
		{"multidecor:cabinet_half_glass_door", "multidecor:cabinet_half_glass_door", "multidecor:hammer"}
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

--Since there`s no marble material yet, it is replaced temporarily to the default silver sandstone
marble_cmpnts.two_floor_drws.craft[3][2] = "multidecor:marble_sheet"
marble_cmpnts.three_floor_drws.craft[3][3] = "multidecor:marble_sheet"
marble_cmpnts.two_floor_doors.craft[3][2] = "multidecor:marble_sheet"
marble_cmpnts.three_floor_doors.craft[3][3] = "multidecor:marble_sheet"
marble_cmpnts.three_floor_drw_door.craft[3][3] = "multidecor:marble_sheet"
marble_cmpnts.sink.craft[3][3] = "multidecor:marble_sheet"

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
		on_activate = multidecor.shelves.on_activate,
		on_rightclick = multidecor.shelves.on_rightclick,
		on_step = props.type == "drawer" and multidecor.shelves.drawer_on_step or multidecor.shelves.door_on_step,
		get_staticdata = multidecor.shelves.get_staticdata,
		on_deactivate = multidecor.shelves.on_deactivate
	})
end

multidecor.register.register_furniture_unit("ceiling_fan", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Ceiling Fan"),
	mesh = "multidecor_ceiling_fan.b3d",
	tiles = {"multidecor_ceiling_fan.png"},
	inventory_image = "multidecor_ceiling_fan_inv.png",
	bounding_boxes = {{-0.2, 0, -0.2, 0.2, 0.5, 0.2}},
	callbacks = {
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			minetest.add_entity(pos, "modern:ceiling_fan_blades", minetest.serialize({pos=pos, name=node.name}))
		end
	}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:plastic_sheet", ""},
		{"multidecor:metal_bar", "", ""},
		{"", "", ""}
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
			-- The code below is for backwards compatibility with versions < 1.2.5
			local attach = vector.from_string(staticdata)

			if attach then
				self.object:remove()
				minetest.set_node(attach, minetest.get_node(attach))
				return
			end
			-- end

			self.attached_to = minetest.deserialize(staticdata)

			if not attach and not self.attached_to then
				self.object:remove()
				return
			end

			if self.attached_to.sound then
				minetest.sound_stop(self.attached_to.sound)
			end

			self.attached_to.sound = minetest.sound_play("multidecor_fan_noise", {object=self.object, fade=1.0, max_hear_distance=15, loop=true})
		end

		self.object:set_animation({x=1, y=40}, 30)
	end,
	on_step = function(self, dtime)
		if not self.attached_to then
			self.object:remove()
			return
		end

		local cur_node = minetest.get_node(self.attached_to.pos)

		if cur_node.name ~= self.attached_to.name then
			self.object:remove()
			minetest.sound_stop(self.attached_to.sound)
			return
		end
	end,
	get_staticdata = function(self)
		return minetest.serialize(self.attached_to)
	end
})

multidecor.register.register_furniture_unit("kitchen_cooker", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Cooker"),
	mesh = "multidecor_kitchen_cooker.b3d",
	inventory_image = "multidecor_kitchen_cooker_inv.png",
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_metal_material3.png",
		"multidecor_kitchen_cooker_grid.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.can_dig
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
				side = "down",
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "multidecor:plastic_sheet"},
		{"multidecor:bulb", "xpanes:pane_flat", "multidecor:steel_sheet"},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("kitchen_cooker_activated", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Cooker"),
	mesh = "multidecor_kitchen_cooker.b3d",
	inventory_image = "multidecor_kitchen_cooker_inv.png",
	light_source = 8,
	tiles = {
		"multidecor_metal_material.png",
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_metal_material3.png",
		"multidecor_kitchen_cooker_grid.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
	groups = {not_in_creative_inventory=1},
	callbacks = {
		can_dig = multidecor.shelves.can_dig
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
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})

multidecor.register.register_light("kitchen_hood", {
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Hood"),
	mesh = "multidecor_kitchen_hood.b3d",
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
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "dye:black"},
		{"multidecor:chainlink", "multidecor:bulb", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("kitchen_fridge", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Fridge"),
	mesh = "multidecor_fridge.b3d",
	inventory_image = "multidecor_fridge_inv.png",
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
		can_dig = multidecor.shelves.can_dig
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
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "multidecor:steel_sheet"},
		{"multidecor:steel_sheet", "multidecor:plastic_sheet", "multidecor:plastic_sheet"},
		{"multidecor:metal_bar", "xpanes:pane_flat", "multidecor:wolfram_wire"}
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
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
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
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})

multidecor.register.register_furniture_unit("porcelain_plate", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = modern.S("Porcelain Plate"),
	mesh = "multidecor_porcelain_plate.b3d",
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
	description = modern.S("Porcelain Plate With Fork And Knife"),
	mesh = "multidecor_porcelain_plate_with_fork_and_knife.b3d",
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
		{"default:stick", "", "multidecor:steel_stripe"},
		{"", "multidecor:porcelain_plate", "multidecor:steel_scissors"},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("porcelain_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = modern.S("Porcelain Cup"),
	mesh = "multidecor_porcelain_cup.b3d",
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
	description = modern.S("Glass Cup"),
	mesh = "multidecor_porcelain_cup.b3d",
	use_texture_alpha = "blend",
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
	description = modern.S("Rack for paper napkins"),
	mesh = "multidecor_napkins_rack.b3d",
	tiles = {"multidecor_metal_material.png", "multidecor_paper_napkins.png"},
	bounding_boxes = {{-0.2, -0.5, -0.1, 0.2, -0.1, 0.1}}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:wool_cloth", ""},
		{"multidecor:wool_cloth", "multidecor:wool_cloth", "multidecor:wool_cloth"},
		{"" , "", ""}
	},
	count = 2
})

multidecor.register.register_furniture_unit("saucepans_set", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Saucepans set (put it on the cooker top)"),
	mesh = "multidecor_saucepans_set.b3d",
	use_texture_alpha = "blend",
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
		{"multidecor:steel_sheet", "xpanes:pane_flat", "multidecor:plastic_strip"},
		{"multidecor:steel_sheet" , "", ""}
	}
})


multidecor.register.register_furniture_unit("cast_iron_pan", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Cast Iron Pan"),
	mesh = "multidecor_cast_iron_pan.b3d",
	tiles = {
		"multidecor_coarse_metal_material.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.25, -0.5, -0.25, 0.25, -0.35, 0.25}
	}
},
{
	recipe = {
		{"multidecor:coarse_steel_sheet", "multidecor:plank", ""},
		{"multidecor:coarse_steel_sheet", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("porcelain_saucer_with_cup", {
	type = "decoration",
	style = "modern",
	material = "glass",
	description = modern.S("Porcelain Saucer With Cup"),
	mesh = "multidecor_porcelain_saucer_with_cup.b3d",
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
	description = modern.S("Porcelain Saucer With Tea Cup"),
	mesh = "multidecor_porcelain_saucer_with_tea_cup.b3d",
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
	description = modern.S("Faceted Glass"),
	mesh = "multidecor_faceted_glass.b3d",
	tiles = {"multidecor_glass_material.png"},
	use_texture_alpha = "blend",
	bounding_boxes = {
		{-0.15, -0.5, -0.15, 0.15, -0.1, 0.15}
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
	description = modern.S("Porcelain Teapot"),
	mesh = "multidecor_porcelain_teapot.b3d",
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

local tiles = {
	["kitchen_ceramic_tile_1"] = {
		"Kitchen Wall Ceramic Tile",
		"multidecor_kitchen_ceramic_tile1.png",
		{
			{"multidecor:ceramic_tile", "dye:yellow", ""},
			{"multidecor:paint_brush", "", ""},
			{"", "", ""}
		}
	},
	["kitchen_ceramic_tile_2"] = {
		"Kitchen Wall Ceramic Tile",
		"multidecor_kitchen_ceramic_tile2.png",
		{
			{"multidecor:ceramic_tile", "dye:brown", ""},
			{"multidecor:paint_brush", "", ""},
			{"", "", ""}
		}
	},
	["kitchen_marble_tile"] = {
		"Kitchen Wall Marble Tile",
		"multidecor_kitchen_marble_tile.png",
		{
			{"multidecor:ceramic_tile", "dye:white", ""},
			{"multidecor:paint_brush", "dye:grey", "dye:dark_grey"},
			{"", "", ""}
		}
	},
	["kitchen_floor_black_tile"] = {
		"Kitchen Floor Black Tile",
		"multidecor_kitchen_floor_black_tile.png",
		{
			{"multidecor:ceramic_tile", "dye:black", ""},
			{"multidecor:paint_brush", "", ""},
			{"", "", ""}
		}
	},
	["kitchen_floor_white_tile"] = {
		"Kitchen Floor White Tile",
		"multidecor_kitchen_floor_white_tile.png",
		{
			{"multidecor:ceramic_tile", "dye:white", ""},
			{"multidecor:paint_brush", "", ""},
			{"", "", ""}
		}
	},
}

for name, def in pairs(tiles) do
	local tile_name = "multidecor:" .. name
	minetest.register_node(":" .. tile_name, {
		description = modern.S(def[1]),
		drawtype = "nodebox",
		visual_scale = 1.0,
		paramtype = "light",
		paramtype2 = "wallmounted",
		tiles = {def[2]},
		groups = {cracky=3.5},
		node_box = tile_bboxes,
		selection_box = tile_bboxes,
		sounds = default.node_sound_stone_defaults()
	})

	minetest.register_craft({
		output = tile_name,
		recipe = def[3],
		replacements = {{"multidecor:paint_brush", "multidecor:paint_brush"}}
	})

	local block_name = "multidecor:" .. name .. "s_block"
	minetest.register_node(":" .. block_name, {
		description = modern.S(def[1] .. "s Block"),
		visual_scale = 0.5,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {def[2]},
		groups = {cracky=2.5},
		sounds = default.node_sound_stone_defaults()
	})

	minetest.register_craft({
		type = "shapeless",
		output = block_name,
		recipe = {
			tile_name,
			tile_name,
			tile_name,
			tile_name,
			tile_name,
			tile_name
		}
	})
end


multidecor.register.register_furniture_unit("kitchen_metallic_hanger", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Metallic Hanger"),
	mesh = "multidecor_kitchen_metallic_hanger.b3d",
	tiles = {
		"multidecor_metal_material3.png",
		"multidecor_coarse_metal_material.png",
	},
	bounding_boxes = {
		{-0.425, 0.175, 0.225, 0.425, 0.275, 0.3},
		{-0.5, 0.1, 0.195, -0.425, 0.3, 0.5},
		{0.425, 0.1, 0.195, 0.5, 0.3, 0.5}
	}
},
{
	recipe = {
		{"multidecor:coarse_steel_sheet", "multidecor:metal_bar", ""},
		{"", "", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("kitchen_metallic_hanger_with_ladle_and_board", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Kitchen Metallic Hanger With Ladle And Board"),
	mesh = "multidecor_kitchen_metallic_hanger_with_ladle_and_board.b3d",
	tiles = {
		"multidecor_metal_material3.png",
		"multidecor_coarse_metal_material.png",
		"multidecor_wood.png",
		"multidecor_metal_material.png",
		"multidecor_kitchen_cooker_black_metal.png"
	},
	bounding_boxes = {
		{-0.425, 0.175, 0.225, 0.425, 0.275, 0.3},
		{-0.5, 0.1, 0.195, -0.425, 0.3, 0.5},
		{0.425, 0.1, 0.195, 0.5, 0.3, 0.5}
	}
},
{
	recipe = {
		{"multidecor:coarse_steel_sheet", "multidecor:metal_bar", "multidecor:metal_bar"},
		{"multidecor:coarse_steel_sheet", "multidecor:board", ""},
		{"", "", ""}
	}
})

multidecor.register.register_furniture_unit("kitchen_organiser", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Kitchen Cutlery Organiser"),
	mesh = "multidecor_kitchen_cutlery_organiser.b3d",
	tiles = {
		"multidecor_kitchen_cooker_black_metal.png",
		"multidecor_metal_material.png",
		"multidecor_metal_material4.png"
	},
	bounding_boxes = {
		{-0.15, -0.5, 0, 0.15, 0.15, 0.3}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:plastic_sheet", "dye:black"},
		{"multidecor:steel_stripe", "multidecor:steel_scissors", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("microwave", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Microwave"),
	mesh = "multidecor_microwave.b3d",
	tiles = {
		"multidecor_plastic_material.png",
		"multidecor_microwave_interior.png",
		"multidecor_metal_material3.png"
	},
	bounding_boxes = {
		{-0.45, -0.5, -0.3, 0.45, 0, 0.3}
	},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.can_dig
	},
	add_properties = {
		shelves_data = {
			common_name = "microwave",
			{
				type = "door",
				object = "modern:microwave_door",
				pos = {x=0.425, y=-0.25, z=0.225},
				invlist_type = "cooker",
				acc = 1,
				side = "left",
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:plastic_sheet", "multidecor:plastic_sheet"},
		{"multidecor:steel_sheet", "xpanes:pane_flat", "multidecor:wolfram_wire"},
		{"multidecor:chainlink", "multidecor:steel_sheet", ""}
	}
}
)

multidecor.register.register_furniture_unit("microwave_activated", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	description = modern.S("Microwave"),
	mesh = "multidecor_microwave.b3d",
	light_source = 8,
	tiles = {
		"multidecor_plastic_material.png",
		"multidecor_microwave_interior.png",
		"multidecor_metal_material3.png"
	},
	bounding_boxes = {
		{-0.45, -0.5, -0.3, 0.45, 0, 0.3}
	},
	groups = {not_in_creative_inventory=1},
	callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.can_dig
	},
	add_properties = {
		shelves_data = {
			common_name = "microwave",
			{
				type = "door",
				object = "modern:microwave_door",
				pos = {x=0.425, y=-0.25, z=0.225},
				invlist_type = "cooker",
				acc = 1,
				side = "left",
				sounds = {
					open = "multidecor_cabinet_door_open",
					close = "multidecor_cabinet_door_close"
				}
			}
		}
	}
})

minetest.register_entity("modern:microwave_door", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	mesh = "multidecor_microwave_door.b3d",
	textures = {"multidecor_black_plastic_material.png", "multidecor_microwave_net.png"},
	use_texture_alpha = true,
	physical = false,
	backface_culling = false,
	selectionbox = {-0.575, -0.25, 0.075, 0, 0.25, 0},
	static_save = true,
	on_activate = multidecor.shelves.on_activate,
	on_rightclick = multidecor.shelves.on_rightclick,
	on_step = multidecor.shelves.door_on_step,
	get_staticdata = multidecor.shelves.get_staticdata,
	on_deactivate = multidecor.shelves.on_deactivate
})
