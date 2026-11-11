-- Direction op functions
--------------------------------------------------------------

require("decor_api.helpers.common")

local dir_ops = {}

-- Basic direction vectors
function dir_ops.up() return vector.new(0, 1, 0) end
function dir_ops.down() return vector.new(0, -1, 0) end
function dir_ops.left() return vector.new(-1, 0, 0) end
function dir_ops.right() return vector.new(1, 0, 0) end
function dir_ops.forward() return vector.new(0, 0, 1) end
function dir_ops.back() return vector.new(0, 0, -1) end

-- Returns the direction vector pointing away from the player
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

	return dir
end

-- Returns the direction vector of the node at 'pos'
function dir_ops.get_dir(pos)
	local node = core.get_node(pos)
	return dir_ops.get_dir_from_param2(node.name, node.param2)
end

-- Returns the param2 value of a node that is facing 'dir'
-- and having the same color index as in 'old_param2'
function dir_ops.from_dir_get_param2(name, old_param2, dir)
	local param2 = 0
	local def = core.registered_nodes[name]

	if def.paramtype2 == "facedir" then
		param2 = core.dir_to_facedir(dir)
	elseif def.paramtype2 == "wallmounted" then
		param2 = core.dir_to_wallmounted(dir)
	elseif def.paramtype2 == "colorfacedir" then
		local palette_index = math.floor(old_param2 / 32)
		param2 = core.dir_to_facedir(dir) + palette_index * 32
	elseif def.paramtype2 == "colorwallmounted" then
		local palette_index = math.floor(old_param2 / 8)
		param2 = core.dir_to_wallmounted(dir) + palette_index * 8
	end

	return param2
end

-- Returns the param2 of the node turned around the vertical axis by 'angle'
-- (keeps the palette index of the original 'param2')
function dir_ops.rotate_param2_y(name, param2, angle)
	local dir = dir_ops.rotate_y(dir_ops.get_dir_from_param2(name, param2), angle)
	return dir_ops.from_dir_get_param2(name, param2, dir)
end

function dir_ops.get_near_pos_from_dir(pos, dir)
	return pos + dir
end

function dir_ops.get_near_node_from_dir(pos, dir)
	local near_pos = dir_ops.get_near_pos_from_dir(pos, dir)
	return core.get_node_or_nil(near_pos)
end

-- Returns a new position from 'pos' that shifted by the direction
-- which either is the global dir or passed 'dir' rotated correspondingly to 'dir_name'
function dir_ops.get_near_pos(pos, dir_name, dir)
	local shift_dir = dir or vector.new()
	if dir_name == "up" then
		shift_dir = dir_ops.up()
	elseif dir_name == "down" then
		shift_dir = dir_ops.down()
	elseif dir_name == "left" then
		shift_dir = dir and vector.new(-dir.z, dir.y, dir.x) or dir_ops.left()
	elseif dir_name == "right" then
		shift_dir = dir and vector.new(dir.z, dir.y, -dir.x) or dir_ops.right()
	elseif dir_name == "forward" then
		shift_dir = dir and dir or dir_ops.forward()
	elseif dir_name == "backward" then
		shift_dir = dir and vector.new(-dir.x, dir.y, -dir.z) or dir_ops.back()
	end

	return dir_ops.get_near_pos_from_dir(pos, shift_dir)
end

function dir_ops.get_near_nodepos(pos, dir_name)
	return dir_ops.get_near_pos(pos, dir_name, dir_ops.get_dir(pos))
end

-- Returns the node nearby 'pos' that shifted by the direction
-- which either is the global dir or the dir of 'pos' node
function dir_ops.get_near_node(pos, dir_name)
	local near_pos = dir_ops.get_near_nodepos(pos, dir_name)
	return core.get_node_or_nil(near_pos)
	
end

-- Returns the name of the axis 'dir' points along ("x", "y" or "z")
function dir_ops.get_dominant_axis(dir)
	if dir.x ~= 0 then return "x"
	elseif dir.y ~= 0 then return "y"
	else return "z" end
end

-- Gets the yaw rotation of 'dir' in radians counting from +Z axis (0, 0, 1) in clockwise direction
function dir_ops.get_rot_y(dir)
	return vector.dir_to_rotation(dir).y
end

-- Rotates the vertically rotated 'pos' around (0, 1, 0) axis at 'angle'.
function dir_ops.rotate_y(pos, angle)
	return vector.rotate_around_axis(pos, dir_ops.up(), angle)
end

-- Rotates the vertically rotated 'pos' correspondingly to 'dir'
function dir_ops.rotate_to_dir(pos, dir)
	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	return dir_ops.rotate_y(pos, dir_ops.get_rot_y(dir))
end

-- Rotates the vertically rotated 'rel_pos' which is relative to 'pos' of some node or
-- returns the absolute position of the rotated 'rel_pos' if 'make_absolute' is true
function dir_ops.rotate_to_node_dir(pos, rel_pos, make_absolute, rel_rot)
	rel_rot = rel_rot or vector.zero()

	local dir = dir_ops.get_dir(pos)
	local rotated_rel_pos = dir_ops.rotate_to_dir(rel_pos, dir)
	local dir_rot = dir_ops.get_rot_y(dir)
	local res_pos = make_absolute and pos + rotated_rel_pos or rotated_rel_pos
	local res_rot = vector.new(rel_rot.x, dir_rot + rel_rot.y, rel_rot.z)

	return res_pos, res_rot
end

function dir_ops.rotate_box_to_node_dir(pos, box)
	local dir = dir_ops.get_dir(pos)
	box:rotate(dir)
	return box:get_coords()
end

return dir_ops
