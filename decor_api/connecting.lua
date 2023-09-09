multidecor.connecting = {}


-- Checks if two nodes with 'pos1' and 'pos2' positions belongs to the same table
function multidecor.connecting.are_nodes_identical(pos1, pos2)
	local add_props1 = minetest.registered_nodes[minetest.get_node(pos1).name].add_properties
	local add_props2 = minetest.registered_nodes[minetest.get_node(pos2).name].add_properties

	return add_props1 and add_props2 and add_props1.common_name == add_props2.common_name
end

function multidecor.connecting.are_nodes_codirectional(pos1, pos2)
	local dir1 = minetest.facedir_to_dir(minetest.get_node(pos1).param2)
	local dir2 = minetest.facedir_to_dir(minetest.get_node(pos2).param2)

	return vector.equals(dir1, dir2)
end

-- Replaces surrounding the identical table nodes to other to look like "connected" with node at 'pos'
function multidecor.connecting.replace_node_to(pos, disconnect, cmn_name)
	local ord_shifts = {
		pos + vector.new(-1, 0, 0),
		pos + vector.new(0, 0, 1),
		pos + vector.new(1, 0, 0),
		pos + vector.new(0, 0, -1)
	}

	local node_name = minetest.get_node(pos).name
	local add_props = minetest.registered_nodes[node_name].add_properties
	local modname = node_name:find("multidecor:")

	if not modname or not add_props or not add_props.common_name then
		return
	end

	if add_props.common_name ~= cmn_name then
		return
	end

	local target_node = ""
	local rel_rot = 0

	if multidecor.connecting.are_nodes_identical(ord_shifts[1], pos) then
		target_node = "edge"
		rel_rot = 180
	end

	if multidecor.connecting.are_nodes_identical(ord_shifts[2], pos) then
		target_node = target_node == "edge" and "corner" or "edge"
		rel_rot = 90
	end

	if multidecor.connecting.are_nodes_identical(ord_shifts[3], pos) then
		if target_node == "corner" then
			target_node = "edge_middle"
		elseif target_node == "edge" then
			target_node = rel_rot == 90 and "corner" or "middle"
		else
			target_node = "edge"
		end
		rel_rot = 0
	end

	if multidecor.connecting.are_nodes_identical(ord_shifts[4], pos) then
		if target_node == "edge_middle" then
			target_node = "off_edge"
			rel_rot = 0
		elseif target_node == "edge" then
			target_node = (rel_rot == 180 or rel_rot == 0) and "corner" or "middle"
			rel_rot = rel_rot == 0 and -90 or rel_rot
		elseif target_node == "corner" then
			target_node = "edge_middle"
			rel_rot = rel_rot == 0 and -90 or rel_rot
		elseif target_node == "middle" then
			target_node = "edge_middle"
			rel_rot = 180
		else
			target_node = "edge"
			rel_rot = -90
		end
	end

	target_node = target_node ~= "" and "_" .. target_node or ""

	if not disconnect and target_node == "" then
		return
	end

	local param2 = minetest.dir_to_facedir(vector.rotate_around_axis({x=0, y=0, z=1}, {x=0, y=1, z=0}, math.rad(rel_rot))*-1)
	minetest.set_node(pos, {name="multidecor:" .. add_props.common_name .. target_node, param2=param2})
end

