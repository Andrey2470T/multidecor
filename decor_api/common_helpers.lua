multidecor.helpers = {}

hlpfuncs = multidecor.helpers

function multidecor.helpers.get_dir_from_param2(name, param2)
	local def = minetest.registered_nodes[name]

	local dir = vector.new(0, 0, 0)

	if def.paramtype2 == "facedir" then
		dir = minetest.facedir_to_dir(param2)
	elseif def.paramtype2 == "wallmounted" then
		dir = minetest.wallmounted_to_dir(param2)
	elseif def.paramtype2 == "colorfacedir" then
		dir = minetest.facedir_to_dir(param2 % 32)
	elseif def.paramtype2 == "colorwallmounted" then
		dir = minetest.wallmounted_to_dir(param2 % 8)
	end

	dir = dir*-1

	return dir
end

-- Returns a direction of the node with 'pos' position
function multidecor.helpers.get_dir(pos)
	local node = minetest.get_node(pos)

	return hlpfuncs.get_dir_from_param2(node.name, node.param2)
end

function multidecor.helpers.from_dir_get_param2(name, old_param2, dir)
	local param2 = minetest.dir_to_facedir(dir)

	local def = minetest.registered_nodes[name]

	if def.paramtype2 == "colorfacedir" then
		local palette_index = math.floor(old_param2 / 32)
		param2 = param2 + palette_index * 32
	end

	return param2
end

-- Returns a node def of the node at 'pos'
function multidecor.helpers.ndef(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name]
end

-- Rotates vertically 'pos' around (0, 1, 0) axis at 'angle'.
function multidecor.helpers.rot(pos, angle)
	return vector.rotate_around_axis(pos, vector.new(0, 1, 0), angle)
end

-- Rotates vertically 'pos' according to 'dir'
function multidecor.helpers.rotate_to_dir(pos, dir)
	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	local rot_y = vector.dir_to_rotation(dir).y

	return hlpfuncs.rot(pos, rot_y)
end

-- Rotates vertically 'rel_pos' which is relative to 'pos' of some node according to its param2 direction
function multidecor.helpers.rotate_to_node_dir(pos, rel_pos)
	local dir = hlpfuncs.get_dir(pos)

	return hlpfuncs.rotate_to_dir(rel_pos, dir)
end

-- Returns rotated 'bbox' bounding box (collision or selection) corresponding to 'dir'
function multidecor.helpers.rotate_bbox(bbox, dir)
	local box = {
		min = {x=bbox[1], y=bbox[2], z=bbox[3]},
		max = {x=bbox[4], y=bbox[5], z=bbox[6]}
	}

	box.min = hlpfuncs.rotate_to_dir(box.min, dir)
	box.max = hlpfuncs.rotate_to_dir(box.max, dir)

	local new_bbox = {
		box.min.x, box.min.y, box.min.z,
		box.max.x, box.max.y, box.max.z
	}

	return new_bbox
end

-- Swaps two values if a > b
function multidecor.helpers.swap(a, b, criteria)
	if criteria == true or criteria == nil then
		return b, a
	else
		return a, b
	end
end

-- Limits the 'v' value at the range [s, e]. If 'v' < 's', returns 's', 'v' > 'e', returns 'e'
function multidecor.helpers.clamp(s, e, v)
	local start_v, end_v = hlpfuncs.swap(s, e, s > e)

	return v < start_v and start_v or v > end_v and end_v or v
end

-- Makes the first letters of each word uppercase in 's' string
function multidecor.helpers.upper_first_letters(s)
	local new_s = ""

	for substr in s:gmatch("%a+") do
		new_s = new_s .. substr:sub(1, 1):upper() .. substr:sub(2) .. " "
	end

	return new_s
end

-- Builds a inv/list/fs name in the template 'multidecor:<name>_<i>_<type>_<strpos>'
function multidecor.helpers.build_name_from_tmp(name, type, i, pos)
	local strpos = pos.x .. "_" .. pos.y .. "_" .. pos.z
	local res = name .. "_" .. i .. "_".. type .. "_" .. strpos

	if not name:match("multidecor:") then
		res = "multidecor:" .. res
	end

	return res
end

-- Copies all elements from 't1' array inserting them in 't2'
function table.copy_to(t1, t2)
	for _, val in ipairs(t1) do
		table.insert(t2, val)
	end
end
