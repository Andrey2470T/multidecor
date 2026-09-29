-- Sitting API based on the SittingEntity class
-----------------------------------------------

local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureEntity, FurnitureManager = furniture_t[1], furniture_t[3]

local dir_ops = require("decor_api.helpers.dir_ops")

-- SittingEntity: an invisible entity the player is attached to while sitting.
-- It is spawned at the moment of sitting and removed at the standup.
--------------------------------------------------------------------------------
local SittingEntity = FurnitureEntity:extend("decor_api:seat_furniture")

function SittingEntity:on_activate(staticdata)
	if not FurnitureEntity.on_activate(self, staticdata) then
		return false
	end

	self.sitting_player_name = self.sitting_player_name or ""
	return true
end

function SittingEntity:sit_player(player, seat_data, rand_anim)
	if not player or self:is_busy() then return false end

	local playername = player:get_player_name()

	local physics = player:get_physics_override()
	local prev_pdata = {
		attached_to = self.attached_to.pos,
		physics = { speed = physics.speed, jump = physics.jump }
	}

	if seat_data and seat_data.model and player_api then
		prev_pdata.model = player_api.get_animation(player)
	end

	player:get_meta():set_string("previous_player_data", core.serialize(prev_pdata))

	player:set_physics_override({speed=0, jump=0})
	player:set_attach(self.object, "", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true)

	if seat_data and seat_data.model and player_api then
		player_api.set_model(player, seat_data.model)
		player_api.set_animation(player, rand_anim)
	end

	self.sitting_player_name = playername
	return true
end

function SittingEntity:standup_player()
	if not self:is_busy() then return false end

	local player = core.get_player_by_name(self.sitting_player_name)
	if player then
		local player_meta = player:get_meta()
		local prev_pdata = core.deserialize(player_meta:get_string("previous_player_data"))

		player:set_detach()

		if prev_pdata then
			player:set_physics_override(prev_pdata.physics)
			if prev_pdata.model and player_api then
				player_api.set_model(player, prev_pdata.model.model)
			end
		end

		player_meta:set_string("previous_player_data", "")
	end

	self.sitting_player_name = ""

	FurnitureManager.remove_by_object(self.object)
	return true
end

function SittingEntity:is_busy()
	return self.sitting_player_name ~= ""
end

function SittingEntity:on_deactivate(removal)
	if self:is_busy() then
		self:standup_player()
	end
	FurnitureEntity.on_deactivate(self, removal)
end

FurnitureManager.register(SittingEntity.name, SittingEntity, {
	pointable = false
})

-- Sitting API surface for furniture nodes
------------------------------------------------
local sitting = {}
sitting.standard_model = "multidecor_character_sitting.b3d"

if player_api then
	player_api.register_model(sitting.standard_model, {
		animations = {
			sit1 = { x = 4, y = 84 },
			sit2 = { x = 0, y = 1 },
			sit3 = { x = 2, y = 3, is_near_block_required = true }
		}
	})
end

function sitting.is_player_sitting(player)
	return player:get_meta():get_string("previous_player_data") ~= ""
end

-- Returns the luaentity of a busy SittingEntity attached to the node at 'node_pos'
function sitting.get_active_seat(node_pos)
	local list = FurnitureManager.get(node_pos)
	for _, desc in ipairs(list) do
		if desc.entity_name == SittingEntity.name and desc:exists() then
			local lua_ent = desc.object:get_luaentity()
			if lua_ent and lua_ent:is_busy() then
				return lua_ent
			end
		end
	end
	return nil
end

function sitting.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker or not clicker:is_player() then return end

	-- If this player already sits somewhere, stand him up first
	if sitting.is_player_sitting(clicker) then
		local player_meta = clicker:get_meta()
		local prev_pdata = core.deserialize(player_meta:get_string("previous_player_data"))
		if prev_pdata and prev_pdata.attached_to then
			local active_seat = sitting.get_active_seat(prev_pdata.attached_to)
			if active_seat then
				active_seat:standup_player()
				return
			end
		end
	end

	local active_seat = sitting.get_active_seat(pos)
	if active_seat then
		core.chat_send_player(clicker:get_player_name(), multidecor.S("This seat is busy!"))
		return
	end

	local node_def = core.registered_nodes[node.name]
	if not node_def or not node_def.add_properties or not node_def.add_properties.seat_data then return end

	local seat_data = table.copy(node_def.add_properties.seat_data)
	local rand_anim

	if seat_data.model and player_api then
		local node_dir = dir_ops.get_dir(pos)
		local near_node = core.get_node(vector.add(pos, node_dir))

		if core.get_item_group(near_node.name, "table") ~= 1 then
			local anims2 = {}
			for i = 1, #seat_data.anims do
				local m_def = player_api.registered_models[seat_data.model]
				if m_def and m_def.animations[seat_data.anims[i]] and
					not m_def.animations[seat_data.anims[i]].is_near_block_required then
					table.insert(anims2, seat_data.anims[i])
				end
			end
			seat_data.anims = anims2
		end

		if #seat_data.anims > 0 then
			rand_anim = seat_data.anims[math.random(1, #seat_data.anims)]
		end
	end

	local dir = dir_ops.get_dir(pos)
	local dir_rot = vector.dir_to_rotation(dir)
	local rot_seat_pos = vector.rotate_around_axis(
		dir_ops.rotate_to_dir(seat_data.pos, dir),
		vector.new(0, 1, 0),
		math.pi
	)

	local spawn_pos = pos + rot_seat_pos
	local spawn_rot = dir_rot + (seat_data.rot or vector.new())

	FurnitureManager.add(SittingEntity.name, pos, node.name, spawn_pos, spawn_rot)

	local list = FurnitureManager.get(pos)
	for _, desc in ipairs(list) do
		if desc.entity_name == SittingEntity.name and desc:exists() then
			local lua_ent = desc.object:get_luaentity()
			if lua_ent and not lua_ent:is_busy() then
				lua_ent:sit_player(clicker, seat_data, rand_anim)
				break
			end
		end
	end
end

function sitting.on_destruct(pos)
	local active_seat = sitting.get_active_seat(pos)
	if active_seat then
		active_seat:standup_player()
	end
end

function sitting.on_construct(pos) end

core.register_on_leaveplayer(function(player)
	local prev_pdata = core.deserialize(player:get_meta():get_string("previous_player_data"))
	if prev_pdata and prev_pdata.attached_to then
		local active_seat = sitting.get_active_seat(prev_pdata.attached_to)
		if active_seat then
			active_seat:standup_player()
		end
	end
end)

return { SittingEntity, sitting }
