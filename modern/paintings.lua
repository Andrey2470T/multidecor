local frame_types = {
	"quadratic",
	"ext_quadratic",
	"round",
	"embossed_quadratic",
	"embossed_ext_quadratic",
	"embossed_ext_quadratic2",
	"ext_quadratic2"
}

local materials = {"wood", "plastic"}

local dyes = {
	"black",
	"blue",
	"brown",
	"cyan",
	"dark_green",
	"dark_grey",
	"green",
	"grey",
	"magenta",
	"orange",
	"pink",
	"red",
	"violet",
	"white",
	"yellow"
}

local bbox = {-0.5, -0.5, 0.35, 0.5, 0.5, 0.5}

local images = {
	--{<image_name>, <frame_types_i>, <materials_i>, <size>}
	{"alps", 1, 1, 1, {4, 5, 8, 14, 6}},
	{"cactus_valley", 1, 2, 1, {3, 7, 14, 15, 11}},
	{"cefeus", 1, 2, 1, {1, 14, 8, 13}},
	{"chamomile", 4, 1, 1, {7, 14, 15, 10}},
	{"dark_forest", 2, 1, 1, {1, 2, 13, 5, 4}},
	{"elk", 1, 2, 1, {15, 7, 3, 14}},
	{"forest", 4, 1, 1, {15, 3, 7, 14}},
	{"fruits_vase", 1, 1, 2, {2, 6, 12, 11, 7, 8}},
	{"jupiter_and_saturn", 2, 2, 2, {1, 3, 12, 11, 15}},
	{"minetest_castle", 5, 1, 1, {4, 14, 8, 3, 2}},
	{"minetest_cathedral", 7, 1, 1, {4, 14, 15, 8, 3}},
	{"minetest_logo", 1, 2, 1, {2, 5, 14, 15, 4}},
	{"prairie", 1, 1, 1, {15, 4, 14, 2}},
	{"rose", 4, 1, 1, {12, 5, 11, 7}},
	{"ship_in_lava", 4, 1, 2, {1, 12, 10, 15, 2}},
	{"sky", 3, 2, 1, {4, 14, 12, 15, 7}},
	{"sunset_in_sea", 6, 1, 1, {14, 15, 2, 13}},
	{"supernova", 3, 1, 2, {1, 11, 14, 13}},
	{"tropic", 2, 2, 1, {4, 2, 7, 5, 14}},
	{"physical_world_map", 2, 2, 2, {4, 14, 7, 15}}
}

local function painting_craft_recipe(inds)
	local recipe = {
		{"", "", ""},
		{"", "multidecor:painting_frame", ""},
		{"", "", ""}
	}

	local c = 0
	local n = 0
	for i, dye_i in ipairs(inds) do
		n = n + 1
		if i == 5 then
			n = n+1
			c = c+1
		end

		if c == 3 then
			c = 0
		end

		c = c + 1
		recipe[math.ceil(n/3)][c] = "dye:" .. dyes[dye_i]
	end

	return recipe
end

for _, img in ipairs(images) do
	local img_bbox = table.copy(bbox)

	local ftype = frame_types[img[2]]
	if ftype == "ext_quadratic" or ftype == "round" or ftype == "embossed_ext_quadratic" then
		img_bbox[4] = img_bbox[4] + 1
	elseif ftype == "ext_quadratic2" or ftype == "embossed_ext_quadratic2" then
		img_bbox[5] = img_bbox[5] + 1
	end

	img_bbox[4] = (img_bbox[4]+0.5) * img[4] - 0.5
	img_bbox[5] = (img_bbox[5]+0.5) * img[4] - 0.5

	local mat = materials[img[3]]
	local base_tile = "multidecor_" .. mat

	if mat == "plastic" then
		base_tile = base_tile .. "_material.png^[multiply:dimgray"
	else
		base_tile = base_tile .. ".png"
	end

	local mesh = ftype .. "_painting"
	mesh = img[4] > 1 and "upscaled_" .. mesh or mesh

	local name = mesh .. "_" .. img[1]
	multidecor.register.register_furniture_unit(name, {
		type = "decoration",
		style = "modern",
		material = mat,
		description = modern.S(multidecor.helpers.upper_first_letters(name)),
		mesh = "multidecor_" .. mesh .. ".b3d",
		tiles = {base_tile, "multidecor_image_" .. img[1] .. ".png"},
		bounding_boxes = {img_bbox}
	},
	{
		recipe = painting_craft_recipe(img[5])
	})
end


minetest.register_craftitem(":multidecor:painting_frame", {
	description = modern.S("Painting Frame"),
	inventory_image = "multidecor_painting_frame.png"
})

minetest.register_craft({
	output = "multidecor:painting_frame",
	recipe = {
		{"default:paper", "multidecor:plank", "multidecor:saw"},
		{"", "", ""},
		{"", "", ""}
	},
	replacements = {{"multidecor:saw", "multidecor:saw"}}
})
