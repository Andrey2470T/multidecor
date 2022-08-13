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

