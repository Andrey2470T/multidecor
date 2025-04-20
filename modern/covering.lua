local wallpapers = {
	{name="white", colorable=true, recipe={"dye:white"}},
	{name="cyan_patterned", colorable=false, recipe={"dye:cyan", "dye:blue"}},
	{name="yellow_patterned", colorable=false, recipe={"dye:yellow", "dye:white"}},
	{name="white_patterned", colorable=true, recipe={"dye:white", "dye:grey"}}
}

local cover_sbox = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05}

local function wallpaper_colorable(name)
	for _, wallpaper_sort in ipairs(wallpapers) do
		if wallpaper_sort.name .. "_wallpaper" == name and wallpaper_sort.colorable then
			return true
		end
	end

	return false
end

local function check_for_dye_in_inv(player)
	local inv = player:get_inventory()
	local dye_index = player:get_wield_index() + 1
	local dye = inv:get_stack("main", dye_index)
	local next_itemname = dye:get_name()

	if not dye or dye:is_empty() or
		minetest.get_item_group(next_itemname, "dye") ~= 1 then -- no any dye next to the brush or the slot is empty
		return
	end

	local index

	-- Checks if the color of the given dye is supported for painting
	for colorindex, colorname in ipairs(multidecor.colors) do
		if minetest.get_item_group(next_itemname, "color_" .. colorname) == 1 then
			index = colorindex - 1

			break
		end
	end

	return index
end

minetest.register_entity(":multidecor:cover", {
	visual = "upright_sprite",
	physical = false,
	pointable = true,
	collisionbox = {0, 0, 0, 0, 0, 0},
	selectionbox = wallpaper_sbox,
	damage_texture_modifier = "",
	on_activate = function(self, staticdata)
		if staticdata == "" then
			self.object:remove()
			return
		end

		local data = minetest.deserialize(staticdata)

		if not data then
			self.object:remove()
			return
		end

		self.cover_name = data.cover_name
		self.box = data.box
		self.color = data.color

		local texture = "multidecor_" .. self.cover_name .. ".png"

		if self.color then
			texture = texture .. "^[multiply:" .. self.color
		end

		self.object:set_properties({
			textures = {texture},
			selectionbox = self.box
		})
		self.object:set_armor_groups({immortal=1})
	end,
	on_rightclick = function(self, clicker)
		local paint_brush = clicker:get_wielded_item()

		if paint_brush:get_name() ~= "multidecor:paint_brush" then
			return
		end

		local color_index = check_for_dye_in_inv(clicker)

		if not color_index then
			return
		end

		if self.cover_name ~= "plaster" and not wallpaper_colorable(self.cover_name) then
			return
		end

		if minetest.is_protected(pos, clicker:get_player_name()) then
			return
		end

		local color = multidecor.colors[color_index+1]

		self.color = color

		self.object:set_properties({
			textures = {"multidecor_" .. self.cover_name .. ".png^[multiply:" .. self.color}
		})

		local dye_index = clicker:get_wield_index() + 1
		local inv = clicker:get_inventory()
		local dye = inv:get_stack("main", dye_index)
		dye:take_item()
		inv:set_stack("main", dye_index, dye)
	end,
	on_punch = function(self, puncher)
		local wielded_item = puncher:get_wielded_item()

		if wielded_item:get_name() ~= "multidecor:scraper" then
			return
		end

		if minetest.is_protected(self.object:get_pos(), puncher:get_player_name()) then
			return
		end

		self.object:remove()

		wielded_item:set_wear(wielded_item:get_wear()+math.modf(65535/50))
		puncher:set_wielded_item(wielded_item)

		multidecor.tools_sounds.play(puncher:get_player_name(), 4)
	end,
	get_staticdata = function(self)
		return minetest.serialize({cover_name=self.cover_name, box=self.box, color=self.color})
	end
})

