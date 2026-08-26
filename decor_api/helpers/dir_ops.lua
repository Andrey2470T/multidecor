-- Direction op functions
--------------------------------------------------------------

local dir_ops = {}

function dir_ops.get_dir_from_param2(name, param2)
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
function dir_ops.get_dir(pos)
	local node = core.get_node(pos)
	return dir_ops.get_dir_from_param2(node.name, node.param2)
end

function dir_ops.from_dir_get_param2(name, old_param2, dir)
	local param2 = core.dir_to_facedir(dir)

	local def = core.registered_nodes[name]

	if def.paramtype2 == "colorfacedir" then
		local palette_index = math.floor(old_param2 / 32)
		param2 = param2 + palette_index * 32
	end

	return param2
end

-- Gets the yaw rotation of 'dir'
function dir_ops.get_rot_y(dir)
	return vector.dir_to_rotation(dir).y
end

-- Rotates vertically 'pos' around (0, 1, 0) axis at 'angle'.
function dir_ops.rotate_y(pos, angle)
	return vector.rotate_around_axis(pos, vector.new(0, 1, 0), angle)
end

-- Rotates vertically 'pos' according to 'dir'
function dir_ops.rotate_to_dir(pos, dir)
	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	return dir_ops.rotate_y(pos, dir_ops.get_rot_y(dir))
end

-- Rotates vertically 'rel_pos' which is relative to 'pos' of some node according to its param2 direction
function dir_ops.rotate_to_node_dir(pos, rel_pos)
	local dir = dir_ops.get_dir(pos)
	return dir_ops.rotate_to_dir(rel_pos, dir)
end

return dir_ops




