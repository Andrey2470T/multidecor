local dir_ops = require("decor_api.helpers.dir_ops")
local BBox = require("decor_api.helpers.box")
local common = require("decor_api.helpers.common")
local register = require("decor_api.common.register")
local animation_t = require("decor_api.common.animation")
local AnimatedEntity = animation_t[1]
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureEntity, FurnitureManager = furniture_t[1], furniture_t[3]

local Door = {}
Door.__index = Door

-- DoorEntity
-- The AnimatedEntity subclass driving door and drawer models: it swings or slides
-- the model through the "Door" bone of its carrier. The bone mechanics itself
-- stays in AnimatedEntity — the class only declares its "anim_params" and keeps
-- the open/close state logic. For real door nodes the entity exists only while
-- the transition runs (the node itself is removed for that time and restored on
-- animation end); shelf doors and drawers are persistent and validate against
-- their node as usual.
--------------------------------------------------------------------------------
local DoorEntity = AnimatedEntity:extend("decor_api:bone_animator")

-- Returns the rest ("closed") transform of the door model: the hinge-relative
-- offset rotated to 'dir' plus the yaw of 'dir' added to the model rotation.
-- The model data ('pos'/'rot') is authored in the front (player-facing) frame
-- with +Z looking at the player, while 'dir' is the plain engine dir (get_dir)
-- pointing at the node's back side — the data is converted here, in the only
-- place where it meets the dir. Shelf uses this as well to spawn its doors
function DoorEntity.get_base_transform(node_pos, mparams, dir)
	local rel_pos = vector.new(mparams.pos)
	if mparams.hinge_shifted then
		rel_pos.x = rel_pos.x + mparams.box:width() * 2
	end

	-- front -> engine frame: the half turn around Y ("up"/"down" door
	-- hinges keep their vertical offsets unaffected)
	rel_pos = dir_ops.rotate_y(rel_pos, math.pi)

	local pos = node_pos + dir_ops.rotate_to_dir(rel_pos, dir)
	local rot = vector.new(mparams.rot.x, dir_ops.get_rot_y(dir) + mparams.rot.y + math.pi, mparams.rot.z)
	return pos, rot
end

function DoorEntity:on_activate(staticdata)
	if not AnimatedEntity.on_activate(self, staticdata) then
		return false
	end

	local aparams = self.anim_params or {}
	aparams.rotate = aparams.rotate ~= false
	aparams.target_axis = aparams.target_axis or "y"
	aparams.target_offset = aparams.target_offset or math.pi/2
	aparams.velocity = aparams.velocity or math.pi/1.5
	self.anim_params = aparams

	self.cur_mode = self.cur_mode or "closed"

	if not self.initialized then
		self.initialized = true
		self:update_door_state(self.cur_mode)
		-- snaps into the current mode without a transition
		self:apply_door_offset(true)

		if self.pending_action then
			local action = self.pending_action
			self.pending_action = nil
			self:set_action(action)
		end
	else
		if not FurnitureManager.get_by_object(self.object) then
			-- An already initialized entity not tracked by the manager means the
			-- server restarted while it was active (the descriptors are runtime-only).
			-- Persistent shelf doors with their node still present keep working;
			-- a transition door would never finish (its animation end callback is
			-- manager-driven), so its node is restored right away instead
			if not self.persistent or not self:check_node_valid() then
				self:on_orphan()
				return false
			end
		end

		-- The dummy is recreated above, but the bone override is not persisted:
		-- restore the visual state of the persistent doors (shelf doors/drawers)
		-- instead of leaving them in the rest pose
		if self.persistent then
			self:update_door_state(self.cur_mode)
			self:apply_door_offset(true)
		end
	end

	return true
end

-- The door node is intentionally absent while the entity animates:
-- non-persistent entities are valid only during the transition, persistent ones
-- (shelf doors) validate against their node exactly like FurnitureEntity does —
-- except when the node may swap inside its family ("node_pattern", e.g. to
-- "_activated" while cooking)
function DoorEntity:check_node_valid()
	if not self.attached_to then
		return false
	end

	if not self.persistent then
		return self.anim_timer:is_started() or self.pending_action ~= nil
	end

	if not self.node_pattern then
		return FurnitureEntity.check_node_valid(self)
	end

	local cur_node = core.get_node_or_nil(self.attached_to.pos)
	return cur_node ~= nil and cur_node.name:match(self.node_pattern) ~= nil
