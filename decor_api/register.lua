-- Registration API

-- NOTE: since version 1.3.5 the registration API encapsulates some own methods/varyables via the local 'register'
-- intentionally doing them inaccessible outside, it has been done in the safety goals.
-- Only the really necessary API will be exposed for mods as global.

multidecor.register = {}

local register = {}


-- Default furniture types
register.supported_types = {
	"banister",
	"door",
	"seat",
	"table",
	"shelf",
	"bed",
	"light",
	"hedge",
	"decoration",
	"curtain"
}

-- Default furniture styles
register.supported_styles = {
	"baroque",
	"classic",
	"high_tech",
	"mixed",
	"modern",
	"royal"
}

-- Default furniture materials
register.supported_materials = {
	"wood",
	"glass",
	"metal",
	"plastic",
	"stone"
}

-- Registers a new furniture type
function multidecor.register.register_type(type_name)
	table.insert(register.supported_types, type_name)
end

-- Checks whether the given 'name' is in the category with 'category_id' (whether it is registered there).
-- 'category_id': '0' - types, '1' - styles, '2' - materials
function multidecor.register.category_contains(name, category_id)
	local lookup_t

	if category_id == 0 then
		lookup_t = register.supported_types
	elseif category_id == 1 then
		lookup_t = register.supported_styles
	elseif category_id == 2 then
		lookup_t = register.supported_materials
	end

	for _, cat_name in ipairs(lookup_t) do
		if cat_name == name then
			return true
		end
	end

	return false
end

function register.build_description(style, material, base_desc)
	material = material or "unknown"

	local desc = base_desc .. multidecor.S("\nStyle: ") .. "%s" .. multidecor.S("\nMaterial: ") .. "%s" 
	return desc:format(multidecor.S(style), multidecor.S(material))
end

function multidecor.register.after_place_node(pos, placer, itemstack)
	local place = multidecor.placement.check_for_placement(pos, itemstack:get_name())

	if not place then
		minetest.chat_send_player(placer:get_player_name(), "Not enough free place for the given node!")
		minetest.remove_node(pos)
	else
		itemstack:set_count(itemstack:get_count()-1)
	end

	return itemstack
end

function multidecor.register.on_punch(pos, node, puncher)
	local wielded_item = puncher:get_wielded_item()

	if wielded_item:get_name() ~= "multidecor:scraper" then
		return
	end

	local def = hlpfuncs.ndef(pos)

	if not def.is_colorable then return end

	local mul = def.paramtype2 == "colorwallmounted" and 8 or 32
	local palette_index = math.floor(node.param2 / mul)

	if palette_index == 0 then return end

	local playername = puncher:get_player_name()
	if minetest.is_protected(pos, playername) then
		return
	end

	local color = multidecor.colors[palette_index+1]
	local rot = node.param2 % mul

	minetest.swap_node(pos, {name=node.name, param2=rot})

	minetest.item_drop(ItemStack("dye:" .. color), puncher, pos)

	wielded_item:set_wear(wielded_item:get_wear()+math.modf(65535/50))
	puncher:set_wielded_item(wielded_item)

	multidecor.tools_sounds.play(playername, 4)
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

	assert(multidecor.register.category_contains(def.type, 0), "The type with a name \"" .. def.type .. "\" is not registered!")
	assert(multidecor.register.category_contains(def.style, 1), "The style with a name \"" .. def.style .. "\" is not registered!")

	f_def.description = def.description
	f_def.visual_scale = def.visual_scale or 0.5
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

	if f_def.paramtype2 == "colorfacedir" or f_def.paramtype2 == "colorwallmounted" then
		f_def.palette = "multidecor_palette.png"
	end

	f_def.tiles = def.tiles
	f_def.overlay_tiles = def.overlay_tiles
	f_def.inventory_image = def.inventory_image
	f_def.wield_image = def.wield_image

	f_def.groups = def.groups or {}
	f_def.groups[def.type] = 1
	f_def.groups[def.style] = 1


	if def.material then
		f_def.groups[def.material] = 1
	end

	if def.material == "wood" then
		f_def.groups.choppy = 2
	elseif def.material == "glass" then
		f_def.groups.cracky = 2.5
	elseif def.material == "metal" or def.material == "stone" then
		f_def.groups.cracky = 1.5
	elseif def.material == "plastic" then
		f_def.groups.snappy = 3
	end

	if def.material ~= "metal" and def.material ~= "stone" then
		f_def.groups.oddly_breakable_by_hand = 1
	end

	f_def.description = register.build_description(def.style, def.material, f_def.description)

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

	f_def.prevent_placement_check = def.prevent_placement_check
	f_def.is_colorable = def.is_colorable

	f_def.callbacks = def.callbacks or {}
	for cb_name, f in pairs(f_def.callbacks) do
		f_def[cb_name] = f
	end

	if f_def.after_place_node then
		local prev_after_place = f_def.after_place_node
		local function after_place(pos, placer, itemstack)
			prev_after_place(pos, placer, itemstack)

			return multidecor.register.after_place_node(pos, placer, itemstack)
		end

		f_def.after_place_node = after_place
	else
		f_def.after_place_node = multidecor.register.after_place_node
	end

	if f_def.on_punch then
		local prev_on_punch = f_def.on_punch
		f_def.on_punch = function(pos, node, puncher)
			prev_on_punch(pos, node, puncher)

			multidecor.register.on_punch(pos, node, puncher)
		end
	else
		f_def.on_punch = multidecor.register.on_punch
	end

	f_def.add_properties = def.add_properties or {}

	local f_name = "multidecor:" .. name
	minetest.register_node(":" .. f_name, f_def)

	if craft_def then
		minetest.register_craft({
			type = craft_def.type,
			output = f_name .. (craft_def.count and " " .. tostring(craft_def.count) or ""),
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

	assert(multidecor.register.category_contains(def.style, 1), "The style with a name \"" .. def.style .. "\" is not registered!")

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
		cabdef.callbacks.can_dig = cabdef.callbacks.can_dig or multidecor.shelves.can_dig
		cabdef.add_properties = {}

		minetest.register_craft({
			output = "multidecor:" .. def.common_name .. "_" .. name,
			recipe = def.components[name].craft,
			replacements = {{"multidecor:hammer", "multidecor:hammer"}}
		})

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
		three_floor_drw_door.add_properties.shelves_data[2].visual_size_adds = {x=0, y=-1.75, z=0}

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
		sink.add_properties.tap_data = def.components.sink.tap_data

		multidecor.register.register_table(sink.add_properties.shelves_data.common_name, sink)
	end
end