-- Replaces the current sofa part at 'pos' position depending on the adjacent sofas parts.
-- 'pos' - position of the replacing sofa.
-- 'dir' - the face direction that the placed/destructed sofa part has.
-- 'side' - "left"/"right".
-- 'disconnect' - sofas should be disconnected or connected?
-- 'cmn_name' - common name.
function multidecor.connecting.directional_replace_node_to(pos, dir, side, disconnect, cmn_name, is_corner)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local add_props = def.add_properties

	local modname = node.name:find("multidecor:")

	if not modname or not add_props or not add_props.common_name then
		return
	end

	if add_props.common_name ~= cmn_name then
		return
	end
	
	local parts = add_props.connect_parts

	local dir_rot = math.deg(vector.dir_to_rotation(dir).y)
	local cur_dir = multidecor.helpers.get_dir(pos)
	local dir_rot2 = math.deg(vector.dir_to_rotation(cur_dir).y)
	
	if dir_rot == 180 and dir_rot2 == -90 then
		dir_rot2 = 270
	end
	
	-- The left and right adjacent sofa parts should have the same face dir to be connected/disconnected, but there are six exceptions below
	local is_right_side = not disconnect and parts.right_side == def.mesh and side == "left" and
		math.abs(dir_rot+90) == math.abs(dir_rot2)

	local is_left_side = not disconnect and parts.left_side == def.mesh and side == "right" and
		math.abs(dir_rot-90) == math.abs(dir_rot2)

	local is_left_corner = disconnect and parts.corner == def.mesh and side == "right" and
		math.abs(dir_rot-90) == math.abs(dir_rot2)

	local is_right_corner = disconnect and parts.corner == def.mesh and side == "left" and
		math.abs(dir_rot) == math.abs(dir_rot2)
		
	local is_corner_1 = is_corner and (parts.middle == def.mesh or parts.left_side == def.mesh) and side == "left" and
		math.abs(dir_rot+90) == math.abs(dir_rot2)
		
	local is_corner_2 = is_corner and (parts.middle == def.mesh or parts.right_side == def.mesh) and side == "right" and
		math.abs(dir_rot) == math.abs(dir_rot2)

	if dir_rot ~= dir_rot2 and not is_right_side and not is_left_side and 
		not is_left_corner and not is_right_corner and not is_corner_1 and not is_corner_2 then return end

	local target_part
	local rel_rot = 0
	local t_dir = dir

	if dir_rot ~= dir_rot2 or is_right_corner then
		local adj_pos = pos + dir
		local is_adj_node_identical = multidecor.connecting.are_nodes_identical(adj_pos, pos)

		if is_adj_node_identical then
			if is_left_corner then
				target_part = "_left_side"
				rel_rot = -math.pi/2
			elseif is_right_corner then
				target_part = "_right_side"
				rel_rot = math.pi/2
			elseif is_left_side then
				target_part = "_corner"
				rel_rot = -math.pi/2
			elseif is_right_side then
				target_part = "_corner"
				rel_rot = 0
			end
		end
	end

	-- true if the adjacent sofa parts are co-directional yet
	if not target_part then
		target_part = ""
		rel_rot = 0
		t_dir = cur_dir
		local left_pos = pos + vector.rotate_around_axis(cur_dir, vector.new(0, 1, 0), -math.pi/2)
		local right_pos = pos + vector.rotate_around_axis(cur_dir, vector.new(0, 1, 0), math.pi/2)

		local is_left_node_identical = multidecor.connecting.are_nodes_identical(left_pos, pos)
		local is_right_node_identical = multidecor.connecting.are_nodes_identical(right_pos, pos)

		if is_left_node_identical then
			local is_left_node_codir = multidecor.connecting.are_nodes_codirectional(left_pos, pos)
			local left_node_def = minetest.registered_nodes[minetest.get_node(left_pos).name]
			local is_left_node_corner = left_node_def.add_properties.connect_parts.corner == left_node_def.mesh

			if is_left_node_codir or is_left_node_corner then
				target_part = "_right_side"
			end
		end

		if is_right_node_identical then
			local is_right_node_codir = multidecor.connecting.are_nodes_codirectional(right_pos, pos)
			local right_node_def = minetest.registered_nodes[minetest.get_node(right_pos).name]
			local is_right_node_corner = right_node_def.add_properties.connect_parts.corner == right_node_def.mesh

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

	local rot_dir = vector.rotate_around_axis(t_dir, vector.new(0, 1, 0), rel_rot)
	local param2 = minetest.dir_to_facedir(rot_dir*-1)
	minetest.set_node(pos, {name="multidecor:" .. add_props.common_name .. target_part, param2=param2})
end