end

function DoorEntity:on_rightclick(clicker)
	if self.shelf_i and multidecor.shelves then
		multidecor.shelves.handle_door_click(self, clicker)
	end
end

-- Starts the transition to 'action' ("open"/"close"): plays the sound,
-- recalculates the target bone offset and animates towards it
function DoorEntity:set_action(action)
	self.action = action

	if self.sound_defs then
		local sound_name = action == "open" and self.sound_defs.open or self.sound_defs.close
		if sound_name then
			self.sound.name = sound_name
			self:play_sound()
		end
	end

	self:update_door_state(action == "open" and "open" or "closed")
	self:apply_door_offset()
end

-- Recalculates the entity base transform (always the "closed" rest pose),
-- the bone target offset for 'new_mode' and the rotated collision box
function DoorEntity:update_door_state(new_mode)
	-- The door node is absent during the transition, so the direction
	-- comes from the spawn data
	local dir = self.node_dir and vector.new(self.node_dir) or dir_ops.get_dir(self.attached_to.pos)
	local mparams = self.model_params

	self.bone_offset = new_mode == "closed" and 0 or self.anim_params.target_offset

	-- The box rotation must also reach the dummy carrying the visible model
	mparams.box:rotate(dir)
	if self.dummy_entity and self.dummy_entity:is_valid() then
		local coords = mparams.box:get_coords()
		self.dummy_entity:set_properties({collisionbox = coords, selectionbox = coords})
	end

	local pos, rot = DoorEntity.get_base_transform(self.attached_to.pos, mparams, dir)
	self.object:set_pos(pos)
	self.object:set_rotation(rot)
end

function DoorEntity:calc_anim_time()
	local aparams = self.anim_params
	return math.abs(self.bone_offset - (self.cur_bone_offset or 0)) / math.max(0.001, aparams.velocity)
end

-- Moves the "Door" bone towards the current 'bone_offset' target through the
-- AnimatedEntity mechanics: instantly with 'instant' (the rest pose right after
-- activation), otherwise the transition takes |delta|/velocity seconds and the
-- animation timer is armed for exactly that duration
function DoorEntity:apply_door_offset(instant)
	local aparams = self.anim_params
	local time = 0

	if not instant then
		time = self:calc_anim_time()
	end

	self:apply_bone_override(aparams.rotate, self.bone_offset, aparams.target_axis, time)
	self.cur_bone_offset = self.bone_offset

	if not instant then
		self.anim_timer:start(time)
	end
end

function DoorEntity:on_animation_end()
	if self.convert_on_end and self.action then
		Door.from_entity(self)
	end
end

function DoorEntity:on_deactivate(removal)
	if self.shelf_i and multidecor.shelves then
		multidecor.shelves.on_door_deactivated(self, removal)
	end
	AnimatedEntity.on_deactivate(self, removal)
end

function DoorEntity:on_orphan()
	if self.convert_on_end then
		Door.from_entity(self)
	elseif self.object and self.object:is_valid() then
		self.object:remove()
	end
end

FurnitureManager.register(DoorEntity.name, DoorEntity, {
	visual = "mesh",
	mesh = "multidecor_bone_animator.glb",
	physical = true,
	static_save = true
})

-- Door: manages the door node in its inactive (resting) state.
-- Converts the node to DoorEntity on interaction and back on animation end.
--------------------------------------------------------------------------------

-- Returns the world direction the sliding door moves to when going to the
-- 'is_open' state ('dir' is the plain engine dir of the door node)
local function get_move_dir(dir, is_open, is_mirrored)
	local angle = is_open and -math.pi/2 or math.pi/2
	return dir_ops.rotate_y(dir, is_mirrored and -angle or angle)
end

-- Returns the signed target bone offset of the door; for sliding doors
-- also the axis the door moves along
local function get_target_offset(is_regular, dir, is_open, is_mirrored)
	if is_regular then
		local offset = is_open and -math.pi/2 or math.pi/2
		return is_mirrored and -offset or offset
	end

	local move_dir = get_move_dir(dir, is_open, is_mirrored)
	local move_axis = dir_ops.get_dominant_axis(move_dir)

	return move_dir[move_axis], move_axis
