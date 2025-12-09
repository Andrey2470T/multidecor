multidecor.register = {}
local register = multidecor.register

local SUPPORTED_TYPES = {
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

local SUPPORTED_STYLES = {
	"baroque",
	"classic",
	"high_tech",
	"mixed",
	"modern",
	"royal"
}

local SUPPORTED_MATERIALS = {
	"wood",
	"glass",
	"metal",
	"plastic",
	"stone"
}

local function shallow_copy(source)
	if not source then
		return {}
	end

	local copy = {}

	for key, value in pairs(source) do
		copy[key] = value
	end

	return copy
end

local function build_lookup(list)
	local lookup = {}

	for _, name in ipairs(list) do
		lookup[name] = true
	end

	return lookup
end

local CATEGORY_CONFIG = {
	[0] = {label = "type", values = SUPPORTED_TYPES},
	[1] = {label = "style", values = SUPPORTED_STYLES},
	[2] = {label = "material", values = SUPPORTED_MATERIALS}
}

for _, config in pairs(CATEGORY_CONFIG) do
	config.lookup = build_lookup(config.values)
end

register.supported_types = CATEGORY_CONFIG[0].values
register.supported_styles = CATEGORY_CONFIG[1].values
register.supported_materials = CATEGORY_CONFIG[2].values

local function add_category_value(category_id, name)
	local config = CATEGORY_CONFIG[category_id]

	if not config or config.lookup[name] then
		return
	end

	table.insert(config.values, name)
	config.lookup[name] = true
end

local function ensure_category(name, category_id)
	local config = CATEGORY_CONFIG[category_id]

	assert(config and config.lookup[name], "The " .. config.label .. " with a name \"" .. name .. "\" is not registered!")
end

function register.register_type(type_name)
	add_category_value(0, type_name)
end

function register.category_contains(name, category_id)
	local config = CATEGORY_CONFIG[category_id]

	return config and config.lookup[name] or false
end

local function translate_or_unknown(value)
	if value then
		return multidecor.S(value)
	end

	return multidecor.S("unknown")
end

local function build_description(style, material, base_desc)
	return base_desc .. multidecor.S("\nStyle: ") .. translate_or_unknown(style) .. multidecor.S("\nMaterial: ") .. translate_or_unknown(material)
end

function register.after_place_node(pos, placer, itemstack)
	if not multidecor.placement.check_for_placement(pos, itemstack:get_name()) then
		minetest.chat_send_player(placer:get_player_name(), "Not enough free place for the given node!")
		minetest.remove_node(pos)
		return itemstack
	end

	itemstack:take_item()

	return itemstack
end

local function is_scraper(item)
	return item:get_name() == "multidecor:scraper"
end

local function can_change_color(def)
	return def and def.is_colorable
end

local function resolve_palette_multiplier(def)
	if def.paramtype2 == "colorwallmounted" then
		return 8
	end

	return 32
end

local function get_palette_color(index)
	return multidecor.colors[index + 1]
end

local function strip_rotation(param2, multiplier)
	return param2 % multiplier
end

local function has_palette_color(param2, multiplier)
	return math.floor(param2 / multiplier) ~= 0
end

local function apply_color_scrape(pos, node, puncher, multiplier)
	local color = get_palette_color(math.floor(node.param2 / multiplier))
	local rotation = strip_rotation(node.param2, multiplier)

	minetest.swap_node(pos, {name = node.name, param2 = rotation})
	minetest.item_drop(ItemStack("dye:" .. color), puncher, pos)
end

function register.on_punch(pos, node, puncher)
	local wielded_item = puncher:get_wielded_item()

	if not is_scraper(wielded_item) then
		return
	end

	local def = hlpfuncs.ndef(pos)

	if not can_change_color(def) then
		return
	end

	local multiplier = resolve_palette_multiplier(def)

	if not has_palette_color(node.param2, multiplier) then
		return
	end

	local playername = puncher:get_player_name()

	if minetest.is_protected(pos, playername) then
		return
	end

	apply_color_scrape(pos, node, puncher, multiplier)

	wielded_item:set_wear(wielded_item:get_wear() + math.modf(65535 / 50))
	puncher:set_wielded_item(wielded_item)
	multidecor.tools_sounds.play(playername, 4)
end

local MATERIAL_PRESETS = {
	wood = {
		groups = {choppy = 2, oddly_breakable_by_hand = 1},
		sounds = function()
			return default.node_sound_wood_defaults()
		end
	},
	glass = {
		groups = {cracky = 2.5, oddly_breakable_by_hand = 1},
		sounds = function()
			return default.node_sound_glass_defaults()
		end
	},
	metal = {
		groups = {cracky = 1.5},
		sounds = function()
			return default.node_sound_metal_defaults()
		end
	},
	plastic = {
		groups = {snappy = 3, oddly_breakable_by_hand = 1},
		sounds = function()
			return default.node_sound_wood_defaults({dig = {name = "default_dig_snappy", gain = 0.5}})
		end
	},
	stone = {
		groups = {cracky = 1.5},
		sounds = function()
			return default.node_sound_stone_defaults()
		end
	}
}

local function merge_missing(target, source)
	if not source then
		return
	end

	for name, value in pairs(source) do
		if target[name] == nil then
			target[name] = value
		end
	end
end

local function apply_material_defaults(node_def, def)
	if not def.material then
		return
	end

	local preset = MATERIAL_PRESETS[def.material]

	node_def.groups[def.material] = 1
	merge_missing(node_def.groups, preset and preset.groups)

	if node_def.groups.oddly_breakable_by_hand == nil and def.material ~= "metal" and def.material ~= "stone" then
		node_def.groups.oddly_breakable_by_hand = 1
	end

	if node_def.sounds or not preset then
		return
	end

	node_def.sounds = preset.sounds()
end

local function apply_palette(node_def)
	local param = node_def.paramtype2

	if param == "colorfacedir" or param == "colorwallmounted" then
		node_def.palette = "multidecor_palette.png"
	end
end

local function apply_bounding_boxes(node_def, def)
	if not def.bounding_boxes then
		return
	end

	if node_def.drawtype == "nodebox" then
		node_def.node_box = {
			type = "fixed",
			fixed = def.bounding_boxes
		}
	else
		node_def.collision_box = {
			type = "fixed",
			fixed = def.bounding_boxes
		}
	end

	node_def.selection_box = node_def.collision_box or node_def.node_box
end

local function ensure_groups_table(node_def)
	node_def.groups = node_def.groups or {}
end

local function ensure_add_properties(node_def)
	node_def.add_properties = node_def.add_properties or {}
end

local function create_node_definition(def)
	local node_def = {
		description = def.description,
		visual_scale = def.visual_scale or 0.5,
		wield_scale = def.wield_scale or {x = 0.5, y = 0.5, z = 0.5},
		drawtype = def.drawtype or "mesh",
		paramtype = def.paramtype or "light",
		paramtype2 = def.paramtype2 or "facedir",
		tiles = def.tiles,
		overlay_tiles = def.overlay_tiles,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		drop = def.drop,
		light_source = def.light_source,
		sounds = def.sounds,
		groups = shallow_copy(def.groups),
		add_properties = shallow_copy(def.add_properties)
	}

	node_def.mesh = def.mesh
	node_def.callbacks = shallow_copy(def.callbacks)

	if node_def.paramtype2 == "wallmounted" and def.drawtype ~= "nodebox" then
		node_def.paramtype2 = "facedir"
	end

	node_def.prevent_placement_check = def.prevent_placement_check
	node_def.is_colorable = def.is_colorable
	node_def.use_texture_alpha = def.use_texture_alpha ~= nil and def.use_texture_alpha or (node_def.drawtype == "mesh" and "clip" or def.use_texture_alpha)

	return node_def
end

local function apply_callbacks(node_def, callbacks)
	if not callbacks then
		return
	end

	for name, handler in pairs(callbacks) do
		node_def[name] = handler
	end
end

local function attach_callback(node_def, name, fallback)
	local handler = node_def[name]

	if handler then
		node_def[name] = function(...)
			handler(...)
			return fallback(...)
		end
	else
		node_def[name] = fallback
	end
end

function register.register_furniture_unit(name, def, craft_def)
	ensure_category(def.type, 0)
	ensure_category(def.style, 1)

	local node_def = create_node_definition(def)

	ensure_groups_table(node_def)
	node_def.groups[def.type] = 1
	node_def.groups[def.style] = 1

	apply_material_defaults(node_def, def)
	apply_palette(node_def)
	apply_bounding_boxes(node_def, def)

	node_def.description = build_description(def.style, def.material, node_def.description)

	apply_callbacks(node_def, node_def.callbacks)
	node_def.callbacks = nil

	ensure_add_properties(node_def)

	attach_callback(node_def, "after_place_node", register.after_place_node)
	attach_callback(node_def, "on_punch", register.on_punch)

	minetest.register_node(":" .. "multidecor:" .. name, node_def)

	if not craft_def then
		return
	end

	minetest.register_craft({
		type = craft_def.type,
		output = "multidecor:" .. name .. (craft_def.count and " " .. tostring(craft_def.count) or ""),
		recipe = craft_def.recipe,
		replacements = craft_def.replacements,
		cooktime = craft_def.cooktime
	})
end

local DOOR_SOUNDS = {
	open = "multidecor_squeaky_door_open",
	close = "multidecor_squeaky_door_close"
}

local DRAWER_SOUNDS = {
	open = "multidecor_drawer_open",
	close = "multidecor_drawer_close"
}

local OBJECT_SUFFIXES = {
	floor_door = "floor_door",
	floor_half_door = "floor_half_door",
	wall_door = "wall_door",
	wall_half_door = "wall_half_door",
	wall_half_glass_door = "wall_half_glass_door",
	large_drawer = "large_drawer",
	small_drawer = "small_drawer"
}

local COMPONENT_TEMPLATES = {
	two_floor_drws = {
		entries = {
			{type = "drawer", object = "large_drawer", pos = "pos_lower"},
			{type = "drawer", object = "large_drawer", pos = "pos_upper"}
		}
	},
	three_floor_drws = {
		entries = {
			{type = "drawer", object = "small_drawer", pos = "pos_lower"},
			{type = "drawer", object = "small_drawer", pos = "pos_middle"},
			{type = "drawer", object = "small_drawer", pos = "pos_upper"}
		}
	},
	two_floor_doors = {
		entries = {
			{type = "sym_doors", object = "floor_half_door", pos = "pos_left", pos2 = "pos_right"}
		}
	},
	three_floor_doors = {
		entries = {
			{type = "sym_doors", object = "floor_half_door", pos = "pos_left", pos2 = "pos_right"}
		}
	},
	three_floor_drw_door = {
		entries = {
			{type = "drawer", object = "small_drawer", pos = "pos_upper"},
			{type = "sym_doors", object = "floor_half_door", pos = "pos_left", pos2 = "pos_right", customize = function(entry)
				entry.visual_size_adds = {x = 0, y = -1.75, z = 0}
			end}
		}
	},
	two_wall_door = {
		entries = {
			{type = "door", object = "wall_door", pos = "pos", side = "left"}
		}
	},
	two_wall_hdoor = {
		entries = {
			{type = "sym_doors", object = "wall_half_door", pos = "pos_left", pos2 = "pos_right"}
		}
	},
	two_wall_hgldoor = {
		entries = {
			{type = "sym_doors", object = "wall_half_glass_door", pos = "pos_left", pos2 = "pos_right"}
		}
	},
	two_wall_crn_hgldoor = {
		entries = {
			{type = "sym_doors", object = "wall_half_glass_door", pos = "pos_left", pos2 = "pos_right", orig_angle = {x = 0, y = -math.pi / 4, z = 0}}
		}
	},
	sink = {
		entries = {
			{type = "door", object = "floor_door", pos = "pos_trash", side = "left", list_type = "trash"}
		},
		apply_properties = function(node_def, component)
			node_def.add_properties.tap_data = component.tap_data
		end
	}
}

local function build_object_lookup(def)
	local lookup = {}
	local prefix = def.modname .. ":" .. def.objs_common_name .. "_"

	for alias, suffix in pairs(OBJECT_SUFFIXES) do
		lookup[alias] = prefix .. suffix
	end

	return lookup
end

local function build_shelf_entry(component, entry_cfg, object_lookup)
	local shelves_meta = component.shelves_data or {}
	local entry = {
		type = entry_cfg.type,
		object = object_lookup[entry_cfg.object],
		invlist_type = entry_cfg.list_type or shelves_meta.invlist_type,
		inv_size = shelves_meta.inv_size,
		pos = shelves_meta[entry_cfg.pos],
		pos2 = entry_cfg.pos2 and shelves_meta[entry_cfg.pos2] or nil,
		orig_angle = entry_cfg.orig_angle,
		side = entry_cfg.side or shelves_meta.side,
		sounds = entry_cfg.type == "drawer" and DRAWER_SOUNDS or DOOR_SOUNDS
	}

	if entry_cfg.type == "drawer" then
		entry.length = entry_cfg.length or 0.5
	else
		entry.acc = entry_cfg.acc or 1
	end

	if entry_cfg.customize then
		entry_cfg.customize(entry)
	end

	return entry
end

local function ensure_shelves_callbacks(callbacks)
	callbacks.on_construct = callbacks.on_construct or function(pos)
		multidecor.shelves.set_shelves(pos)
	end
	callbacks.can_dig = callbacks.can_dig or multidecor.shelves.can_dig
end

local function clone_base_node(base_node)
	local node_def = shallow_copy(base_node)

	node_def.groups = shallow_copy(base_node.groups)
	node_def.add_properties = shallow_copy(base_node.add_properties)

	return node_def
end

local function create_component_node_def(base_node_def, component)
	local node_def = clone_base_node(base_node_def)

	node_def.description = component.description
	node_def.mesh = component.mesh
	node_def.inventory_image = component.inventory_image
	node_def.bounding_boxes = component.bounding_boxes

	if component.tiles then
		node_def.tiles = component.tiles
	end

	return node_def
end

local function build_shelves_data(def, component_name, component, config, object_lookup)
	local shelves_data = {common_name = def.common_name .. "_" .. component_name}

	for _, entry_cfg in ipairs(config.entries) do
		table.insert(shelves_data, build_shelf_entry(component, entry_cfg, object_lookup))
	end

	return shelves_data
end

local function register_component_craft(def, component_name, component)
	if not component.craft then
		return
	end

	if component.craft.type then
		local count = component.craft.count and " " .. tostring(component.craft.count) or ""
		local craft_output = component.craft.output or ("multidecor:" .. def.common_name .. "_" .. component_name .. count)

		minetest.register_craft({
			type = component.craft.type,
			output = craft_output,
			recipe = component.craft.recipe,
			replacements = component.craft.replacements or {{"multidecor:hammer", "multidecor:hammer"}},
			cooktime = component.craft.cooktime
		})
	else
		minetest.register_craft({
			output = "multidecor:" .. def.common_name .. "_" .. component_name,
			recipe = component.craft,
			replacements = {{"multidecor:hammer", "multidecor:hammer"}}
		})
	end
end

local function register_component(def, component_name, component, config, base_node_def, object_lookup)
	local node_def = create_component_node_def(base_node_def, component)
	local callbacks = shallow_copy(component.callbacks)

	ensure_groups_table(node_def)
	ensure_add_properties(node_def)
	ensure_shelves_callbacks(callbacks)
	apply_callbacks(node_def, callbacks)

	local shelves_data = build_shelves_data(def, component_name, component, config, object_lookup)

	node_def.add_properties.shelves_data = shelves_data

	if component.tap_data then
		node_def.add_properties.tap_data = component.tap_data
	end

	if config.apply_properties then
		config.apply_properties(node_def, component)
	end

	register.register_table(shelves_data.common_name, node_def)
	register_component_craft(def, component_name, component)
end

function register.register_garniture(def)
	ensure_category(def.style, 1)

	local base_node_def = {
		type = def.type,
		style = def.style,
		material = def.material,
		drawtype = "mesh",
		visual_scale = 0.5,
		tiles = def.tiles,
		groups = shallow_copy(def.groups),
		add_properties = {}
	}

	local object_lookup = build_object_lookup(def)

	for component_name, config in pairs(COMPONENT_TEMPLATES) do
		local component = def.components and def.components[component_name]

		if component then
			register_component(def, component_name, component, config, base_node_def, object_lookup)
		end
	end
end
