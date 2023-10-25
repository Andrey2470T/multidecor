multidecor.register.register_door("high_dark_rusty_gate", {
	style = "modern",
	material = "metal",
	description = "High Dark Rusty Gate",
	mesh = "multidecor_high_dark_rusty_gate.b3d",
	tiles = {
		"multidecor_fence_chainlink.png",
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_wood.png",
		"multidecor_metal_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		mesh_open = "multidecor_high_dark_rusty_gate_open.b3d",
		mesh_activated = "multidecor_high_dark_rusty_gate_activated.b3d",
		vel = 90, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:high_dark_rusty_fence", "multidecor:steel_sheet", "multidecor:steel_sheet"},
		{"multidecor:steel_scissors", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_door("dark_rusty_gate", {
	style = "modern",
	material = "metal",
	description = "Dark Rusty Gate",
	mesh = "multidecor_dark_rusty_gate.b3d",
	tiles = {
		"multidecor_fence_chainlink.png",
		"multidecor_dark_metal_rusty_fence.png",
		"multidecor_wood.png",
		"multidecor_metal_material.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4}}
},
{
	door = {
		mesh_open = "multidecor_dark_rusty_gate_open.b3d",
		mesh_activated = "multidecor_dark_rusty_gate_activated.b3d",
		vel = 90, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	type = "shapeless",
	recipe = {"multidecor:high_dark_rusty_gate", "multidecor:high_dark_rusty_gate"}
})

multidecor.register.register_door("wooden_door", {
	style = "modern",
	material = "wood",
	description = "Wooden Door",
	mesh = "multidecor_modern_wooden_door.b3d",
	tiles = {
		"multidecor_modern_wooden_door_base.png",
		"multidecor_jungle_wood.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
},
{
	door = {
		mesh_open = "multidecor_modern_wooden_door_open.b3d",
		mesh_activated = "multidecor_modern_wooden_door_activated.b3d",
		vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:board", "multidecor:plank", "multidecor:steel_sheet"},
		{"multidecor:board", "multidecor:plank", "multidecor:steel_scissors"},
		{"", "", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_door("bathroom_door", {
	style = "modern",
	material = "wood",
	description = "Bathroom Door",
	mesh = "multidecor_bathroom_door.b3d",
	tiles = {
		"multidecor_white_pine_wood.png",
		"multidecor_pine_wood2.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.35}}
},
{
	door = {
		mesh_open = "multidecor_bathroom_door_open.b3d",
		mesh_activated = "multidecor_bathroom_door_activated.b3d",
		vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:pine_board", "multidecor:pine_plank", "multidecor:pine_plank"},
		{"multidecor:pine_board", "dye:white", "multidecor:saw"},
		{"", "", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
})

multidecor.register.register_door("pine_glass_door", {
	style = "modern",
	material = "wood",
	description = "Pine Glass Door",
	mesh = "multidecor_pine_glass_door.b3d",
	tiles = {
		"multidecor_pine_glass_door_base.png",
		"multidecor_metal_material.png",
		"multidecor_glass_material.png"
	},
	use_texture_alpha = "blend",
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		mesh_open = "multidecor_pine_glass_door_open.b3d",
		mesh_activated = "multidecor_pine_glass_door_activated.b3d",
		vel = 100, -- degrees per sec
		sounds = {
			open = "multidecor_wooden_door_open",
			close = "multidecor_wooden_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:pine_board", "xpanes:pane_flat", "multidecor:pine_plank"},
		{"multidecor:pine_board", "xpanes:pane_flat", "multidecor:pine_plank"},
		{"multidecor:steel_sheet", "multidecor:steel_scissors", ""}
	},
	replacements = {{"multidecor:steel_scissors", "multidecor:steel_scissors"}}
})

multidecor.register.register_door("technical_door", {
	style = "modern",
	material = "metal",
	description = "Technical Door",
	mesh = "multidecor_technical_door.b3d",
	use_texture_alpha = "blend",
	tiles = {
		"multidecor_metal_material2.png",
		"multidecor_metal_material.png",
		"multidecor_metal_door_chainlink.png"
	},
	bounding_boxes = {{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}}
},
{
	door = {
		mesh_open = "multidecor_technical_door_open.b3d",
		mesh_activated = "multidecor_technical_door_activated.b3d",
		vel = 80, -- degrees per sec
		sounds = {
			open = "multidecor_metallic_door_open",
			close = "multidecor_metallic_door_close"
		}
	}
},
{
	recipe = {
		{"multidecor:steel_sheet", "multidecor:chainlink", "multidecor:steel_scissors"},
		{"multidecor:steel_sheet", "multidecor:steel_sheet", ""},
		{"multidecor:steel_sheet", "multidecor:steel_sheet", ""}
	}
})
