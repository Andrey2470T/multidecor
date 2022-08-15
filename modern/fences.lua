register.register_hedge("dark_rusty_fence", {
	style = "modern",
	material = "metal",
	visual_scale = 0.5,
	description = "Dark Rusty Fence",
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
	}
},
{
	recipe = {
		{"multidecor:metal_bar", "dye:black", "multidecor:metal_bar"},
		{"", "multidecor:chainlink", ""},
		{"multidecor:metal_bar", "", "multidecor:metal_bar"}
	}
})

register.register_hedge("high_dark_rusty_fence", {
	style = "modern",
	material = "metal",
	visual_scale = 0.5,
	description = "High Dark Rusty Fence",
	mesh = "multidecor_high_dark_rusty_fence.b3d",
	tiles = {
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_fence_chainlink.png",
		"multidecor_wood.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 0.5, 1.5, -0.3}
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
