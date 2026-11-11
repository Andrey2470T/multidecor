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

function SittingEntity:sit_player(player, seat_data, rand_anim, look_yaw)
	if not player or self:is_busy() then return false end

	local playername = player:get_player_name()

	if seat_data and seat_data.model and player_api then
		local anim_data = player_api.get_animation(player)
		if anim_data then
			self.sitting.prev_model = anim_data.model
			self.sitting.prev_anim = anim_data.animation
		end
		player_api.set_model(player, seat_data.model)
		if rand_anim then
			player_api.set_animation(player, rand_anim)
		end
	end

	local physics = player:get_physics_override()
	self.sitting.prev_physics = {speed = physics.speed, jump = physics.jump}
	player:set_physics_override({speed = 0, jump = 0})

	if player_api then
		player_api.player_attached[playername] = true
	end

	if look_yaw then
		player:set_look_horizontal(look_yaw)
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

		if self.sitting.prev_physics then
			player:set_physics_override(self.sitting.prev_physics)
		end

		if player_api then
			player_api.player_attached[playername] = false
		end

		if self.sitting.prev_model and player_api then
			player_api.set_model(player, self.sitting.prev_model)
			if self.sitting.prev_anim then
				player_api.set_animation(player, self.sitting.prev_anim)
			end
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

-- The seat entity is transient: it is spawned on demand and never saved.
-- It is rendered as a fully transparent cube instead of is_visible = false:
-- invisible objects get no scene node at all (addToScene returns early), so
-- an attached player would have no parent transform to glue to (the model
-- ends up at a garbage position). pointable = false keeps it click-through,
-- its rotation is what the attached sitting player is glued to
FurnitureManager.register(SittingEntity.name, SittingEntity, {
	static_save = false,
	visual = "cube",
	textures = {
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png",
		"multidecor_transparency.png"
	},
	physical = false,
	pointable = false
})

-- Sitting API surface for furniture nodes
------------------------------------------------
local sitting = {}
-- The .b3d model keeps the sit1/sit2/sit3 keyframe animations: the .glb
-- sibling was converted without animation tracks (empty "animations" array),
-- and glTF keyframes would have to be selected by clip name instead of frame
-- ranges anyway
sitting.standard_model = "multidecor_character_sitting.b3d"

if player_api then
	player_api.register_model(sitting.standard_model, {
		textures = {"character.png"},
		animations = {
			sit1 = { x = 4, y = 84 },
			sit2 = { x = 0, y = 1 },
			sit3 = { x = 2, y = 3, is_near_block_required = true }
		}
	})
end

-- Returns the luaentity of the seat the player is currently sitting on, or nil.
-- Stale registry entries (the seat entity is already gone) are cleaned up here.
function sitting.get_player_seat_desc(player)
	if not player then return end

	local playername = player:get_player_name()
	local seat = sitting_players[playername]
	return FurnitureManager.get_by_object(seat and seat.object)
end

function sitting.is_player_sitting(player)
	return sitting.get_player_seat_desc(player) ~= nil
end

-- Returns the first found busy SittingEntity descriptor attached to the node at 'node_pos'
function sitting.get_active_seat_desc(node_pos)
	local list = FurnitureManager.get(node_pos)
	for _, desc in ipairs(list) do
		if desc.entity_name == SittingEntity.name and desc:exists() then
			return desc
		end
	end
	return
end

function sitting.on_rightclick(pos, node, clicker)
	if not clicker or not clicker:is_player() then return end

	-- If this player already sits somewhere, stand him up first
	local player_seat = sitting.get_player_seat_desc(clicker)
	if player_seat then
		FurnitureManager.remove_by_object(player_seat.object)
		return
	end

	local active_seat = sitting.get_active_seat_desc(pos)
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

		local near_node = dir_ops.get_near_node(pos, "back", true)

		if not near_node or core.get_item_group(near_node.name, "table") ~= 1 then
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

	local spawn_pos, spawn_rot = dir_ops.rotate_to_node_dir(
		pos, seat_data.pos, true, seat_data.rot)
	-- The sitting player model is authored facing +Z at yaw 0 (unlike the
	-- furniture models, whose player-facing front side is -Z), so the seat
	-- entity is half-turned from the node dir: the attached player then looks
	-- along the front side of the seat (against the engine dir). Matches the
	-- 1.3.x formula dir_to_rotation(-dir) + seat_data.rot
	spawn_rot.y = spawn_rot.y + math.pi

	local desc = FurnitureManager.add(SittingEntity.name, pos, node.name, spawn_pos, spawn_rot)

	if desc and desc:exists() then
		local lua_ent = desc.object:get_luaentity()
		if lua_ent then
			lua_ent:sit_player(clicker, seat_data, rand_anim, spawn_rot.y)
		end
	end
end

function sitting.on_destruct(pos)
	local active_seat = sitting.get_active_seat_desc(pos)
	if active_seat then
		FurnitureManager.remove_by_object(active_seat.object)
	end
end

core.register_on_leaveplayer(function(player)
	local seat = sitting.get_player_seat_desc(player)
	if seat then
		FurnitureManager.remove_by_object(seat.object)
	end
end)

core.register_on_respawnplayer(function(player)
	local seat = sitting.get_player_seat_desc(player)
	if seat then
		FurnitureManager.remove_by_object(seat.object)
	end
end)

return { SittingEntity, sitting }
