local wallpapers = {
	"white",
	"cyan_patterned",
	"yellow_patterned",
	"white_patterned",
}

local cover_sbox = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05}

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
		end

		self.texture = staticdata
		local texture = "multidecor_" .. staticdata .. ".png"

		self.object:set_properties({textures={texture}})
		self.object:set_armor_groups({immortal=1})
	end,
	on_punch = function(self, puncher)
		local wielded_item = puncher:get_wielded_item()

		if wielded_item:get_name() ~= "multidecor:scraper" then
			return
		end

		self.object:remove()

		wielded_item:set_wear(wielded_item:get_wear()+math.modf(65535/50))
		puncher:set_wielded_item(wielded_item)

		local playername = puncher:get_player_name()
		if not multidecor.players_actions_sounds[playername] then
			multidecor.players_actions_sounds[playername] = {
				name = "multidecor_scraping",
				cur_time = 0.0,
				durability = 4.0
			}

			minetest.sound_play("multidecor_scraping", {to_player=playername})
		end
	end,
	get_staticdata = function(self)
		return self.texture
	end
})

local function on_place_cover(pointed_thing, cover_stack, cover_name)
	local pos = pointed_thing.under

	local dir_to_pos = vector.normalize(pos - pointed_thing.above)

	if cover_name ~= "plaster" and dir_to_pos.y ~= 0.0 then -- Can not place on the floor or ceiling
		return cover_stack
	end
	local target_pos = pointed_thing.above + dir_to_pos * 0.5

	-- Slight position displacement
	target_pos = target_pos - dir_to_pos * 0.01

	local target_rot = vector.dir_to_rotation(dir_to_pos)
	local target_sbox = hlpfuncs.rotate_bbox(cover_sbox, dir_to_pos)

	local obj = minetest.add_entity(target_pos, "multidecor:cover", cover_name)

	obj:set_rotation(target_rot)
	obj:set_properties({selectionbox=target_sbox})

	cover_stack:take_item()

	return cover_stack
end

for _, wallpaper_sort in ipairs(wallpapers) do
	local itemname = wallpaper_sort .. "_wallpaper"
	minetest.register_craftitem(":multidecor:" .. itemname, {
		description = hlpfuncs.upper_first_letters(itemname),
		inventory_image = "multidecor_" .. itemname .. ".png",
		on_place = function(itemstack, placer, pointed_thing)
			return on_place_cover(pointed_thing, itemstack, itemname)
		end
	})
end

minetest.register_tool(":multidecor:scraper", {
	description = "Scraper (for stripping wallpapers, paint or plaster)",
	inventory_image = "multidecor_scraper.png"
})

minetest.register_craftitem(":multidecor:plaster_lump", {
	description = "Plaster Lump",
	inventory_image = "multidecor_plaster_lump.png"
})


minetest.register_tool(":multidecor:paint_brush", {
	description = "Paint Brush (for painting armchairs, curtains, beds, chairs and etc)",
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

		local inv = placer:get_inventory()
		local dye_index = placer:get_wield_index()
		local next_itemstack = inv:get_stack("main", dye_index+1)
		local next_itemname = next_itemstack:get_name()

		if not next_itemstack or next_itemstack:is_empty() or
			minetest.get_item_group(next_itemname, "dye") ~= 1 then -- no any dye next to the brush or the slot is empty
			return
		end

		local index, dye_color

		for colorindex, colorname in ipairs(multidecor.colors) do
			if minetest.get_item_group(next_itemname, "color_" .. colorname) == 1 then
				index = colorindex - 1
				dye_color = colorname

				break
			end
		end

		if not dye_color then return end -- not supported color

		local rot = node.param2 % mul
		minetest.swap_node(pos, {name=node.name, param2=index*mul+rot})

		next_itemstack:take_item()
		inv:set_stack("main", dye_index+1, next_itemstack)
	end
})

minetest.register_tool(":multidecor:spatula", {
	description = "Spatula (for spreading plaster on surfaces)",
	inventory_image = "multidecor_spatula.png",
	on_place = function(itemstack, placer, pointed_thing)
		local inv = placer:get_inventory()
		local spatula_index = placer:get_wield_index()
		local next_itemstack = inv:get_stack("main", spatula_index+1)

		if not next_itemstack or next_itemstack:is_empty() or
			next_itemstack:get_name() ~= "multidecor:plaster_lump" then
			return
		end

		next_itemstack = on_place_cover(pointed_thing, next_itemstack, "plaster")
		inv:set_stack("main", spatula_index+1, next_itemstack)
	end
})
