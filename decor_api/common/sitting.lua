-- Sitting API based on the SittingEntity class
-----------------------------------------------

local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureEntity, FurnitureManager = furniture_t[1], furniture_t[3]

local common = require("decor_api.helpers.common")
local dir_ops = require("decor_api.helpers.dir_ops")

-- SittingEntity
-- The invisible entity the player is attached to while sitting.
-- It is spawned at the moment of sitting and removed at the standup.
--------------------------------------------------------------------------------
local SittingEntity = FurnitureEntity:extend("decor_api:seat_furniture")

-- Runtime registry of occupied seats: [player name] = SittingEntity luaentity.
-- It replaces the former player metadata storage ("previous_player_data"):
-- the sitting state is transient and lives no longer than the seat entity.
local sitting_players = {}

function SittingEntity:on_activate(staticdata)
	if not FurnitureEntity.on_activate(self, staticdata) then
		return false
	end

	self.sitting = self.sitting or {}
	self.sitting.current_player_name = self.sitting.current_player_name or ""
	return true
end

function SittingEntity:sit_player(player, seat_data, rand_anim)
	if not player or self:is_busy() then return false end

	local playername = player:get_player_name()

	if seat_data and seat_data.model and player_api then
		self.sitting.prev_model, _, self.sitting.prev_anim = player_api.get_animation(player)
		player_api.set_model(player, seat_data.model)
		player_api.set_animation(player, rand_anim)
	end

	player:set_attach(self.object, "", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true)

	self.sitting.current_player_name = playername
	sitting_players[playername] = self
	return true
end

function SittingEntity:standup_player()
	if not self:is_busy() then return false end

	local playername = self.sitting.current_player_name
	local player = core.get_player_by_name(playername)
	if player then
		player:set_detach()

		if self.sitting.prev_model and player_api then
			player_api.set_model(player, self.sitting.prev_model)
			player_api.set_animation(player, self.sitting.prev_anim)
		end
	end

	sitting_players[playername] = nil
	self.sitting.current_player_name = ""

	return true
end

function SittingEntity:is_busy()
	return self.sitting.current_player_name ~= ""
end

function SittingEntity:on_deactivate(removal)
	if self:is_busy() then
		self:standup_player()
	end
	FurnitureEntity.on_deactivate(self, removal)
end

-- The seat entity is transient: it is spawned on demand and never saved
FurnitureManager.register(SittingEntity.name, SittingEntity, {
	static_save = false
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

-- Returns the luaentity of the seat the player is currently sitting on, or nil.
-- Stale registry entries (the seat entity is already gone) are cleaned up here.
function sitting.get_player_seat(player)
	if not player then return end

	local playername = player:get_player_name()
	local seat = sitting_players[playername]
	if seat and seat.object and seat.object:is_valid() then
		return seat
	end

	sitting_players[playername] = nil
	return
end

function sitting.is_player_sitting(player)
	return sitting.get_player_seat(player) ~= nil
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
	return
end

function sitting.on_rightclick(pos, node, clicker)
	if not clicker or not clicker:is_player() then return end

	-- If this player already sits somewhere, stand him up first
	local player_seat = sitting.get_player_seat(clicker)
	if player_seat then
		player_seat:standup_player()
		return
	end

	local active_seat = sitting.get_active_seat(pos)
	if active_seat then
		common.msg("This seat is busy!", clicker)
		return
	end

	local node_def = core.registered_nodes[node.name]
	if not node_def or not node_def.add_properties or not node_def.add_properties.seat_data then return end

	local seat_data = table.copy(node_def.add_properties.seat_data)
	local rand_anim

	if seat_data.model and player_api then
		seat_data.anims = seat_data.anims or {"sit1"}

		local node_dir = dir_ops.get_dir(pos) * -1
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
	local dir_rot = vector.dir_to_rotation(dir * -1)
	local rot_seat_pos = dir_ops.rotate_to_dir(seat_data.pos, dir)

	local spawn_pos = pos + rot_seat_pos
	local spawn_rot = dir_rot + (seat_data.rot or vector.new())

	local desc = FurnitureManager.add(SittingEntity.name, pos, node.name, spawn_pos, spawn_rot)

	if desc and desc:exists() then
		local lua_ent = desc.object:get_luaentity()
		if lua_ent then
			lua_ent:sit_player(clicker, seat_data, rand_anim)
		end
	end
end

function sitting.on_destruct(pos)
	local active_seat = sitting.get_active_seat(pos)
	if active_seat then
		active_seat:standup_player()
	end
end

core.register_on_leaveplayer(function(player)
	local seat = sitting.get_player_seat(player)
	if seat then
		seat:standup_player()
	end
end)

core.register_on_respawnplayer(function(player)
	local seat = sitting.get_player_seat(player)
	if seat then
		seat:standup_player()
	end
end)

return { SittingEntity, sitting }