local function on_place_cover(pointed_thing, cover_stack, cover_name, placer)
	local pos = pointed_thing.under

	local dir_to_pos = vector.normalize(pos - pointed_thing.above)

	if cover_name ~= "plaster" and dir_to_pos.y ~= 0.0 then -- Can not place on the floor or ceiling
		return cover_stack
	end

	if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
		return cover_stack
	end

	local target_pos = pointed_thing.above + dir_to_pos * 0.5

	-- Slight position displacement
	target_pos = target_pos - dir_to_pos * 0.01

	local target_rot = vector.dir_to_rotation(dir_to_pos)
	local target_sbox = hlpfuncs.rotate_bbox(cover_sbox, dir_to_pos)

	local obj = minetest.add_entity(target_pos, "multidecor:cover", minetest.serialize({cover_name=cover_name, box=target_sbox}))

	obj:set_rotation(target_rot)

	cover_stack:take_item()

	return cover_stack
end

for _, wallpaper_sort in ipairs(wallpapers) do
	local itemname = wallpaper_sort.name .. "_wallpaper"
	minetest.register_craftitem(":multidecor:" .. itemname, {
		description = modern.S(hlpfuncs.upper_first_letters(itemname) .. " (see the guide paper on how to use)"),
		inventory_image = "multidecor_" .. itemname .. ".png",
		on_place = function(itemstack, placer, pointed_thing)
			return on_place_cover(pointed_thing, itemstack, itemname, placer)
		end
	})

	local recipe = table.copy(wallpaper_sort.recipe)
	table.insert(recipe, "default:paper")
	table.insert(recipe, "multidecor:paint_brush")

	minetest.register_craft({
		type = "shapeless",
		output = "multidecor:" .. itemname,
		recipe = recipe,
		replacements = {{"multidecor:paint_brush", "multidecor:paint_brush"}}
	})
end

minetest.register_tool(":multidecor:scraper", {
	description = modern.S("Scraper (see the guide paper on how to use)"),
	inventory_image = "multidecor_scraper.png"
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:scraper",
	recipe = {"multidecor:steel_stripe", "multidecor:plastic_strip"}
})

minetest.register_craftitem(":multidecor:plaster_lump", {
	description = modern.S("Plaster Lump"),
	inventory_image = "multidecor_plaster_lump.png"
})

minetest.register_craft({
	type = "cooking",
	output = "multidecor:plaster_lump",
	recipe = "default:clay",
	cooktime = 8
})


minetest.register_tool(":multidecor:paint_brush", {
	description = modern.S("Paint Brush (see the guide paper on how to use)"),
	inventory_image = "multidecor_paint_brush.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local def = hlpfuncs.ndef(pos)

		if not def.is_colorable then -- not colorable
			return
		end

		local node = minetest.get_node(pos)

		local mul = def.paramtype2 == "colorwallmounted" and 8 or 32
		local palette_index = math.floor(node.param2 / mul)

		if palette_index ~= 0 then -- already colored
			return
		end

		local color_index = check_for_dye_in_inv(placer)

		if not color_index then
			return
		end

		if minetest.is_protected(pos, placer:get_player_name()) then
			return
		end

		local rot = node.param2 % mul
		minetest.swap_node(pos, {name=node.name, param2=color_index*mul+rot})

		local dye_index = placer:get_wield_index() + 1
		local inv = placer:get_inventory()
		local dye = inv:get_stack("main", dye_index)
		dye:take_item()
		inv:set_stack("main", dye_index, dye)
	end
})

minetest.register_craft({
	output = "multidecor:paint_brush",
	recipe = {
		{"default:stick", "multidecor:wool_cloth", "multidecor:steel_scissors"},
		{"", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_tool(":multidecor:spatula", {
	description = modern.S("Spatula (see the guide paper on how to use)"),
	inventory_image = "multidecor_spatula.png",
	on_place = function(itemstack, placer, pointed_thing)
		local inv = placer:get_inventory()
		local plaster_index = placer:get_wield_index() + 1
		local plaster = inv:get_stack("main", plaster_index)

		if not plaster or plaster:is_empty() or
			plaster:get_name() ~= "multidecor:plaster_lump" then
			return
		end

		plaster = on_place_cover(pointed_thing, plaster, "plaster", placer)
		inv:set_stack("main", plaster_index, plaster)
	end
})

minetest.register_craft({
	type = "shapeless",
	output = "multidecor:spatula",
	recipe = {"multidecor:steel_stripet", "multidecor:coarse_steel_sheet"}
})