-- Connects or disconnects adjacent nodes around 'pos' position.
-- If the identical table node was set at 'pos' as surrounding, connect them. On destroying it, disconnect.
-- 'type' - "horizontal", "vertical", "pair", "sofa"
function multidecor.connecting.update_adjacent_nodes_connection(pos, type, disconnect, old_node)
	local node = disconnect and old_node or minetest.get_node(pos)

	if not disconnect then
		local add_props = minetest.registered_nodes[node.name].add_properties
		local modname = node.name:find("multidecor:")
		local cmn_name = add_props and add_props.common_name

		if not modname or not cmn_name then
			return
		end
	end

	if type == "horizontal" then
		local shifts = {
			pos + vector.new(-1, 0, 0),
			pos + vector.new(0, 0, 1),
			pos + vector.new(1, 0, 0),
			pos + vector.new(0, 0, -1)
		}

		local cmn_name = minetest.registered_nodes[node.name].add_properties.common_name
		for _, s in ipairs(shifts) do
			multidecor.connecting.replace_node_to(s, disconnect, cmn_name)
		end

		if not disconnect then
			multidecor.connecting.replace_node_to(pos, nil, cmn_name)
		end
	elseif type == "pair" then
		if not disconnect then
			local dir = multidecor.helpers.get_dir(pos)
			local left = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
			local right = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)

			local lnode = minetest.get_node(left)
			local rnode = minetest.get_node(right)

			local add_props = minetest.registered_nodes[node.name].add_properties
			local is_left_identical = lnode.name == "multidecor:" .. add_props.common_name and multidecor.connecting.are_nodes_codirectional(left, pos)
			local is_right_identical = rnode.name == "multidecor:" .. add_props.common_name and multidecor.connecting.are_nodes_codirectional(right, pos)

			local place_pos
			if is_left_identical then
				place_pos = left
			elseif is_right_identical then
				place_pos = pos
			else
				return
			end

			minetest.set_node(place_pos, {name="multidecor:" .. add_props.common_name .. "_double", param2=minetest.dir_to_facedir(dir*-1)})
			minetest.remove_node(place_pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2))
		else
			local dir = minetest.facedir_to_dir(old_node.param2)
			local right = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
			local add_props = minetest.registered_nodes[old_node.name].add_properties
			minetest.set_node(right, {name="multidecor:" .. add_props.common_name, param2=minetest.dir_to_facedir(dir)})
		end
	elseif type == "directional" then
		local def = minetest.registered_nodes[node.name]
		local dir

		if disconnect then
			dir = minetest.facedir_to_dir(old_node.param2)*-1
		else
			dir = multidecor.helpers.get_dir(pos)
		end

		local left_shift = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
		--local left_dir = dir
		--local right_dir = dir
		local corner = false
		if disconnect and def.add_properties.connect_parts.corner == def.mesh then
			left_shift = dir
			corner = true
			--left_dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)
		end
		local left = pos+left_shift
		local right = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)

		local cmn_name = def.add_properties.common_name
		multidecor.connecting.directional_replace_node_to(left, dir, "left", disconnect, cmn_name, corner)
		multidecor.connecting.directional_replace_node_to(right, dir, "right", disconnect, cmn_name, corner)

		if not disconnect then
			multidecor.connecting.directional_replace_node_to(pos, dir, nil, nil, cmn_name, corner)
		end
	end
end

function multidecor.connecting.register_connect_parts(def)
	for name, mesh in pairs(def.add_properties.connect_parts) do
		local c_def = table.copy(def)
		c_def.mesh = mesh
		c_def.drop = "multidecor:" .. def.add_properties.common_name

		if c_def.groups then
			c_def.groups.not_in_creative_inventory = 1
		else
			c_def.groups = {not_in_creative_inventory=1}
		end

		if name == "corner" and def.add_properties.corner_bounding_boxes then
			c_def.bounding_boxes = def.add_properties.corner_bounding_boxes
		end
		c_def.callbacks.on_construct = nil

		multidecor.register.register_furniture_unit(def.add_properties.common_name .. "_" .. name, c_def)
	end
end
