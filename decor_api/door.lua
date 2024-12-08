multidecor.doors = {}


-- Returns new position rotated around 'rotate_p' and rotation correponding to "dir"
function multidecor.doors.rotate(pos, dir, rotate_p)
	local y_rot = vector.dir_to_rotation(dir).y
	local rel_pos = pos - rotate_p

	rel_pos = hlpfuncs.rot(rel_pos, y_rot)

	return rotate_p + rel_pos, {x=0, y=y_rot, z=0}
end

-- Activates obj rotation from 'self.start_v' to 'self.end_v' or vice versa depending on 'dir_sign' value
function multidecor.doors.smooth_rotate(obj, dir_sign)
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

	rot[rot_axis] = hlpfuncs.clamp(self.start_v, self.end_v, rot[rot_axis])

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

	rot[rot_axis] = rot[rot_axis]+new_rot
	self.object:set_rotation(rot)
end

function multidecor.doors.convert_to_entity(pos)
	local node = minetest.get_node(pos)
	local dir = hlpfuncs.get_dir(pos)

	local meta = minetest.get_meta(pos)


	local is_mir_cpart = minetest.get_meta(pos):get_string("mirrored_counterpart") == "true"
	minetest.remove_node(pos)

	local add_props = minetest.registered_nodes[node.name].add_properties
	local is_open = add_props.door.mode == "open"

	local obj_name = is_open and node.name:gsub("_open", "") or node.name

	if is_open then
		dir = hlpfuncs.rot(dir, -math.pi/2)
	end

	local shift = {x=pos.x+0.495, y=pos.y, z=pos.z+0.45}
	local new_pos, rot = multidecor.doors.rotate(shift, dir, pos)

	local def = minetest.registered_entities[obj_name]

	local sbox, cbox
	sbox = hlpfuncs.rotate_bbox(def.selectionbox, dir)

	if def.collisionbox then
		cbox = hlpfuncs.rotate_bbox(def.collisionbox, dir)
	end

	local start_r, end_r = rot.y, rot.y+math.pi/2

	if is_open then
		rot.y = end_r
	else
		rot.y = start_r
	end

	if is_mir_cpart then
		is_open = not is_open
	end

	if add_props.door.sounds and not is_open then
		minetest.sound_play(add_props.door.sounds.open, {pos=pos, max_hear_distance=10})
	end

	local obj = minetest.add_entity(new_pos, obj_name)
	obj:set_rotation(rot)
	obj:set_properties({
		collisionbox = cbox,
		selectionbox = sbox
	})

	local self = obj:get_luaentity()
	self.start_v = start_r
	self.end_v = end_r

	if is_mir_cpart then
		self.mirrored_counterpart = true
	end

	return obj
end

function multidecor.doors.convert_from_entity(obj)
	local y_rots_n = math.round(math.deg(obj:get_rotation().y) / 90)
	local dir = hlpfuncs.rot({x=0, y=0, z=1}, math.pi/2*y_rots_n)*-1
	local param2 = minetest.dir_to_facedir(dir)

	local pos = obj:get_pos()
	local self = obj:get_luaentity()

	local is_mir_cpart = self.mirrored_counterpart
	local add_props = minetest.registered_nodes[self.name].add_properties

	local is_closed = self.action == "close"

	if is_mir_cpart then
		is_closed = not is_closed
	end

	if add_props.door.sounds and is_closed then
		minetest.sound_play(add_props.door.sounds.close, {pos=pos, max_hear_distance=10})
	end

	obj:remove()

	local name = self.action == "open" and self.name .. "_open" or self.name

	minetest.set_node(pos, {name=name, param2=param2})

	local meta = minetest.get_meta(pos)
	if is_mir_cpart then
		meta:set_string("mirrored_counterpart", "true")
	end

	if self.owner then
		meta:set_string("owner", self.owner)
		meta:set_string("infotext", "Owned by " .. self.owner)
	end
end

function multidecor.doors.default_node_on_rightclick(pos, node, clicker)
	local door_data = hlpfuncs.ndef(pos).add_properties.door

	local owner = minetest.get_meta(pos):get_string("owner")

	if door_data.has_lock then
		local playername = clicker:get_player_name()
		if owner ~= playername then
			minetest.chat_send_player(playername, multidecor.S("This door has locked!"))
			return
		end
	end

	local obj = multidecor.doors.convert_to_entity(pos)

	local self = obj:get_luaentity()
	local dir_sign = 0
	if door_data.mode == "closed" then
		dir_sign = 1
		self.action = "open"
	else
		dir_sign = -1
		self.action = "close"
	end

	if door_data.has_lock then
		self.owner = owner
	end

	multidecor.doors.smooth_rotate(obj, dir_sign)
