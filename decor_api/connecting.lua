multidecor.connecting = multidecor.connecting or {}
local connecting = multidecor.connecting
local hlpfuncs = multidecor.helpers

local horizontal_order = {"left", "front", "right", "back"}
local horizontal_offsets = {
	left = vector.new(-1, 0, 0),
	front = vector.new(0, 0, 1),
	right = vector.new(1, 0, 0),
	back = vector.new(0, 0, -1)
}

local vertical_order = {"left", "top", "right", "bottom"}
local axis_lookup = {
	["y+"] = {index = 0, shift = 0},
	["z+"] = {index = 1, shift = -2},
	["z-"] = {index = 2, shift = 0},
	["x+"] = {index = 3, shift = -1},
	["x-"] = {index = 4, shift = -3},
	["y-"] = {index = 5, shift = 0}
}

local function get_node_info(pos)
	local node = minetest.get_node(pos)
	if not node then
		return
	end

	local def = minetest.registered_nodes[node.name]
	return node, def, def and def.add_properties
end

local function common_name_at(pos)
	local _, _, add_props = get_node_info(pos)
	return add_props and add_props.common_name or nil
end

local function build_node_name(cmn_name, variant)
	if variant ~= "" then
		return "multidecor:" .. cmn_name .. "_" .. variant
	end

	return "multidecor:" .. cmn_name
end

local function rotate_index(value, delta)
	local result = (value + delta) % 4
	if result < 0 then
		result = result + 4
	end

	return result
end

local function axis_key_from_dir(dir)
	if not dir then
		return
	end

	if dir.x ~= 0 then
		return dir.x > 0 and "x-" or "x+"
	end

	if dir.y ~= 0 then
		return dir.y > 0 and "y-" or "y+"
	end

	if dir.z ~= 0 then
		return dir.z > 0 and "z-" or "z+"
	end
end

local function rotated_dir(dir, angle)
	return vector.round(vector.rotate_around_axis(dir, vector.new(0, 1, 0), angle))
end

local function vertical_offsets(dir)
	if not dir then
		return
	end

	return {
		left = rotated_dir(dir, math.pi / 2),
		top = vector.new(0, 1, 0),
		right = rotated_dir(dir, -math.pi / 2),
		bottom = vector.new(0, -1, 0)
	}
end

local function horizontal_neighbors(pos, cmn_name)
	local neighbors = {}

	for _, key in ipairs(horizontal_order) do
		neighbors[key] = common_name_at(vector.add(pos, horizontal_offsets[key])) == cmn_name
	end

	return neighbors
end

local function vertical_neighbors(pos, cmn_name, dir)
	local offsets = vertical_offsets(dir)
	if not offsets then
		return
	end

	local neighbors = {}

	for _, key in ipairs(vertical_order) do
		neighbors[key] = common_name_at(vector.add(pos, offsets[key])) == cmn_name
	end

	return neighbors, offsets
end

local function evaluate_horizontal_variant(neighbors)
	local variant = ""
	local rel_rot = 0

	if neighbors.left then
		variant = "edge"
		rel_rot = 180
	end

	if neighbors.front then
		variant = variant == "edge" and "corner" or "edge"
		rel_rot = 90
	end

	if neighbors.right then
		local prev_rot = rel_rot
		if variant == "corner" then
			variant = "edge_middle"
		elseif variant == "edge" then
			variant = prev_rot == 90 and "corner" or "middle"
		else
			variant = "edge"
		end
		rel_rot = 0
	end

	if neighbors.back then
		local prev_rot = rel_rot
		if variant == "edge_middle" then
			variant = "off_edge"
			rel_rot = 0
		elseif variant == "edge" then
			variant = (prev_rot == 180 or prev_rot == 0) and "corner" or "middle"
			rel_rot = prev_rot == 0 and -90 or prev_rot
		elseif variant == "corner" then
			variant = "edge_middle"
			rel_rot = prev_rot == 0 and -90 or prev_rot
		elseif variant == "middle" then
			variant = "edge_middle"
			rel_rot = 180
		else
			variant = "edge"
			rel_rot = -90
		end
	end

	return variant, rel_rot
end

