local common = require("decor_api.helpers.common")
local BBox = require("decor_api.helpers.box")
local Timer = require("decor_api.helpers.timer")
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureEntity, FurnitureManager = furniture_t[1], furniture_t[3]

local EntityTimer = Timer:extend()

function EntityTimer.new(object, duration, cyclic, callbacks)
	callbacks = callbacks or {}
	callbacks.end_callback_data = callbacks.end_callback_data or { guid = object:get_guid() }
	local self = Timer.new(duration, cyclic, callbacks)
	return setmetatable(self, EntityTimer)
end

function EntityTimer:tick(dtime)
	local desc = FurnitureManager.get_by_guid(self.end_callback_data.guid)
	if desc and desc:exists() then
		Timer.tick(self, dtime)
	end
end

common.register_class("EntityTimer", EntityTimer)

-- AnimatedEntity
-- The child class of FurnitureEntity handling the bone animation and the sound playback.
-- Consists of two entities - self.object, the invisible one having the "Door" bone and attaching sound
-- and self.dummy_entity, the visible one carrying the model and attached to the "Door" bone of the parent entity.
----------------------------------------------------
local AnimatedEntity = FurnitureEntity:extend("decor_api:animated_furniture")

function AnimatedEntity:on_activate(staticdata)
	if not FurnitureEntity.on_activate(self, staticdata) then
		return false
	end

	self.model_params = self.model_params or {}
	self.model_params.size = self.model_params.size or {x=5, y=5, z=5}
	self.model_params.mesh = self.model_params.mesh or ""
	self.model_params.textures = self.model_params.textures or {}
	self.model_params.box = self.model_params.box or BBox.from_default()
	if self.model_params.box.min_edge == nil then
		self.model_params.box = BBox.from_box(self.model_params.box)
	end

	self.sound = self.sound or {}
	self.sound.handle = nil
	self.sound.name = self.sound.name or ""
	self.sound.volume = self.sound.volume or 1.0
	self.sound.max_distance = self.sound.max_distance or 10.0

	self.anim_timer = EntityTimer.new(self.object, 0, false, {
		end_callback = function(data)
			local desc = FurnitureManager.get_by_guid(data.guid)
			local desc_self = desc.object:get_luaentity()

			if desc_self.on_animation_end then
				desc_self:on_animation_end()
			end
		end
	})

	self:create_dummy_model()

	return true
end

function AnimatedEntity:create_dummy_model()
	if not self.object then return end

	-- The entity itself carries the model when there is none for the dummy
	if self.model_params.mesh == "" then return end

	-- Prevents the entity duplication
	if self.dummy_entity and self.dummy_entity:is_valid() then return end

	local p = self.object:get_pos()
	self.dummy_entity = core.add_entity(p, "decor_api:animator_dummy")

	if self.dummy_entity then
		-- Attaches the dummy entity with some model to the bone-entity. When
		self.dummy_entity:set_attach(self.object, "Door", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true)

		local size = vector.new(self.model_params.size)
		if self.model_params.mirrored then
			size.x = -size.x
		end

		local box_coords = self.model_params.box:get_coords()
		self.dummy_entity:set_properties({
			visual_size = size,
			mesh = self.model_params.mesh,
			textures = self.model_params.textures,
			collisionbox = box_coords,
			selectionbox = box_coords
		})
	end
end

-- Applies the raw bone override to the "Door" bone: 'offset' along 'offset_axis'
-- reached in 'time' seconds, as a rotation when 'rotate' is true or as a position
-- otherwise. The engine interpolates from the current bone pose, so 'time' == 0
-- applies the offset instantly. Subclasses build their transitions on it instead
-- of constructing the set_bone_override table themselves
function AnimatedEntity:apply_bone_override(rotate, offset, offset_axis, time)
	local target_pos = vector.new()
	target_pos[offset_axis] = offset

	local override_key = rotate and "rotation" or "position"
	self.object:set_bone_override("Door", {[override_key] = {vec = target_pos, interpolation = time or 0}})
end

function AnimatedEntity:play_animation(rotate, target_offset, offset_axis, velocity, time)
	self:stop_animation(true)

	self.animation = {
		rotate = rotate,
		offset_axis = offset_axis,
		target_offset = target_offset,
		velocity = velocity
	}
	self:apply_bone_override(rotate, target_offset, offset_axis, time)
end

