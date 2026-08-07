multidecor = {}

local mod_channel = core.mod_channel_join("decor_api:tap_on")

multidecor.tap = {tmp_data={}}

function multidecor.tap.on(pos)
	local ser_pos = vector.to_string(pos)
	local data = multidecor.tap.tmp_data[ser_pos]

	if data then return end

	local water_info = {
		min_pos = {x=0.0, y=0.65, z=-0.1},
		max_pos = {x=0.0, y=0.65, z=-0.1},
		amount = 30,
		velocity = 2,
		direction = {x=0, y=-1, z=0},
		sound = "multidecor_tap",
		check_for_sink = false
	}

	local rot_water_min_pos = helpers.rotate_to_node_dir(pos, water_info.min_pos)
	local rot_water_max_pos = helpers.rotate_to_node_dir(pos, water_info.max_pos)
	local rot_water_dir = helpers.rotate_to_node_dir(pos, water_info.direction)

	local id = core.add_particlespawner({
		amount = water_info.amount,
		time = 0,
		collisiondetection = true,
		object_collision = true,
		collision_removal = true,
		texture = "multidecor_water_drop.png",
		minpos = pos+rot_water_min_pos+vector.new(-0.05, 0, -0.05),
		maxpos = pos+rot_water_max_pos+vector.new(0.05, 0, 0.05),
		minvel = rot_water_dir*water_info.velocity,
		maxvel = rot_water_dir*water_info.velocity,
		minacc = vector.new(0, -9.8, 0),
		maxacc = vector.new(0, -9.8, 0),
		minsize = 0.8,
		maxsize = 2
	})

	local sound_handle = core.sound_play(water_info.sound, {pos=pos, fade=1.0, max_hear_distance=12, loop=true})

	multidecor.tap.tmp_data[ser_pos] = {water_stream_id=id, sound=sound_handle}
end

function multidecor.tap.off(pos)
	local ser_pos = vector.to_string(pos)
	local data = multidecor.tap.tmp_data[ser_pos]

	if not data then return end

	core.delete_particlespawner(data.water_stream_id)

	core.sound_stop(data.sound)
	multidecor.tap.tmp_data[ser_pos] = nil
end

function multidecor.tap.toggle(pos)
	local ser_pos = vector.to_string(pos)
	local data = multidecor.tap.tmp_data[ser_pos]

	if not data then
		multidecor.tap.on(pos)
	else
		multidecor.tap.off(pos)
	end
end

core.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name ~= "decor_api:tap_on" or (sender and sender ~= "") then
		return
	end

	local tap_on_data = core.deserialize(message)

	if tap_on_data.force_off then
		multidecor.tap.off(tap_on_data.pos)
	else
		multidecor.tap.toggle(tap_on_data.pos)
	end
end)
