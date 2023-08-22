local bathtub_def = {{
	style = "modern",
	material = "stone",
	description = "Bathtub",
	visual_scale = 0.5,
	mesh = "multidecor_bathtub.b3d",
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_bathroom_leakage.png",
		"multidecor_coarse_metal_material.png"
	},
	bounding_boxes = {
		{-0.5, -0.5, -0.5, 1.5, -0.1, 0.5},
		{-0.5, -0.1, -0.35, -0.35, 0.5, 0.35},
		{1.35, -0.1, -0.35, 1.5, 0.5, 0.35},
		{-0.5, -0.1, -0.5, 1.5, 0.5, -0.35},
		{-0.5, -0.1, 0.35, 1.5, 0.5, 0.5}
	}
},
{
	seat_data = {
		pos = {x=0.8, y=0.2, z=0.0},
		rot = {x=0, y=0, z=0},
		model = multidecor.sitting.standard_model,
		anims = {"sit1", "sit2"}
	}
}}

multidecor.register.register_seat("bathtub", bathtub_def[1], bathtub_def[2])

local ceramic_tiles = {
	"darkceladon",
	"darksea",
	"light",
	"sand",
	"red",
	"green_mosaic"
}

for _, tile in ipairs(ceramic_tiles) do
	local name = "bathroom_ceramic_" .. tile .. "_tile"
	local tex_name = "multidecor_" .. name .. ".png"
	local upper_tile = multidecor.helpers.upper_first_letters(tile)
	minetest.register_node(":multidecor:" .. name, {
		description = "Bathroom Ceramic " .. upper_tile .. " Tile",
		visual_scale = 0.5,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {tex_name},
		groups = {cracky=1.5},
		sounds = default.node_sound_stone_defaults()
	})
	
	local bathtub_with_shields_def = table.copy(bathtub_def)
	bathtub_with_shields_def[1].description = "Bathtub With " .. upper_tile .. " Shields"
	bathtub_with_shields_def[1].mesh = "multidecor_bathtub_with_shields.b3d"
	table.insert(bathtub_with_shields_def[1].tiles, tex_name)
	
	multidecor.register.register_seat("bathtub_with_shields_" .. tile, bathtub_with_shields_def[1], bathtub_with_shields_def[2])
	
end

multidecor.register.register_furniture_unit("bathroom_fluffy_rug", {
	type = "decoration",
	style = "modern",
	material = "plastic",
	visual_scale = 0.5,
	description = "Bathroom Fluffy Rug",
	mesh = "multidecor_bathroom_fluffy_rug.b3d",
	tiles = {
		"multidecor_fluff_material.png"
	},
	bounding_boxes = {{-0.4, -0.5, -0.3, 0.4, -0.35, 0.3}}
})

multidecor.register.register_furniture_unit("bathroom_sink", {
	type = "decoration",
	style = "modern",
	material = "stone",
	visual_scale = 0.5,
	description = "Bathroom Sink",
	mesh = "multidecor_bathroom_sink.b3d",
	tiles = {
		"multidecor_marble_material.png",
		"multidecor_metal_material.png",
		"multidecor_coarse_metal_material.png",
		"multidecor_bathroom_leakage.png"
	},
	bounding_boxes = {{-0.5, -0.4, -0.4, 0.5, 0.5, 0.5}}
})
