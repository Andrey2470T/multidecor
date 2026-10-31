-- Placement checking
--------------------------------------------------------------

local common = require("decor_api.helpers.common")
local BBox = require("decor_api.helpers.box")
local dir_ops = require("decor_api.helpers.dir_ops")

local placement = {}

function placement.check_for_free_space(pos, size_bbox)
	local free = true

	for x = size_bbox[1], size_bbox[4] do
		for y = size_bbox[2], size_bbox[5] do
			for z = size_bbox[3], size_bbox[6] do
				local shift_pos = pos + vector.new(x, y, z)

				if not vector.equals(pos, shift_pos) then
					if not common.is_airlike(shift_pos) then
						free = false
						break
					end
				end
			end

			if not free then break end
		end

		if not free then break end
	end

	return free
end

-- Aggregates 'bboxes' ({x1, y1, z1, x2, y2, z2} arrays) into one BBox
-- covering them all
function placement.calc_place_space_size(bboxes)
	local max_bbox = BBox.from_default()

	for _, bbox in ipairs(bboxes) do
		max_bbox:extend_by(bbox)
	end

	return max_bbox
end

-- Rounds every coordinate of the plain {x1, ..., z2} array 'coords'
-- to the whole node position it reaches into
local function round_to_nodes(coords)
	for i, coord in ipairs(coords) do
		local _, frac = math.modf(coord)
		local sgn = math.sign(coord)
		coords[i] = math.abs(frac) > 0.5 and sgn*math.ceil(math.abs(coord)) or sgn*math.floor(math.abs(coord))
	end
end

function placement.check_for_placement(pos, name)
	local def = common.ndef(pos)

	if not def then
		core.log("error", "Node definition not found for: " .. name)
		return true
	end

	if def.drawtype ~= "mesh" and def.drawtype ~= "nodebox" then
		return true
	end

	if def.prevent_placement_check then
		return true
	end

	local bboxes

	if def.drawtype == "nodebox" then
		bboxes = def.node_box.fixed
	else
		bboxes = def.collision_box.fixed
	end

	local max_bbox = placement.calc_place_space_size(bboxes)
	local coords = dir_ops.rotate_box_to_node_dir(pos, max_bbox)
	round_to_nodes(coords)

	return placement.check_for_free_space(pos, coords)
end

return placement
