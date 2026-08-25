local hlpfuncs = multidecor.helpers

-- Door/drawer object animator class
----------------------------------------------------------

multidecor.DoorAnimator = {
	obj_name = "multidecor:animator",
	bone_name = "Door",

	model_params = {
		size = {x=5, y=5, z=5},
		mesh = "",
		textures = {},
		box = hlpfuncs.BBox.from_default(),
		mirrored = false,
		pos = vector.new(-0.495, 0, -0.45),
		rot = vector.new()
	},
	anim_params = {
		rotate = true,
		target_axis = "y",
		target_offset = math.pi/2,
		velocity = math.pi/1.5,		-- within a sec
		rotate_dir = "inward"		-- the doors can be open inward or outward
	},
	timer = hlpfuncs.Timer.new(0, function (data)
		if data.rotate then
			data.obj:set_rotation(data.target)
		else
			data.obj:set_pos(data.target)
		end
		data.obj:set_properties({
			collisionbox = data.box,
			selectionbox = data.box
		})
		if data.callback then
			data.callback(data.obj)
		end
	end, {}),

	nodepos = vector.new(),
	obj = nil,
	cur_mode = "closed"
}

multidecor.DoorAnimator.__index = multidecor.DoorAnimator

function multidecor.DoorAnimator.new(_nodepos, _model_params, _anim_params)
	local self = setmetatable({}, multidecor.DoorAnimator)

	self.nodepos = _nodepos

	self.model_params.size = _model_params.size or self.model_params.size
	self.model_params.mesh = _model_params.mesh or self.model_params.mesh
	self.model_params.textures = _model_params.textures or self.model_params.textures
	self.model_params.box = _model_params.box or self.model_params.box
	self.model_params.mirrored = _model_params.mirrored or self.model_params.mirrored
	self.model_params.pos = _model_params.pos or self.model_params.pos
	self.model_params.rot = _model_params.rot or self.model_params.rot

	self.anim_params.rotate = _anim_params.rotate or self.anim_params.rotate
	self.anim_params.target_axis = _anim_params.target_axis or self.anim_params.target_axis
	self.anim_params.target_offset = _anim_params.target_offset or self.anim_params.target_offset
	self.anim_params.velocity = _anim_params.velocity or self.anim_params.velocity
	self.anim_params.rotate_dir = _anim_params.rotate_dir or self.anim_params.rotate_dir

	self.cur_pos = self.nodepos + self.model_params.pos
	self.cur_rot = self.model_params.rot

	self.timer.callback_data.rotate = self.anim_params.rotate

	local serialize_data = {model_params=self.model_params, anim_params=self.anim_params, timer=self.timer}
	self.obj = core.add_entity(self.cur_pos, self.obj_name, core.serialize(serialize_data))
	self.obj:set_rotation(self.cur_rot)

	self.timer.callback_data.rotate = self.anim_params.rotate
	self.timer.callback_data.box = self.model_params.box
	self.timer.callback_data.obj = self.obj
	self.timer.callback_data.callback = _anim_params.callback

	self:update_mode("closed")

	return self
end

function multidecor.DoorAnimator:animate()
	local anim_time = math.abs(self.target_offset[self.anim_params.target_axis]) / self.anim_params.velocity
	local override

	if self.anim_params.rotate then
		self.target = self.cur_rot + self.target_offset
		override = {rotation = {vec = self.target, interpolation=anim_time}}
	else
		self.target = self.cur_pos + self.target_offset
		override = {position = {vec = self.target, interpolation=anim_time}}
	end
	self.obj:set_bone_override("Door", override)

	self.timer.callback_data.target = self.target
	self.timer:start(anim_time)
end

function multidecor.DoorAnimator:update_model()
	local size = self.model_params.size

	if self.model_params.mirrored then
		size.x = -size.x
	end

	self.obj:set_properties({
		visual_size = size,
		mesh = self.model_params.mesh,
		textures = self.model_params.textures,
		collisionbox=self.model_params.box:get_coords(),
		selectionbox=self.model_params.box:get_coords()
	})
end

local function get_rot_offset_dir(closed, mirrored, rotate_dir)
	local dir = 0
	if not closed then dir = rotate_dir == "inward" and -1 or 1 end -- for the left door
	if mirrored then dir = -dir end -- for the right door

	return dir
end

local function get_target_rot_offset_dir(closed, mirrored, rotate_dir)
	local dir = 0
	if not closed then dir = 1 else dir = -1 end -- for the left door and inward rotate dir
	if rotate_dir == "outward" then dir = -dir end
	if mirrored then dir = -dir end -- for the right door

	return dir
end

function multidecor.DoorAnimator:update_mode(new_mode)
	local dir = hlpfuncs.get_dir(self.nodepos)

	local mparams = self.model_params
	local pos = mparams.pos
	local box_length = mparams.box:width()
	pos.x = mparams.mirrored and pos.x + box_length * 2 or pos.x

	self.cur_pos = self.nodepos + hlpfuncs.rotate_to_dir(pos, dir)
	self.cur_rot = mparams.rot
	self.cur_rot.y = self.cur_rot.y + hlpfuncs.get_rot_y(dir)

	self.cur_mode = new_mode

	local target_offset = self.anim_params.target_offset
	local closed = new_mode == "closed"
	local mirrored = mparams.mirrored
	local rotate_dir = self.anim_params.rotate_dir

	if self.anim_params.rotate then
		local start_rot_dir = get_rot_offset_dir(closed, mirrored, rotate_dir)
		self.cur_rot[mparams.target_axis] = self.cur_rot[mparams.target_axis] + start_rot_dir * target_offset

		local target_rot_dir = get_target_rot_offset_dir(closed, mirrored, rotate_dir)
		target_offset = target_offset * target_rot_dir
	else
		local start_shift_dir = 0
		if not closed then start_shift_dir = 1 end
		self.cur_pos[mparams.target_axis] = self.cur_pos[mparams.target_axis] + start_shift_dir * target_offset

		local shift_dir = closed and 1 or -1
		target_offset = target_offset * shift_dir
	end

	self.target_offset = vector.new()
	self.target_offset[self.anim_params.target_axis] = target_offset

	mparams.box:rotate(dir)

	self.obj:set_pos(self.cur_pos)
	self.obj:set_rotation(self.cur_rot)
	
	self:update_model()
end

local function animator_on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = core.deserialize(staticdata)
		self.model_params = data.model_params
		self.anim_params = data.anim_params
		self.timer = data.timer
		self.target = data.target
	end

	self:update_model()

	self.object:set_armor_groups({immortal=1})
end

local function animator_on_step(self, dtime)
	self.timer:tick(dtime)
end

local function animator_get_staticdata(self)
	return core.serialize({
		model_params = self.model_params,
		anim_params = self.anim_params,
		timer = self.timer,
		target = self.target
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
