local animation_t = require("decor_api.common.animation")
local CyclicEntity = animation_t[2]
local FurnitureManager = require("decor_api.common.furniture_entity")[3]
local dir_ops = require("decor_api.helpers.dir_ops")

multidecor.clock = {}

-- ClockEntity: an invisible wheel entity running the keyframed animation
-- and the looping sound while the clock is activated.
-- The model is carried by the dummy when 'time_params.def' provides one.
--------------------------------------------------------------------------------
local ClockEntity = CyclicEntity:extend("decor_api:clock_wheel")

function ClockEntity:on_activate(staticdata)
	if not CyclicEntity.on_activate(self, staticdata) then
		return false
	end

	self.is_running = core.get_meta(self.attached_to.pos):get_string("is_activated") == "true"
	self.infotext_time = 0
	self:apply_running_state()

	return true
end

-- Replaces the bone cycling of CyclicEntity with a keyframed animation
-- and a looping sound bound to the activation state
function ClockEntity:cycle()
	if self.is_running then
		if self.frame_animation then
			self:play_frame_animation(self.frame_animation.range, self.frame_animation.speed)
		end
		if self.sound.name ~= "" then
			self:play_sound()
		end
	else
		self:stop_frame_animation()
		self:stop_sound()
	end
end

function ClockEntity:apply_running_state()
	self:cycle()

	if self.is_running then
		local hours, minutes = multidecor.clock.get_current_time()
		core.get_meta(self.attached_to.pos):set_string(
			"infotext", multidecor.clock.get_formatted_time_str(hours, minutes))
	end
end

function ClockEntity:start()
	if self.is_running then return end
	self.is_running = true
	self:apply_running_state()
end

function ClockEntity:stop()
	if not self.is_running then return end
	self.is_running = false
	self:apply_running_state()
	core.get_meta(self.attached_to.pos):set_string("infotext", "")
end

function ClockEntity:on_step(dtime)
	CyclicEntity.on_step(self, dtime)

	if self.is_running then
		self.infotext_time = self.infotext_time + dtime
		if self.infotext_time >= 1 then
			self.infotext_time = 0
			local hours, minutes = multidecor.clock.get_current_time()
			core.get_meta(self.attached_to.pos):set_string(
				"infotext", multidecor.clock.get_formatted_time_str(hours, minutes))
		end
	end
end

FurnitureManager.register(ClockEntity.name, ClockEntity, {
	pointable = false,
	static_save = true
})

multidecor.ClockEntity = ClockEntity

function multidecor.clock.get_current_time()
	local timeofday = core.get_timeofday()
	local time = math.floor(timeofday * 1440)
	local minute = time % 60
	local hour = (time - minute) / 60

	return hour, minute
end

function multidecor.clock.get_formatted_time_str(hours, minutes)
	return (multidecor.S("Current time: %d:%d")):format(hours, minutes)
end

function multidecor.clock.on_construct(pos)
	local node = core.get_node(pos)
	local time_params = core.registered_nodes[node.name].add_properties.time_params

	local dir = dir_ops.get_dir(pos)
	local y_rot = vector.dir_to_rotation(dir).y

	local model_def = time_params.def

	FurnitureManager.add(ClockEntity.name, pos, node.name, pos, {x=0, y=y_rot, z=0}, {
		model_params = model_def and {
			mesh = model_def.mesh or "",
			textures = model_def.textures or {},
			size = model_def.visual_size or {x=5, y=5, z=5},
			pointable = false
		} or nil,
		frame_animation = time_params.animation,
		sound = time_params.sound and {
			name = time_params.sound.name,
			volume = time_params.sound.gain or 1.0,
			max_distance = time_params.sound.max_hear_distance or 10.0,
			loop = true
		} or nil
	})

	core.get_meta(pos):set_string("is_activated", "false")
end

function multidecor.clock.on_rightclick(pos, node, clicker)
	local meta = core.get_meta(pos)
	local is_activated = meta:get_string("is_activated") == "true"

	meta:set_string("is_activated", tostring(not is_activated))

	for _, desc in ipairs(FurnitureManager.get(pos)) do
		if desc.entity_name == ClockEntity.name and desc:exists() then
			local lua_ent = desc.object:get_luaentity()
			if lua_ent then
				if is_activated then
					lua_ent:stop()
				else
					lua_ent:start()
				end
			end
		end
	end
end
