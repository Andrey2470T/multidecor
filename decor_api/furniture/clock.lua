local animation_t = require("decor_api.common.animation")
local CyclicEntity = animation_t[2]
local EntityTimer = animation_t[3]
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

	self.is_running = self.is_running or false
	self.infotext_timer = EntityTimer.new(self.object, 1, true, {
		end_callback = function(data)
			local desc = FurnitureManager.get_by_guid(data.guid)
			local desc_self = desc and desc.object:get_luaentity()

			if desc_self then
				desc_self:update_infotext()
			end
		end
	})
	self:apply_running_state()

	return true
end

-- Ticks both timers: the animation cycle timer and the once-per-second
-- infotext refresh one
function ClockEntity:on_step(dtime)
	CyclicEntity.on_step(self, dtime)

	if self.infotext_timer then
		self.infotext_timer:tick(dtime)
	end
end

-- Runs one swing-and-sound cycle while the clock is running and halts
-- the animation, the sound and the cycle timer otherwise
function ClockEntity:cycle()
	if self.is_running then
		CyclicEntity.cycle(self)

		if not self.infotext_timer:is_started() then
			self.infotext_timer:start()
		end
	else
		self.anim_timer:stop()
		self.infotext_timer:stop()
		self:stop_animation()
		self:stop_sound()
	end
end

-- Refreshes the infotext of the attached node with the current in-game
-- time, or clears it when the clock is not running
function ClockEntity:update_infotext()
	local infotext = ""

	if self.is_running then
		local hours, minutes = clock.get_current_time()
		infotext = clock.get_formatted_time_str(hours, minutes)
	end

	core.get_meta(self.attached_to.pos):set_string("infotext", infotext)
end

-- Applies the current running state to the animation, the sound and the infotext
function ClockEntity:apply_running_state()
	self:cycle()
	self:update_infotext()
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
end

FurnitureManager.register(ClockEntity.name, ClockEntity,
{
	visual = "mesh",
	backface_culling = true,
	mesh = "multidecor_bone_animator.glb",
	textures = {"multidecor_transparency.png"},
	use_texture_alpha = true
})

-- Returns the current in-game time as the hours and minutes pair
function clock.get_current_time()
	local time = math.floor(core.get_timeofday() * 1440)
	local minutes = time % 60
	local hours = (time - minutes) / 60

	return hours, minutes
end

function clock.get_formatted_time_str(hours, minutes)
	return (common.translator("Current time: %d:%02d")):format(hours, minutes)
end

-- Returns the luaentity of the clock animator entity at 'pos', if it exists
function clock.get_wheel_entity(pos)
	for _, desc in ipairs(FurnitureManager.get(pos)) do
		if desc.entity_name == ClockEntity.name and desc:exists() then
			return desc.object:get_luaentity()
		end
	end
end

-- Returns whether the clock at 'pos' is currently running
function clock.is_running(pos)
	local wheel_entity = clock.get_wheel_entity(pos)
	if wheel_entity then
		return wheel_entity.is_running
	end
	return false
end

-- Spawns the clock animator entity. Requires "clock_params".
-- A clock without 'model_params'/'cyclic_animation' is sound-only (alarm clock)
function clock.on_construct(pos)
	local node = core.get_node(pos)
	local add_props = core.registered_nodes[node.name].add_properties
	local clock_params = add_props and add_props.clock_params

	if not clock_params then
		return
	end

	-- The default pos is the zero offset: the animator spawns right in the node
	local spawn_pos, spawn_rot = dir_ops.rotate_to_node_dir(pos, clock_params.pos or vector.zero(), true)

	FurnitureManager.add(ClockEntity.name, pos, node.name, spawn_pos, spawn_rot, {
		-- The balance wheel model carried by the animator dummy
		model_params = clock_params.model_params and table.copy(clock_params.model_params) or nil,
		-- The bone swing parameters of the balance wheel
		cyclic_animation = clock_params.cyclic_animation,
		sound = clock_params.sound and table.copy(clock_params.sound) or nil
	})
end

-- Toggles the running state on the animator entity
function clock.on_rightclick(pos)
	local is_running = clock.is_running(pos)
	local wheel_entity = clock.get_wheel_entity(pos)
	if wheel_entity then
		if not is_running then
			wheel_entity:start()
		else
			wheel_entity:stop()
		end
	end
end

function clock.on_destruct(pos)
	FurnitureManager.remove(pos)
end

return { ClockEntity, clock }
