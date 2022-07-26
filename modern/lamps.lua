local silvered_lamp_recipe

if minetest.get_modpath("moreores") then
	silvered_lamp_recipe = {
		recipe = {
			{"moreores:silver_ingot", "multidecor:bulb", "moreores:silver_ingot"},
			{"moreores:silver_ingot", "multidecor:lampshade", "moreores:silver_ingot"},
			{"", "", ""}
		}
	}
end


register.register_light("silvered_desk_lamp_off", {
	style = "modern",
	material = "metal",
	description = "Silvered Desk Lamp",
	use_texture_alpha = "blend",
	mesh = "multidecor_silvered_desk_lamp.b3d",
	tiles = {"multidecor_silver_material.png", "multidecor_silvered_lampshade.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
},
{
	swap_light = {
		name = "silvered_desk_lamp_on",
		light_level = 10
	}
}, silvered_lamp_recipe)

register.register_light("copper_wall_sconce_off", {
	style = "modern",
	material = "glass",
	description = "Copper Wall Sconce",
	paramtype2 = "wallmounted",
	mesh = "multidecor_copper_wall_sconce.b3d",
	tiles = {"multidecor_copper_material.png", "multidecor_bulb_surf.png"},
	bounding_boxes = {{-0.2, 0, 0.3, 0.2, 0.4, 0.5}},
},
{
	swap_light = {
		name = "copper_wall_sconce_on"
	}
},
{
	recipe = {
		{"default:copper_ingot", "multidecor:bulb", ""},
		{"default:copper_ingot", "", ""},
		{"", "", ""}
	}
})

register.register_light("plastic_desk_lamp_off", {
	style = "modern",
	material = "plastic",
	description = "Plastic Desk Lamp",
	use_texture_alpha = "blend",
	mesh = "multidecor_plastic_desk_lamp.b3d",
	tiles = {"multidecor_plastic_material.png", "multidecor_plastic_desk_lampshade.png"},
	bounding_boxes = {{-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},
},
{
	swap_light = {
		name = "plastic_desk_lamp_on",
		light_level = 10
	}
},
{
	recipe = {
		{"multidecor:plastic_sheet", "multidecor:lampshade", "multidecor:plastic_sheet"},
		{"multidecor:plastic_sheet", "multidecor:bulb", "multidecor:plastic_sheet"},
		{"", "multidecor:plastic_sheet", ""}
	}
})
