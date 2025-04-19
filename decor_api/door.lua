multidecor.doors = {}


-- Returns new position rotated around 'rotate_p' and rotation correponding to "dir"
function multidecor.doors.rotate(pos, dir, rotate_p)
	local rel_pos = hlpfuncs.rotate_to_dir(pos - rotate_p, dir)

	return rotate_p + rel_pos, {x=0, y=vector.dir_to_rotation(dir).y, z=0}
end

-- Activates obj movement/rotation from 'self.start_v' to 'self.end_v' or vice versa depending on 'dir_sign' value
function multidecor.doors.set_dir(obj, dir_sign)
	local self = obj:get_luaentity()
	if not self then
		return
	end

	self.dir = dir_sign

end

-- Step of obj rotation
function multidecor.doors.smooth_rotate_step(self, dtime, vel, acc)
	if self.dir == 0 or not self.dir then
		return
	end

	local rot = self.object:get_rotation()
	local rot_axis = self.rotate_x and "x" or "y"
	local target_rot = self.dir == 1 and self.end_v or self.start_v

	if math.abs(target_rot-rot[rot_axis]) <= math.rad(10) then
		self.dir = 0
		self.step_c = nil
		rot[rot_axis] = target_rot
		self.object:set_rotation(rot)
		return
	end

	self.step_c = self.step_c and self.step_c+acc or 1
	-- Rotation speed is 60 degrees/sec
	local sign = self.start_v > self.end_v and -1 or 1
	local new_rot = self.dir*sign*math.rad(vel)*dtime*self.step_c

	rot[rot_axis] = hlpfuncs.clamp(self.start_v, self.end_v, rot[rot_axis]+new_rot)
	self.object:set_rotation(rot)
end

function get_movement_dir(dir, action, is_mirrored)
	local movedir_rot

	if action == "open" then
		movedir_rot = -math.pi/2
	else
		movedir_rot = math.pi/2
	end

	movedir_rot = is_mirrored and movedir_rot*-1 or movedir_rot

	return hlpfuncs.rot(dir, movedir_rot)
end

function multidecor.doors.smooth_movement(obj, node_dir, action, vel, is_mirrored)
	local move_dir = get_movement_dir(node_dir, action, is_mirrored)

	obj:set_velocity(move_dir*vel)
end

function multidecor.doors.track_movement(self)
	if self.dir == 0 or not self.dir then
		return
	end

	local cur_pos = self.object:get_pos()
	local target_pos = self.dir == 1 and self.end_v or self.start_v

	if math.abs(target_pos - cur_pos[self.move_axis]) <= 0.05 then
		self.dir = 0
		self.object:set_velocity(vector.zero())
		cur_pos[self.move_axis] = target_pos
		self.object:set_pos(cur_pos)
	end
end

function multidecor.doors.convert_to_entity(pos)
	local node = minetest.get_node(pos)
	local dir = hlpfuncs.get_dir(pos)

	local meta = minetest.get_meta(pos)
	local is_mir_cpart = meta:get_string("mirrored_counterpart") == "true"

	local mode = meta:get_string("door_mode")

	local is_open

	local door_data = minetest.registered_nodes[node.name].add_properties.door
	if door_data.type == "regular" then
		-- here 'is_open' means the open model version of the door
		is_open = (not is_mir_cpart and mode == "open") or (is_mir_cpart and mode == "closed")
	else
		is_open = mode == "open"
	end

	minetest.remove_node(pos)

	local obj_name = node.name

	if is_open and door_data.type == "regular" then
		obj_name = node.name:gsub("_open", "")
		dir = hlpfuncs.rot(dir, -math.pi/2)
	end

	if is_mir_cpart and door_data.type == "sliding" then
		obj_name = node.name:gsub("_mirrored", "")
	end

	local offset = vector.new(door_data.object_offset or {x=0.495, y=0, z=0.45})
	local shift = pos + offset
	local new_pos, rot = multidecor.doors.rotate(shift, dir, pos)

	local def = minetest.registered_entities[obj_name]

	local sbox, cbox
	local inv_dir = door_data.type == "sliding" and dir * -1 or dir
	sbox = hlpfuncs.rotate_bbox(def.selectionbox, inv_dir)

	if def.collisionbox then
		cbox = hlpfuncs.rotate_bbox(def.collisionbox, inv_dir)
	end

	local start_v, end_v
	local move_axis

	if door_data.type == "regular" then
		start_v = rot.y
		end_v = start_v + math.pi/2
	else
		local move_dir = get_movement_dir(dir, is_open and "close" or "open", is_mir_cpart)

		if move_dir.x ~= 0 then move_axis = "x"
		elseif move_dir.y ~= 0 then move_axis = "y"
		else move_axis = "z"
		end

		start_v = new_pos[move_axis]
		end_v = (new_pos + move_dir)[move_axis]

		if is_open then
			start_v, end_v = hlpfuncs.swap(start_v, end_v)
		end
	end

	if door_data.type == "regular" then
		if is_open then
			rot.y = end_v
		else
			rot.y = start_v
		end
	else
		rot.y = rot.y + math.pi
	end

	if door_data.type == "regular" and is_mir_cpart then
		is_open = not is_open
	end

	if door_data.sounds and not is_open then
		minetest.sound_play(door_data.sounds.open, {pos=pos, max_hear_distance=10})
	end

	local obj = minetest.add_entity(new_pos, obj_name)

	obj:set_rotation(rot)
	obj:set_properties({
		collisionbox = cbox,
		selectionbox = sbox
	})

	local self = obj:get_luaentity()
	self.start_v = start_v
	self.end_v = end_v
	self.move_axis = move_axis

	self.mirrored_counterpart = is_mir_cpart

	return obj
