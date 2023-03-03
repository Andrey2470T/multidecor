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
	assert(multidecor.register.check_for_style(def.style), "The style with a name \"" .. def.style .. "\" is not registered!")

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

	assert(multidecor.register.check_for_style(def.style), "The style with a name \"" .. def.style .. "\" is not registered!")

	cmn_def.style = def.style
	cmn_def.material = def.material
	cmn_def.drawtype = "mesh"
	cmn_def.visual_scale = 0.5
	cmn_def.tiles = def.tiles
	cmn_def.groups = def.groups

	local objects = {
		def.modname .. ":" .. def.objs_common_name .. "_floor_door",
		def.modname .. ":" .. def.objs_common_name .. "_floor_half_door",
		def.modname .. ":" .. def.objs_common_name .. "_wall_door",
		def.modname .. ":" .. def.objs_common_name .. "_wall_half_door",
		def.modname .. ":" .. def.objs_common_name .. "_wall_half_glass_door",
		def.modname .. ":" .. def.objs_common_name .. "_large_drawer",
		def.modname .. ":" .. def.objs_common_name .. "_small_drawer"
	}

	local door_sounds = {
		open = "multidecor_squeaky_door_open",
		close = "multidecor_squeaky_door_close"
	}

	local drawer_sounds = {
		open = "multidecor_drawer_open",
		close = "multidecor_drawer_close"
	}

	local function form_cab_def(name)
		local cabdef = table.copy(cmn_def)
		cabdef.description = def.components[name].description
		cabdef.mesh = def.components[name].mesh
		cabdef.inventory_image = def.components[name].inventory_image
		cabdef.bounding_boxes = def.components[name].bounding_boxes
		cabdef.callbacks = def.components[name].callbacks or {}
		cabdef.callbacks.on_construct = cabdef.callbacks.on_construct or function(pos) multidecor.shelves.set_shelves(pos) end
		cabdef.callbacks.can_dig = cabdef.callbacks.can_dig or multidecor.shelves.default_can_dig
		cabdef.add_properties = {}

		return cabdef
	end

	local function form_shelf_data(name, type, objname, pos1, pos2, orig_angle, side, list_type)
		return {
			type = type,
			object = objname,
			invlist_type = list_type,
			inv_size = def.components[name].shelves_data.inv_size,
			pos = pos1,
			pos2 = pos2,
			length = type == "drawer" and 0.5,
			acc = type ~= "drawer" and 1,
			orig_angle = orig_angle,
			side = side,
			sounds = type == "drawer" and drawer_sounds or door_sounds
		}
	end

	-- kitchen floor two shelves cabinet with drawers
	if def.components.two_floor_drws then
		local two_floor_drws = form_cab_def("two_floor_drws")
		local tf_drws_s = def.components.two_floor_drws.shelves_data
		two_floor_drws.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_floor_drws",
			form_shelf_data("two_floor_drws", "drawer", objects[6], tf_drws_s.pos_lower),
			form_shelf_data("two_floor_drws", "drawer", objects[6], tf_drws_s.pos_upper)
		}

		multidecor.register.register_table(two_floor_drws.add_properties.shelves_data.common_name, two_floor_drws)
	end

	-- kitchen floor three shelves cabinet with drawers
	if def.components.three_floor_drws then
		local three_floor_drws = form_cab_def("three_floor_drws")
		local thf_drws_s = def.components.three_floor_drws.shelves_data
		three_floor_drws.add_properties.shelves_data = {
			common_name = def.common_name .. "_three_floor_drws",
			form_shelf_data("three_floor_drws", "drawer", objects[7], thf_drws_s.pos_lower),
			form_shelf_data("three_floor_drws", "drawer", objects[7], thf_drws_s.pos_middle),
			form_shelf_data("three_floor_drws", "drawer", objects[7], thf_drws_s.pos_upper)
		}

		multidecor.register.register_table(three_floor_drws.add_properties.shelves_data.common_name, three_floor_drws)
	end

	-- kitchen floor two shelves cabinet with doors
	if def.components.two_floor_doors then
		local two_floor_doors = form_cab_def("two_floor_doors")
		local tf_drs_s = def.components.two_floor_doors.shelves_data
		two_floor_doors.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_floor_doors",
			form_shelf_data("two_floor_doors", "sym_doors", objects[2], tf_drs_s.pos_left, tf_drs_s.pos_right)
		}

		multidecor.register.register_table(two_floor_doors.add_properties.shelves_data.common_name, two_floor_doors)
	end

	-- kitchen floor three shelves cabinet with doors
	if def.components.three_floor_doors then
		local three_floor_doors = form_cab_def("three_floor_doors")
		local thf_drs_s = def.components.three_floor_doors.shelves_data
		three_floor_doors.add_properties.shelves_data = {
			common_name = def.common_name .. "_three_floor_doors",
			form_shelf_data("three_floor_doors", "sym_doors", objects[2], thf_drs_s.pos_left, thf_drs_s.pos_right)
		}

		multidecor.register.register_table(three_floor_doors.add_properties.shelves_data.common_name, three_floor_doors)
	end

	-- kitchen floor three shelves cabinet with drawer and door
	if def.components.three_floor_drw_door then
		local three_floor_drw_door = form_cab_def("three_floor_drw_door")
		local thf_drw_d_s = def.components.three_floor_drw_door.shelves_data
		three_floor_drw_door.add_properties.shelves_data = {
			common_name = def.common_name .. "_three_floor_drw_door",
			form_shelf_data("three_floor_drw_door", "drawer", objects[7], thf_drw_d_s.pos_upper),
			form_shelf_data("three_floor_drw_door", "sym_doors", objects[2], thf_drw_d_s.pos_left, thf_drw_d_s.pos_right)
		}

		multidecor.register.register_table(three_floor_drw_door.add_properties.shelves_data.common_name, three_floor_drw_door)
	end

	-- kitchen wall two shelves cabinet with door
	if def.components.two_wall_door then
		local two_wall_door = form_cab_def("two_wall_door")
		two_wall_door.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_wall_door",
			form_shelf_data("two_wall_door", "door", objects[3], def.components.two_wall_door.shelves_data.pos, nil, nil, "left")
		}

		multidecor.register.register_table(two_wall_door.add_properties.shelves_data.common_name, two_wall_door)
	end

	-- kitchen wall two shelves cabinet with half doors
	if def.components.two_wall_hdoor then
		local two_wall_hdoor = form_cab_def("two_wall_hdoor")
		local tw_hd_s = def.components.two_wall_hdoor.shelves_data
		two_wall_hdoor.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_wall_hdoor",
			form_shelf_data("two_wall_hdoor", "sym_doors", objects[4], tw_hd_s.pos_left, tw_hd_s.pos_right)
		}

		multidecor.register.register_table(two_wall_hdoor.add_properties.shelves_data.common_name, two_wall_hdoor)
	end

	-- kitchen wall two shelves cabinet with half glass doors
	if def.components.two_wall_hgldoor then
		local two_wall_hgldoor = form_cab_def("two_wall_hgldoor")
		local tw_hgld_s = def.components.two_wall_hgldoor.shelves_data
		two_wall_hgldoor.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_wall_hgldoor",
			form_shelf_data("two_wall_hgldoor", "sym_doors", objects[5], tw_hgld_s.pos_left, tw_hgld_s.pos_right)
		}

		multidecor.register.register_table(two_wall_hgldoor.add_properties.shelves_data.common_name, two_wall_hgldoor)
	end

	-- kitchen wall corner two shelves cabinet with half glass doors
	if def.components.two_wall_crn_hgldoor then
		local two_wall_crn_hgldoor = form_cab_def("two_wall_crn_hgldoor")
		two_wall_crn_hgldoor.add_properties.shelves_data = {
			common_name = def.common_name .. "_two_wall_crn_hgldoor",
			form_shelf_data("two_wall_crn_hgldoor", "sym_doors", objects[5], def.components.two_wall_crn_hgldoor.shelves_data.pos_left,
				def.components.two_wall_crn_hgldoor.shelves_data.pos_right, {x=0, y=-math.pi/4, z=0})
		}

		multidecor.register.register_table(two_wall_crn_hgldoor.add_properties.shelves_data.common_name, two_wall_crn_hgldoor)
	end

	-- kitchen sink
	if def.components.sink then
		local sink = form_cab_def("sink")
		sink.add_properties.shelves_data = {
			common_name = def.common_name .. "_sink",
			form_shelf_data("sink", "door", objects[1], def.components.sink.shelves_data.pos_trash, nil, nil, "left", "trash")
		}

		multidecor.register.register_table(sink.add_properties.shelves_data.common_name, sink)
	end
end
