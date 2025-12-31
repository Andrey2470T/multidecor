multidecor.helpers = {}

local hlpfuncs = multidecor.helpers

function hlpfuncs.get_dir_from_param2(name, param2)
	local def = core.registered_nodes[name]

	local dir = vector.new(0, 0, 0)

	if def.paramtype2 == "facedir" then
		dir = core.facedir_to_dir(param2)
	elseif def.paramtype2 == "wallmounted" then
		dir = core.wallmounted_to_dir(param2)
	elseif def.paramtype2 == "colorfacedir" then
		dir = core.facedir_to_dir(param2 % 32)
	elseif def.paramtype2 == "colorwallmounted" then
		dir = core.wallmounted_to_dir(param2 % 8)
	end

	dir = dir*-1

	return dir
end

-- Returns a direction of the node with 'pos' position
function hlpfuncs.get_dir(pos)
	local node = core.get_node(pos)
	return hlpfuncs.get_dir_from_param2(node.name, node.param2)
end

function hlpfuncs.from_dir_get_param2(name, old_param2, dir)
	local param2 = core.dir_to_facedir(dir)

	local def = core.registered_nodes[name]

	if def.paramtype2 == "colorfacedir" then
		local palette_index = math.floor(old_param2 / 32)
		param2 = param2 + palette_index * 32
	end

	return param2
end

-- Returns a node def of the node at 'pos'
function hlpfuncs.ndef(pos)
	return core.registered_nodes[core.get_node(pos).name]
end

-- Rotates vertically 'pos' around (0, 1, 0) axis at 'angle'.
function hlpfuncs.rot_y(pos, angle)
	return vector.rotate_around_axis(pos, vector.new(0, 1, 0), angle)
end

-- Rotates vertically 'pos' according to 'dir'
function hlpfuncs.rotate_to_dir(pos, dir)
	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	local rot_y = vector.dir_to_rotation(dir).y

	return hlpfuncs.rot_y(pos, rot_y)
end

-- Rotates vertically 'rel_pos' which is relative to 'pos' of some node according to its param2 direction
function hlpfuncs.rotate_to_node_dir(pos, rel_pos)
	local dir = hlpfuncs.get_dir(pos)

	return hlpfuncs.rotate_to_dir(rel_pos, dir)
end

-- Returns rotated 'bbox' bounding box (collision or selection) corresponding to 'dir'
function hlpfuncs.rotate_bbox(bbox, dir)
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
function hlpfuncs.swap(a, b, criteria)
	if criteria == true or criteria == nil then
		return b, a
	else
		return a, b
	end
end

-- Limits the 'v' value at the range [s, e]. If 'v' < 's', returns 's', 'v' > 'e', returns 'e'
function hlpfuncs.clamp(s, e, v)
	local start_v, end_v = hlpfuncs.swap(s, e, s > e)

	return v < start_v and start_v or v > end_v and end_v or v
end

-- Makes the first letters of each word uppercase in 's' string
function hlpfuncs.upper_first_letters(s)
	local new_s = ""

	for substr in s:gmatch("%a+") do
		new_s = new_s .. substr:sub(1, 1):upper() .. substr:sub(2) .. " "
	end

	return new_s
end

-- Builds a inv/list/fs name in the template 'multidecor:<name>_<i>_<type>_<strpos>'
function hlpfuncs.build_name_from_tmp(name, type, i, pos)
	local resname = ("%s_%d_%s_%d_%d_%d"):format(
		name, i, type, pos.x, pos.y, pos.z)

	if not name:match("multidecor:") then
		resname = "multidecor:" .. resname
	end

	return resname
end

-- Copies all elements from 't1' array inserting them in 't2'
function table.copy_to(t1, t2)
	for _, val in ipairs(t1) do
		table.insert(t2, val)
	end
end
