for _, wood_n in ipairs({"", "jungle", "pine", "aspen"}) do
	wood_n = wood_n .. (wood_n ~= "" and wood_n ~= "jungle" and "_" or "")
	local tex = "multidecor_" .. wood_n .. (wood_n == "jungle" and "_" or "") .. "wood.png^[sheet:2x2:0,0"

	register.register_table("modern_wooden_" .. wood_n .. "closed_shelf", {
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
		}
	},
	{
		recipe = {
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board"},
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"", "", ""}
		}
	})

	register.register_table("modern_wooden_" .. wood_n .. "closed_shelf_with_back", {
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
		}
	},
	{
		recipe = {
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"multidecor:" .. wood_n .. "board", "multidecor:" .. wood_n .. "board", ""},
			{"", "", ""}
		}
	})

	register.register_table("modern_wooden_" .. wood_n .. "wall_shelf", {
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
			--[[{-0.5, 0.4, 0, 0.5, 0.5, 0.5},
			{-0.5, 0.15, 0, -0.4, 0.4, 0.5},
			{0.4, 0.15, 0, 0.5, 0.4, 0.5}]]
		}
	},
	{
		type = "shapeless",
		recipe = {"multidecor:" .. wood_n .. "plank", "multidecor:" .. wood_n .. "plank"}
	})
end
