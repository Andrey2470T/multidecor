local wallpapers = {
	"white",
	"cyan_patterned",
	"yellow_patterned",
	"white_patterned"
}

local wallpaper_sbox = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05}

minetest.register_entity(":multidecor:wallpaper", {
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
		local texture = "multidecor_" .. staticdata .. "_wallpaper.png"

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

for _, wallpaper_sort in ipairs(wallpapers) do
	local itemname = wallpaper_sort .. "_wallpaper"

	minetest.register_craftitem(":multidecor:" .. itemname, {
		description = hlpfuncs.upper_first_letters(itemname),
		inventory_image = "multidecor_" .. itemname .. ".png",
		on_place = function(itemstack, placer, pointed_thing)
			local pos = vector.add(pointed_thing.above, pointed_thing.under) / 2

			local dir_to_pos = vector.normalize(pos - pointed_thing.above)

			if dir_to_pos.y ~= 0.0 then -- Can not place on the floor or ceiling
				return itemstack
			end
			local target_pos = pointed_thing.above + dir_to_pos * 0.5

			-- Slight position displacement
			target_pos = target_pos - dir_to_pos * 0.01

			local target_rot = vector.dir_to_rotation(dir_to_pos)
			local target_sbox = hlpfuncs.rotate_bbox(wallpaper_sbox, dir_to_pos)

			local obj = minetest.add_entity(target_pos, "multidecor:wallpaper", wallpaper_sort)

			obj:set_rotation(target_rot)
			obj:set_properties({selectionbox=target_sbox})

			itemstack:take_item()

			return itemstack
		end
	})
end

minetest.register_tool(":multidecor:scraper", {
	description = "Scraper (for stripping wallpapers, paint or plaster)",
	inventory_image = "multidecor_scraper.png"
})

minetest.register_tool(":multidecor:spatula", {
	description = "Spatula (for spreading plaster on ceilings)",
	inventory_image = "multidecor_spatula.png"
})
