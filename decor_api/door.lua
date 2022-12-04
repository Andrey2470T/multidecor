multidecor.doors = {}

local doors = multidecor.doors

-- Returns new position rotated around 'rotate_p' and rotation correponding to "dir"
function doors.rotate(pos, dir, rotate_p)
	local y_rot = vector.dir_to_rotation(dir).y
	local rel_pos = pos - rotate_p

	rel_pos = vector.rotate_around_axis(rel_pos, {x=0, y=1, z=0}, y_rot)

	return rotate_p + rel_pos, {x=0, y=y_rot, z=0}
end

-- Returns rotated collisionbox and selectionbox corresponding to "dir"
function doors.rotate_bbox(sbox, cbox, dir)
	local y_rot = vector.dir_to_rotation(dir).y

	local box = {
		min = {x=sbox[1], y=sbox[2], z=sbox[3]},
		max = {x=sbox[4], y=sbox[5], z=sbox[6]}
	}

	box.min = vector.rotate_around_axis(box.min, {x=0, y=1, z=0}, y_rot)
	box.max = vector.rotate_around_axis(box.max, {x=0, y=1, z=0}, y_rot)

	local new_sbox = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z}
	local new_cbox

	if cbox then
		box = {
			min = {x=cbox[1], y=cbox[2], z=cbox[3]},
			max = {x=cbox[4], y=cbox[5], z=cbox[6]}
		}

		box.min = vector.rotate_around_axis(box.min, {x=0, y=1, z=0}, y_rot)
		box.max = vector.rotate_around_axis(box.max, {x=0, y=1, z=0}, y_rot)

		new_cbox = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z}
	end

	return new_sbox, new_cbox
end

-- Activates obj rotation from 'self.start_v' to 'self.end_v' or vice versa depending on 'dir_sign' value
function doors.smooth_rotate(obj, dir_sign)
	local self = obj:get_luaentity()
	if not self then
		return
	end

	self.dir = dir_sign

end

-- Step of obj rotation
function doors.smooth_rotate_step(self, dtime, vel, acc)
	if self.dir == 0 or not self.dir then
		return
	end

	local rot = self.object:get_rotation()
	local target_rot = self.dir == 1 and self.end_v or self.start_v

	rot.y = helpers.clamp(self.start_v, self.end_v, rot.y)

	if math.abs(target_rot-rot.y) <= math.rad(10) then
		self.dir = 0
		self.step_c = nil
		self.object:set_rotation({x=rot.x, y=target_rot, z=rot.z})
		return
	end

	self.step_c = self.step_c and self.step_c+acc or 1
	-- Rotation speed is 60 degrees/sec
	local sign = self.start_v > self.end_v and -1 or 1
	local new_rot = self.dir*sign*math.rad(vel)*dtime*self.step_c

	self.object:set_rotation({x=rot.x, y=rot.y+new_rot, z=rot.z})
end

function doors.convert_to_entity(pos)
	local node = minetest.get_node(pos)
	local dir = helpers.get_dir(pos)

	minetest.remove_node(pos)

	local add_props = minetest.registered_nodes[node.name].add_properties
	local is_open = add_props.door.mode == "open"

	local obj_name = is_open and node.name:gsub("_open", "") or node.name

	if is_open then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
	end

	local shift = {x=pos.x+0.495, y=pos.y, z=pos.z+0.45}
	local new_pos, rot = doors.rotate(shift, dir, pos)

	local def = minetest.registered_entities[obj_name]
	local sbox, cbox = doors.rotate_bbox(def.selectionbox, def.collisionbox, dir)

	local y_rot = vector.dir_to_rotation(dir).y
	local start_r, end_r = y_rot, y_rot+math.pi/2

	if is_open then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)
		local new_pos2, rot2 = doors.rotate(new_pos, dir, shift)
		rot = rot2
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

	return obj
end

function doors.convert_from_entity(obj)
	local y_rots_n = math.round(math.deg(obj:get_rotation().y) / 90)
	local dir = vector.rotate_around_axis({x=0, y=0, z=1}, {x=0, y=1, z=0}, math.pi/2*y_rots_n)*-1
	local param2 = minetest.dir_to_facedir(dir)

	local pos = obj:get_pos()
	local self = obj:get_luaentity()

	local add_props = minetest.registered_nodes[self.name].add_properties

	if add_props.door.sounds and self.action == "close" then
		minetest.sound_play(add_props.door.sounds.close, {pos=pos, max_hear_distance=10})
	end

	obj:remove()

	local name = self.action == "open" and self.name .. "_open" or self.name

	minetest.set_node(pos, {name=name, param2=param2})
end

local function default_door_on_rightclick(pos)
	local door_data = minetest.registered_nodes[minetest.get_node(pos).name].add_properties.door

	local obj = doors.convert_to_entity(pos)
	local self = obj:get_luaentity()
	local dir_sign = 0
	if door_data.mode == "closed" then
		dir_sign = 1
		self.action = "open"
	else
		dir_sign = -1
		self.action = "close"
	end

	doors.smooth_rotate(obj, dir_sign)
end

local function default_entity_door_on_rightclick(self)
	local dir_sign = 0
	if self.action == "open" then
		dir_sign = -1
		self.action = "close"
	else
		dir_sign = 1
		self.action = "open"
	end

	doors.smooth_rotate(self.object, dir_sign)
end

local function default_entity_door_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		self.dir = data[1]
		self.bbox = data[2]
		self.start_v = data[3]
		self.end_v = data[4]
		self.action = data[5]
	end

	if self.bbox then
		obj:set_properties({
			collisionbox = self.bbox,
			selectionbox = self.bbox
		})
	end
end

local function default_entity_door_on_step(self, dtime)
	local door_data = minetest.registered_nodes[self.name].add_properties.door

	doors.smooth_rotate_step(self, dtime, door_data.vel or 30, door_data.acc or 0)

	if self.dir == 0 then
		doors.convert_from_entity(self.object)
	end
end

local function default_entity_door_get_staticdata(self)
	return minetest.serialize({self.dir, self.bbox, self.start_v, self.end_v, self.action})
end

function register.register_door(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "table"

	if add_def then
		if add_def.recipe then
			return
		else
			c_def.add_properties = add_def
		end
	end

	c_def.add_properties.door.mode = "closed"

	if c_def.callbacks then
		c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or default_door_on_rightclick
	else
		c_def.callbacks = {on_rightclick = default_door_on_rightclick}
	end

	register.register_furniture_unit(name, c_def, craft_def)

	local c_def2 = table.copy(c_def)
	c_def2.add_properties.door.mode = "open"
	c_def2.mesh = c_def2.add_properties.door.mesh_open
	c_def2.drop = "multidecor:" .. name
	c_def2.bounding_boxes[1][3] = c_def2.bounding_boxes[1][3] * -1
	c_def2.bounding_boxes[1][6] = c_def2.bounding_boxes[1][6] *-1

	if c_def2.groups then
		c_def2.groups.not_in_creative_inventory = 1
	else
		c_def2.groups = {not_in_creative_inventory=1}
	end

	register.register_furniture_unit(name .. "_open", c_def2)

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
		on_activate = default_entity_door_on_activate,
		on_rightclick = default_entity_door_on_rightclick,
		on_step = default_entity_door_on_step,
		get_staticdata = default_entity_door_get_staticdata
	})
end
