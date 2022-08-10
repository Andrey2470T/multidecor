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
})