local function evaluate_vertical_variant(neighbors)
	local variant = ""
	local axis_rot = 0

	if neighbors.left then
		variant = "edge"
		axis_rot = 180
	end

	if neighbors.top then
		variant = variant == "edge" and "corner" or "edge"
		axis_rot = 270
	end

	if neighbors.right then
		local prev_rot = axis_rot
		if variant == "corner" then
			variant = "edge_middle"
		elseif variant == "edge" then
			variant = prev_rot == 270 and "corner" or "middle"
		else
			variant = "edge"
		end
		axis_rot = 0
	end

	if neighbors.bottom then
		local prev_rot = axis_rot
		if variant == "edge_middle" then
			variant = "off_edge"
			axis_rot = 0
		elseif variant == "edge" then
			variant = (prev_rot == 180 or prev_rot == 0) and "corner" or "middle"
			axis_rot = prev_rot == 0 and 90 or prev_rot
		elseif variant == "corner" then
			variant = "edge_middle"
			axis_rot = prev_rot == 0 and 270 or prev_rot
		elseif variant == "middle" then
			variant = "edge_middle"
			axis_rot = 180
		else
			variant = "edge"
			axis_rot = 270
		end
	end

	return variant, axis_rot
end

function connecting.are_nodes_identical(pos1, pos2)
	local cmn = common_name_at(pos1)
	return cmn ~= nil and cmn == common_name_at(pos2)
end

function connecting.has_same_cmn_name(pos, cmn_name)
	return common_name_at(pos) == cmn_name
end

function connecting.are_nodes_codirectional(pos1, pos2)
	local node1 = minetest.get_node(pos1)
	local node2 = minetest.get_node(pos2)
	local dir1 = hlpfuncs.get_dir_from_param2(node1.name, node1.param2)
	local dir2 = hlpfuncs.get_dir_from_param2(node2.name, node2.param2)

	return vector.equals(dir1, dir2)
end

function connecting.has_same_dir(pos, dir)
	local node = minetest.get_node(pos)
	local node_dir = vector.multiply(hlpfuncs.get_dir_from_param2(node.name, node.param2), -1)

	return vector.equals(dir, node_dir)
end

function connecting.replace_node_to(pos, disconnect, cmn_name)
	if not connecting.has_same_cmn_name(pos, cmn_name) then
		return
	end

	local neighbors = horizontal_neighbors(pos, cmn_name)
	local variant, rel_rot = evaluate_horizontal_variant(neighbors)

	if not disconnect and variant == "" then
		return
	end

	local name = build_node_name(cmn_name, variant)
	local node = minetest.get_node(pos)
	local rotated_dir = vector.multiply(vector.rotate_around_axis(vector.new(0, 0, 1), vector.new(0, 1, 0), math.rad(rel_rot)), -1)
	local param2 = hlpfuncs.from_dir_get_param2(name, node.param2, rotated_dir)

	minetest.set_node(pos, {name = name, param2 = param2})
end

function connecting.replace_node_vertically(pos, disconnect, cmn_name, node)
	node = node or minetest.get_node(pos)
	local dir = hlpfuncs.get_dir_from_param2(node.name, node.param2)

	if not connecting.has_same_cmn_name(pos, cmn_name) or not connecting.has_same_dir(pos, dir) then
		return
	end

	local neighbors = vertical_neighbors(pos, cmn_name, dir)
	if not neighbors then
		return
	end

	local variant, axis_rot = evaluate_vertical_variant(neighbors)

	if not disconnect and variant == "" then
		return
	end

	local axis_key = axis_key_from_dir(dir)
	local axis_conf = axis_lookup[axis_key]
	if not axis_conf then
		return
	end

	local turns = rotate_index(math.floor(axis_rot / 90), axis_conf.shift)

	local name = build_node_name(cmn_name, variant)
	local param2 = axis_conf.index * 4 + turns

	minetest.set_node(pos, {name = name, param2 = param2})
end

