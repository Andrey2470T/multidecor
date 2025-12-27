multidecor.placement = {}

function multidecor.placement.is_free_space(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]

	return def.drawtype == "airlike"
end

function multidecor.placement.check_for_free_space(pos, size_bbox)
	local free = true

	for x = size_bbox[1], size_bbox[4] do
		for y = size_bbox[2], size_bbox[5] do
			for z = size_bbox[3], size_bbox[6] do
				local shift_pos = pos + vector.new(x, y, z)

				if not vector.equals(pos, shift_pos) then
					if not multidecor.placement.is_free_space(shift_pos) then
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

function multidecor.placement.box_repair(box)
	local rep_box = table.copy(box)

	if rep_box[1] > rep_box[4] then
		local x = rep_box[1]
		rep_box[1] = rep_box[4]
		rep_box[4] = x
	end

	if rep_box[2] > rep_box[5] then
		local y = rep_box[2]
		rep_box[2] = rep_box[5]
		rep_box[5] = y
	end

	if rep_box[3] > rep_box[6] then
		local z = rep_box[3]
		rep_box[3] = rep_box[6]
		rep_box[6] = z
	end

	return rep_box
end

function multidecor.placement.calc_place_space_size(bboxes)
	local max_bbox = {0, 0, 0, 0, 0, 0}

	for box_id, _ in ipairs(bboxes) do
		local new_box = multidecor.placement.box_repair(bboxes[box_id])

		for i, v in ipairs(new_box) do
			if i < 4 then
				max_bbox[i] = box_id == 1 and v or math.min(max_bbox[i], v)
			else
				max_bbox[i] = math.max(max_bbox[i], v)
			end
		end
	end

	for i, coord in ipairs(max_bbox) do
		local int, frac = math.modf(coord)
		local sgn = math.sign(coord)
		max_bbox[i] = math.abs(frac) > 0.5 and sgn*math.ceil(math.abs(coord)) or sgn*math.floor(math.abs(coord))
	end

	return max_bbox
end

function multidecor.placement.check_for_placement(pos, name)
	local def = minetest.registered_nodes[name]

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

	local max_bbox = multidecor.placement.calc_place_space_size(bboxes)

	local rot_bbox = {}
	rot_bbox.min = multidecor.helpers.rotate_to_node_dir(pos,
		vector.rotate_around_axis(vector.new(max_bbox[1], max_bbox[2], max_bbox[3]), vector.new(0, 1, 0), math.pi)
	)
	rot_bbox.max = multidecor.helpers.rotate_to_node_dir(pos,
		vector.rotate_around_axis(vector.new(max_bbox[4], max_bbox[5], max_bbox[6]), vector.new(0, 1, 0), math.pi)
	)

	max_bbox = multidecor.placement.box_repair({
		rot_bbox.min.x, rot_bbox.min.y, rot_bbox.min.z,
		rot_bbox.max.x, rot_bbox.max.y, rot_bbox.max.z
	})

	return multidecor.placement.check_for_free_space(pos, max_bbox)
end
