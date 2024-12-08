multidecor.register.register_hedge("dark_rusty_fence", {
	style = "modern",
	material = "metal",
	description = modern.S("Dark Rusty Fence"),
	mesh = "multidecor_dark_rusty_fence.b3d",
	tiles = {
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_fence_chainlink.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	}
},
{
	common_name = "dark_rusty_fence",
	connect_parts = {
		["left_side"] = "multidecor_dark_rusty_fence_2.b3d",
		["right_side"] = "multidecor_dark_rusty_fence_1.b3d",
		["middle"] = "multidecor_dark_rusty_fence_3.b3d",
		["corner"] = "multidecor_dark_rusty_fence_4.b3d"
	},
	corner_bounding_boxes = {
		{-0.5, -0.5, 0.4, 0.5, 0.5, 0.5},
		{-0.5, -0.5, -0.5, -0.4, 0.5, 0.4}
	}
},
{
	recipe = {
		{"multidecor:metal_bar", "dye:black", "multidecor:metal_bar"},
		{"", "multidecor:chainlink", ""},
		{"multidecor:metal_bar", "", "multidecor:metal_bar"}
	}
})

multidecor.register.register_hedge("high_dark_rusty_fence", {
	style = "modern",
	material = "metal",
	description = modern.S("High Dark Rusty Fence"),
	mesh = "multidecor_high_dark_rusty_fence.b3d",
	tiles = {
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_fence_chainlink.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}
	}
},
{
	common_name = "high_dark_rusty_fence",
	double = {
		mutable_bounding_box_indices = {1},
		description = "High Dark Rusty Fence (extended)",
		mesh = "multidecor_high_ext_dark_rusty_fence.b3d"
	}
},
{
	type = "shapeless",
	recipe = {"multidecor:dark_rusty_fence", "multidecor:dark_rusty_fence"}
})

multidecor.register.register_furniture_unit("slatted_wooden_fence", {
	type = "decoration",
	style = "modern",
	material = "wood",
	description = modern.S("Slatted Wooden Fence"),
	use_texture_alpha = "blend",
	mesh = "multidecor_slatted_wooden_fence.b3d",
	tiles = {"multidecor_wood.png^multidecor_fence_nail_knob.png"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4}}
},
{
	recipe = {
		{"multidecor:plank", "multidecor:plank", ""},
		{"multidecor:plank", "multidecor:metal_bar", ""},
		{"multidecor:plank", "multidecor:steel_scissors", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("high_slatted_wooden_fence", {
	type = "decoration",
	style = "modern",
	material = "wood",
	description = modern.S("High Slatted Wooden Fence"),
	use_texture_alpha = "blend",
	mesh = "multidecor_high_slatted_wooden_fence.b3d",
	tiles = {"multidecor_wood.png^multidecor_fence_nail_knob2.png"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	type = "shapeless",
	recipe = {"multidecor:slatted_wooden_fence", "multidecor:slatted_wooden_fence"}
})

multidecor.register.register_furniture_unit("corrugated_fence", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("Corrugated Fence"),
	mesh = "multidecor_corrugated_fence.b3d",
	tiles = {"multidecor_plastic_material.png^[multiply:darkgreen"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4}}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:steel_sheet", "multidecor:steel_sheet"},
		{"multidecor:steel_scissors", "dye:dark_green", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_furniture_unit("high_corrugated_fence", {
	type = "decoration",
	style = "modern",
	material = "metal",
	description = modern.S("High Corrugated Fence"),
	mesh = "multidecor_high_corrugated_fence.b3d",
	tiles = {"multidecor_plastic_material.png^[multiply:darkgreen"},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	type = "shapeless",
	recipe = {"multidecor:corrugated_fence", "multidecor:corrugated_fence"}
})
