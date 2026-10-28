local BBox = require("decor_api.helpers.box")
local Timer = require("decor_api.helpers.timer")
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureEntity, FurnitureManager = furniture_t[1], furniture_t[3]

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

	self.sound = self.sound or {}
	self.sound.handle = nil
	self.sound.name = self.sound.name or ""
	self.sound.volume = self.sound.volume or 1.0
	self.sound.max_distance = self.sound.max_distance or 10.0

	local cb_data = { guid = self.object:get_guid() }
	self.anim_timer = Timer.new(0, false, {
		end_callback = function(data)
			local desc = FurnitureManager.get_by_guid(data.guid)
			if desc and desc:exists() then
				local desc_self = desc.object:get_luaentity()

				if desc_self and desc_self.on_animation_end then
					desc_self:on_animation_end()
				end
			end
		end,
		end_callback_data = cb_data
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

function AnimatedEntity:play_animation(rotate, target_offset, offset_axis, velocity)
	self:stop_animation(true)

	local time = math.abs(target_offset) / math.max(0.001, velocity)

	local target_pos = vector.new()
	target_pos[offset_axis] = target_offset

	local override
	if rotate then
		override = {rotation = {vec = target_pos, interpolation = time}}
	else
		override = {position = {vec = target_pos, interpolation = time}}
	end

	self.animation = {
		rotate = rotate,
		offset_axis = offset_axis,
		target_offset = target_offset,
		velocity = velocity
	}
	self.object:set_bone_override("Door", override)
end

function AnimatedEntity:stop_animation(instant)
	if not self.animation then return end

	local cur_time = self.anim_timer:get_time()
	local cur_offset = -self.animation.velocity * cur_time

	local target_pos = vector.new()
	target_pos[self.animation.offset_axis] = cur_offset

	local override
	if self.animation.rotate then
		override = {rotation = {vec = target_pos, interpolation = instant and 0.0 or cur_time}}
	else
		override = {position = {vec = target_pos, interpolation = instant and 0.0 or cur_time}}
	end

	self.object:set_bone_override("Door", override)
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
FurnitureManager.register(AnimatedEntity.name, AnimatedEntity)

core.register_entity("decor_api:animator_dummy", {
	visual = "mesh",
	physical = false,
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

-- Calls the one animation cycle
function CyclicEntity:cycle()
	local anim = self.cyclic_animation

	local time
	if anim then
		time = math.abs(anim.angle) / math.max(0.001, anim.velocity)
		self:play_animation(true, anim.angle * anim.direction, anim.axis, anim.velocity)
	end

	if not time then
		time = self.sound.duration or 0
	end
	self:play_sound()

	if not self.anim_timer:is_started() then
		self.anim_timer:start(time)
	end
end

function CyclicEntity:on_activate(staticdata)
	if not AnimatedEntity.on_activate(self, staticdata) then
		return false
	end

	self.cyclic_animation = self.cyclic_animation or {}
	self.cyclic_animation.angle = self.cyclic_animation.angle or math.pi/2
	self.cyclic_animation.axis = self.cyclic_animation.axis or "y"
	self.cyclic_animation.velocity = self.cyclic_animation.velocity or math.pi/4
	self.cyclic_animation.direction = self.cyclic_animation.direction or 1
	self.anim_timer.cyclic = true

	return true
end

-- Called at the end of the timer cycle once the duration is reached
-- Inverts the animation direction if "swap_direction=true", used for the floor clock balance wheel,
-- the ceiling fan blades don't invert it
function CyclicEntity:on_animation_end()
	if self.cyclic_animation.swap_direction then
		self.cyclic_animation.direction = self.cyclic_animation.direction * -1
	end

	self:cycle()
end

-- Registers the "decor_api:cyclic_furniture" entity
FurnitureManager.register(CyclicEntity.name, CyclicEntity)

return { AnimatedEntity, CyclicEntity }
