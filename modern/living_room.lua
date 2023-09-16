local function get_current_time()
	local timeofday = minetest.get_timeofday()
	local time = math.floor(timeofday * 1440)
	local minute = time % 60
	local hour = (time - minute) / 60

	return hour, minute
end

local function get_formatted_time_str(hours, minutes)
	return ("Current time: %d:%d"):format(hours, minutes)
end

local function return_book_form(pos)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text")

	local formstr = "formspec_version[5]size[8,9]" ..
		"textarea[1,1;6,6;book_textarea;;" .. text .."]button[3,7.5;2,1;book_save;Save]"

	return formstr
end

local function book_save_meta_after_dig(pos, oldnode, oldmeta, drops)
	if oldmeta.text then
		local stackmeta = drops[1]:get_meta()

		local base_desc = "Book" .. (oldmeta.text ~= "" and " (written)" or "")

		stackmeta:set_string("description", multidecor.register.build_description(oldnode.name, base_desc))
		stackmeta:set_string("text", oldmeta.text)
	end
end

local tile_bboxes = {
	type = "wallmounted",
	wall_top = {-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
	wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	wall_side = {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5}
		
}

multidecor.register.register_furniture_unit("modern_floor_clock", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = "Floor Clock",
	inventory_image = "multidecor_floor_clock_inv.png",
	use_texture_alpha = "blend",
	mesh = "multidecor_floor_clock.b3d",
	tiles = {
		"multidecor_gold_material.png",
		"multidecor_jungle_wood.png",
		"multidecor_dial.png",
		"multidecor_glass_material.png"
	},
	bounding_boxes = {{-0.4, -0.5, -0.3, 0.4, 2, 0.4}},
	callbacks = {
		on_construct = function(pos)
			local wheel = minetest.add_entity(pos, "modern:floor_clock_balance_wheel")

			local dir = vector.multiply(minetest.facedir_to_dir(minetest.get_node(pos).param2), -1)
			local y_rot = vector.dir_to_rotation(dir).y

			wheel:set_rotation({x=0, y=y_rot, z=0})

			minetest.get_meta(pos):set_string("is_activated", "false")
		end,
		on_rightclick = function(pos, node, clicker)
			local wheel = minetest.get_objects_inside_radius(pos, 0.3)

			-- Not found the balance wheel
			if #wheel == 0 then
				return
			end

			wheel = wheel[1]

			if wheel:get_luaentity().name ~= "modern:floor_clock_balance_wheel" then
				return
			end

			local meta = minetest.get_meta(pos)

			if meta:get_string("is_activated") == "false" then
				wheel:set_animation({x=1, y=40}, 40.0, 0.0, true)
				meta:set_string("is_activated", "true")

				local handle = minetest.sound_play("multidecor_clock_chime", {object=wheel, fade=1.0, max_hear_distance=10, loop=true})
				meta:set_string("sound_handle", minetest.serialize(handle))

				minetest.get_node_timer(pos):start(1)
			else
				wheel:set_animation({x=1, y=1}, 0.0)
				meta:set_string("is_activated", "false")

				local handle = minetest.deserialize(meta:get_string("sound_handle"))
				minetest.sound_stop(handle)

				minetest.get_node_timer(pos):stop()
			end
		end,
		after_dig_node = function(pos, oldnode, oldmeta)
			local wheel = minetest.get_objects_inside_radius(pos, 0.3)

			-- Not found the balance wheel
			if #wheel == 0 then
				return
			end

			wheel = wheel[1]

			if wheel:get_luaentity().name ~= "modern:floor_clock_balance_wheel" then
				return
			end

			local handle = minetest.deserialize(oldmeta.fields.sound_handle)

			if handle then
				minetest.sound_stop(handle)
			end
			wheel:remove()
		end,
		on_timer = function(pos, elapsed)
			local hours, minutes, seconds = get_current_time()
			minetest.get_meta(pos):set_string("infotext", get_formatted_time_str(hours, minutes))

			return true
		end
	}
},
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"doors:door_glass", "multidecor:digital_dial", "multidecor:jungleboard"},
		{"multidecor:gear", "multidecor:gear", "multidecor:spring"}
	}
})


minetest.register_entity("modern:floor_clock_balance_wheel", {
	visual = "mesh",
	visual_size = {x=5, y=5, z=5},
	physical = false,
	pointable = false,
	mesh = "multidecor_floor_clock_balance_wheel.b3d",
	textures = {"multidecor_gold_material.png"},
	static_save = true
})

