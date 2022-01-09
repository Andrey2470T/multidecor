-- Sitting API

--[[Node that can be sat on should contain 'is_busy' metadata field with playername string.
	Player that is currently sitting should contain 'previous_mesh_data' metadata field to return his previous mesh after detaching.
	It is presented in such form:
	{
		mesh = <current mesh name>,
		anim = {range=float, speed=float, blend=bool, loop=bool},
		physics = {speed=float, jump=float}
	}
]]
multidecor.sitting = {}

sitting = multidecor.sitting

function sitting.attach_player_to_node(attacher, seat_data)
	attacher:set_pos(seat_data.pos)
	attacher:set_look_vertical(seat_data.rot.x)
	attacher:set_look_horizontal(seat_data.rot.y)
	attacher:set_physics_override({speed=0, jump=0})

	if seat_data.model then
		attacher:set_properties({mesh = seat_data.model.mesh})
		attacher:set_animation(seat_data.model.anim.range, seat_data.model.anim.speed, seat_data.model.anim.blend, seat_data.model.anim.loop)
	end
end

function sitting.detach_player_from_node(detacher, prev_pdata)
	if not prev_pdata then
		minetest.debug("3")
		return
	end
	minetest.debug("prev_pdata.physics: " .. dump(prev_pdata.physics))
	detacher:set_physics_override(prev_pdata.physics)
	
	if prev_pdata.mesh and prev_pdata.anim then
		detacher:set_properties({mesh = prev_pdata.mesh})
		detacher:set_animation(prev_pdata.anim.range, prev_pdata.anim.speed, prev_pdata.anim.blend, prev_pdata.anim.loop)
	end
end

function sitting.is_player_attached_to_anything(player)
	local prev_pdata = player:get_meta():get_string("previous_player_data")
	
	return prev_pdata ~= ""
end

function sitting.is_seat_busy(node_pos)
	local is_busy = minetest.get_meta(node_pos):get_string("is_busy")
	
	return is_busy ~= ""
end

function sitting.sit_player(player, node_pos)
	if not player then
		return
	end

	if sitting.is_player_attached_to_anything(player) then
		return false
	end

	local playername = player:get_player_name()
	if sitting.is_seat_busy(node_pos) then
		minetest.chat_send_player(playername, "This seat is busy!")
		return false
	end

	local physics = player:get_physics_override()
	
	local prev_pdata = {
		physics = {speed = physics.speed, jump = physics.jump}
	}
	local node = minetest.get_node(node_pos)
	local seat_data = minetest.registered_nodes[node.name].add_properties.seat_data
	
	local rand_model
	if seat_data.models then
		local range, speed, blend, loop = player:get_animation()
		
		prev_pdata.mesh = player:get_properties().mesh
		prev_pdata.anim = {range = range, speed = speed, blend = blend, loop = loop}
		
		rand_model = seat_data.models[math.random(1, #seat_data.models)]
	end
	
	player:get_meta():set_string("previous_player_data", minetest.serialize(prev_pdata))
	
	local dir_rot = vector.dir_to_rotation(minetest.facedir_to_dir(node.param2))
	sitting.attach_player_to_node(player, {pos = vector.add(node_pos, seat_data.pos), rot = vector.add(dir_rot, seat_data.rot), model = rand_model})

	minetest.get_meta(node_pos):set_string("is_busy", playername)

	return true
end

function sitting.standup_player(player, node_pos)
	if not player then
		minetest.debug("1")
		return
	end
	local meta = minetest.get_meta(node_pos)

	if player:get_player_name() ~= meta:get_string("is_busy") then
		minetest.debug("2")
		return false
	end

	local player_meta = player:get_meta()
	sitting.detach_player_from_node(player, minetest.deserialize(player_meta:get_string("previous_player_data")))

	player_meta:set_string("previous_player_data", "")
	meta:set_string("is_busy", "")

	return true
end
