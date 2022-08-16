register.register_furniture_unit("modern_floor_clock", {
	type = "decoration",
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description = "Floor Clock",
	inventory_image = "multidecor_floor_clock_inv.png",
	use_texture_alpha = "blend",
	mesh = "multidecor_floor_clock.b3d",
	tiles = {
		"multidecor_jungle_wood.png",
		"multidecor_dial.png",
		"multidecor_gold_material.png",
		"multidecor_glass_material.png"
	},
	bounding_boxes = {{-0.4, -0.5, -0.3, 0.4, 2, 0.4}}
},
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"doors:door_glass", "multidecor:digital_dial", "multidecor:jungleboard"},
		{"multidecor:gear", "multidecor:gear", "multidecor:spring"}
	}
})


register.register_furniture_unit("book", {
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
	bounding_boxes = {{-0.2, -0.5, -0.3, 0.2, -0.35, 0.3}}
},
{
	recipe = {
		{"default:paper", "default:paper", "dye:blue"},
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})

register.register_furniture_unit("books_stack", {
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

register.register_furniture_unit("alarm_clock", {
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
	bounding_boxes = {{-0.25, -0.5, -0.175, 0.25, 0.1, 0.175}}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "dye:green"},
		{"multidecor:plastic_sheet", "multidecor:digital_dial", "multidecor:plastic_sheet"},
		{"multidecor:spring", "multidecor:gear", "multidecor:steel_scissors"}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

minetest.register_node(":multidecor:laminate",
{
	drawtype = "nodebox",
	description = "Laminate",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"multidecor_laminate.png"},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
	},
	groups = {choppy=1.5}
})


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

	local is_flowers_mod_i, is_flowers_mod_i2 = itemname:find("flowers:")
	minetest.debug("is_flowers_mod_i: " .. dump(is_flowers_mod_i))
	minetest.debug("group: " .. minetest.get_item_group(itemname, "flower"))
	if not is_flowers_mod_i or minetest.get_item_group(itemname, "flower") == 0 then
		return
	end

	local flower = itemname:sub(is_flowers_mod_i2+1)

	minetest.set_node(pos, {name=node.name .. "_with_flower_" .. flower, param2=node.param2})

	itemstack:take_item()

	return itemstack
end

local on_rightclick_flowerpot_with_flower = function(pos, node, clicker, itemstack)
	local pot_groups = minetest.registered_nodes[node.name].groups
	local current_flower = flowers[pot_groups.flower_in_pot]

	local itemname = itemstack:get_name()

	local is_flowers_mod_i, is_flowers_mod_i2 = itemname:find("flowers:")
	if is_flowers_mod_i and minetest.get_item_group(itemname, "flower") == 1 then
		local flower = itemname:sub(is_flowers_mod_i2+1)
		minetest.set_node(pos, {name=node.name:gsub(current_flower, flower), param2=node.param2})

		itemstack:take_item()
	else
		minetest.set_node(pos, {name=node.name:gsub("_with_flower_" .. current_flower, ""), param2=node.param2})
	end

	minetest.debug("current_flower: " .. current_flower)
	clicker:get_inventory():add_item("main", "flowers:" .. current_flower)

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
		bounding_boxes = {{-0.4, -0.5, -0.4, 0.4, 0.25, 0.4}}
	},
	["green_small_flowerpot"] = {
		description = "Green Small Flowerpot (right-click to place wielded flower)",
		mesh = "multidecor_green_small_flowerpot",
		tiles = {
			"multidecor_terracotta_material.png^[multiply:palegreen",
			"default_dirt.png"
		},
		bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.05, 0.3}},
	}
}

for name, def in pairs(pots_defs) do
	local cdef = table.copy(flowerpot_tmp_def)
	cdef.description = def.description
	cdef.mesh = def.mesh .. ".b3d"
	cdef.tiles = def.tiles
	cdef.collision_box = {
		type = "fixed",
		fixed = def.bounding_boxes
	}

	cdef.groups = {cracky=1.5}
	cdef.sounds = default.node_sound_stone_defaults()
	cdef.selection_box = cdef.collision_box

	cdef.on_rightclick = on_rightclick_flowerpot

	minetest.register_node(":multidecor:" .. name, cdef)

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

--[[minetest.register_node(":multidecor:terracotta_flowerpot", {
	visual_scale = 0.5,
	drawtype = "mesh",
	description = "Terracotta Flowerpot (right-click to place wielded flower)",
	paramtype = "light"
	mesh = "multidecor_terracotta_flowerpot.b3d",
	tiles = {
		"multidecor_terracotta_material2.png^[multiply:brown",
		"multidecor_terracotta_material.png^[multiply:brown",
		"default_dirt.png",
	},
	bounding_boxes = {{-0.4, -0.5, -0.4, 0.4, 0.25, 0.4}},
	callbacks = {
		on_rightclick = on_rightclick_flowerpot
	}
},
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"doors:door_glass", "multidecor:digital_dial", "multidecor:jungleboard"},
		{"multidecor:gear", "multidecor:gear", "multidecor:spring"}
	}
}]]

register.register_furniture_unit("white_plastic_flowerpot", {
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
}--[[,
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"doors:door_glass", "multidecor:digital_dial", "multidecor:jungleboard"},
		{"multidecor:gear", "multidecor:gear", "multidecor:spring"}
	}
}]])

--[[register.register_furniture_unit("green_small_flowerpot", {
	type = "decoration",
	style = "modern",
	material = "stone",
	visual_scale = 0.5,
	description = "Green Small Flowerpot (right-click to place wielded flower)",
	mesh = "multidecor_green_small_flowerpot.b3d",
	tiles = {
		"multidecor_terracotta_material.png^[multiply:palegreen",
		"default_dirt.png"
	},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.05, 0.3}},
	callbacks = {
		on_rightclick = on_rightclick_flowerpot
	}
}--[[,
{
	recipe = {
		{"multidecor:jungleboard", "multidecor:jungleboard", "multidecor:jungleboard"},
		{"doors:door_glass", "multidecor:digital_dial", "multidecor:jungleboard"},
		{"multidecor:gear", "multidecor:gear", "multidecor:spring"}
	}
})


for i = 1, #flowers do
	register.register_furniture_unit("terracotta_flowerpot_with_flower_" .. flowers[i], {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = "Terracotta Flowerpot (right-click to place wielded flower)",
		mesh = "multidecor_terracotta_flowerpot_with_flower.b3d",
		tiles = {
			"multidecor_terracotta_material2.png^[multiply:brown",
			"multidecor_terracotta_material.png^[multiply:brown",
			"default_dirt.png",
			"flowers_" .. flowers[i] .. ".png"
		},
		bounding_boxes = {{-0.4, -0.5, -0.4, 0.4, 0.25, 0.4}},
		groups = {not_in_creative_inventory=1, flower_in_pot=i},
		callbacks = {
			on_rightclick = on_rightclick_flowerpot_with_flower
		}
	})

	register.register_furniture_unit("green_small_flowerpot_with_flower_" .. flowers[i], {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = "Green Small Flowerpot (right-click to place wielded flower)",
		mesh = "multidecor_green_small_flowerpot_with_flower.b3d",
		tiles = {
			"multidecor_terracotta_material.png^[multiply:palegreen",
			"default_dirt.png",
			"flowers_" .. flowers[i] .. ".png"
		},
		bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.05, 0.3}},
		groups = {not_in_creative_inventory=1, flower_in_pot=i},
		callbacks = {
			on_rightclick = on_rightclick_flowerpot_with_flower
		}
	})
end]]