multidecor.register.register_furniture_unit("book", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = "Book",
	mesh = "multidecor_book.b3d",
	tiles = {
		"multidecor_book_envelope.png^[multiply:blue^multidecor_book_pattern.png",
		"multidecor_book.png"
	},
	bounding_boxes = {{-0.2, -0.5, -0.3, 0.2, -0.35, 0.3}},
	callbacks = {
		on_punch = function(pos, node, puncher, pointed_thing)
			minetest.swap_node(pos, {name="multidecor:book_open", param1=node.param1, param2=node.param2})
		end,
		preserve_metadata = book_save_meta_after_dig,
		after_place_node = function(pos, placer, itemstack)
			local text = itemstack:get_meta():get_string("text")

			minetest.get_meta(pos):set_string("text", text)
		end
	}
},
{
	recipe = {
		{"default:paper", "default:paper", "dye:blue"},
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})

multidecor.register.register_furniture_unit("book_open", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = "Book",
	mesh = "multidecor_book_open.b3d",
	tiles = {
		"multidecor_book_envelope.png^[multiply:blue^multidecor_book_pattern.png",
		"multidecor_book.png",
		"multidecor_book2.png"
	},
	groups = {not_in_creative_inventory=1},
	drop = "multidecor:book",
	bounding_boxes = {{-0.5, -0.5, -0.3, 0.5, -0.35, 0.3}},
	callbacks = {
		on_punch = function(pos, node, puncher, pointed_thing)
			minetest.swap_node(pos, {name="multidecor:book", param1=node.param1, param2=node.param2})
		end,
		on_rightclick = function(pos, node, clicker)
			clicker:get_meta():set_string("open_book_at", vector.to_string(pos))
			minetest.show_formspec(clicker:get_player_name(), "multidecor:book_form", return_book_form(pos))
		end,
		preserve_metadata = book_save_meta_after_dig
	}
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "multidecor:book_form" then
		return
	end

	local player_meta = player:get_meta()

	if fields.quit then
		player_meta:set_string("open_book_at", "")
	end

	if fields.book_save then
		local pos = vector.from_string(player_meta:get_string("open_book_at"))

		if pos then
			minetest.get_meta(pos):set_string("text", fields.book_textarea)
			minetest.sound_play("multidecor_book_writing", {gain=1.0, pitch=1.0, to_player=player:get_player_name()})
		end
	end
end)

multidecor.register.register_furniture_unit("books_stack", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = "Books Stack",
	mesh = "multidecor_books_stack.b3d",
	tiles = {
		"multidecor_book_envelope.png^[multiply:green^multidecor_book_pattern.png",
		"multidecor_book.png",
		"multidecor_book_envelope.png^[multiply:blueviolet^multidecor_book_pattern.png",
		"multidecor_book_envelope.png^[multiply:red",
		"multidecor_book_envelope.png^[multiply:darkorange^multidecor_book_pattern2.png",
	},
	bounding_boxes = {{-0.2, -0.5, -0.3, 0.2, -0.1, 0.3}}
},
{
	type = "shapeless",
	recipe = {
		"multidecor:book", "multidecor:book",
		"multidecor:book", "multidecor:book"
	}
})

