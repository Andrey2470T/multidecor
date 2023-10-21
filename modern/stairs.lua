local stairs_data = {
	{name="stone", tex="multidecor_stone_material.png"},
	{name="marble", tex="multidecor_marble_material.png"},
	{name="granite", tex="multidecor_granite_material.png"}
}

local stair_bboxes = {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, 0.25, -0.25, 0.5, 0.5},
	{-0.25, 0, 0, 0, 0.5, 0.5},
	{0, 0, -0.25, 0.25, 0.5, 0.5},
	{0.25, 0, -0.5, 0.5, 0.5, 0.5}
}

for _, stair in ipairs(stairs_data) do
	local upper_name = multidecor.helpers.upper_first_letters(stair.name)

	stairs.register_stair_and_slab(
		stair.name,
		"multidecor:" .. stair.name .. "_block",
		{cracky=3},
		{stair.tex .. "^[sheet:2x2:0,0"},
		upper_name .. " Stair",
		upper_name .. " Slab",
		default.node_sound_stone_defaults(),
		true
	)

	multidecor.register.register_furniture_unit(stair.name .. "_ledged_stair_segment", {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = upper_name .. " Ledged Stair Segment",
		mesh = "multidecor_ledged_stair_segment.b3d",
		tiles = {stair.tex},
		bounding_boxes = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			{-0.5, 0, 0, 0.5, 0.5, 0.5}
		}
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_stair_base", {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = "Spiral " .. upper_name .. " Stair Base",
		mesh = "multidecor_spiral_stair_base.b3d",
		tiles = {stair.tex},
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_stair_segment", {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = "Spiral " .. upper_name .. " Stair Segment",
		mesh = "multidecor_spiral_stair_segment.b3d",
		tiles = {stair.tex},
		bounding_boxes = stair_bboxes
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_ledged_stair_segment", {
		type = "decoration",
		style = "modern",
		material = "stone",
		visual_scale = 0.5,
		description = "Spiral " .. upper_name .. " Ledged Stair Segment",
		mesh = "multidecor_spiral_ledged_stair_segment.b3d",
		tiles = {stair.tex},
		bounding_boxes = stair_bboxes
	})
end

minetest.register_node(":multidecor:marble_block", {
	description = "Marble Block",
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	tiles = {"multidecor_marble_material.png^[sheet:2x2:0,0"},
	groups = {cracky=2.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node(":multidecor:granite_block", {
	description = "Granite Block",
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	tiles = {"multidecor_granite_material.png^[sheet:2x2:0,0"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})
