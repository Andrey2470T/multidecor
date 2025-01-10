for _, wood_n in ipairs({"", "jungle", "pine", "aspen"}) do
	wood_n = wood_n .. (wood_n ~= "" and wood_n ~= "jungle" and "_" or "")
	local tex = "multidecor_" .. wood_n .. (wood_n == "jungle" and "_" or "") .. "wood.png^[sheet:2x2:0,0"

	local closed_shelf_name = "modern_wooden_" .. wood_n .. "closed_shelf"
	multidecor.register.register_table(closed_shelf_name, {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = modern.S("Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Closed Shelf (without back)"),
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5}			-- Top side
		},
		callbacks = {
			on_construct = multidecor.shelves.on_construct,
			on_rightclick = multidecor.shelves.node_on_rightclick,
			can_dig = multidecor.shelves.can_dig,
			on_receive_fields = multidecor.shelves.on_receive_fields,
			on_destruct = multidecor.shelves.on_destruct
		}
	},
	{
		shelves_data = {
			common_name = closed_shelf_name,
			{
				inv_size = {w=7, h=2}
			}
		}
	},
	{
		recipe = {
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board"},
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"", "", ""}
		}
	})

	local closed_shelf_with_back_name = "modern_wooden_" .. wood_n .. "closed_shelf_with_back"
	multidecor.register.register_table(closed_shelf_with_back_name, {
		style = "modern",
		material = "wood",
		drawtype = "nodebox",
		visual_scale = 1,
		description = modern.S("Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Closed Shelf (with back)"),
		tiles = {tex, tex, tex, tex, tex, tex},
		bounding_boxes = {
			{-0.5, -0.4, -0.5, -0.4, 0.4, 0.5},			-- Left side
			{0.4, -0.4, -0.5, 0.5, 0.4, 0.5},			-- Right side
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},			-- Bottom side
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},			-- Top side
			{-0.4, -0.4, 0.4, 0.4, 0.4, 0.5}			-- Back side
		},
		callbacks = {
			on_construct = multidecor.shelves.on_construct,
			on_rightclick = multidecor.shelves.node_on_rightclick,
			can_dig = multidecor.shelves.can_dig,
			on_receive_fields = multidecor.shelves.on_receive_fields,
			on_destruct = multidecor.shelves.on_destruct
		}
	},
	{
		shelves_data = {
			common_name = closed_shelf_with_back_name,
			{
				inv_size = {w=7, h=2}
			}
		}
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
		paramtype2 = "wallmounted",
		description = modern.S("Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf"),
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
		paramtype2 = "wallmounted",
		description = modern.S("Modern Corner Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf"),
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
		paramtype2 = "wallmounted",
		description = modern.S("Modern Wooden " .. wood_n:sub(1, 1):upper() .. wood_n:sub(2, -1) .. " Wall Shelf With Books"),
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
	description =  modern.S("Three Level Wooden Rack"),
	mesh = "multidecor_three_level_wooden_rack.b3d",
	tiles = {"multidecor_wood.png"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
	callbacks = {
		on_construct = multidecor.shelves.on_construct,
		on_rightclick = multidecor.shelves.node_on_rightclick,
		can_dig = multidecor.shelves.can_dig,
		on_receive_fields = multidecor.shelves.on_receive_fields,
		on_destruct = multidecor.shelves.on_destruct
	}
},
{
	shelves_data = {
		common_name = "three_level_wooden_rack",
		{
			inv_size = {w=8, h=3}
		}
	}
},
{
	recipe = {
		{"multidecor:plank", "multidecor:board", "multidecor:plank"},
		{"multidecor:plank", "multidecor:board", "multidecor:plank"},
		{"", "multidecor:board", ""}
	}
})