end

-- Removes the door node and spawns the animating DoorEntity in its place.
-- 'action' is the transition target ("open"/"close"), 'owner' is kept for locked doors
function Door.to_entity(pos, action, owner)
	local node_def = common.ndef(pos)
	local add_data = node_def.add_properties
	local door_data = add_data.door
	local dtype = door_data.type
	local is_regular = dtype == "regular"

	-- The plain engine dir; the front-framed model data is converted
	-- inside get_base_transform
	local dir = dir_ops.get_dir(pos)
	local meta = core.get_meta(pos)
	local is_mir = meta:get_string("mirrored_counterpart") == "true"
	local mode = meta:get_string("door_mode")

	-- A mirrored regular door shows the opposite model of its mode
	local is_open_model = mode == "open"
	if is_regular then
		is_open_model = (mode == "open") ~= is_mir
	end

	local base_name = "multidecor:" .. add_data.common_name
	local base_def = core.registered_nodes[base_name]

	local bbox = BBox.from_box(base_def.collision_box.fixed[1])
	if is_regular then
		-- The box is re-centered around the hinge corner the entity sits at
		bbox:shift(-0.5, 0, -bbox:center().z)
	end

	local model_params = {
		size = door_data.size or {x=5, y=5, z=5},
		mesh = base_def.mesh,
		textures = base_def.tiles,
		box = bbox,
		pos = vector.new(door_data.object_offset or {x=0.495, y=0, z=0.45}),
		rot = vector.new(0, dtype == "sliding" and math.pi or 0, 0),
		mirrored = is_mir,
		hinge_shifted = is_mir,
		use_texture_alpha = base_def.use_texture_alpha == "blend",
		backface_culling = false
	}

	-- rotate/target_axis/velocity defaults are owned by DoorEntity itself;
	-- "vel" is always preset by register.register_door
	local anim_params
	if is_regular then
		anim_params = {
			target_offset = get_target_offset(true, dir, true, is_mir),
			velocity = math.rad(door_data.vel)
		}
	else
		local offset, move_axis = get_target_offset(false, dir, true, is_mir)
		anim_params = {
			rotate = false,
			target_axis = move_axis,
			target_offset = offset,
			velocity = door_data.vel
		}
	end

	local data = {
		model_params = model_params,
		anim_params = anim_params,
		sound_defs = door_data.sounds,
		door_type = dtype,
		node_param2 = dir_ops.from_dir_get_param2(base_name, core.get_node(pos).param2, dir),
		node_dir = vector.new(dir),
		owner = owner ~= "" and owner or nil,
		pending_action = action,
		cur_mode = is_open_model and "open" or "closed",
		convert_on_end = true,
		persistent = false
	}

	local spawn_pos, spawn_rot = DoorEntity.get_base_transform(pos, model_params, dir)

	core.remove_node(pos)

	return FurnitureManager.add(DoorEntity.name, pos, base_name, spawn_pos, spawn_rot, data)
end

-- Restores the door node from the finished DoorEntity
function Door.from_entity(door_ent)
	local obj = door_ent.object
	-- The entity sits at the hinge corner; the node position is exact
	local pos = vector.new(door_ent.attached_to.pos)
	local action = door_ent.action or door_ent.cur_mode or "closed"
	local base_name = door_ent.attached_to.name
	local is_mir = door_ent.model_params.mirrored == true

	local name = base_name
	if door_ent.door_type == "regular" then
		if (action == "open" and not is_mir) or (action == "close" and is_mir) then
			name = name .. "_open"
		end
	elseif is_mir then
		name = name .. "_mirrored"
	end

	FurnitureManager.remove_by_object(obj)
	-- The object may be untracked (a restart orphan); remove it directly then
	if obj and obj:is_valid() then
		obj:remove()
	end

	core.set_node(pos, {name=name, param2=door_ent.node_param2})

	local meta = core.get_meta(pos)
	if is_mir then
		meta:set_string("mirrored_counterpart", "true")
	end
	meta:set_string("door_mode", action == "open" and "open" or "closed")

	if door_ent.owner then
		meta:set_string("owner", door_ent.owner)
		meta:set_string("infotext", "Owned by " .. door_ent.owner)
	end
end

-- Node callbacks of the registered door nodes
--------------------------------------------------------------------------------

