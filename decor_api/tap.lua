multidecor.tap = {}

--[[function multidecor.tap.register_water_stream(pos, spawn_min_pos, spawn_max_pos, amount, velocity, direction, sound, check_for_sink)
	local meta = minetest.get_meta(pos)

	meta:set_string("water_stream_info", minetest.serialize({
		water_min_pos = spawn_min_pos,
		water_max_pos = spawn_max_pos,
		water_amount = amount,
		water_velocity = velocity,
		water_direction = direction,
		water_sound = sound,
		check_for_sink = check_for_sink
	}))
end]]

function multidecor.tap.is_on(pos)
	return minetest.get_meta(pos):get_string("water_stream_id") ~= ""
end

function multidecor.tap.on(pos)
	local meta = minetest.get_meta(pos)
	local id = meta:get_string("water_stream_id")

	if id ~= "" then return end


	local water_info = minetest.registered_nodes[minetest.get_node(pos).name].add_properties.tap_data

	if water_info.check_for_sink then
		local down_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local down_node2 = minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z})

		if minetest.get_item_group(down_node.name, "sink") ~= 1 and minetest.get_item_group(down_node2.name, "sink") ~= 1 then
			return
		end
	end

	local rot_water_min_pos = multidecor.helpers.rotate_to_node_dir(pos, water_info.min_pos)
	local rot_water_max_pos = multidecor.helpers.rotate_to_node_dir(pos, water_info.max_pos)
	local rot_water_dir = multidecor.helpers.rotate_to_node_dir(pos, water_info.direction)

	local id = minetest.add_particlespawner({
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

	meta:set_string("water_stream_id", tostring(id))

	local sound_handle = minetest.sound_play(water_info.sound, {pos=pos, fade=1.0, max_hear_distance=12, loop=true})
	meta:set_string("sound_handle", minetest.serialize(sound_handle))
end

function multidecor.tap.off(pos)
	local meta = minetest.get_meta(pos)
	local id = meta:get_string("water_stream_id")

	if id == "" then return end

	minetest.delete_particlespawner(id)
	meta:set_string("water_stream_id", "")

	local sound_handle = minetest.deserialize(meta:get_string("sound_handle"))

	minetest.sound_stop(sound_handle)
end

function multidecor.tap.toggle(pos)
	local meta = minetest.get_meta(pos)
	local id = meta:get_string("water_stream_id")

	if id == "" then
		multidecor.tap.on(pos)
	else
		multidecor.tap.off(pos)
	end
end

function multidecor.tap.on_rightclick(pos)
	multidecor.tap.toggle(pos)
end

function multidecor.tap.on_destruct(pos)
	multidecor.tap.off(pos)
end

function multidecor.tap.on_timer(pos, elapsed)
	local down_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	local down_node2 = minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z})

	if multidecor.tap.is_on(pos) and
		minetest.get_item_group(down_node.name, "sink") ~= 1 and minetest.get_item_group(down_node2.name, "sink") ~= 1 then

		multidecor.tap.off(pos)
	end

	return true
end
