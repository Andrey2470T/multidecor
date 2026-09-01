local BBox = require("decor_api.helpers.box")
local Timer = require("decor_api.helpers.timer")
local FurnitureEntity, _, FurnitureManager = unpack(require("decor_api.common.furniture_entity"))

-- AnimatedEntity
----------------------------------------------------
local AnimatedEntity = setmetatable({}, { __index = FurnitureEntity })
AnimatedEntity.__index = AnimatedEntity
AnimatedEntity.name = "decor_api:animated_furniture"

function AnimatedEntity:on_activate(staticdata)
	if not FurnitureEntity.on_activate(self, staticdata) then
		return false
	end

	self.model_params = self.model_params or {}
	self.model_params.size = self.model_params.size or {x=5, y=5, z=5}
	self.model_params.mesh = self.model_params.mesh or ""
	self.model_params.textures = self.model_params.textures or {}
	self.model_params.box = self.model_params.box or BBox.from_default()
	self.sound_handle = nil

	local cb_data = { node_pos = self.attached_to.pos }
	self.anim_timer = Timer.new(0, false, {
		end_callback = function(data)
			local desc = FurnitureManager.get(data.node_pos)
			if desc:exists() then
				local desc_self = desc.object:get_luaentity()

				if desc_self.on_animation_end then
					desc_self:on_animation_end()
				end
			end
		end,
		end_callback_data = cb_data
	})

	if staticdata and staticdata ~= "" then
		self:create_dummy_model()
	end

	return true
end

function AnimatedEntity:create_dummy_model()
	if not self.object then return end

	-- Prevents the entity duplication
	if self.dummy_entity and self.dummy_entity:is_valid() then return end

	local p = self.object:get_pos()
	self.dummy_entity = core.add_entity(p, "decor_api:animator_dummy")

	if self.dummy_entity then
		-- Attaches the dummy entity with some model to the bone-entity
		self.dummy_entity:set_attach(self.object, "Door", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true)

		local size = vector.new(self.model_params.size)
		if self.model_params.mirrored then
			size.x = -size.x
		end

		self.dummy_entity:set_properties({
			visual_size = size,
			mesh = self.model_params.mesh,
			textures = self.model_params.textures,
			collisionbox = self.model_params.box,
			selectionbox = self.model_params.box
		})
	end
end

function AnimatedEntity:animate(rotate, target_offset, offset_axis, velocity)
	local time = math.abs(target_offset) / math.max(0.001, velocity)

	local target_pos = vector.new()
	target_pos[offset_axis] = target_offset

	local override
	if rotate then
		override = {rotation = {vec = target_pos, interpolation = time}}
	else
		override = {position = {vec = target_pos, interpolation = time}}
	end

	self.object:set_bone_override("Door", override)
	self.anim_timer:start(time)
end

function AnimatedEntity:play_sound(sound_name, gain, max_dist, loop)
	self:stop_sound()
	if sound_name and self.object then
		self.sound_handle = core.sound_play(sound_name, {
			object = self.object,
			gain = gain or 1.0,
			max_hear_distance = max_dist or 15,
			loop = loop
		})
	end
end

function AnimatedEntity:stop_sound()
	if self.sound_handle then
		core.sound_stop(self.sound_handle)
		self.sound_handle = nil
	end
end

function AnimatedEntity:on_step(dtime)
	if self.anim_timer then
		self.anim_timer:tick(dtime)
	end
end

function AnimatedEntity:on_deactivate(removal)
	self:stop_sound()
	if self.dummy_entity and self.dummy_entity:is_valid() then
		self.dummy_entity:remove()
	end
	multidecor.FurnitureEntity.on_deactivate(self, removal)
end

-- Registers the "decor_api:animated_furniture" entity
FurnitureManager.register(AnimatedEntity.name, AnimatedEntity)

core.register_entity("decor_api:animator_dummy", {
	visual = "mesh",
	physical = true,
	pointable = true,
	static_save = false,
})

-- CyclicEntity
------------------------------------------------
local CyclicEntity = setmetatable({}, { __index = AnimatedEntity })
CyclicEntity.__index = CyclicEntity
CyclicEntity.name = "decor_api:cyclic_furniture"

function CyclicEntity:cycle()
	local anim = self.cyclic_animation

	if anim then
		self:animate(true, anim.angle * anim.direction, anim.axis, anim.velocity)
	end

	local sound = self.cyclic_sound
	if sound then
		self:play_sound(sound.name, sound.volume, sound.max_distance, true)
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

	self.cyclic_sound = self.cyclic_sound or {}
	self.cyclic_sound.volume = self.cyclic_sound.volume or 1.0
	self.cyclic_sound.max_distance = self.cyclic_sound.max_distance or 10

	self:cycle()

	return true
end

function CyclicEntity:on_animation_end()
	if self.swap_direction then
		self.cyclic_animation.direction = self.cyclic_animation.direction * -1
	end

	self:cycle()
end

-- Registers the "decor_api:cyclic_furniture" entity
FurnitureManager.register(CyclicEntity.name, CyclicEntity)

return AnimatedEntity, CyclicEntity