end

function multidecor.doors.default_after_place_node(pos, placer)
	local nodedef = hlpfuncs.ndef(pos)

	if nodedef.add_properties.door.has_mirrored_counterpart then
		local dir = hlpfuncs.get_dir(pos)

		local to_left = hlpfuncs.rot(dir, -math.pi/2)
		local left_nodedef = hlpfuncs.ndef(pos + to_left)
		local left_dir = hlpfuncs.get_dir(pos + to_left)

		if left_nodedef.add_properties and left_nodedef.add_properties.common_name ==
			nodedef.add_properties.common_name and vector.equals(dir, left_dir) then

			local open_door_name = nodedef.add_properties.common_name .. "_open"
			local open_door_param2 = minetest.dir_to_facedir(dir)

			minetest.set_node(pos, {name="multidecor:" .. open_door_name, param2=open_door_param2})

			minetest.get_meta(pos):set_string("mirrored_counterpart", "true")
		end
	end

	if nodedef.add_properties.door.has_lock then
		local meta = minetest.get_meta(pos)
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Owned by " .. playername)
	end
end

function multidecor.doors.default_entity_on_rightclick(self, clicker)
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

	multidecor.doors.smooth_rotate(self.object, dir_sign)
end

function multidecor.doors.default_entity_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		self.dir = data[1]
		self.bbox = data[2]
		self.start_v = data[3]
		self.end_v = data[4]
		self.action = data[5]
		self.mirrored_counterpart = data[6]
		self.owner = data[7]
	end

	if self.bbox then
		obj:set_properties({
			collisionbox = self.bbox,
			selectionbox = self.bbox
		})
	end

	self.object:set_armor_groups({immortal=1})
end

function multidecor.doors.default_entity_on_step(self, dtime)
	local door_data = minetest.registered_nodes[self.name].add_properties.door

	multidecor.doors.smooth_rotate_step(self, dtime, door_data.vel or 30, door_data.acc or 0)

	if self.dir == 0 then
		multidecor.doors.convert_from_entity(self.object)
	end
end

function multidecor.doors.default_entity_get_staticdata(self)
	return minetest.serialize({self.dir, self.bbox,
		self.start_v, self.end_v, self.action, self.mirrored_counterpart, self.owner})
end

function multidecor.register.register_door(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "door"

	if not add_def or not add_def.door then
		return
	end

	c_def.add_properties = add_def
	c_def.add_properties.door.mode = "closed"

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or multidecor.doors.default_node_on_rightclick
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or multidecor.doors.default_after_place_node

	multidecor.register.register_furniture_unit(name, c_def, craft_def)

	local c_def2 = table.copy(c_def)
	c_def2.add_properties.door.mode = "open"
	c_def2.mesh = c_def2.add_properties.door.mesh_open
	c_def2.drop = "multidecor:" .. name
	c_def2.bounding_boxes[1][3] = c_def2.bounding_boxes[1][3] * -1
	c_def2.bounding_boxes[1][6] = c_def2.bounding_boxes[1][6] *-1

	c_def2.groups = c_def2.groups or {}
	c_def2.groups.not_in_creative_inventory = 1

	c_def2.callbacks.after_place_node = nil

	multidecor.register.register_furniture_unit(name .. "_open", c_def2)

	local bbox = table.copy(base_def.bounding_boxes[1])
	local z_center = (bbox[3]+bbox[6])/2
	bbox[3] = bbox[3] - z_center
	bbox[6] = bbox[6] - z_center

	bbox[1] = bbox[1] - 0.5
	bbox[4] = bbox[4] - 0.5
	minetest.register_entity(":multidecor:" .. name, {
		visual = "mesh",
		visual_size = {x=5, y=5, z=5},
		textures = base_def.tiles,
		mesh = c_def2.add_properties.door.mesh_activated,
		physical = true,
		collisionbox = bbox,
		selectionbox = bbox,
		use_texture_alpha = base_def.use_texture_alpha == "blend",
		backface_culling = false,
		static_save = true,
		on_activate = multidecor.doors.default_entity_on_activate,
		on_rightclick = multidecor.doors.default_entity_on_rightclick,
		on_step = multidecor.doors.default_entity_on_step,
		get_staticdata = multidecor.doors.default_entity_get_staticdata
	})
end
