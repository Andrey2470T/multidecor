multidecor.tap = {}

function multidecor.tap.register_water_stream(pos, spawn_pos, amount, velocity, sound, check_for_sink)
	local meta = minetest.get_meta(pos)
	
	meta:set_string("water_stream_info", minetest.serialize({
		water_pos = spawn_pos,
		water_amount = amount,
		water_velocity = velocity,
		water_sound = sound,
		check_for_sink = check_for_sink
	}))
end

function multidecor.tap.is_on(pos)
	return minetest.get_meta(pos):get_string("water_stream_id") ~= ""
end

function multidecor.tap.on(pos)
	local meta = minetest.get_meta(pos)
	local id = meta:get_string("water_stream_id")
	
	if id ~= "" then return end
	
	
	local water_info = minetest.deserialize(meta:get_string("water_stream_info"))
	
	if water_info.check_for_sink then
		local down_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		
		if minetest.get_item_group(down_node.name, "sink") ~= 1 then
			return
		end
	end
	
	local rot_water_pos = multidecor.helpers.rotate_to_node_dir(pos, water_info.water_pos)
	
	local id = minetest.add_particlespawner({
		amount = water_info.water_amount,
		time = 0,
		collisiondetection = true,
		object_collision = true,
		collision_removal = true,
		texture = "multidecor_water_drop.png",
		minpos = pos+rot_water_pos+vector.new(-0.05, 0, -0.05),
		maxpos = pos+rot_water_pos+vector.new(0.05, 0, 0.05),
		minvel = {x=0, y=-water_info.water_velocity, z=0},
		maxvel = {x=0, y=-water_info.water_velocity, z=0},
		minsize = 0.8,
		maxsize = 2
	})
	
	meta:set_string("water_stream_id", tostring(id))
	
	local sound_handle = minetest.sound_play(water_info.water_sound, {pos=pos, fade=1.0, max_hear_distance=12, loop=true})
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
