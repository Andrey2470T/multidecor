register.register_door("high_dark_rusty_gate", {
	style = "modern",
	material = "metal",
	visual_scale = 0.5,
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
		vel = 90 -- degrees per sec
	}
})

register.register_door("dark_rusty_gate", {
	style = "modern",
	material = "metal",
	visual_scale = 0.5,
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
		vel = 90 -- degrees per sec
	}
})