function connecting.directional_replace_node_to(pos, dir, side, disconnect, cmn_name, is_corner)
	local node, def, add_props = get_node_info(pos)
	if not node or not def or not add_props then
		return
	end

	if add_props.common_name ~= cmn_name or not node.name:find("multidecor:", 1, true) then
		return
	end

	local parts = add_props.connect_parts
	if not parts then
		return
	end

	local dir_rot = math.deg(vector.dir_to_rotation(dir).y)
	local cur_dir = hlpfuncs.get_dir(pos)
	local dir_rot2 = math.deg(vector.dir_to_rotation(cur_dir).y)

	if dir_rot == 180 and dir_rot2 == -90 then
		dir_rot2 = 270
	end

	local mesh = def.mesh
	local is_right_side = not disconnect and parts.right_side == mesh and side == "left" and math.abs(dir_rot + 90) == math.abs(dir_rot2)
	local is_left_side = not disconnect and parts.left_side == mesh and side == "right" and math.abs(dir_rot - 90) == math.abs(dir_rot2)
	local is_left_corner = disconnect and parts.corner == mesh and side == "right" and math.abs(dir_rot - 90) == math.abs(dir_rot2)
	local is_right_corner = disconnect and parts.corner == mesh and side == "left" and math.abs(dir_rot) == math.abs(dir_rot2)
	local is_corner_1 = is_corner and (parts.middle == mesh or parts.left_side == mesh) and side == "left" and math.abs(dir_rot + 90) == math.abs(dir_rot2)
	local is_corner_2 = is_corner and (parts.middle == mesh or parts.right_side == mesh) and side == "right" and math.abs(dir_rot) == math.abs(dir_rot2)

	if dir_rot ~= dir_rot2 and not is_right_side and not is_left_side and not is_left_corner and not is_right_corner and not is_corner_1 and not is_corner_2 then
		return
	end

	local target_part
	local rel_rot = 0
	local t_dir = dir

	if dir_rot ~= dir_rot2 or is_right_corner then
		local adj_pos = vector.add(pos, dir)
		if connecting.are_nodes_identical(adj_pos, pos) then
			if is_left_corner then
				target_part = "_left_side"
				rel_rot = -math.pi / 2
			elseif is_right_corner then
				target_part = "_right_side"
				rel_rot = math.pi / 2
			elseif is_left_side then
				target_part = "_corner"
				rel_rot = -math.pi / 2
			elseif is_right_side then
				target_part = "_corner"
				rel_rot = 0
			end
		end
	end

	if not target_part then
		target_part = ""
		rel_rot = 0
		t_dir = cur_dir
		local left_pos = vector.add(pos, rotated_dir(cur_dir, -math.pi / 2))
		local right_pos = vector.add(pos, rotated_dir(cur_dir, math.pi / 2))

		local is_left_node_identical = connecting.are_nodes_identical(left_pos, pos)
		local is_right_node_identical = connecting.are_nodes_identical(right_pos, pos)

		if is_left_node_identical then
			local is_left_node_codir = connecting.are_nodes_codirectional(left_pos, pos)
			local _, left_def, left_props = get_node_info(left_pos)
			local is_left_node_corner = left_props and left_props.connect_parts and left_props.connect_parts.corner == left_def.mesh

			if is_left_node_codir or is_left_node_corner then
				target_part = "_right_side"
			end
		end

		if is_right_node_identical then
			local is_right_node_codir = connecting.are_nodes_codirectional(right_pos, pos)
			local _, right_def, right_props = get_node_info(right_pos)
			local is_right_node_corner = right_props and right_props.connect_parts and right_props.connect_parts.corner == right_def.mesh

			if is_right_node_codir or is_right_node_corner then
				if target_part ~= "" then
					target_part = "_middle"
				else
					target_part = "_left_side"
				end
			end
		end
	end

	if not disconnect and target_part == "" then
		return
	end

	local name = "multidecor:" .. add_props.common_name .. target_part
	local rot_dir = vector.rotate_around_axis(t_dir, vector.new(0, 1, 0), rel_rot)
	local param2 = hlpfuncs.from_dir_get_param2(name, node.param2, vector.multiply(rot_dir, -1))

	minetest.set_node(pos, {name = name, param2 = param2})
end

local connection_handlers = {}

local function handle_grid_connection(kind, pos, node, add_props, disconnect, old_node)
	local cmn_name = add_props.common_name
	if not cmn_name then
		return
	end

	if kind == "horizontal" then
		for _, key in ipairs(horizontal_order) do
			local shift_pos = vector.add(pos, horizontal_offsets[key])
			connecting.replace_node_to(shift_pos, disconnect, cmn_name)
		end

		if not disconnect then
			connecting.replace_node_to(pos, nil, cmn_name)
		end

		return
	end

	local reference = disconnect and old_node or node
	local dir = hlpfuncs.get_dir_from_param2(reference.name, reference.param2)
	local offsets = vertical_offsets(dir)
	if not offsets then
		return
	end

	for _, key in ipairs(vertical_order) do
		local shift_pos = vector.add(pos, offsets[key])
		connecting.replace_node_vertically(shift_pos, disconnect, cmn_name, reference)
	end

	if not disconnect then
		connecting.replace_node_vertically(pos, nil, cmn_name, reference)
	end
