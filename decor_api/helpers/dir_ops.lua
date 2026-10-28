-- Direction op functions
--------------------------------------------------------------

require("decor_api.helpers.common")

local dir_ops = {}

-- Returns the engine-native direction of a node: where the placing player
-- was LOOKING (facedir family: the node model's +Z/back side points there)
-- or INTO the surface the node is mounted on (wallmounted family).
-- In both cases the vector points AWAY from the player; this is exactly what
-- core.facedir_to_dir/core.wallmounted_to_dir return and what
-- core.dir_to_facedir/core.dir_to_wallmounted expect back.
function dir_ops.get_look_dir_from_param2(name, param2)
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

-- Returns the engine-native (look) direction of the node at 'pos'
function dir_ops.get_look_dir(pos)
	local node = core.get_node(pos)
	return dir_ops.get_look_dir_from_param2(node.name, node.param2)
end

-- Returns the modpack direction of a node: the exact opposite of the look
-- direction — from the node TOWARD the player, i.e. the front, user-facing
-- side of the furniture. The whole modpack geometry (relative offsets rotated
-- with rotate_to_dir, entity yaws via get_rot_y, "left"/"right" sides) is
-- built on this frame. Do not mix the two frames without an explicit *-1.
function dir_ops.get_dir_from_param2(name, param2)
	return dir_ops.get_look_dir_from_param2(name, param2) * -1
end

-- Returns the modpack (front) direction of the node with 'pos' position
function dir_ops.get_dir(pos)
	local node = core.get_node(pos)
	return dir_ops.get_dir_from_param2(node.name, node.param2)
end

-- The inverse of get_dir_from_param2: builds the param2 of the node with 'name'
-- from its modpack (front) 'dir', keeping the palette index for color types.
function dir_ops.from_dir_get_param2(name, old_param2, dir)
	local param2 = 0
	local def = core.registered_nodes[name]

	-- convert the front dir to the engine (look) one
	dir = dir * -1

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

-- Gets the yaw rotation of 'dir' (the angle an entity model whose front is +Z
-- needs in set_rotation to face 'dir')
function dir_ops.get_rot_y(dir)
	return vector.dir_to_rotation(dir).y
end

-- Rotates vertically 'pos' around (0, 1, 0) axis at 'angle'.
function dir_ops.rotate_y(pos, angle)
	return vector.rotate_around_axis(pos, vector.up, angle)
end

-- Rotates vertically 'pos' so that its +Z axis lands on 'dir'
-- ('dir' is usually the modpack front direction of some node)
function dir_ops.rotate_to_dir(pos, dir)
	if dir.x == 0 and dir.z == 0 then
		return vector.zero()
	end

	return dir_ops.rotate_y(pos, dir_ops.get_rot_y(dir))
end

-- Rotates vertically 'rel_pos' which is relative to 'pos' of some node
-- according to the front direction of that node
function dir_ops.rotate_to_node_dir(pos, rel_pos)
	local dir = dir_ops.get_dir(pos)
	return dir_ops.rotate_to_dir(rel_pos, dir)
end

return dir_ops
