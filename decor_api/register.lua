-- Registration API

multidecor.register = {}


-- Default furniture types
multidecor.register.supported_types = {
	"seat",
	"table",
	"shelf",
	"bed",
	"light",
	"hedge",
	"decoration"
}

-- Default furniture styles
multidecor.register.supported_styles = {
	"baroque",
	"classic",
	"high_tech",
	"mixed",
	"modern",
	"royal"
}

-- Default furniture materials
multidecor.register.supported_materials = {
	"wood",
	"glass",
	"metal",
	"plastic",
	"stone"
}

-- Registers a new furniture type
function multidecor.register.register_type(type_name)
	table.insert(multidecor.register.supported_types, type_name)
end

-- Checks whether type with 'type_name' name is registered
function multidecor.register.check_for_type(type_name)
	for _, type in ipairs(multidecor.register.supported_types) do
		if type == type_name then
			return true
		end
	end

	return false
end

-- Checks whether style with 'style_name' name is registered
function multidecor.register.check_for_style(style_name)
	for _, style in ipairs(multidecor.register.supported_styles) do
		if style == style_name then
			return true
		end
	end

	return false
end

--[[def:
	{
		type = <seat, shelf, bed, table, >
		style = <baroque, classic, high_tech, mixed, modern, royal>,
		material = <wood, glass, metal and etc>,
		description = <description>,
		drawtype = <nodebox, mesh>,
		mesh = <filename>,
		tiles = {<textures>},
		paramtype2 = <paramtype2>,
		bounding_boxes = {
			Box1: {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			Box2: {0.5, 1.5, 0.1, 0.5, 1.0, 0.5},
			...
		},
		wield_scale = {x=<float>, y=<float>, z=<float>} (Optional),
		visual_scale = <float> (Optional),
		drop = <drop name> (Optional),
		groups = {snappy=<int>, choppy=<int>, crumbly=<int>...} (Optional),
		sounds = {
			footstep = <SimpleSoundSpec>,
			dig = <SimpleSoundSpec>,
			dug = <SimpleSoundSpec>,
			place = <SimpleSoundSpec>,
			place_failed = <SimpleSoundSpec>,
			fall = <SimpleSoundSpec>
		} (Optional),

		callbacks = {
			on_construct = <function>,
			on_destruct = <function>,
			on_rightclick = <function>,
			on_timer = <function>
		}
	}
]]

-- Registers some furniture component (chair, stool, table, sofa, cupboard and etc).
function multidecor.register.register_furniture_unit(name, def, craft_def)
	local f_def = {}

	assert(multidecor.register.check_for_type(def.type), "The type with a name \"" .. def.type .. "\" is not registered!")
	assert(multidecor.register.check_for_style(def.style), "The type with a name \"" .. def.style .. "\" is not registered!")

	f_def.description = def.description
	f_def.visual_scale = def.visual_scale or 0.4
	f_def.wield_scale = def.wield_scale or {x=0.5, y=0.5, z=0.5}
	f_def.drawtype = def.drawtype or "mesh"
	f_def.paramtype = "light"
	f_def.paramtype2 = def.paramtype2 or "facedir"
	f_def.use_texture_alpha = def.use_texture_alpha or "clip"
	f_def.drop = def.drop
	f_def.light_source = def.light_source
	f_def.use_texture_alpha = def.use_texture_alpha

	if f_def.drawtype == "mesh" then
		f_def.mesh = def.mesh
	end

	f_def.tiles = def.tiles
	f_def.inventory_image = def.inventory_image
	f_def.wield_image = def.wield_image

	f_def.groups = def.groups or {}
	f_def.groups[def.type] = 1
	f_def.groups[def.style] = 1


	if def.material then
		f_def.groups[def.material] = 1
	end

	if def.material == "wood" then
		f_def.groups.choppy = 1.5
	elseif def.material == "glass" or def.material == "metal" or def.material == "stone" then
		f_def.groups.cracky = 1.5
	elseif def.material == "plastic" then
		f_def.groups.snappy = 1.5
	end

	f_def.description = f_def.description .. "\nStyle: " .. def.style .. (def.material and "\nMaterial: " .. def.material or "")
	if def.bounding_boxes then
		if f_def.drawtype == "nodebox" then
			f_def.node_box = {
				type = "fixed",
				fixed = def.bounding_boxes
			}
		elseif f_def.drawtype == "mesh" then
			f_def.collision_box = {
				type = "fixed",
				fixed = def.bounding_boxes
			}
		end
		f_def.selection_box = f_def.collision_box or f_def.node_box
	end

	if def.sounds then
		f_def.sounds = def.sounds
	else
		if def.material == "wood" then
			f_def.sounds = default.node_sound_wood_defaults()
		elseif def.material == "glass" then
			f_def.sounds = default.node_sound_glass_defaults()
		elseif def.material == "metal" then
			f_def.sounds = default.node_sound_metal_defaults()
		elseif def.material == "plastic" then
			f_def.sounds = default.node_sound_wood_defaults({dig={name="default_dig_snappy", gain=0.5}})
		elseif def.material == "stone" then
			f_def.sounds = default.node_sound_stone_defaults()
		end
	end


	f_def.callbacks = def.callbacks or {}
	for cb_name, f in pairs(f_def.callbacks) do
		f_def[cb_name] = f
	end

	f_def.add_properties = def.add_properties or {}

	local f_name = "multidecor:" .. name
	minetest.register_node(":" .. f_name, f_def)

	if craft_def then
		minetest.register_craft({
			type = craft_def.type,
			output = f_name,
			recipe = craft_def.recipe,
			replacements = craft_def.replacements or nil
		})
	end
end


--[[def:
	{
		type = <kitchen, bathroom>,
		style = <baroque, classic, high_tech, mixed, modern, royal>,
		material = <wood, glass, metal and etc>,
		tiles = {
			<tabletop texture>,
			<base texture>,
			<texture of legs/handles/sink>
		},
		groups = <groups>,
		modname = <name of mod registering the garniture>,

		For kitchen garniture:
		components = {
			["two_floor_drws"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_lower = <position of lower shelf>,
					pos_upper = <position of upper shelf>,
					inventory = <formspec_string>
				}
			},
			["three_floor_drws"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_lower = <position of lower shelf>,
					pos_middle = <position of middle shelf>
					pos_upper = <position of upper shelf>,
					inventory = <formspec_string>
				}
			},
			["two_floor_doors"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_left = <position of left door>,
					pos_right = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["three_floor_doors"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos = <position of left door>,
					pos2 = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["three_floor_drw_door"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_upper = <position of upper drawer>,
					pos_left = <position of left door>,
					pos_right = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["two_wall_door"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos = <position of shelf>,
					inventory = <formspec_string>
				}
			},
			["two_wall_hdoor"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_left = <position of left door>,
					pos_right = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["two_wall_hgldoors"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_left = <position of left door>,
					pos_right = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["two_wall_crn_hgldoors"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				shelves_data = {
					pos_left = <position of left door>,
					pos_right = <position of right door>,
					inventory = <formspec_string>
				}
			},
			["sink"] = {
				description = <description>,
				mesh = <filename>,
				bounding_boxes = <table of bboxes definitions>,
				tap_pos = <tap position>,
				shelves_data = {
					pos_trash = <position of trash shelf>,
					inventory = <formspec_string>
				}
			},
		},
		move_parts = {
			["floor_door"] = <meshname>,
			["floor_half_door"] = <meshname>,
			["wall_door"] = <meshname>,
			["wall_half_door"] = <meshname>,
			["wall_half_glass_door"] = <meshname>,
			["large_drawer"] = <meshname>,
			["small_drawer"] = <meshname>
		}
	}

]]
-- Registers a set of furniture components of certain type: "kitchen", "bathroom", "bedroom", "living_room" and etc.
function multidecor.register.register_garniture(def)
	local cmn_def = {}

	assert(multidecor.register.check_for_style(def.style), "The type with a name \"" .. def.style .. "\" is not registered!")

	cmn_def.style = def.style
	cmn_def.material = def.material
	cmn_def.drawtype = "mesh"
	cmn_def.visual_scale = 0.5
	cmn_def.tiles = def.tiles
	cmn_def.groups = def.groups

	cmn_def.callbacks = {
		on_construct = function(pos)
			multidecor.shelves.set_shelves(pos)
		end,
		can_dig = multidecor.shelves.default_can_dig
	}

	local function form_objname(name)
		return ("%s:%s_%s_%s"):format(def.modname, def.style, def.type, name)
	end

	local objects = {
		form_objname("floor_door"),
		form_objname("floor_half_door"),
		form_objname("wall_door"),
		form_objname("wall_half_door"),
		form_objname("wall_half_glass_door"),
		form_objname("large_drawer"),
		form_objname("small_drawer")
	}

	local door_sounds = {
		open = "multidecor_cabinet_door_open",
		close = "multidecor_cabinet_door_close"
	}

	local drawer_sounds = {
		open = "multidecor_drawer_open",
		close = "multidecor_drawer_close"
	}

	local function form_cab_def(name)
		local cabdef = table.copy(cmn_def)
		cabdef.description = def.components[name].description
		cabdef.mesh = def.components[name].mesh
		cabdef.bounding_boxes = def.components[name].bounding_boxes
		cabdef.callbacks.on_rightclick = def.components[name].callbacks and def.components[name].callbacks.on_rightclick
		cabdef.add_properties = {}

		return cabdef
	end

	local function form_shelf_data(name, type, objname, pos1, pos2, orig_angle)
		return {
			type = type,
			object = objname,
			inv_size = def.components[name].shelves_data.inv_size,
			pos = pos1,
			pos2 = pos2,
			length = type == "drawer" and 0.5,
			acc = type ~= "drawer" and 1,
			orig_angle = orig_angle,
			sounds = type == "drawer" and drawer_sounds or door_sounds
		}
	end

	-- kitchen floor two shelves cabinet with drawers
	local two_floor_drws = form_cab_def("two_floor_drws")
	two_floor_drws.add_properties.shelves_data = {
		form_shelf_data("two_floor_drws", "drawer", objects[6], def.components.two_floor_drws.shelves_data.pos_lower),
		form_shelf_data("two_floor_drws", "drawer", objects[6], def.components.two_floor_drws.shelves_data.pos_upper)
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_floor_with_drawers", two_floor_drws)

	-- kitchen floor three shelves cabinet with drawers
	local three_floor_drws = form_cab_def("three_floor_drws")
	three_floor_drws.add_properties.shelves_data = {
		form_shelf_data("three_floor_drws", "drawer", objects[7], def.components.three_floor_drws.shelves_data.pos_lower),
		form_shelf_data("three_floor_drws", "drawer", objects[7], def.components.three_floor_drws.shelves_data.pos_middle),
		form_shelf_data("three_floor_drws", "drawer", objects[7], def.components.three_floor_drws.shelves_data.pos_upper)
	}

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_drawers", three_floor_drws)

	-- kitchen floor two shelves cabinet with doors
	local two_floor_doors = form_cab_def("two_floor_doors")
	two_floor_doors.add_properties.shelves_data = {
		form_shelf_data("two_floor_doors", "sym_doors", objects[2], def.components.two_floor_doors.shelves_data.pos_left, def.components.two_floor_doors.shelves_data.pos_right)
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_floor_with_doors", two_floor_doors)

	-- kitchen floor three shelves cabinet with doors
	local three_floor_doors = form_cab_def("three_floor_doors")
	three_floor_doors.add_properties.shelves_data = {
		form_shelf_data("three_floor_doors", "sym_doors", objects[2], def.components.three_floor_doors.shelves_data.pos_left, def.components.three_floor_doors.shelves_data.pos_right)
	}

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_doors", three_floor_doors)

	-- kitchen floor three shelves cabinet with drawer and door
	local three_floor_drw_door = form_cab_def("three_floor_drw_door")
	three_floor_drw_door.add_properties.shelves_data = {
		form_shelf_data("three_floor_drw_door", "drawer", objects[7], def.components.three_floor_drw_door.shelves_data.pos_upper),
		form_shelf_data("three_floor_drw_door", "sym_doors", objects[2], def.components.three_floor_drw_door.shelves_data.pos_left, def.components.three_floor_drw_door.shelves_data.pos_right)
	}

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_drawer_and_door", three_floor_drw_door)

	-- kitchen wall two shelves cabinet with door
	local two_wall_door = form_cab_def("two_wall_door")
	two_wall_door.add_properties.shelves_data = {
		form_shelf_data("two_wall_door", "door", objects[3], def.components.two_wall_door.shelves_data.pos)
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_door", two_wall_door)

	-- kitchen wall two shelves cabinet with half doors
	local two_wall_hdoor = form_cab_def("two_wall_hdoor")
	two_wall_hdoor.add_properties.shelves_data = {
		form_shelf_data("two_wall_hdoor", "sym_doors", objects[4], def.components.two_wall_hdoor.shelves_data.pos_left, def.components.two_wall_hdoor.shelves_data.pos_right)
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_half_doors", two_wall_hdoor)

	-- kitchen wall two shelves cabinet with half glass doors
	local two_wall_hgldoor = form_cab_def("two_wall_hgldoor")
	two_wall_hgldoor.add_properties.shelves_data = {
		form_shelf_data("two_wall_hgldoor", "sym_doors", objects[5], def.components.two_wall_hgldoor.shelves_data.pos_left, def.components.two_wall_hgldoor.shelves_data.pos_right)
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_half_glass_doors", two_wall_hgldoor)

	-- kitchen wall corner two shelves cabinet with half glass doors
	local two_wall_crn_hgldoor = form_cab_def("two_wall_crn_hgldoor")
	two_wall_crn_hgldoor.add_properties.shelves_data = {
		form_shelf_data("two_wall_crn_hgldoor", "sym_doors", objects[5], def.components.two_wall_crn_hgldoor.shelves_data.pos_left,
			def.components.two_wall_crn_hgldoor.shelves_data.pos_right, -math.pi/4)
	}

	multidecor.register.register_table("kitchen_corner_cabinet_two_shelves_wall_with_half_glass_doors", two_wall_crn_hgldoor)

	-- kitchen sink
	local sink = form_cab_def("sink")
	sink.add_properties.shelves_data = {
		form_shelf_data("sink", "door", objects[1], def.components.sink.shelves_data.pos_trash)
	}

	multidecor.register.register_table("kitchen_sink", sink)



	--[[-- kitchen floor two shelves cabinet with drawers
	local two_floor_drws = table.copy(cmn_def)
	two_floor_drws.description = def.components.two_floor_drws.description
	two_floor_drws.mesh = def.components.two_floor_drws.mesh
	two_floor_drws.bounding_boxes = def.components.two_floor_drws.bounding_boxes

	local two_floors_drws_shelf = {
		type = "drawer",
		object = objects[6],
		inv_size = def.components.two_floor_drws.shelves_data.inv_size,
		sounds = drawer_sounds
	}
	two_floor_drws.add_properties = {shelves_data = {table.copy(two_floors_drws_shelf), table.copy(two_floors_drws_shelf)}}
	two_floor_drws.add_properties.shelves_data[1].pos = def.components.two_floor_drws.shelves_data.pos_lower
	two_floor_drws.add_properties.shelves_data[2].pos = def.components.two_floor_drws.shelves_data.pos_upper

	multidecor.register.register_table("kitchen_cabinet_two_shelves_floor_with_drawers", two_floor_drws)

	-- kitchen floor three shelves cabinet with drawers
	local three_floor_drws = table.copy(cmn_def)
	three_floor_drws.description = def.components.three_floor_drws.description
	three_floor_drws.mesh = def.components.three_floor_drws.mesh
	three_floor_drws.bounding_boxes = def.components.three_floor_drws.bounding_boxes

	local three_floors_drws_shelf = {
		type = "drawer",
		object = objects[7],
		inv_size = def.components.three_floor_drws.shelves_data.inv_size,
		sounds = drawer_sounds
	}
	three_floor_drws.add_properties = {shelves_data = {table.copy(three_floors_drws_shelf), table.copy(three_floors_drws_shelf), table.copy(three_floors_drws_shelf)}}
	three_floor_drws.add_properties.shelves_data[1].pos = def.components.three_floor_drws.shelves_data.pos_lower
	three_floor_drws.add_properties.shelves_data[2].pos = def.components.three_floor_drws.shelves_data.pos_middle
	three_floor_drws.add_properties.shelves_data[3].pos = def.components.three_floor_drws.shelves_data.pos_upper

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_drawers", three_floor_drws)

	-- kitchen floor two shelves cabinet with doors
	local two_floor_doors = table.copy(cmn_def)
	two_floor_doors.description = def.components.two_floor_doors.description
	two_floor_doors.mesh = def.components.two_floor_doors.mesh
	two_floor_doors.bounding_boxes = def.components.two_floor_doors.bounding_boxes

	local two_floors_doors_shelf = {
		type = "sym_doors",
		object = objects[2],
		inv_size = def.components.two_floor_doors.shelves_data.inv_size,
		sounds = door_sounds
	}
	two_floor_doors.add_properties = {shelves_data = {table.copy(two_floors_doors_shelf)}}
	two_floor_doors.add_properties.shelves_data[1].pos = def.components.two_floor_doors.shelves_data.pos_left
	two_floor_doors.add_properties.shelves_data[1].pos2 = def.components.two_floor_doors.shelves_data.pos_right

	multidecor.register.register_table("kitchen_cabinet_two_shelves_floor_with_doors", two_floor_doors)

	-- kitchen floor three shelves cabinet with doors
	local three_floor_doors = table.copy(cmn_def)
	three_floor_doors.description = def.components.three_floor_doors.description
	three_floor_doors.mesh = def.components.three_floor_doors.mesh
	three_floor_doors.bounding_boxes = def.components.three_floor_doors.bounding_boxes

	local three_floors_doors_shelf = {
		type = "sym_doors",
		object = objects[2],
		inv_size = def.components.three_floor_doors.shelves_data.inv_size,
		sounds = door_sounds
	}
	three_floor_doors.add_properties = {shelves_data = {table.copy(three_floors_doors_shelf)}}
	three_floor_doors.add_properties.shelves_data[1].pos = def.components.three_floor_doors.shelves_data.pos_left
	three_floor_doors.add_properties.shelves_data[1].pos2 = def.components.three_floor_doors.shelves_data.pos_right

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_doors", three_floor_doors)

	-- kitchen floor three shelves cabinet with drawer and door
	local three_floor_drw_door = table.copy(cmn_def)
	three_floor_drw_door.description = def.components.three_floor_drw_door.description
	three_floor_drw_door.mesh = def.components.three_floor_drw_door.mesh
	three_floor_drw_door.bounding_boxes = def.components.three_floor_drw_door.bounding_boxes

	three_floor_drw_door.add_properties = {
		shelves_data = {
			{
				type = "drawer",
				object = objects[7],
				pos = def.components.three_floor_drw_door.shelves_data.pos_upper,
				inv_size = def.components.three_floor_drw_door.shelves_data.inv_size,
				sounds = drawer_sounds
			},
			{
				type = "sym_doors",
				object = objects[2],
				pos = def.components.three_floor_drw_door.shelves_data.pos_left,
				pos2 = def.components.three_floor_drw_door.shelves_data.pos_right,
				inv_size = def.components.three_floor_drw_door.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_cabinet_three_shelves_floor_with_drawer_and_door", three_floor_drw_door)

	-- kitchen wall two shelves cabinet with door
	local two_wall_door = table.copy(cmn_def)
	two_wall_door.description = def.components.two_wall_door.description
	two_wall_door.mesh = def.components.two_wall_door.mesh
	two_wall_door.bounding_boxes = def.components.two_wall_door.bounding_boxes

	two_wall_door.add_properties = {
		shelves_data = {
			{
				type = "door",
				object = objects[3],
				pos = def.components.two_wall_door.shelves_data.pos,
				inv_size = def.components.two_wall_door.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_door", two_wall_door)

	-- kitchen wall two shelves cabinet with half doors
	local two_wall_hdoor = table.copy(cmn_def)
	two_wall_hdoor.description = def.components.two_wall_hdoor.description
	two_wall_hdoor.mesh = def.components.two_wall_hdoor.mesh
	two_wall_hdoor.bounding_boxes = def.components.two_wall_hdoor.bounding_boxes

	two_wall_hdoor.add_properties = {
		shelves_data = {
			{
				type = "sym_doors",
				object = objects[4],
				pos = def.components.two_wall_hdoor.shelves_data.pos_left,
				pos2 = def.components.two_wall_hdoor.shelves_data.pos_right,
				inv_size = def.components.two_wall_hdoor.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_half_doors", two_wall_hdoor)

	-- kitchen wall two shelves cabinet with half glass doors
	local two_wall_hgldoor = table.copy(cmn_def)
	two_wall_hgldoor.description = def.components.two_wall_hgldoor.description
	two_wall_hgldoor.mesh = def.components.two_wall_hgldoor.mesh
	two_wall_hgldoor.bounding_boxes = def.components.two_wall_hgldoor.bounding_boxes

	two_wall_hgldoor.add_properties = {
		shelves_data = {
			{
				type = "sym_doors",
				object = objects[5],
				pos = def.components.two_wall_hgldoor.shelves_data.pos_left,
				pos2 = def.components.two_wall_hgldoor.shelves_data.pos_right,
				inv_size = def.components.two_wall_hgldoor.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_cabinet_two_shelves_wall_with_half_glass_doors", two_wall_hgldoor)

	-- kitchen wall corner two shelves cabinet with half glass doors
	local two_wall_crn_hgldoor = table.copy(cmn_def)
	two_wall_crn_hgldoor.description = def.components.two_wall_crn_hgldoor.description
	two_wall_crn_hgldoor.mesh = def.components.two_wall_crn_hgldoor.mesh
	two_wall_crn_hgldoor.bounding_boxes = def.components.two_wall_crn_hgldoor.bounding_boxes

	two_wall_crn_hgldoor.add_properties = {
		shelves_data = {
			{
				type = "sym_doors",
				object = objects[5],
				pos = def.components.two_wall_crn_hgldoor.shelves_data.pos_left,
				pos2 = def.components.two_wall_crn_hgldoor.shelves_data.pos_right,
				orig_angle = math.pi/4,
				inv_size = def.components.two_wall_hgldoor.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_corner_cabinet_two_shelves_wall_with_half_glass_doors", two_wall_crn_hgldoor)

	-- kitchen sink
	local sink = table.copy(cmn_def)
	sink.description = def.components.sink.description
	sink.mesh = def.components.sink.mesh
	sink.bounding_boxes = def.components.sink.bounding_boxes
	sink.callbacks = {
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
					minpos = vector.add(def.components.sink.tap_pos, {x=-0.1, y=0, z=-0.1}),
					maxpos = vector.add(def.components.sink.tap_pos, {x=0.1, y=0, z=0.1}),
					minvel = {x=0, y=1, z=0},
					maxvel = {x=0, y=1, z=0},
					minsize = 0.2,
					maxsize = 0.8
				})

				meta:set_string("water_stream_id", tonumber(id))

				local sound_handle = minetest.sound_play("multidecor_tap", {max_hear_distance=12, loop=true})
				meta:set_string("sound_handle", minetest.serialize(sound_handle))
			end
		end
	}

	sink.add_properties = {
		shelves_data = {
			{
				type = "door",
				object = objects[3],
				pos = def.components.sink.shelves_data.pos,
				inv_size = def.components.sink.shelves_data.inv_size,
				sounds = door_sounds
			}
		}
	}

	multidecor.register.register_table("kitchen_sink", sink)]]


	for obj_name, props in pairs(def.move_parts) do
		minetest.register_entity(("%s:%s_%s_%s"):format(def.modname, def.style, def.type, obj_name), {
			visual = "mesh",
			visual_size = {x=5, y=5, z=5},
			mesh = props.mesh,
			textures = def.obj_tiles,
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
end
