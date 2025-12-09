multidecor.placement = multidecor.placement or {}
local placement = multidecor.placement
local hlpfuncs = multidecor.helpers

local function node_def_at(pos)
	local node = minetest.get_node(pos)
	return node and minetest.registered_nodes[node.name]
end

local function snap_coord(coord)
	local abs_value = math.abs(coord)
	local int = math.floor(abs_value)
	local frac = abs_value - int

	if frac > 0.5 then
		abs_value = math.ceil(abs_value)
	else
		abs_value = int
	end

	return coord < 0 and -abs_value or abs_value
end

local function ensure_box(box)
	if not box then
		return {}
	end

	if type(box[1]) == "number" then
		return {table.copy(box)}
	end

	local result = {}
	for _, sub_box in ipairs(box) do
		result[#result + 1] = table.copy(sub_box)
	end

	return result
end

function placement.is_free_space(pos)
	local def = node_def_at(pos)
	return def and def.drawtype == "airlike"
end

function placement.check_for_free_space(pos, bbox)
	for x = bbox[1], bbox[4] do
		for y = bbox[2], bbox[5] do
			for z = bbox[3], bbox[6] do
				local shift_pos = vector.new(pos.x + x, pos.y + y, pos.z + z)
				if not vector.equals(pos, shift_pos) and not placement.is_free_space(shift_pos) then
					return false
				end
			end
		end
	end

	return true
end

function placement.box_repair(box)
	local repaired = table.copy(box)

	if repaired[1] > repaired[4] then
		repaired[1], repaired[4] = repaired[4], repaired[1]
	end

	if repaired[2] > repaired[5] then
		repaired[2], repaired[5] = repaired[5], repaired[2]
	end

	if repaired[3] > repaired[6] then
		repaired[3], repaired[6] = repaired[6], repaired[3]
	end

	return repaired
end

function placement.calc_place_space_size(bboxes)
	local list = ensure_box(bboxes)
	if #list == 0 then
		return {0, 0, 0, 0, 0, 0}
	end

	local min_x, min_y, min_z = math.huge, math.huge, math.huge
	local max_x, max_y, max_z = -math.huge, -math.huge, -math.huge

	for _, box in ipairs(list) do
		local repaired = placement.box_repair(box)
		min_x = math.min(min_x, repaired[1])
		min_y = math.min(min_y, repaired[2])
		min_z = math.min(min_z, repaired[3])
		max_x = math.max(max_x, repaired[4])
		max_y = math.max(max_y, repaired[5])
		max_z = math.max(max_z, repaired[6])
	end

	return {
		snap_coord(min_x),
		snap_coord(min_y),
		snap_coord(min_z),
		snap_coord(max_x),
		snap_coord(max_y),
		snap_coord(max_z)
	}
end

local function rotate_bbox(pos, bbox)
	local min_vec = hlpfuncs.rotate_to_node_dir(pos, vector.rotate_around_axis(vector.new(bbox[1], bbox[2], bbox[3]), vector.new(0, 1, 0), math.pi))
	local max_vec = hlpfuncs.rotate_to_node_dir(pos, vector.rotate_around_axis(vector.new(bbox[4], bbox[5], bbox[6]), vector.new(0, 1, 0), math.pi))

	return placement.box_repair({min_vec.x, min_vec.y, min_vec.z, max_vec.x, max_vec.y, max_vec.z})
end

function placement.check_for_placement(pos, name)
	local def = minetest.registered_nodes[name]
	if not def then
		return true
	end

	if def.prevent_placement_check then
		return true
	end

	local drawtype = def.drawtype
	if drawtype ~= "mesh" and drawtype ~= "nodebox" then
		return true
	end

	local source = drawtype == "nodebox" and def.node_box and def.node_box.fixed or def.collision_box and def.collision_box.fixed
	if not source then
		return true
	end

	local max_bbox = placement.calc_place_space_size(source)
	local rotated = rotate_bbox(pos, max_bbox)

	return placement.check_for_free_space(pos, rotated)
end
