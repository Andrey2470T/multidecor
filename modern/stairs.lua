local stair_ledged_bboxes = {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, 0, 0.5, 0.5, 0.5}
}

local sstair_bboxes = {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, 0, 0.25, 0.5, 0.5}
}

local sstair_plank_bboxes = {
	{-0.5, -0.085, -0.5, 0.45, 0, -0.25}, -- stairs
	{-0.5, -0.085, -0.25, 0.25, 0, 0},
	{-0.5, 0.415, 0, 0, 0.5, 0.5},

	{-0.55, -0.5, -0.55, -0.45, 0.5, -0.45} -- pillar
}

local sstair_plank_bboxes_wban = {
	{0.45, -0.49, -0.5, 0.6, 1.85, 0}, -- banister
	{0.25, -0.49, 0, 0.5, 1.85, 0.25},
	{0, -0.49, 0.25, 0.25, 1.85, 0.5},
	{-0.5, -0.49, 0.45, 0, 1.85, 0.6},

	{-0.5, -0.085, -0.5, 0.45, 0, -0.25}, -- stairs
	{-0.5, -0.085, -0.25, 0.25, 0, 0},
	{-0.5, 0.415, 0, 0, 0.5, 0.5},

	{-0.55, -0.5, -0.55, -0.45, 0.5, -0.45} -- pillar
}

local banister_bboxes = {
	{0.45, -0.5, -0.5, 0.55, 0.5, 0.5}
}

local right_banister_bbox = {
	{-0.55, -0.5, -0.5, -0.45, 0.5, 0.5}
}

local corner_banister_bboxes = {
	{0.45, -0.5, -0.5, 0.55, 0.5, 0.5},
	{-0.5, -0.5, -0.55, 0.5, 0.5, -0.45}
}

local spiral_banister_bboxes = {
	{0.45, -1.0, -0.5, 0.6, 0.8, 0}, -- banister
	{0.25, -1.0, 0, 0.5, 0.8, 0.25},
	{0, -0.5, 0.25, 0.25, 0.8, 0.5},
	{-0.5, -0.5, 0.45, 0, 0.8, 0.6}
}

local stairs_data = {
	{name="stone", tex="multidecor_stone_material.png"},
	{name="marble", tex="multidecor_marble_material.png"},
	{name="granite", tex="multidecor_granite_material.png"}
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
		description = upper_name .. " Ledged Stair Segment",
		mesh = "multidecor_ledged_stair_segment.b3d",
		tiles = {stair.tex},
		groups = {stair=1},
		bounding_boxes = stair_ledged_bboxes
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_stair_base", {
		type = "decoration",
		style = "modern",
		material = "stone",
		description = "Spiral " .. upper_name .. " Stair Base",
		mesh = "multidecor_spiral_stair_base.b3d",
		tiles = {stair.tex},
		bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_stair_segment", {
		type = "decoration",
		style = "modern",
		material = "stone",
		description = "Spiral " .. upper_name .. " Stair Segment",
		mesh = "multidecor_spiral_stair_segment.b3d",
		tiles = {stair.tex},
		groups = {stair=1, spiral=1},
		bounding_boxes = sstair_bboxes
	})

	multidecor.register.register_furniture_unit("spiral_" .. stair.name .. "_ledged_stair_segment", {
		type = "decoration",
		style = "modern",
		material = "stone",
		description = "Spiral " .. upper_name .. " Ledged Stair Segment",
		mesh = "multidecor_spiral_ledged_stair_segment.b3d",
		tiles = {stair.tex},
		groups = {stair=1, spiral=1},
		bounding_boxes = sstair_bboxes
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

local spiral_stairs_data = {
	{name="metal", tex={"multidecor_coarse_metal_material.png", "multidecor_coarse_metal_material.png"}},
	{name="plastic", tex={"multidecor_plastic_material.png", "multidecor_gold_material.png"}}
}

if minetest.get_modpath("ethereal") then
	table.insert(spiral_stairs_data, {name="sequoia", tex={"ethereal_redwood_wood.png", "ethereal_redwood_wood.png"}})
end


for _, sstair in ipairs(spiral_stairs_data) do
	local upper_name = multidecor.helpers.upper_first_letters(sstair.name)

	multidecor.register.register_furniture_unit("spiral_" .. sstair.name .. "_plank_stair_segment", {
		type = "decoration",
		style = "modern",
		material = sstair.name == "sequoia" and "wood" or sstair.name,
		description = "Spiral " .. upper_name .. "Plank Stair Segment",
		mesh = "multidecor_spiral_plank_stair_segment.b3d",
		tiles = sstair.tex,
		groups = {stair=1, spiral=1},
		bounding_boxes = sstair_plank_bboxes
	})

	multidecor.register.register_furniture_unit("spiral_" .. sstair.name .. "_plank_stair_segment_with_banister", {
		type = "decoration",
		style = "modern",
		material = sstair.name == "sequoia" and "wood" or sstair.name,
		description = "Spiral " .. upper_name .. "Plank Stair Segment With Banister",
		mesh = "multidecor_spiral_plank_stair_segment_with_banister.b3d",
		tiles = sstair.tex,
		bounding_boxes = sstair_plank_bboxes_wban
	})

	--[[multidecor.register.register_banister("spiral_" .. sstair.name .. "_banister", {
		style = "modern",
		material = sstair.name == "sequoia" and "wood" or sstair.name,
		description = "Spiral " .. upper_name .. " Banister",
		mesh = "multidecor_spiral_banister.b3d",
		tiles = sstair.tex,
		bounding_boxes = spiral_banister_bboxes,
		prevent_placement_check = true
	})]]

	local banister_common_name = sstair.name .. "_banister"
	multidecor.register.register_banister(banister_common_name, {
		style = "modern",
		material = sstair.name == "sequoia" and "wood" or sstair.name,
		description = upper_name .. " Banister",
		mesh = "multidecor_banister.b3d",
		tiles = sstair.tex,
		bounding_boxes = banister_bboxes,
		prevent_placement_check = true
	},
	{
		common_name = banister_common_name,
		banister_shapes = {
			["raised_left"] = {mesh="multidecor_banister_raised_left.b3d", bboxes=banister_bboxes},
			["raised_right"] = {mesh="multidecor_banister_raised_right.b3d", bboxes=right_banister_bbox},
			["spiral"] = {mesh="multidecor_spiral_banister.b3d", bboxes=spiral_banister_bboxes},
			["corner"] = {mesh="multidecor_banister_corner.b3d", bboxes=corner_banister_bboxes}
		}
	})

	--[[multidecor.register.register_banister(sstair.name .. "_banister_raised", {
		type = "decoration",
		style = "modern",
		material = sstair.name == "sequoia" and "wood" or sstair.name,
		description = upper_name .. " Banister Raised",
		mesh = "multidecor_banister_raised.b3d",
		tiles = sstair.tex,
		bounding_boxes = banister_bboxes,
		prevent_placement_check = true
	})]]
end
