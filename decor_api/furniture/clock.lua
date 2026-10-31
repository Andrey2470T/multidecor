local animation_t = require("decor_api.common.animation")
local CyclicEntity = animation_t[2]
local FurnitureManager = require("decor_api.common.furniture_entity")[3]
local common = require("decor_api.helpers.common")
local dir_ops = require("decor_api.helpers.dir_ops")

local clock = {}

-- ClockEntity: an invisible wheel entity running the bone swing animation
-- and the restarted-on-cycle sound while the clock is activated.
-- The balance wheel model is carried by the dummy and its own bone is animated
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

-- The balance wheel swings via the cyclic bone animation; the (non-looped)
-- sound is restarted on every cycle by CyclicEntity
function ClockEntity:cycle()
	if self.is_running then
		CyclicEntity.cycle(self)
	else
		self:stop_animation()
		self:stop_sound()
	end
end

function ClockEntity:apply_running_state()
	self:cycle()

	if self.is_running then
		local hours, minutes = clock.get_current_time()
		core.get_meta(self.attached_to.pos):set_string(
			"infotext", clock.get_formatted_time_str(hours, minutes))
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
			local hours, minutes = clock.get_current_time()
			core.get_meta(self.attached_to.pos):set_string(
				"infotext", clock.get_formatted_time_str(hours, minutes))
		end
	end
end

FurnitureManager.register(ClockEntity.name, ClockEntity, {
	pointable = false,
	static_save = true
})

function clock.get_current_time()
	local timeofday = core.get_timeofday()
	local time = math.floor(timeofday * 1440)
	local minute = time % 60
	local hour = (time - minute) / 60

	return hour, minute
end

function clock.get_formatted_time_str(hours, minutes)
	return (common.translator("Current time: %d:%d")):format(hours, minutes)
end

function clock.on_construct(pos)
	local node = core.get_node(pos)
	local time_params = core.registered_nodes[node.name].add_properties.time_params

	local dir = dir_ops.get_dir(pos) * -1
	local y_rot = vector.dir_to_rotation(dir).y

	local model_def = time_params.def

	FurnitureManager.add(ClockEntity.name, pos, node.name, pos, {x=0, y=y_rot, z=0}, {
		model_params = model_def and {
			mesh = model_def.mesh or "",
			textures = model_def.textures or {},
			size = model_def.visual_size or {x=5, y=5, z=5},
			pointable = false
		} or nil,
		-- the bone swing parameters of the balance wheel
		cyclic_animation = time_params.animation,
		sound = time_params.sound and {
			name = time_params.sound.name,
			volume = time_params.sound.gain or 1.0,
			max_distance = time_params.sound.max_hear_distance or 10.0,
			-- for clocks without a wheel: the non-looped sound is restarted
			-- every 'interval' seconds
			interval = time_params.sound.interval
		} or nil
	})

	core.get_meta(pos):set_string("is_activated", "false")
end

function clock.on_rightclick(pos, node, clicker)
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

return { ClockEntity, clock }
