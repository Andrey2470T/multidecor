local frame_types = {
	"quadratic",
	"ext_quadratic",
	"round",
	"embossed_quadratic",
	"embossed_ext_quadratic",
	"embossed_ext_quadratic2"
}

local materials = {"wood", "plastic"}

local bbox = {-0.5, -0.5, 0.35, 0.5, 0.5, 0.5}

local images = {
	--{<image_name>, <frame_types_i>, <materials_i>, <size>}
	{"alps", 1, 1, 1},
	{"cactus_valley", 1, 2, 1},
	{"cefeus", 1, 2, 1},
	{"chamomile", 4, 1, 1},
	{"dark_forest", 2, 1, 1},
	{"elk", 1, 2, 1},
	{"forest", 4, 1, 1},
	{"jupiter_and_saturn", 2, 2, 2},
	{"minetest_castle", 5, 1, 1},
	{"minetest_logo", 1, 2, 1},
	{"prairie", 1, 1, 1},
	{"rose", 4, 1, 1},
	{"ship_in_lava", 4, 1, 2},
	{"sky", 3, 2, 1},
	{"sunset_in_sea", 6, 1, 1},
	{"supernova", 3, 1, 2},
	{"tropic", 2, 2, 1}
}


for _, img in ipairs(images) do
	local img_bbox = table.copy(bbox)

	local ftype = frame_types[img[2]]
	if ftype == "ext_quadratic" or ftype == "round" or ftype == "embossed_ext_quadratic" then
		img_bbox[4] = img_bbox[4] + 1
	elseif ftype == "embossed_ext_quadratic2" then
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
	register.register_furniture_unit(name, {
		type = "decoration",
		style = "modern",
		material = mat,
		visual_scale = 0.5,
		description = helpers.upper_first_letters(name),
		mesh = "multidecor_" .. mesh .. ".b3d",
		tiles = {base_tile, "multidecor_image_" .. img[1] .. ".png"},
		bounding_boxes = {img_bbox}
	})
end