end

function get_dir_from_object_rot(obj)
	local y_rots_n = math.round(math.deg(obj:get_rotation().y) / 90)
	local dir = hlpfuncs.rot({x=0, y=0, z=1}, math.pi/2*y_rots_n)

	return dir
end

function multidecor.doors.convert_from_entity(obj)
	local dir = get_dir_from_object_rot(obj)

	local self = obj:get_luaentity()
	local door_data = minetest.registered_nodes[self.name].add_properties.door

	if door_data.type == "regular" then
		dir = dir * -1
	end
	local param2 = minetest.dir_to_facedir(dir)

	local pos = obj:get_pos()

	local is_closed = self.action == "close"

	local is_mir_cpart = self.mirrored_counterpart

	if door_data.sounds and is_closed then
		minetest.sound_play(door_data.sounds.close, {pos=pos, max_hear_distance=10})
	end

	local action = self.action
	local owner = self.owner
	local name = self.name

	obj:remove()

	if door_data.type == "regular" then
		if action == "open" and not is_mir_cpart or action == "close" and is_mir_cpart then
			name = name .. "_open"
		end
	end

	if door_data.type == "sliding" and is_mir_cpart then
		name = name .. "_mirrored"
	end

	minetest.set_node(pos, {name=name, param2=param2})

	local meta = minetest.get_meta(pos)
	if is_mir_cpart then
		meta:set_string("mirrored_counterpart", "true")
	end

	local new_mode = action == "close" and "closed" or "open"
	meta:set_string("door_mode", new_mode)

	if owner then
		meta:set_string("owner", owner)
		meta:set_string("infotext", "Owned by " .. owner)
	end
end

function multidecor.doors.node_on_rightclick(pos, node, clicker)
	local door_data = hlpfuncs.ndef(pos).add_properties.door

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local cur_mode = meta:get_string("door_mode")
	local is_mir_cpart = meta:get_string("mirrored_counterpart") == "true"

	if door_data.has_lock then
		local playername = clicker:get_player_name()
		if owner ~= playername then
			minetest.chat_send_player(playername, multidecor.S("This door has locked!"))
			return
		end
	end

	local node_dir = hlpfuncs.get_dir(pos)

	local dir_sign = 0
	local action

	if cur_mode == "closed" then
		dir_sign = 1
		action = "open"
	else
		dir_sign = -1
		action = "close"
	end

	if door_data.type == "regular" and is_mir_cpart then
		dir_sign = dir_sign * -1
	end

	if door_data.type == "sliding" then
		local move_dir = get_movement_dir(node_dir, action, is_mir_cpart)

		local place_check = multidecor.placement.check_for_placement(pos + move_dir, node.name)
		local next_node_free = multidecor.placement.is_free_space(pos + move_dir)
		if not place_check or not next_node_free then
			minetest.chat_send_player(clicker:get_player_name(), "Not enough free place to move the door!")
			return
		end
	end

	local obj = multidecor.doors.convert_to_entity(pos)

	local self = obj:get_luaentity()
	self.action = action

	if door_data.has_lock then
		self.owner = owner
	end

	multidecor.doors.set_dir(obj, dir_sign)

	if door_data.type == "sliding" then
		multidecor.doors.smooth_movement(obj, node_dir, self.action,
			door_data.vel or 1, is_mir_cpart)
	end
end

function multidecor.doors.after_place_node(pos, placer)
	local add_props = hlpfuncs.ndef(pos).add_properties

	local meta = minetest.get_meta(pos)
	meta:set_string("door_mode", "closed")

	if add_props.door.has_mirrored_counterpart then
		local dir = hlpfuncs.get_dir(pos)

		local to_left = hlpfuncs.rot(dir, -math.pi/2)
		local left_nodedef = hlpfuncs.ndef(pos + to_left)
		local left_dir = hlpfuncs.get_dir(pos + to_left)

		if left_nodedef.add_properties and left_nodedef.add_properties.common_name ==
			add_props.common_name and vector.equals(dir, left_dir) then

			local mirrored_door_name = add_props.door.type == "regular" and add_props.common_name .. "_open" or
				add_props.common_name .. "_mirrored"
			dir = add_props.door.type == "sliding" and dir*-1 or dir
			local mirrored_door_param2 = minetest.dir_to_facedir(dir)

			minetest.swap_node(pos, {name="multidecor:" .. mirrored_door_name, param2=mirrored_door_param2})
			meta:set_string("mirrored_counterpart", "true")
		end
	end

	if add_props.door.has_lock then
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Owned by " .. playername)
	end
