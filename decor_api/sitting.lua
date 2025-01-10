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
multidecor.sitting.players_seats_objs = {}


function multidecor.sitting.attach_player_to_node(attacher, seat_data)

	local seat = minetest.add_entity(seat_data.pos, "decor_api:seat_entity", "")
	seat:set_rotation(seat_data.rot)
	multidecor.sitting.players_seats_objs[attacher:get_player_name()] = seat

	attacher:set_physics_override({speed=0, jump=0})

	attacher:set_attach(seat, "", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true)

	if seat_data.model then
		player_api.set_model(attacher, seat_data.model)
		player_api.set_animation(attacher, seat_data.anim)
	end
end

function multidecor.sitting.detach_player_from_node(detacher, prev_pdata)
	if not prev_pdata then
		return
	end

	local seat = multidecor.sitting.players_seats_objs[detacher:get_player_name()]

	if seat then
		detacher:set_detach()
		seat:remove()
	end

	detacher:set_physics_override(prev_pdata.physics)

	if prev_pdata.model then
		player_api.set_model(detacher, prev_pdata.model.model)
	end
end

function multidecor.sitting.is_player_attached_to_anything(player)
	local prev_pdata = player:get_meta():get_string("previous_player_data")

	return prev_pdata ~= ""
end

function multidecor.sitting.is_seat_busy(node_pos)
	local is_busy = minetest.get_meta(node_pos):get_string("is_busy")

	return is_busy ~= ""
end

function multidecor.sitting.sit_player(player, node_pos)
	if not player then
		return
	end

	if multidecor.sitting.is_player_attached_to_anything(player) then
		return false
	end

	local playername = player:get_player_name()
	if multidecor.sitting.is_seat_busy(node_pos) then
		minetest.chat_send_player(playername, multidecor.S("This seat is busy!"))
		return false
	end

	local physics = player:get_physics_override()

	local prev_pdata = {
		attached_to = node_pos,
		physics = {speed = physics.speed, jump = physics.jump}
	}
	local node = minetest.get_node(node_pos)
	local seat_data = table.copy(minetest.registered_nodes[node.name].add_properties.seat_data)

	local rand_anim
	if seat_data.model then
		prev_pdata.model = player_api.get_animation(player)

		local node_dir = multidecor.helpers.get_dir(node_pos)
		local near_node = minetest.get_node(vector.add(node_pos, node_dir))

		if minetest.get_item_group(near_node.name, "table") ~= 1 then
			local anims2 = {}
			for i=1, #seat_data.anims do
				if not player_api.registered_models[seat_data.model].animations[seat_data.anims[i]].is_near_block_required then
					table.insert(anims2, seat_data.anims[i])
				end
			end

			seat_data.anims = anims2
		end


		rand_anim = seat_data.anims[math.random(1, #seat_data.anims)]
	end

	local player_meta = player:get_meta()

	player:get_meta():set_string("previous_player_data", minetest.serialize(prev_pdata))

	local dir_rot = vector.dir_to_rotation(multidecor.helpers.get_dir(node_pos))
	local rot_seat_pos = vector.rotate_around_axis(multidecor.helpers.rotate_to_node_dir(node_pos, seat_data.pos), vector.new(0, 1, 0), math.pi)

	local data = {
		pos = node_pos+rot_seat_pos,
		rot = dir_rot+seat_data.rot,
		model = seat_data.model,
		anim = rand_anim
	}

	multidecor.sitting.attach_player_to_node(player, data)

	minetest.get_meta(node_pos):set_string("is_busy", playername)

	return true
end

function multidecor.sitting.standup_player(player, node_pos)
	if not player then
		return
	end
	local meta = minetest.get_meta(node_pos)

	if player:get_player_name() ~= meta:get_string("is_busy") then
		return false
	end

	local player_meta = player:get_meta()
	multidecor.sitting.detach_player_from_node(player, minetest.deserialize(player_meta:get_string("previous_player_data")))

	player_meta:set_string("previous_player_data", "")
	meta:set_string("is_busy", "")

	return true
end

multidecor.sitting.standard_model = "multidecor_character_sitting.b3d"

player_api.register_model(multidecor.sitting.standard_model, {
	animations = {
		sit1 = {
			x = 4,
			y = 84
		},
		sit2 = {
			x = 0,
			y = 1
		},
		sit3 = {
			x = 2,
			y = 3,
			is_near_block_required = true
		}
	}
})

multidecor.sitting.on_construct = function(pos)
	minetest.get_meta(pos):set_string("is_busy", "")
end

multidecor.sitting.on_destruct = function(pos)
	multidecor.sitting.standup_player(minetest.get_player_by_name(minetest.get_meta(pos):get_string("is_busy")), pos)
end

multidecor.sitting.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local bool = multidecor.sitting.sit_player(clicker, pos)

	if not bool then
		multidecor.sitting.standup_player(clicker, pos)
	end
end

minetest.register_entity("decor_api:seat_entity", {
	visual = "cube",
	textures = {
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png"
	},
	use_texture_alpha = true,
	physical = false,
	pointable = false,
	static_save = true
})

minetest.register_on_leaveplayer(function(player)
	local prev_pdata = minetest.deserialize(player:get_meta():get_string("previous_player_data"))

	if prev_pdata and prev_pdata.attached_to then
		multidecor.sitting.standup_player(player, prev_pdata.attached_to)
	end
end)
