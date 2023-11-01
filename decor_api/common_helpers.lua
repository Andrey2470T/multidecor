multidecor.helpers = {}


-- Returns a direction of the node with 'pos' position
function multidecor.helpers.get_dir(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local dir = def.paramtype2 == "facedir" and vector.copy(minetest.facedir_to_dir(node.param2)) or
			def.paramtype2 == "wallmounted" and vector.copy(minetest.wallmounted_to_dir(node.param2))
	dir = dir*-1

	return dir
end

-- Rotates 'rel_pos' vertically relative to 'pos' of some node according to its facedir
function multidecor.helpers.rotate_to_node_dir(pos, rel_pos)
	local dir = multidecor.helpers.get_dir(pos)

	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	local rot_y = vector.dir_to_rotation(dir).y

	local new_rel_pos = vector.rotate_around_axis(rel_pos, vector.new(0, 1, 0), rot_y)

	return new_rel_pos
end

function multidecor.helpers.clamp(s, e, v)
	local start_v = s
	local end_v = e

	if s > e then
		start_v = e
		end_v = s
	end

	return v < start_v and start_v or v > end_v and end_v or v
end

function multidecor.helpers.upper_first_letters(s)
	local new_s = ""

	for substr in s:gmatch("%a+") do
		new_s = new_s .. substr:sub(1, 1):upper() .. substr:sub(2) .. " "
	end

	return new_s
end

function multidecor.helpers.build_name_from_tmp(name, type, i, pos)
	local strpos = pos.x .. "_" .. pos.y .. "_" .. pos.z
	local res = name .. "_" .. i .. "_".. type .. "_" .. strpos

	if not name:match("multidecor:") then
		res = "multidecor:" .. res
	end

	return res
end

function table.copy_to(t1, t2)
	for _, val in ipairs(t1) do
		table.insert(t2, val)
	end
end
