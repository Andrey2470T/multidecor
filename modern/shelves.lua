local function get_shelf_formspec(name, pos, w, h)
	local listname = multidecor.helpers.build_name_from_tmp(name, "list", 1, pos)
	return table.concat({
		"formspec_version[5]",
		"size[11,9]",
		("list[nodemeta:%f,%f,%f;%s;0.5,0.5;%u,%u;]"):format(pos.x, pos.y, pos.z, listname, w, h),
		"list[current_player;main;0.5,3.5;8,4;]"
	}, "")
end

local shelf_on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	local name = minetest.get_node(pos).name
	local add_props = minetest.registered_nodes[name].add_properties
	meta:set_string("formspec", get_shelf_formspec(name, pos, add_props.inv_size.w, add_props.inv_size.h))

	local inv = minetest.get_inventory({type="node", pos=pos})
	local list_name = multidecor.helpers.build_name_from_tmp(name, "list", 1, pos)
	inv:set_size(list_name, add_props.inv_size.w*add_props.inv_size.h)
	inv:set_width(list_name, add_props.inv_size.w)

	inv:set_size("main", 8*4)
	inv:set_width("main", 8)
end

local shelf_can_dig = function(pos)
	local inv = minetest.get_inventory({type="node", pos=pos})

	return inv:is_empty(multidecor.helpers.build_name_from_tmp(minetest.get_node(pos).name, "list", 1, pos))
end


for _, wood_n in ipairs({"", "jungle", "pine", "aspen"}) do
	wood_n = wood_n .. (wood_n ~= "" and wood_n ~= "jungle" and "_" or "")
	local tex = "multidecor_" .. wood_n .. (wood_n == "jungle" and "_" or "") .. "wood.png^[sheet:2x2:0,0"

	multidecor.register.register_table("modern_wooden_" .. wood_n .. "closed_shelf", {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Closed Shelf (without back)",
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}			-- Top side
		},
		callbacks = {
			on_construct = shelf_on_construct,
			can_dig = shelf_can_dig
		}
	},
	{
		inv_size = {w=7, h=2}
	},
	{
		recipe = {
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board"},
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"", "", ""}
		}
	})

	multidecor.register.register_table("modern_wooden_" .. wood_n .. "closed_shelf_with_back", {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Closed Shelf (with back)",
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},			-- Top side
			{-0.4, -0.4, 0.4, 0.4, 0.4, 0.5}			-- Back side
		},
		callbacks = {
			on_construct = shelf_on_construct,
			can_dig = shelf_can_dig
		}
	},
	{
		inv_size = {w=7, h=2}
	},
	{
		recipe = {
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"", "", ""}
		}
	})

	multidecor.register.register_table("modern_wooden_" .. wood_n .. "wall_shelf", {
		style = "modern",
		material = "wood",
		visual_scale = 0.5,
		paramtype2 = "wallmounted",
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf",
		mesh = "multidecor_wall_shelf.obj",
		tiles = {tex},
		bounding_boxes = {
			{-0.5, 0, 0.4, 0.5, -0.5, 0.5},
			{-0.5, 0, 0.15, -0.4, -0.5, 0.4},
			{0.4, 0, 0.15, 0.5, -0.5, 0.4}
		}
	},
	{
		type = "shapeless",
		recipe = {"multidecor:" .. wood_n .. "plank", "multidecor:" .. wood_n .. "plank"}
	})

	multidecor.register.register_table("modern_corner_wooden_" .. wood_n .. "wall_shelf", {
		style = "modern",
		material = "wood",
		visual_scale = 0.5,
		paramtype2 = "wallmounted",
		description = "Modern Corner Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf",
		mesh = "multidecor_corner_wall_shelf.b3d",
		tiles = {tex},
		bounding_boxes = {
			{-0.5, 0, 0.4, 0.5, -0.5, 0.5},
			--{-0.5, 0, 0.15, -0.4, -0.5, 0.4},
			{0.4, 0, 0.15, 0.5, -0.5, 0.4},
			{-0.5, 0.5, 0.4, 0, 0, 0.5},
			{-0.5, 0.4, 0.15, 0, 0.5, 0.4}
		}
	},
	{
		type = "shapeless",
		recipe = {"multidecor:modern_wooden_" .. wood_n .. "wall_shelf", "multidecor:" .. wood_n .. "plank"}
	})

	multidecor.register.register_table("modern_wooden_" .. wood_n .. "wall_shelf_with_books", {
		style = "modern",
		material = "wood",
		visual_scale = 0.5,
		paramtype2 = "wallmounted",
		description = "Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf With Books",
		mesh = "multidecor_wall_shelf_with_books.b3d",
		tiles = { -- Red, blue, green, darkmagenta, darkorange
			tex,
			"multidecor_book_envelope.png^[multiply:red^multidecor_book.png",
			"multidecor_book_envelope.png^[multiply:darkorange^multidecor_book.png",
			"multidecor_book_envelope.png^[multiply:blue^multidecor_book_pattern.png^multidecor_book.png",
			"multidecor_book_envelope.png^[multiply:green^multidecor_book_pattern2.png^multidecor_book.png",
			"multidecor_book_envelope.png^[multiply:darkmagenta^multidecor_book_pattern.png^multidecor_book.png",
		},
		bounding_boxes = {
			{-0.5, 0, 0.4, 0.5, -0.5, 0.5},
			{-0.5, 0, 0.15, -0.4, -0.5, 0.4},
			{0.4, 0, 0.15, 0.5, -0.5, 0.4}
		}
	},
	{
		type = "shapeless",
		recipe = {"multidecor:modern_wooden_" .. wood_n .. "wall_shelf", "multidecor:books_stack"}
	})
end


multidecor.register.register_table("three_level_wooden_rack", {
	style = "modern",
	material = "wood",
	visual_scale = 0.5,
	description =  "Three Level Wooden Rack",
	mesh = "multidecor_three_level_wooden_rack.b3d",
	tiles = {"multidecor_wood.png"},
	callbacks = {
		on_construct = shelf_on_construct,
		can_dig = shelf_can_dig
	}
},
{
	inv_size = {w=8, h=3}
},
{
	recipe = {
		{"multidecor:plank", "multidecor:board", "multidecor:plank"},
		{"multidecor:plank", "multidecor:board", "multidecor:plank"},
		{"", "multidecor:board", ""}
	}
})
