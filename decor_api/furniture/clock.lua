multidecor.clock = {}

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

	local wheel = core.add_entity(pos, time_params.object, core.serialize({pos=pos, name=node.name}))

	local dir = multidecor.helpers.get_dir(pos)
	local y_rot = vector.dir_to_rotation(dir).y

	wheel:set_rotation({x=0, y=y_rot, z=0})

	core.get_meta(pos):set_string("is_activated", "false")
end

function multidecor.clock.on_rightclick(pos, node, clicker)
	local meta = core.get_meta(pos)

	if meta:get_string("is_activated") == "false" then
		meta:set_string("is_activated", "true")
	else
		meta:set_string("is_activated", "false")
	end
end

function multidecor.clock.remove_wheel(wheel)
	local self = wheel:get_luaentity()

	if not self then return end

	wheel:remove()

	if self.attached_to.sound then
		core.sound_stop(self.attached_to.sound)
	end
end

function multidecor.clock.start(wheel, time_params)
	local self = wheel:get_luaentity()

	if not self then return end

	if self.attached_to.active then
		return
	end

	self.attached_to.active = true

	if time_params.animation then
		self.object:set_animation(
			time_params.animation.range,
			time_params.animation.speed,
			0.0,
			true)
	end

	if time_params.sound then
		local sound_def = {
			object=self.object,
			gain=time_params.sound.gain or 1.0,
			max_hear_distance=time_params.sound.max_hear_distance,
			loop=true
		}
		self.attached_to.sound = core.sound_play(time_params.sound.name, sound_def)
	end
end

function multidecor.clock.stop(wheel)
	local self = wheel:get_luaentity()

	if not self then return end

	if not self.attached_to.active then
		return
	end

	self.attached_to.active = false
	self.object:set_animation({x=1, y=1}, 0.0)

	if self.attached_to.sound then
		core.sound_stop(self.attached_to.sound)
	end
	self.attached_to.sound = nil
end

function multidecor.clock.on_activate(self, staticdata)
	-- The code below is for backwards compatibility with versions < 1.2.5
	if staticdata == "" then
		local pos = self.object:get_pos()
		self.object:remove()
		core.set_node(pos, core.get_node(pos))
		return
	-- end
	else
		self.attached_to = core.deserialize(staticdata)

		if not self.attached_to then
			self.object:remove()
			return
		end

		if core.get_meta(self.attached_to.pos):get_string("is_activated") == "true" then
			local time_params = core.registered_nodes[self.attached_to.name].add_properties.time_params

			if time_params.animation then
				self.object:set_animation(
					time_params.animation.range,
					time_params.animation.speed,
					0.0,
					true)
			end
		end
	end
end

function multidecor.clock.on_step(self, dtime)
	if not self.attached_to then
		self.object:remove()
		return
	end

	local cur_node = core.get_node(self.attached_to.pos)

	if cur_node.name ~= self.attached_to.name then
		multidecor.clock.remove_wheel(self.object)
		return
	end

	local cur_meta = core.get_meta(self.attached_to.pos)

	local time_params = core.registered_nodes[self.attached_to.name].add_properties.time_params
	if cur_meta:get_string("is_activated") == "true" then
		multidecor.clock.start(self.object, time_params)

		local hours, minutes, seconds = multidecor.clock.get_current_time()
		cur_meta:set_string("infotext", multidecor.clock.get_formatted_time_str(hours, minutes))
	elseif cur_meta:get_string("is_activated") == "false" then
		multidecor.clock.stop(self.object)
	end
end

function multidecor.clock.get_staticdata(self)
	return core.serialize(self.attached_to)
end
