gfx.register_material("md_marble", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_marble_material_normal.png",
		"multidecor_marble_material_roughness.png",
		"multidecor_marble_material_metallic.png",
		"multidecor_marble_material_ao.png"
	}
})

gfx.register_material("md_metal", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_metal_material_normal.png",
		"multidecor_metal_material_roughness.png",
		"multidecor_metal_material_metallic.png",
		"multidecor_metal_material_ao.png"
	}
})

gfx.register_material("md_coarse_metal", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_coarse_metal_material_normal.png",
		"multidecor_coarse_metal_material_roughness.png",
		"multidecor_coarse_metal_material_metallic.png",
		"multidecor_coarse_metal_material_ao.png"
	}
})

gfx.register_material("md_aspen", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_aspen_wood_normal.png",
		"multidecor_aspen_wood_roughness.png",
		"multidecor_aspen_wood_metallic.png",
		"multidecor_aspen_wood_ao.png"
	}
})

gfx.register_material("md_gloss", {
	blend = {enable=true, mode="subtract"},
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_gloss_normal.png",
		"multidecor_gloss_roughness.png",
		"multidecor_gloss_metallic.png",
		"multidecor_gloss_ao.png"
	}
})

gfx.register_material("md_bathroom_ceramic_darksea_tile", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_bathroom_ceramic_darksea_tile_normal.png",
		"multidecor_bathroom_ceramic_darksea_tile_roughness.png",
		"multidecor_bathroom_ceramic_darksea_tile_metallic.png",
		"multidecor_bathroom_ceramic_darksea_tile_ao.png"
	}
})

gfx.register_material("md_bathroom_ceramic_darksea_patterned_tile", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_bathroom_ceramic_darksea_patterned_tile_normal.png",
		"multidecor_bathroom_ceramic_darksea_patterned_tile_roughness.png",
		"multidecor_bathroom_ceramic_darksea_patterned_tile_metallic.png",
		"multidecor_bathroom_ceramic_darksea_patterned_tile_ao.png"
	}
})

gfx.register_material("md_wood", {
	shader = {
		vertex = "normal.vsh",
		geometry = "normal.gsh",
		fragment = "steel.fsh",
		vertex_type = "vertex3dext",
		apply_shadows = true
	},
	samplers = {
		"multidecor_wood_normal.png",
		"multidecor_wood_roughness.png",
		"multidecor_wood_metallic.png",
		"multidecor_wood_ao.png"
	}
})
