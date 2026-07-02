multidecor.doors = {}

local doors = multidecor.doors
local hlpfuncs = multidecor.helpers

-- Returns position, collision and selection boxes rotated according to "dir" and rotation itself
function doors.rotate(nodepos, dir, add_data)
	local offset = vector.new(add_data.door.object_offset or {x=0.495, y=0, z=0.45})
	offset = hlpfuncs.rotate_to_dir(offset, dir)

	local def = core.registered_entities[add_data.common_name]

	local sbox, cbox
	local inv_dir = add_data.door.type == "sliding" and dir * -1 or dir
	sbox = hlpfuncs.rotate_bbox(def.selectionbox, inv_dir)

	if def.collisionbox then
		cbox = hlpfuncs.rotate_bbox(def.collisionbox, inv_dir)
	end

	return nodepos + offset, hlpfuncs.get_rot_y(dir), cbox, sbox
end

-- Animates the door object (open/close) by moving the bone and running the timer in step()
function doors.animate(bone_obj, door_type, velocity, target_offset, move_axis)
	local anim_time = target_offset / velocity
	local bone_override = door_type == "regular" and
		{rotation={vec=target_offset, interpolation=anim_time}} or
		{position={vec=target_offset, interpolation=anim_time}}
	bone_obj:set_bone_override("Door", bone_override)

	local bone_self = bone_obj:get_luaentity()
	bone_self.timer = anim_time
end

-- Adds the bone handling the open/close animation and door entity itself 
function doors.add_door(doorname, pos, rot_y, cbox, sbox, mirrored, door_type, velocity, target_offset, move_axis, owner)
	local bone_serialize_data = {
		target_offset=target_offset,
		move_axis=move_axis,
		cur_time = 0,
		timer=0
	}
	local bone_obj = core.add_entity(pos, "multidecor:door_dummy", core.serialize(bone_serialize_data))

	bone_obj:set_rotation(vector.new(0, rot_y, 0))

	local door_serialize_data = {
		cbox=cbox, sbox=sbox,
		mirrored=mirrored,
		owner = owner,
	}
	local door_obj = core.add_entity(pos, doorname, core.serialize(door_serialize_data))
	door_obj:set_attach(bone_obj, "Door")

	if target_offset and target_offset ~= 0 then
		doors.animate(bone_obj, door_type, velocity, target_offset, move_axis)
	end

	return bone_obj
end

function get_movement_dir(dir, is_open, is_mirrored)
	local movedir_rot = is_open and math.pi/2 or -math.pi/2
	movedir_rot = is_mirrored and -movedir_rot or movedir_rot

	return hlpfuncs.rot(dir, movedir_rot)
end

function get_target_offset(door_type, dir, is_open, is_mirrored)
	if door_type == "regular" then
		local rot_offset = is_open and -math.pi/2 or math.pi/2
		rot_offset = is_mirrored and -rot_offset or rot_offset

		return rot_offset
	end

	local movedir = get_movement_dir(dir, is_open, is_mirrored)

	local move_axis
	if movedir.x ~= 0 then move_axis = "x"
	elseif movedir.y ~= 0 then move_axis = "y"
	else move_axis = "z"
	end

	return movedir[move_axis], move_axis
end

function doors.convert_to_entity(pos, clickername)
	local dir = hlpfuncs.get_dir(pos)

	local meta = core.get_meta(pos)
	local is_mir_cpart = meta:get_string("mirrored_counterpart") == "true"

	local mode = meta:get_string("door_mode")

	local is_open = mode == "open"

	local add_data = hlpfuncs.ndef(pos).add_properties
	if add_data.door.type == "regular" then
		-- here 'is_open' means the open model version of the door
		is_open = (not is_mir_cpart and mode == "open") or (is_mir_cpart and mode == "closed")
	end

	core.remove_node(pos)

	local new_pos, rot_y, cbox, sbox = doors.rotate(pos, dir, add_data)

	if add_data.door.type == "regular" then
		rot_y = is_open and rot_y+math.pi/2 or rot_y
	else
		rot_y = rot_y + math.pi
	end

	local offset, move_axis = get_target_offset(add_data.door.type, dir, is_open, is_mir_cpart)

	if add_data.door.sounds and mode == "closed" then
		core.sound_play(add_data.door.sounds.open, {pos=pos, max_hear_distance=10})
	end

	return doors.add_door(add_data.common_name, new_pos, rot_y, cbox, sbox, is_mir_cpart,
		add_data.door.type, add_data.door.vel, offset, move_axis, clickername)
end

function get_dir_from_object_rot(obj)
	local y_rots_n = math.round(obj:get_rotation().y / math.pi/2)
	local dir = hlpfuncs.rot({x=0, y=0, z=1}, math.pi/2*y_rots_n)

	return dir
end

