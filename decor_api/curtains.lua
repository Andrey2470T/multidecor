multidecor.curtains = {}

-- Defines if the given curtain node with 'nodename' name can be placed at the position 'pos'.
-- Returns two values: 1 - can/can't, 2 - the curtain with rings should be placed or not
function multidecor.curtains.can_place(pos, nodename)
	local data = minetest.registered_nodes[nodename].add_properties.curtains_data

	local up_pos = {x=pos.x, y=pos.y+1, z=pos.z}
	local up_nodename = minetest.get_node(up_pos).name
	local is_hanger = minetest.get_item_group(up_nodename, "hanger") == 1

	local can_be_placed = false

	if is_hanger then
		if data.with_rings then
			can_be_placed = true
		end
	else
		local add_props_up = minetest.registered_nodes[up_nodename].add_properties

		if add_props_up and add_props_up.curtains_data then
			local up_data = add_props_up.curtains_data

			if up_data.common_name == data.common_name and not data.with_rings then
				can_be_placed = true
			end
		end
	end

	return can_be_placed
end

-- Destructs and drops (if was dug by player) below curtain node at the 'pos' position if the above node (cornice or other connected curtain) has got absent
function multidecor.curtains.drop_below_curtain(pos, digger)
	local add_props = hlpfuncs.ndef(pos).add_properties

	if add_props and add_props.curtains_data then
		minetest.dig_node(pos)
	end
end

-- Defines at which direction (unit vector) depending on the 'mover's look dir the curtains at the position 'pos' should be moved
function multidecor.curtains.define_move_dir(pos, mover)
	local node_dir = hlpfuncs.get_dir(pos)*-1
	node_dir.y = 0

	local mover_dir = mover:get_look_dir()
	mover_dir.y = 0

	local node_dir_rot = vector.rotate_around_axis(node_dir, vector.new(0, 1, 0), math.pi/2)
	local node_dir_rot2 = vector.rotate_around_axis(node_dir, vector.new(0, 1, 0), -math.pi/2)

	local dot = vector.dot(node_dir_rot, mover_dir)
	local dot2 = vector.dot(node_dir_rot2, mover_dir)

	local t_dir = vector.zero()

	if dot > 0 and dot <= 1 then
		t_dir = node_dir_rot
	elseif dot2 > 0 and dot <= 1 then
		t_dir = node_dir_rot2
	end

	return t_dir
end

-- Shifts by the unit the position 'pos' of all same curtains arranged vertically in the direction 'dir'
function multidecor.curtains.move_curtains(pos, dir)
	local max_move_nodes = 50
	local curtain_top_found = false

	local add_props = hlpfuncs.ndef(pos).add_properties

	local res = false

	local function iter_func(i)
		local cur_pos = {x=pos.x, y=pos.y+i, z=pos.z}
		local node = minetest.get_node(cur_pos)
		local cur_add_props = minetest.registered_nodes[node.name].add_properties

		-- if the curtains with rings found and above that there are cornices, mark it as found in the varyable
		if cur_add_props and cur_add_props.curtains_data and
			cur_add_props.common_name == add_props.common_name and cur_add_props.curtains_data.with_rings then

			local hanger_pos = {x=cur_pos.x,y=cur_pos.y+1,z=cur_pos.z}
			local is_above_cornice = minetest.get_item_group(minetest.get_node(hanger_pos).name, "hanger") == 1
			local is_above_cornice2 = minetest.get_item_group(minetest.get_node(vector.add(hanger_pos, dir)).name, "hanger") == 1

			if is_above_cornice and is_above_cornice2 then
				curtain_top_found = true
				minetest.sound_play(add_props.curtains_data.sound, {gain=1.0, pitch=1.0, pos=pos, max_hear_distance=10})
			end
		end

		-- if the curtains with rings hasn't found yet, then just skip the iteration
		-- if this is found and the given node is not a curtain, break the search loop
		if curtain_top_found then
			if not (cur_add_props and cur_add_props.curtains_data and cur_add_props.common_name == add_props.common_name) then
				return
			end
		else
			return true
		end

		local target_pos = vector.add(cur_pos, dir)
		local target_def = hlpfuncs.ndef(target_pos)
		local target_add_props = target_def.add_properties

		if target_def.drawtype ~= "airlike" then
			if target_add_props then
				if target_add_props.curtains_data and target_add_props.common_name == add_props.common_name then
					local moved = multidecor.curtains.move_curtains(target_pos, dir)

					-- adjacent curtains couldn't be moved for some reason to move to their positions the current curtains
					if not moved then
						return
					end
				else
					return
				end
			else
				return
			end
		end

		local meta = minetest.get_meta(cur_pos)

		local meta_t = meta:to_table()

		minetest.remove_node(cur_pos)
		minetest.set_node(vector.add(cur_pos, dir), node)

		minetest.get_meta(vector.add(cur_pos, dir)):from_table(meta_t)

		res = true

		return true
	end

	for i = max_move_nodes, -max_move_nodes, -1 do
		local res = iter_func(i)

		if not res then break end
	end

	return res
end

function multidecor.curtains.after_place_node(pos, placer)
	local name = minetest.get_node(pos).name

	local val = multidecor.curtains.can_place(pos, name)

	if not val then
		minetest.remove_node(pos)
		return true
	end
end

function multidecor.curtains.after_dig_node(pos, oldnode, oldmeta, digger)
	multidecor.curtains.drop_below_curtain({x=pos.x, y=pos.y-1, z=pos.z}, digger)
end

function multidecor.curtains.on_rightclick(pos, node, clicker)
	local mdir = multidecor.curtains.define_move_dir(pos, clicker)

	if vector.length(mdir) ~= 0  then
		multidecor.curtains.move_curtains(pos, mdir)
	end
end

function multidecor.register.register_curtain(name, base_def, add_def)
	local c_def = table.copy(base_def)

	c_def.type = "curtain"

	c_def.add_properties = table.copy(add_def)

	local data = c_def.add_properties.curtains_data
	data.with_rings = true
	c_def.description = data.curtain_with_rings.description
	c_def.mesh = data.curtain_with_rings.mesh
	c_def.tiles = data.curtain_with_rings.tiles

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or multidecor.curtains.after_place_node
	c_def.callbacks.after_dig_node = c_def.callbacks.after_dig_node or multidecor.curtains.after_dig_node
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or multidecor.curtains.on_rightclick

	multidecor.register.register_furniture_unit(
		data.curtain_with_rings.name, c_def,
		data.curtain_with_rings.craft)

	local c_def2 = table.copy(base_def)
	c_def2.type = "curtain"

	c_def2.add_properties = table.copy(add_def)

	local data2 = c_def2.add_properties.curtains_data
	data2.with_rings = false
	c_def2.description = data2.curtain.description
	c_def2.mesh = data2.curtain.mesh
	c_def2.tiles = data2.curtain.tiles

	c_def2.callbacks = c_def.callbacks

	multidecor.register.register_furniture_unit(
		data2.curtain.name, c_def2,
		data2.curtain.craft)
end