multidecor.register.register_furniture_unit("alarm_clock", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	visual_scale = 0.5,
	description = "Alarm Clock",
	mesh = "multidecor_alarm_clock.b3d",
	tiles = {
		"multidecor_plastic_material.png^[multiply:green",
		"multidecor_metal_material.png",
		"multidecor_digital_dial.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = {{-0.25, -0.5, -0.175, 0.25, 0.1, 0.175}},
	callbacks = {
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("is_activated", "false")
		end,
		on_rightclick = function(pos)
			local meta = minetest.get_meta(pos)

			if meta:get_string("is_activated") == "false" then
                meta:set_string("is_activated", "true")
                minetest.get_node_timer(pos):start(1)

				local handle = minetest.sound_play("multidecor_clock_ticking", {pos=pos, fade=1.0, max_hear_distance=10, loop=true})
				meta:set_string("sound_handle", minetest.serialize(handle))
			else
                meta:set_string("is_activated", "false")
                minetest.get_node_timer(pos):stop()

                local handle = minetest.deserialize(meta:get_string("sound_handle"))

                if handle then
					minetest.sound_stop(handle)
                end
			end
		end,
		on_timer = function(pos)
			local meta = minetest.get_meta(pos)

			local hours, minutes, seconds = get_current_time()
            meta:set_string("infotext", get_formatted_time_str(hours, minutes))

			return true
		end,
		after_dig_node = function(pos, oldnode, oldmeta)
			local handle = minetest.deserialize(oldmeta.fields.sound_handle)

			if handle then
				minetest.sound_stop(handle)
			end
		end
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "dye:green"},
		{"multidecor:plastic_sheet", "multidecor:digital_dial", "multidecor:plastic_sheet"},
		{"multidecor:spring", "multidecor:gear", "multidecor:steel_scissors"}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

local floors_defs = {
	["laminate"] = {
		"Laminate",
		"multidecor_laminate.png",
		{"multidecor:plank", "multidecor:plank", "multidecor:plank", "multidecor:plank"}
	},
	["white_laminate"] = {
		"White Laminate",
		"multidecor_white_laminate.png",
		{"multidecor:plank", "multidecor:plank", "multidecor:plank", "multidecor:plank", "dye:white"}
	},
	["pine_parquet"] = {
		"Pine Parquet",
		"multidecor_pine_parquet.png",
		{"multidecor:pine_plank", "multidecor:pine_plank", "multidecor:pine_plank", "multidecor:pine_plank"}
	},
	["jungle_linoleum"] = {
		"Jungle Linoleum",
		"multidecor_jungle_linoleum.png",
		{"multidecor:jungleplank", "multidecor:jungleplank", "multidecor:jungleplank", "multidecor:jungleplank"}
	}
}

for name, def in pairs(floors_defs) do
	local tile_name = "multidecor:" .. name .. "_tile"
	minetest.register_node(":" .. tile_name, {
		description = def[1] .. " Tile",
		drawtype = "nodebox",
		visual_scale = 1.0,
		paramtype = "light",
		paramtype2 = "wallmounted",
		tiles = {def[2]},
		groups = {cracky=1.5},
		node_box = tile_bboxes,
		selection_box = tile_bboxes,
		sounds = default.node_sound_wood_defaults()
	})
	
	minetest.register_craft({
		type = "shapeless",
		output = tile_name,
		recipe = def[3]
	})
	
	local block_name = "multidecor:" .. name .. "_block"
	minetest.register_node(":" .. block_name, {
		description = def[1] .. " Block",
		visual_scale = 0.5,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {def[2]},
		groups = {choppy=1.5},
		sounds = default.node_sound_wood_defaults()
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



local flowers = {
	"rose",
	"tulip",
	"dandelion_yellow",
	"chrysanthemum_green",
	"geranium",
	"viola",
	"dandelion_white",
	"tulip_black"
}

local on_rightclick_flowerpot = function(pos, node, clicker, itemstack)
	local itemname = itemstack:get_name()

	local is_flowers_mod_i = itemname:find(":")
	
	if not is_flowers_mod_i then return end
	
	local modname = itemname:sub(1, is_flowers_mod_i-1)
	local flower = itemname:sub(is_flowers_mod_i+1)
	 
	if modname ~= "flowers" or minetest.get_item_group(itemname, "flower") == 0 or table.indexof(flowers, flower) == -1 then
		return
	end

	minetest.set_node(pos, {name=node.name .. "_with_flower_" .. flower, param2=node.param2})

	itemstack:take_item()

	return itemstack
end

local on_rightclick_flowerpot_with_flower = function(pos, node, clicker, itemstack)
	local pot_groups = minetest.registered_nodes[node.name].groups
	local current_flower = flowers[pot_groups.flower_in_pot]

	local itemname = itemstack:get_name()

	local is_flowers_mod_i = itemname:find(":")
	
	local modname, flower
	
	if is_flowers_mod_i then
		modname = itemname:sub(1, is_flowers_mod_i-1)
		flower = itemname:sub(is_flowers_mod_i+1)
	end
	
	if modname == "flowers" and minetest.get_item_group(itemname, "flower") == 1 and table.indexof(flowers, flower) ~= -1 then
		if flower ~= current_flower then
			minetest.set_node(pos, {name=node.name:gsub(current_flower, flower), param2=node.param2})

			itemstack:take_item()

			clicker:get_inventory():add_item("main", "flowers:" .. current_flower)
		end
	else
		minetest.set_node(pos, {name=node.name:gsub("_with_flower_" .. current_flower, ""), param2=node.param2})

		minetest.after(0, function()
			clicker:get_inventory():add_item("main", "flowers:" .. current_flower)
		end)
	end

	return itemstack
end

local after_destruct_flowerpot = function(pos, oldnode, oldmeta, digger)
	local pot_groups = minetest.registered_nodes[oldnode.name].groups
	local flower = flowers[pot_groups.flower_in_pot]

	digger:get_inventory():add_item("main", "flowers:" .. flower)
end

local flowerpot_tmp_def = {
	visual_scale = 0.5,
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
}

local pots_defs = {
	["terracotta_flowerpot"] = {
		description = "Terracotta Flowerpot (right-click to place wielded flower)",
		mesh = "multidecor_terracotta_flowerpot",
		tiles = {
			"multidecor_terracotta_material2.png^[multiply:brown",
			"multidecor_terracotta_material.png^[multiply:brown",
			"default_dirt.png",
		},
		bounding_boxes = {{-0.4, -0.5, -0.4, 0.4, 0.25, 0.4}},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"multidecor:terracotta_fragment", "multidecor:terracotta_fragment", "multidecor:terracotta_fragment"},
				{"multidecor:terracotta_fragment", "default:dirt", "multidecor:terracotta_fragment"},
				{"dye:red", "", ""}
			}
		}
	},
	["green_small_flowerpot"] = {
		description = "Green Small Flowerpot (right-click to place wielded flower)",
		mesh = "multidecor_green_small_flowerpot",
		tiles = {
			"multidecor_terracotta_material.png^[multiply:palegreen",
			"default_dirt.png"
		},
		bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.05, 0.3}},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"multidecor:terracotta_fragment", "default:dirt", "dye:green"},
				{"multidecor:terracotta_fragment", "", ""},
				{"", "", ""}
			}
		}
	},
	["glass_vase"] = {
		description = "Glass Vase (right-click to place wielded flower)",
		mesh = "multidecor_glass_vase",
		tiles = {"multidecor_gloss.png^[opacity:120"},
		inventory_image = "multidecor_glass_vase_inv.png",
		wield_image = "multidecor_glass_vase_inv.png",
		use_texture_alpha = "blend",
		bounding_boxes = {{-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}},
		sounds = default.node_sound_glass_defaults(),
		craft = {
			type = "shapeless",
			recipe = {"xpanes:pane_flat", "xpanes:pane_flat"}
		}
	},
}