function doors.convert_from_entity(bone_obj)
	local dir = get_dir_from_object_rot(bone_obj)

	local self = obj:get_luaentity()
	local door_data = core.registered_nodes[self.name].add_properties.door

	if door_data.type == "regular" then
		dir = dir * -1
	end
	local param2 = core.dir_to_facedir(dir)

	local pos = obj:get_pos()

	local is_closed = self.action == "close"

	local is_mir_cpart = self.mirrored_counterpart

	if door_data.sounds and is_closed then
		core.sound_play(door_data.sounds.close, {pos=pos, max_hear_distance=10})
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

	core.set_node(pos, {name=name, param2=param2})

	local meta = core.get_meta(pos)
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

function doors.node_on_rightclick(pos, node, clicker)
	local def = hlpfuncs.ndef(pos)

    if not def.add_properties or not def.add_properties.door then
        core.log("error", "Node at " .. core.pos_to_string(pos) .. " has no add_properties.door!")
        return
    end

    local door_data = def.add_properties.door
    local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local cur_mode = meta:get_string("door_mode")
	local is_mir_cpart = meta:get_string("mirrored_counterpart") == "true"

	if door_data.has_lock then
		local playername = clicker:get_player_name()
		if owner ~= playername then
			core.chat_send_player(playername, multidecor.S("This door has locked!"))
			return
		end
	end

	local node_dir = hlpfuncs.get_dir(pos)

	local is_open = cur_mode == "closed"

	if door_data.type == "sliding" then
		local move_dir = get_movement_dir(node_dir, is_open, is_mir_cpart)

		local place_check = multidecor.placement.check_for_placement(pos + move_dir, node.name)
		local next_node_free = multidecor.placement.is_free_space(pos + move_dir)
		if not place_check or not next_node_free then
			core.chat_send_player(clicker:get_player_name(), "Not enough free place to move the door!")
			return
		end
	end

	doors.convert_to_entity(pos, owner)
end

function doors.after_place_node(pos, placer)
	local add_props = hlpfuncs.ndef(pos).add_properties

	local meta = core.get_meta(pos)
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
			local mirrored_door_param2 = core.dir_to_facedir(dir)

			core.swap_node(pos, {name="multidecor:" .. mirrored_door_name, param2=mirrored_door_param2})
			meta:set_string("mirrored_counterpart", "true")
		end
	end

	if add_props.door.has_lock then
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Owned by " .. playername)
	end
end

--[[function doors.door_entity_on_rightclick(self, clicker)
	local playername = clicker:get_player_name()
	if self.owner and self.owner ~= playername then
		core.chat_send_player(playername, multidecor.S("This door has locked!"))
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

	doors.set_dir(self.object, dir_sign)

	local door_data = core.registered_nodes[self.name].add_properties.door

	if door_data.type == "sliding" then
		doors.smooth_movement(self.object, get_dir_from_object_rot(self.object)*-1,
			self.action, door_data.vel or 1, self.mirrored_counterpart)
	end
end]]

function doors.bone_entity_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = core.deserialize(staticdata)
		self.target_offset = data.target_offset
		self.move_axis = data.move_axis
		self.cur_time = data.cur_time
		self.timer = data.timer
	end
end

function doors.door_entity_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = core.deserialize(staticdata)
		self.cbox = data.cbox
		self.sbox = data.sbox
		self.mirrored = data.mirrored
		self.owner = data.owner
	end

	if self.bbox or self.mirrored then
		local visual_size = self.object:get_properties().visual_size
		visual_size.x = self.mirrored and -visual_size.x or visual_size.x
		self.object:set_properties({
			visual_size = visual_size,
			collisionbox = self.bbox,
			selectionbox = self.bbox
		})
	end

	self.object:set_armor_groups({immortal=1})
end

function doors.bone_entity_on_step(self, dtime)
	if self.timer == 0 then
		return
	end

	self.cur_time = self.cur_time + dtime

	if self.cur_time >= self.timer then
		doors.convert_from_entity(self.object)
	end
end

function doors.bone_entity_get_staticdata(self)
	return core.serialize({
		target_offset = self.target_offset,
		move_axis = self.move_axis,
		cur_time = self.cur_time,
		timer = self.timer
	})
end

function doors.door_entity_get_staticdata(self)
	return core.serialize({
		cbox = self.cbox,
		sbox = self.sbox,
		mirrored = self.mirrored,
		owner = self.owner,
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
	
	if c_def.add_properties.door.type == "regular" then
		c_def.add_properties.door.vel = c_def.add_properties.door.vel or 2*math.pi/3 -- 120 degrees default
	else
		c_def.add_properties.door.vel = c_def.add_properties.door.vel or 1
	end

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or doors.node_on_rightclick
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or doors.after_place_node

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
	core.register_entity(":multidecor:" .. name, {
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
		on_activate = doors.door_entity_on_activate,
		--on_rightclick = doors.door_entity_on_rightclick,
		get_staticdata = doors.door_entity_get_staticdata
	})
end

-- Registers the dummy entity (single bone) for attaching various kinds of doors/drawers
core.register_entity(":multidecor:door_dummy", {
	visual = "mesh",
	mesh = "door_dummy.glb",
	static_save = true,
	on_activate = doors.bone_entity_on_activate,
	on_step = doors.bone_entity_on_step,
	get_staticdata = doors.bone_entity_get_staticdata
})
