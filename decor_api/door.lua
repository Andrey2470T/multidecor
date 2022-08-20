multidecor.doors = {}

doors = multidecor.doors

-- Rotates an entity corresponding to the 'dir'
function doors.rotate(obj, dir, rotate_p)
	if not obj:get_luaentity() then
		return
	end
	local y_rot = vector.dir_to_rotation(dir).y

	local p = vector.copy(rotate_p)
	local rel_pos = obj:get_pos() - p

	local y_rel_pos_r = vector.dir_to_rotation(rel_pos).y
	rel_pos = vector.rotate_around_axis(rel_pos, {x=0, y=1, z=0}, y_rot)

	obj:set_pos(rotate_p + rel_pos)

	local obj_rot = obj:get_rotation()
	obj:set_rotation({x=obj_rot.x, y=y_rot, z=obj_rot.z})
end

-- Rotates obj's collision/selection boxes corresponding to the 'dir'
function doors.rotate_bbox(obj, dir, rotate_cbox)
	if not obj:get_luaentity() then
		return
	end

	local y_rot = vector.dir_to_rotation(dir).y

	local sel_box = minetest.registered_entities[obj:get_luaentity().name].selectionbox
	local box = {
		min = {x=sel_box[1], y=sel_box[2], z=sel_box[3]},
		max = {x=sel_box[4], y=sel_box[5], z=sel_box[6]}
	}

	box.min = vector.rotate_around_axis(box.min, {x=0, y=1, z=0}, y_rot)
	box.max = vector.rotate_around_axis(box.max, {x=0, y=1, z=0}, y_rot)

	local sbox = {box.min.x, box.min.y, box.min.z, box.max.x, box.max.y, box.max.z}
	obj:set_properties({selectionbox=sbox})
	obj:get_luaentity().bbox = sbox

	if rotate_cbox then
		local col_box = minetest.registered_entities[obj:get_luaentity().name].collisionbox
		local cbox = {
			min = {x=col_box[1], y=col_box[2], z=col_box[3]},
			max = {x=col_box[4], y=col_box[5], z=col_box[6]}
		}

		cbox.min = vector.rotate_around_axis(cbox.min, {x=0, y=1, z=0}, y_rot)
		cbox.max = vector.rotate_around_axis(cbox.max, {x=0, y=1, z=0}, y_rot)

		obj:set_properties({collisionbox={cbox.min.x, cbox.min.y, cbox.min.z, cbox.max.x, cbox.max.y, cbox.max.z}})
	end
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
		minetest.debug("the door is rotated!")
		self.dir = 0
		self.step_c = nil
		self.object:set_rotation({x=rot.x, y=target_rot, z=rot.z})
		return
	end

	self.step_c = self.step_c and self.step_c+acc or 1
	-- Rotation speed is 60 degrees/sec
	local sign = self.start_v > self.end_v and -1 or 1
	local new_rot = self.dir*sign*math.rad(vel)*dtime*0.5*self.step_c

	self.object:set_rotation({x=rot.x, y=rot.y+new_rot, z=rot.z})
end

function doors.convert_to_entity(pos)
	local node = minetest.get_node(pos)
	local dir = helpers.get_dir(pos)

	minetest.remove_node(pos)

	local is_open = minetest.registered_nodes[node.name].add_properties.door.mode == "open"

	local obj_name = is_open and node.name:gsub("_open", "") or node.name

	local shift = {x=pos.x+0.495, y=pos.y, z=pos.z+0.45}
	local obj = minetest.add_entity(shift, obj_name)

	if is_open then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
	end

	doors.rotate(obj, dir, pos)
	doors.rotate_bbox(obj, dir, true)

	local y_rot = vector.dir_to_rotation(dir).y

	local self = obj:get_luaentity()
	self.start_v = y_rot
	self.end_v = y_rot+math.pi/2

	if is_open then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)
		doors.rotate(obj, dir, shift)
		doors.rotate_bbox(obj, dir, true)
	end

	return obj
end

function doors.convert_from_entity(obj)
	local y_rots_n = math.round(math.deg(obj:get_rotation().y) / 90)
	local dir = vector.rotate_around_axis({x=0, y=0, z=1}, {x=0, y=1, z=0}, math.pi/2*y_rots_n)*-1
	local param2 = minetest.dir_to_facedir(dir)

	local pos = obj:get_pos()
	local self = obj:get_luaentity()
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
	self.dir = self.dir * -1
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

	minetest.register_entity(":multidecor:" .. name, {
		visual = "mesh",
		visual_size = {x=5, y=5, z=5},
		textures = base_def.tiles,
		mesh = c_def2.add_properties.door.mesh_activated,
		collisionbox = base_def.bounding_boxes[1],
		selectionbox = base_def.bounding_boxes[1],
		backface_culling = false,
		static_save = true,
		on_activate = default_entity_door_on_activate,
		on_rightclick = default_entity_door_on_rightclick,
		on_step = default_entity_door_on_step,
		get_staticdata = default_entity_door_get_staticdata
	})
end
