multidecor.animation = {}

local hlpfuncs = multidecor.helpers

multidecor.animation.animator_name = "multidecor:animator"
multidecor.animation.default_offset = {x=-0.495, y=0, z=-0.45}

-- Returns position, collision and selection boxes rotated according to "dir" and rotation itself
function multidecor.animation.rotate(nodepos, dir, box, offset)
	offset = vector.new(offset or multidecor.animation.default_offset)
	offset = hlpfuncs.rotate_to_dir(offset, dir)

	box = hlpfuncs.rotate_bbox(box, dir)

	return nodepos + offset, {x=0, y=hlpfuncs.get_rot_y(dir), z=0}, box
end

-- Animates the door object (open/close) by moving the bone and running the anim_duration in step()
function multidecor.animation.animate(anim_obj, rotate, velocity, target_offset)
	local anim_time = target_offset / velocity
	local override = {vec=target_offset, interpolation=anim_time}
	anim_obj:set_bone_override("Door", rotate and {rotation=override} or {position=override})

	local self = anim_obj:get_luaentity()
	self.anim_duration = anim_time
end

-- Adds the bone handling the open/close animation and door entity itself 
function multidecor.animation.add_and_animate(pos, rot, velocity, rotate, target_offset, animator_data)
	local serialize_data = table.copy(animator_data)
	serialize_data.rotate = rotate
	serialize_data.target_offset = target_offset
	serialize_data.cur_time = 0
	serialize_data.anim_duration = 0

	local anim_obj = core.add_entity(pos, multidecor.animation.animator_name, core.serialize(serialize_data))
	anim_obj:set_rotation(rot)

	if target_offset and target_offset ~= 0 then
		multidecor.animation.animate(anim_obj, rotate, velocity, target_offset[animator_data.target_axis])
	end

	return anim_obj
end

local function get_rot_offset_dir(start_dir, closed, mirrored, move_dir, invert_dir)
	local dir = start_dir
	if not closed then dir = invert_dir end -- for the left door and inside animation
	if mirrored then dir = -dir end -- for the right door and inside animation
	if move_dir == "outside" then dir = -dir end -- invert if the animation is outside

	return dir
end

-- "move_dir" defines the move direction ("inside", "outside")
function multidecor.animation.add(nodepos, closed, rotate, move_dir, mirrored, animator_data)
	local dir = hlpfuncs.get_dir(nodepos)

	local data = animator_data.object_data

	local offset = data.offset
	local box_length = data.box[4]-data.box[1]
	offset.x = mirrored and offset.x+box_length or offset.x

	local pos, rot, new_box = multidecor.animation.rotate(
		nodepos, dir, data.box, offset)
	data.box = new_box
	
	local target_offset = data.target_offset

	if rotate then
		local start_rot_dir = 0
		start_rot_dir = get_rot_offset_dir(start_rot_dir, closed, mirrored, move_dir, -1)
		rot[data.target_axis] = rot[data.target_axis] + start_rot_dir * target_offset

		local rot_dir = -1
		rot_dir = get_rot_offset_dir(rot_dir, closed, mirrored, move_dir, 1)
		target_offset = target_offset * rot_dir
	else
		local start_shift_dir = 0
		if not closed then start_shift_dir = 1 end
		pos[data.target_axis] = pos[data.target_axis] + start_shift_dir * target_offset

		local shift_dir = closed and 1 or -1
		target_offset = target_offset * shift_dir
	end

	local target_offset_v = vector.new()
	target_offset_v[data.target_axis] = target_offset

	return multidecor.animation.add_and_animate(pos, rot, data.velocity, rotate, target_offset_v, animator_data)
end

local function animator_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = core.deserialize(staticdata)
		self.object_data = data.object_data or {}
		self.rotate = data.rotate
		self.target_offset = data.target_offset
		self.cur_time = data.cur_time
		self.anim_duration = data.anim_duration
	end

	local size = self.object_data.size

	if self.object_data.mirrored then
		size.x = -size.x
	end

	self.object:set_properties({
		visual_size = size,
		mesh = self.object_data.mesh,
		textures = self.object_data.textures,
		collisionbox = self.object_data.box,
		selectionbox = self.object_data.box
	})

	self.object:set_armor_groups({immortal=1})
end

local function animator_on_step(self, dtime)
	if self.anim_duration == 0 then
		return
	end

	self.cur_time = self.cur_time + dtime

	if self.cur_time >= self.anim_duration then
		local data = self.object_data

		if data.rotate then
			self.object:set_rotation(self.object:get_rotation()+data.target_offset)
		else
			self.object:set_pos(self.object:get_pos()+data.target_offset)
		end
		if data.callback then
			data.callback(self.object)
		end
	end
end

local function animator_get_staticdata(self)
	return core.serialize({
		object_data = self.object_data,
		rotate = self.rotate,
		target_offset = self.target_offset,
		cur_time = self.cur_time,
		anim_duration = self.anim_duration
	})
end

-- Registers the dummy entity (single bone) for attaching various kinds of doors/drawers
core.register_entity(":" .. multidecor.animation.animator_name, {
	visual_size = {x=5, y=5, z=5},
	visual = "mesh",
	mesh = "door_dummy.glb",
	physical = true,
	use_texture_alpha = "blend",
	backface_culling = false,
	static_save = true,
	on_activate = animator_on_activate,
	on_step = animator_on_step,
	get_staticdata = animator_get_staticdata
})