end

function multidecor.doors.entity_on_rightclick(self, clicker)
	if self.owner and self.owner ~= clicker:get_player_name() then
		minetest.chat_send_player(multidecor.S("This door has locked!"))
		return
	end

	local dir_sign = 0
	if self.action == "open" then
		dir_sign = -1
		self.action = "close"
	else
		dir_sign = 1
		self.action = "open"
	end

	multidecor.doors.set_dir(self.object, dir_sign)

	local door_data = minetest.registered_nodes[self.name].add_properties.door

	if door_data.type == "sliding" then
		multidecor.doors.smooth_movement(self.object, get_dir_from_object_rot(self.object)*-1,
			self.action, door_data.vel or 1, self.mirrored_counterpart)
	end
end

function multidecor.doors.entity_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		self.dir = data[1]
		self.bbox = data[2]
		self.start_v = data[3]
		self.end_v = data[4]
		self.action = data[5]
		self.mirrored_counterpart = data[6]
		self.owner = data[7]
		self.move_axis = data[8]
		self.rotate_x = data[9]
	end

	if self.bbox and self.var_props then
		obj:set_properties({
			visual_size = self.var_props.visual_size,
			mesh = self.var_props.mesh,
			textures = self.var_props.textures,
			use_texture_alpha = self.var_props.use_texture_alpha,
			collisionbox = self.bbox,
			selectionbox = self.bbox
		})
	end

	self.object:set_armor_groups({immortal=1})
end

function multidecor.doors.entity_on_step(self, dtime)
	local door_data = minetest.registered_nodes[self.name].add_properties.door

	if door_data.type == "regular" then
		multidecor.doors.smooth_rotate_step(self, dtime, door_data.vel or 120, door_data.acc or 0)
	else
		multidecor.doors.track_movement(self)
	end

	if self.dir == 0 then
		multidecor.doors.convert_from_entity(self.object)
	end
end

function multidecor.doors.entity_get_staticdata(self)
	return minetest.serialize({
		self.dir, self.bbox,
		self.start_v, self.end_v, self.action,
		self.mirrored_counterpart, self.owner,
		self.move_axis, self.rotate_x
	})
end

function multidecor.register.register_door(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "door"

	if not add_def or not add_def.door then
		return
	end

	c_def.add_properties = add_def
	c_def.add_properties.door.type = c_def.add_properties.door.type or "regular"

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or multidecor.doors.node_on_rightclick
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or multidecor.doors.after_place_node

	multidecor.register.register_furniture_unit(name, c_def, craft_def)

	local type = c_def.add_properties.door.type
	local mesh_format = "." .. (c_def.add_properties.door.format or "b3d")
	
	local c_def2 = table.copy(c_def)

	if type == "regular" or (type == "sliding" and c_def.add_properties.door.has_mirrored_counterpart) then
		local endformat = type == "regular" and "_open" or ""
		c_def2.mesh = c_def2.mesh:gsub(mesh_format, endformat .. mesh_format)
		c_def2.drop = "multidecor:" .. name

		if type == "regular" then
			c_def2.bounding_boxes[1][3] = c_def2.bounding_boxes[1][3] * -1
			c_def2.bounding_boxes[1][6] = c_def2.bounding_boxes[1][6] * -1
		end

		c_def2.groups = c_def2.groups or {}
		c_def2.groups.not_in_creative_inventory = 1

		c_def2.callbacks.after_place_node = nil

		local endname = type == "regular" and "_open" or "_mirrored"
		multidecor.register.register_furniture_unit(name .. endname, c_def2)
	end

	local bbox = table.copy(base_def.bounding_boxes[1])

	local mesh = c_def.mesh

	if type == "regular" then
		local z_center = (bbox[3]+bbox[6])/2
		bbox[3] = bbox[3] - z_center
		bbox[6] = bbox[6] - z_center

		bbox[1] = bbox[1] - 0.5
		bbox[4] = bbox[4] - 0.5

		mesh = mesh:gsub(mesh_format, "_activated" .. mesh_format)
	end
	minetest.register_entity(":multidecor:" .. name, {
		visual = "mesh",
		visual_size = c_def.add_properties.door.size or {x=5, y=5, z=5},
		textures = base_def.tiles,
		mesh = mesh,
		physical = true,
		collisionbox = bbox,
		selectionbox = bbox,
		use_texture_alpha = base_def.use_texture_alpha == "blend",
		backface_culling = false,
		static_save = true,
		on_activate = multidecor.doors.entity_on_activate,
		on_rightclick = multidecor.doors.entity_on_rightclick,
		on_step = multidecor.doors.entity_on_step,
		get_staticdata = multidecor.doors.entity_get_staticdata
	})
end