for name, def in pairs(pots_defs) do
	local cdef = table.copy(flowerpot_tmp_def)
	cdef.description = def.description
	cdef.mesh = def.mesh .. ".b3d"
	cdef.tiles = def.tiles
	cdef.inventory_image = def.inventory_image
	cdef.wield_image = def.wield_image
	cdef.collision_box = {
		type = "fixed",
		fixed = def.bounding_boxes
	}

	cdef.use_texture_alpha = def.use_texture_alpha
	cdef.groups = {cracky=1.5}
	cdef.sounds = def.sounds
	cdef.selection_box = cdef.collision_box

	cdef.on_rightclick = on_rightclick_flowerpot

	minetest.register_node(":multidecor:" .. name, cdef)

	def.craft.output = "multidecor:" .. name
	minetest.register_craft(def.craft)
	for i=1, #flowers do
		local cdef2 = table.copy(cdef)
		cdef2.mesh = def.mesh .. "_with_flower.b3d"
		table.insert(cdef2.tiles, "flowers_" .. flowers[i] .. ".png")

		cdef2.drop = "multidecor:" .. name
		cdef2.groups.not_in_creative_inventory = 1
		cdef2.groups.flower_in_pot = i
		cdef2.on_rightclick = on_rightclick_flowerpot_with_flower
		cdef2.after_dig_node = after_destruct_flowerpot

		minetest.register_node(":multidecor:" .. name .. "_with_flower_" .. flowers[i], cdef2)
	end
end


multidecor.register.register_furniture_unit("white_plastic_flowerpot", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	visual_scale = 0.5,
	description = "White Plastic Flowerpot",
	mesh = "multidecor_white_plastic_flowerpot.b3d",
	tiles = {
		"multidecor_white_plastic_pot.png",
		"default_dirt.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:plastic_sheet", "multidecor:plastic_sheet"},
		{"multidecor:plastic_sheet", "default:dirt", "multidecor:plastic_sheet"},
		{"multidecor:plastic_sheet", "multidecor:plastic_sheet", "multidecor:plastic_sheet"}
	}
})
