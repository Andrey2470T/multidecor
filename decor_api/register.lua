-- Registration API

multidecor.register = {}

register = multidecor.register

-- Default furniture types
register.supported_types = {
	"seat",
	"table",
	"shelf",
	"bed"
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
function register.register_type(type_name)
	table.insert(register.supported_types, type_name)
end

-- Checks whether type with 'type_name' name is registered
function register.check_for_type(type_name)
	for _, type in ipairs(register.supported_types) do
		if type == type_name then
			return true
		end
	end

	return false
end

-- Checks whether style with 'style_name' name is registered
function register.check_for_style(style_name)
	minetest.debug("style_name: " .. style_name)
	for _, style in ipairs(register.supported_styles) do
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
function register.register_furniture_unit(name, def, craft_def)
	local f_def = {}

	assert(register.check_for_type(def.type), "The type with a name \"" .. def.type .. "\" is not registered!")
	assert(register.check_for_style(def.style), "The type with a name \"" .. def.style .. "\" is not registered!")

	f_def.description = def.description
	f_def.visual_scale = def.visual_scale or 0.4
	f_def.wield_scale = def.wield_scale or {x=0.5, y=0.5, z=0.5}
	f_def.drawtype = def.drawtype or "mesh"
	f_def.paramtype = "light"
	f_def.paramtype2 = def.paramtype2 or "facedir"
	f_def.use_texture_alpha = "clip"
	f_def.drop = def.drop

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
			f_def.sounds = default.node_sound_leaves_defaults()
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
			output = f_name,
			recipe = craft_def.recipe,
			replacements = craft_def.replacements or nil
		})
	end

	--[[if f_def.add_properties.common_name then
		connecting.register_connect_parts(f_def)
	end]]
end

-- Registers a set of furniture components of certain type: "kitchen", "bathroom", "bedroom", "living_room" and etc.
function register.register_garniture()
end