function AnimatedEntity:stop_animation(instant)
	if not self.animation then return end

	local cur_time = self.anim_timer:get_time()
	local cur_offset = -self.animation.velocity * cur_time

	self:apply_bone_override(self.animation.rotate, cur_offset, self.animation.offset_axis,
		instant and 0.0 or cur_time)
	self.animation = nil
end

function AnimatedEntity:play_sound()
	self:stop_sound()
	if self.sound.name ~= "" and self.object then
		self.sound.handle = core.sound_play(self.sound.name, {
			object = self.object,
			gain = self.sound.volume,
			max_hear_distance = self.sound.max_distance,
			loop = false
		})
	end
end

function AnimatedEntity:stop_sound()
	if self.sound.handle then
		core.sound_stop(self.sound.handle)
		self.sound.handle = nil
	end
end

-- The subclasses must override the method
function AnimatedEntity:calc_anim_time()
	return 0
end

function AnimatedEntity:on_step(dtime)
	if self.anim_timer then
		self.anim_timer:tick(dtime)
	end
end

function AnimatedEntity:on_deactivate(removal)
	self:stop_animation(true)
	self:stop_sound()

	if self.dummy_entity and self.dummy_entity:is_valid() then
		self.dummy_entity:remove()
	end
	FurnitureEntity.on_deactivate(self, removal)
end

-- Registers the "decor_api:animated_furniture" entity
FurnitureManager.register(AnimatedEntity.name, AnimatedEntity,
{
	visual = "mesh",
	backface_culling = true,
	mesh = "multidecor_bone_animator.glb"
})

core.register_entity("decor_api:animator_dummy", {
	visual = "mesh",
	backface_culling = false,
	use_texture_alpha = "blend",
	physical = true,
	pointable = true,
	static_save = false,
	-- The dummy carries the visible model, so it receives clicks instead of the bone entity:
	-- delegate them to the parent entity class
	on_rightclick = function(self, clicker)
		local parent = self.object:get_attach()
		if not parent then return end

		local parent_entity = parent:get_luaentity()
		if parent_entity and parent_entity.on_rightclick then
			parent_entity:on_rightclick(clicker)
		end
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		local parent = self.object:get_attach()
		if not parent then return end

		local parent_entity = parent:get_luaentity()
		if parent_entity and parent_entity.on_punch then
			parent_entity:on_punch(puncher, time_from_last_punch, tool_capabilities, dir, damage)
		end
	end
})

-- CyclicEntity
-- The child class of AnimatedEntity that automatically cycles the animation and sound playback.
-- Used for the floor clock balance wheel where the animation is started/stopped on_rightclick,
-- for the ceiling fan blades where the animation is always running and
-- the alarm clock where only the cyclic sound is played without the animation.
------------------------------------------------
local CyclicEntity = AnimatedEntity:extend("decor_api:cyclic_furniture")

function CyclicEntity:calc_anim_time()
	local time = 0
	local anim = self.cyclic_animation

	if anim then
		time = math.abs(anim.angle) / math.max(0.001, anim.velocity)
	else
		time = self.sound.duration or 0
	end
	return time
end

-- Calls the one animation cycle
function CyclicEntity:cycle()
	local anim = self.cyclic_animation
	local time = self:calc_anim_time()

	if anim then
		self:play_animation(true, anim.angle * anim.direction, anim.axis, anim.velocity, time)
	end
	self:play_sound()

	if not self.anim_timer:is_started() and time > 0 then
		self.anim_timer:start(time)
	end
end

function CyclicEntity:on_activate(staticdata)
	if not AnimatedEntity.on_activate(self, staticdata) then
		return false
	end

	if self.cyclic_animation then
		local anim = self.cyclic_animation
		anim.angle = anim.angle or math.pi/2
		anim.axis = anim.axis or "y"
		anim.velocity = anim.velocity or math.pi/4
		anim.direction = anim.direction or 1
	end
	self.anim_timer.cyclic = true

	return true
end

-- Called at the end of the timer cycle once the duration is reached
-- Inverts the animation direction if "swap_direction=true", used for the floor clock balance wheel,
-- the ceiling fan blades don't invert it
function CyclicEntity:on_animation_end()
	if self.cyclic_animation and self.cyclic_animation.swap_direction then
		self.cyclic_animation.direction = self.cyclic_animation.direction * -1
	end

	self:cycle()
end

-- Registers the "decor_api:cyclic_furniture" entity
FurnitureManager.register(CyclicEntity.name, CyclicEntity,
{
	visual = "mesh",
	backface_culling = true,
	mesh = "multidecor_bone_animator.glb"
})

return { AnimatedEntity, CyclicEntity, EntityTimer }