local doors = {}

function doors.node_on_rightclick(pos, node, clicker)
	local door_data = register.get_decor_api(pos, "door")
	if not door_data then return end

	local meta = core.get_meta(pos)
	local owner = meta:get_string("owner")

	if door_data.has_lock and owner ~= clicker:get_player_name() then
		common.msg("This door has locked!", clicker)
		return
	end

	local action = meta:get_string("door_mode") == "closed" and "open" or "close"

	if door_data.type == "sliding" then
		-- The sliding door needs a free node to move into
		local is_mir = meta:get_string("mirrored_counterpart") == "true"
		local move_dir = get_move_dir(dir_ops.get_dir(pos), action == "open", is_mir)

		if not common.is_airlike(pos + move_dir) or
			not multidecor.placement.check_for_placement(pos + move_dir, node.name) then
			common.msg("Not enough free place to move the door!", clicker)
			return
		end
	end

	Door.to_entity(pos, action, owner)
end

function doors.after_place_node(pos, placer)
	local node = core.get_node(pos)
	local add_props = core.registered_nodes[node.name].add_properties
	local door_data = add_props.door

	local meta = core.get_meta(pos)
	meta:set_string("door_mode", "closed")

	if door_data.has_mirrored_counterpart then
		local dir = dir_ops.get_dir(pos)
		-- The neighbor to the left of the player facing the door front
		local to_left = dir_ops.rotate_y(dir, math.pi/2)
		local left_def = common.ndef(pos + to_left)

		-- A co-directional door of the same family to the left makes this door
		-- the mirrored counterpart of the pair
		if left_def and left_def.add_properties and left_def.add_properties.common_name == add_props.common_name
			and vector.equals(dir, dir_ops.get_dir(pos + to_left)) then

			local is_regular = door_data.type == "regular"
			local swap_name = add_props.common_name .. (is_regular and "_open" or "_mirrored")
			-- The open slab of the mirrored pair faces the player (the front
			-- dir is the engine dir turned around); sliding doors keep facing
			-- away from them
			local swap_dir = is_regular and dir_ops.rotate_y(dir, math.pi) or dir

			core.swap_node(pos, {
				name = "multidecor:" .. swap_name,
				-- keeps the palette index of just placed node
				param2 = dir_ops.from_dir_get_param2(node.name, node.param2, swap_dir)
			})
			meta:set_string("mirrored_counterpart", "true")
		end
	end

	if door_data.has_lock then
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Owned by " .. playername)
	end
end

-- Registers the door node plus its counterpart the door converts to:
-- the "_open" node for regular doors and the "_mirrored" node for sliding
-- ones with a mirrored counterpart
function register.register_door(name, base_def, add_def, craft_def)
	local door_data = add_def and add_def.door
	if not door_data then
		return
	end

	local c_def = table.copy(base_def)
	c_def.type = "door"
	c_def.add_properties = add_def

	door_data.type = door_data.type or "regular"
	-- regular doors rotate (degrees/sec), sliding ones translate (nodes/sec)
	door_data.vel = door_data.vel or (door_data.type == "regular" and 120 or 1)

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or doors.node_on_rightclick
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or doors.after_place_node

	register.register_furniture_unit(name, c_def, craft_def)

	if door_data.type == "regular" or door_data.has_mirrored_counterpart then
		local c_def2 = table.copy(c_def)
		local suffix = door_data.type == "regular" and "_open" or "_mirrored"

		if door_data.type == "regular" then
			-- inserts the suffix before the mesh file extension
			c_def2.mesh = c_def2.mesh:gsub("%.[^.]+$", suffix .. "%0")
			-- the opened door slab sticks out to the opposite side
			c_def2.bounding_boxes[1][3] = c_def2.bounding_boxes[1][3] * -1
			c_def2.bounding_boxes[1][6] = c_def2.bounding_boxes[1][6] * -1
		end
		-- sliding doors share the base model: the mirroring is applied
		-- by the animating entity only

		c_def2.drop = "multidecor:" .. name
		c_def2.groups = c_def2.groups or {}
		c_def2.groups.not_in_creative_inventory = 1

		c_def2.callbacks.after_place_node = nil

		register.register_furniture_unit(name .. suffix, c_def2)
	end
end

return { DoorEntity, Door, doors }