end

connection_handlers.horizontal = function(pos, node, def, add_props, disconnect, old_node)
	handle_grid_connection("horizontal", pos, node, add_props, disconnect, old_node)
end

connection_handlers.vertical = function(pos, node, def, add_props, disconnect, old_node)
	handle_grid_connection("vertical", pos, node, add_props, disconnect, old_node)
end

connection_handlers.pair = function(pos, node, def, add_props, disconnect)
	local cmn_name = add_props.common_name
	if not cmn_name then
		return
	end

	if not disconnect then
		local dir = hlpfuncs.get_dir(pos)
		local left = vector.add(pos, hlpfuncs.rot(dir, -math.pi / 2))
		local right = vector.add(pos, hlpfuncs.rot(dir, math.pi / 2))

		local lnode = minetest.get_node(left)
		local rnode = minetest.get_node(right)

		local is_left_identical = lnode.name == "multidecor:" .. cmn_name and connecting.are_nodes_codirectional(left, pos)
		local is_right_identical = rnode.name == "multidecor:" .. cmn_name and connecting.are_nodes_codirectional(right, pos)

		local place_pos
		if is_left_identical then
			place_pos = left
		elseif is_right_identical then
			place_pos = pos
		else
			return
		end

		minetest.set_node(place_pos, {name = "multidecor:" .. cmn_name .. "_double", param2 = hlpfuncs.from_dir_get_param2(node.name, node.param2, vector.multiply(dir, -1))})
		minetest.remove_node(vector.add(place_pos, hlpfuncs.rot(dir, math.pi / 2)))
	else
		local dir = hlpfuncs.get_dir_from_param2(node.name, node.param2)
		minetest.set_node(pos, {name = "multidecor:" .. cmn_name, param2 = hlpfuncs.from_dir_get_param2(node.name, node.param2, vector.multiply(dir, -1))})
	end
end

connection_handlers.directional = function(pos, node, def, add_props, disconnect)
	local dir

	if disconnect then
		dir = hlpfuncs.get_dir_from_param2(node.name, node.param2)
	else
		dir = hlpfuncs.get_dir(pos)
	end

	local left_shift = hlpfuncs.rot(dir, -math.pi / 2)
	local corner = false

	if disconnect and add_props.connect_parts and add_props.connect_parts.corner == def.mesh then
		left_shift = dir
		corner = true
	end

	local left = vector.add(pos, left_shift)
	local right = vector.add(pos, hlpfuncs.rot(dir, math.pi / 2))
	local cmn_name = add_props.common_name

	connecting.directional_replace_node_to(left, dir, "left", disconnect, cmn_name, corner)
	connecting.directional_replace_node_to(right, dir, "right", disconnect, cmn_name, corner)

	if not disconnect then
		connecting.directional_replace_node_to(pos, dir, nil, nil, cmn_name, corner)
	end
end

function connecting.update_adjacent_nodes_connection(pos, kind, disconnect, old_node)
	local node = disconnect and old_node or minetest.get_node(pos)
	if not node then
		return
	end

	local def = minetest.registered_nodes[node.name]
	if not def then
		return
	end

	local add_props = def.add_properties
	if not add_props or not add_props.common_name then
		return
	end

	if not disconnect and not node.name:find("multidecor:", 1, true) then
		return
	end

	local handler = connection_handlers[kind]
	if handler then
		handler(pos, node, def, add_props, disconnect, old_node)
	end
end

function connecting.register_connect_parts(def)
	local add_props = def.add_properties
	if not add_props or not add_props.connect_parts then
		return
	end

	for name, mesh in pairs(add_props.connect_parts) do
		local c_def = table.copy(def)
		c_def.mesh = mesh
		c_def.drop = "multidecor:" .. add_props.common_name

		local groups = c_def.groups and table.copy(c_def.groups) or {}
		groups.not_in_creative_inventory = 1
		c_def.groups = groups

		if name == "corner" and add_props.corner_bounding_boxes then
			c_def.bounding_boxes = add_props.corner_bounding_boxes
		end

		if c_def.callbacks then
			c_def.callbacks = table.copy(c_def.callbacks)
			c_def.callbacks.on_construct = nil
		end

		multidecor.register.register_furniture_unit(add_props.common_name .. "_" .. name, c_def)
	end
end
