multidecor.connecting = {}

connecting = multidecor.connecting

-- Checks if two nodes with 'pos1' and 'pos2' positions belongs to the same table
function connecting.are_nodes_identical(pos1, pos2)
	local add_props1 = minetest.registered_nodes[minetest.get_node(pos1).name].add_properties
	local add_props2 = minetest.registered_nodes[minetest.get_node(pos2).name].add_properties

	return add_props1 and add_props2 and add_props1.common_name == add_props2.common_name
end

function connecting.are_nodes_codirectional(pos1, pos2)
	local dir1 = minetest.facedir_to_dir(minetest.get_node(pos1).param2)
	local dir2 = minetest.facedir_to_dir(minetest.get_node(pos2).param2)

	return vector.equals(dir1, dir2)
end

-- Replaces surrounding the identical table nodes to other to look like "connected" with node at 'pos'
function connecting.replace_node_to(pos, disconnect)
	local ord_shifts = {
		pos + vector.new(-1, 0, 0),
		pos + vector.new(0, 0, 1),
		pos + vector.new(1, 0, 0),
		pos + vector.new(0, 0, -1)
	}

	local node_name = minetest.get_node(pos).name
	local add_props = minetest.registered_nodes[node_name].add_properties
	local modname = node_name:find("multidecor:")

	--minetest.debug("3")
	if not modname or not add_props or not add_props.common_name then
		return
	end
	--minetest.debug("4")
	local target_node = ""
	local rel_rot = 0

	if connecting.are_nodes_identical(ord_shifts[1], pos) then
		target_node = "edge"
		rel_rot = 180
	end
	--minetest.debug("5")
	if connecting.are_nodes_identical(ord_shifts[2], pos) then
		target_node = target_node == "edge" and "corner" or "edge"
		rel_rot = 90
	end
	--minetest.debug("6")
	if connecting.are_nodes_identical(ord_shifts[3], pos) then
		if target_node == "corner" then
			target_node = "edge_middle"
		elseif target_node == "edge" then
			target_node = rel_rot == 90 and "corner" or "middle"
		else
			target_node = "edge"
		end
		rel_rot = 0
	end
	--minetest.debug("7")
	if connecting.are_nodes_identical(ord_shifts[4], pos) then
		if target_node == "edge_middle" then
			target_node = "off_edge"
			rel_rot = 0
		elseif target_node == "edge" then
			target_node = (rel_rot == 180 or rel_rot == 0) and "corner" or "middle"
			rel_rot = rel_rot == 0 and -90 or rel_rot
			--[[if rel_rot == 180 then
				target_node = "corner"
				rel_rot = 180
			elseif rel_rot == 90 then
				target_node = "middle"
				rel_rot = 90
			else
				target_node = "corner"
				rel_rot = -90]]
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
	minetest.debug("target_node: " .. target_node)
	if not disconnect and target_node == "" then
		return
	end

	local param2 = minetest.dir_to_facedir(vector.rotate_around_axis({x=0, y=0, z=1}, {x=0, y=1, z=0}, math.rad(rel_rot))*-1)
	--minetest.debug("8")
	--minetest.debug("name:" .. dump(minetest.registered_nodes["multidecor:" .. add_props.common_name .. "_" .. target_node]))
	minetest.set_node(pos, {name="multidecor:" .. add_props.common_name .. target_node, param2=param2})
	--minetest.debug("9")
end

-- Connects or disconnects adjacent nodes around 'pos' position.
-- If the identical table node was set at 'pos' as surrounding, connect them. On destroying it, disconnect.
-- *type* can be "horizontal", "vertical", "pair", "sofa"
function connecting.update_adjacent_nodes_connection(pos, type, disconnect, old_node)
	if not disconnect then
		--minetest.debug("1")

		local node = minetest.get_node(pos)
		local add_props = minetest.registered_nodes[node.name].add_properties
		local modname = node.name:find("multidecor:")
		local cmn_name = add_props and add_props.common_name

		if not modname or not cmn_name then
			return
		end
		--minetest.debug("2")
	end

	if type == "horizontal" then
		local shifts = {
			pos + vector.new(-1, 0, 0),
			pos + vector.new(0, 0, 1),
			pos + vector.new(1, 0, 0),
			pos + vector.new(0, 0, -1)
		}

		for _, s in ipairs(shifts) do
			connecting.replace_node_to(s, disconnect)
		end

		if not disconnect then
			connecting.replace_node_to(pos)
		end
	elseif type == "pair" then
		if not disconnect then
			local node = minetest.get_node(pos)
			local dir = minetest.facedir_to_dir(node.param2)
			local left = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)
			local right = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)

			local lnode = minetest.get_node(left)
			local rnode = minetest.get_node(right)

			local add_props = minetest.registered_nodes[node.name].add_properties
			local is_left_identical = lnode.name == "multidecor:" .. add_props.common_name and connecting.are_nodes_codirectional(left, pos)
			local is_right_identical = rnode.name == "multidecor:" .. add_props.common_name and connecting.are_nodes_codirectional(right, pos)

			local place_pos
			if is_left_identical then
				place_pos = left
			elseif is_right_identical then
				place_pos = pos
			else
				return
			end

			minetest.set_node(place_pos, {name="multidecor:" .. add_props.common_name .. "_double", param2=minetest.dir_to_facedir(dir)})
			minetest.remove_node(place_pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2))
		else
			local dir = minetest.facedir_to_dir(old_node.param2)
			local right = pos+vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
			local add_props = minetest.registered_nodes[old_node.name].add_properties
			minetest.set_node(right, {name="multidecor:" .. add_props.common_name, param2=minetest.dir_to_facedir(dir)})
		end
	end
end

function connecting.register_connect_parts(def)
	for name, mesh in pairs(def.add_properties.connect_parts) do
		local c_def = table.copy(def)
		c_def.mesh = mesh
		c_def.drop = "multidecor:" .. def.add_properties.common_name

		if c_def.groups then
			c_def.groups.not_in_creative_inventory = 1
		else
			c_def.groups = {not_in_creative_inventory=1}
		end

		for cb_name, _ in pairs(c_def.callbacks) do
			if cb_name ~= "after_destruct" and cb_name ~= "after_dig_node" then
				c_def[cb_name] = nil
			end
		end

		c_def.callbacks = nil

		register.register_furniture_unit(def.add_properties.common_name .. "_" .. name, c_def)
		--minetest.register_node(":multidecor:" .. def.add_properties.common_name .. "_" .. name, c_def)
	end
end
