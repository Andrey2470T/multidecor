local dir_ops = require("decor_api.helpers.dir_ops")
local BBox = require("decor_api.helpers.box")
local common = require("decor_api.helpers.common")
local register = require("decor_api.common.register")
local animation_t = require("decor_api.common.animation")
local AnimatedEntity = animation_t[1]
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureManager = furniture_t[3]

local Door = {}
Door.__index = Door

-- DoorEntity
-- The AnimatedEntity subclass driving door and drawer models: it swings or slides
-- the model through the "Door" bone of its carrier. The bone mechanics itself
-- stays in AnimatedEntity — the class only declares its "anim_params" and keeps
-- the open/close state logic, nothing subclass-specific. It is also the class
-- every pre-split save activates as (all doors were registered under its
-- historical "bone_animator" name): on_activate upgrades such an instance onto
-- the subclass it belongs to, so the base holds no behaviour of the heirs.
--------------------------------------------------------------------------------
local DoorEntity = AnimatedEntity:extend("decor_api:bone_animator")

-- Returns the rest ("closed") transform of the door model: the hinge-relative
-- offset rotated to 'dir' plus the yaw of 'dir' added to the model rotation.
-- Everything is authored in the engine frame: a model showing its front side
-- to the player carries the half turn in its 'rot.y' by itself. Shelf uses
-- this as well to spawn its doors
function DoorEntity.get_base_transform(node_pos, mparams, dir)
	local rel_pos = vector.new(mparams.pos)
	if mparams.hinge_shifted then
		rel_pos.x = rel_pos.x - mparams.box:width() * 2
	end

	local pos = node_pos + dir_ops.rotate_to_dir(rel_pos, dir)
	local rot = vector.new(mparams.rot.x, dir_ops.get_rot_y(dir) + mparams.rot.y, mparams.rot.z)
	return pos, rot
end

function DoorEntity:on_activate(staticdata)
	-- The pre-split saves all carry the historical "decor_api:bone_animator"
	-- name of this base class, so they activate here no matter which door
	-- they are. Upgrade such an instance onto the subclass it belongs to
	-- right away — before the base activation runs: the adopt/orphan decision
	-- inside it and every later callback (on_step, on_deactivate,
	-- on_animation_end) dispatch through the instance class
	if staticdata and staticdata ~= "" then
		local data = common.deserialize(staticdata)
		if data and data.attached_to then
			local subclass
			if data.shelf_i then
				-- the family pattern keeps the entity valid while the cooker
				-- node is swapped to its "_activated" variant
				self.node_pattern = data.node_pattern or data.attached_to.name:sub(12)
				subclass = multidecor.ShelfDoorEntity

				local ndef = common.ndef(data.attached_to.pos)
				local shelves_data = ndef and ndef.add_properties and ndef.add_properties.shelves_data
				local shelf_data = shelves_data and shelves_data[data.shelf_i]
				if shelf_data and shelf_data.invlist_type == "cooker" then
					subclass = multidecor.CookShelfDoorEntity
				end
			elseif data.convert_on_end then
				subclass = multidecor.NodeDoorEntity
			end

			-- a fresh spawn is already on the right class: nothing to upgrade
			if subclass and subclass ~= getmetatable(self) then
				-- the fields are copied early: the subclass activation below
				-- runs before the base activation copies them itself
				table.copy_to(data, self)
				setmetatable(self, subclass)

				-- Enter the subclass activation when it defines one of its
				-- own (NodeDoorEntity, CookShelfDoorEntity): the resumed
				-- instance must run it too. The call re-enters this method
				-- through its own super call, where the already-installed
				-- metatable makes the upgrade a no-op
				if subclass.on_activate ~= DoorEntity.on_activate then
					return subclass.on_activate(self, staticdata)
				end
			end
		end
	end

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
	else
		if not FurnitureManager.get_by_object(self.object) then
			-- An already initialized entity not tracked by the manager means the
			-- server restarted while it was active (the descriptors are
			-- runtime-only). Persistent shelf doors with their node still
			-- present keep working; a transition door would never finish (its
			-- animation end callback is manager-driven), so its node is
			-- restored right away instead
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
	local delta = math.abs(self.bone_offset - (self.cur_bone_offset or 0))
	local vel = math.max(0.001, aparams.velocity)

	-- The 1.3.x stepped animation grew its speed by 'acc' every ~0.1s server
	-- step ('vel' was only the initial one); the engine-interpolated override
	-- is linear, so the acceleration is folded into the equivalent duration
	-- of that motion: vel*t + (vel*acc/0.1)*t^2/2 == delta
	local acc = aparams.acc and aparams.acc * vel / 0.1 or 0

	if acc <= 0 then
		return delta / vel
	end

	return (math.sqrt(vel*vel + 2*acc*delta) - vel) / acc
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

	-- 'bone_offset' is the signed travel magnitude: along 'target_axis' for
	-- the swinging doors, along the full 'target_vec' for the sliding parts
	-- (drawers; the vec is pre-rotated into the carrier-local bone frame —
	-- the bone axes themselves do not follow the node facedir)
	local offset = self.bone_offset
	if aparams.target_vec then
		offset = vector.multiply(aparams.target_vec, self.bone_offset)
	end

	self:apply_bone_override(aparams.rotate, offset, aparams.target_axis, time)
	self.cur_bone_offset = self.bone_offset

	if not instant then
		self.anim_timer:start(time)
	end
end

FurnitureManager.register(DoorEntity.name, DoorEntity)

-- NodeDoorEntity
-- The DoorEntity subclass driving the real door nodes: the node is removed
-- while the transition runs and restored from the entity afterwards. The class
-- owns everything node-specific — the mesh selection ("_activated"), the
-- resting param2 quarter-turns, the meta restore, the pending action of a
-- fresh spawn and the transition end and orphan handling.
--------------------------------------------------------------------------------
local NodeDoorEntity = DoorEntity:extend("decor_api:node_door")

-- The class-level marker of the transition entities: the node converts into
-- the entity and back
NodeDoorEntity.convert_on_end = true

-- The node door activation specifics: the pending action of a fresh spawn and
-- an interrupted transition of a reactivation
function NodeDoorEntity:on_activate(staticdata)
	if not DoorEntity.on_activate(self, staticdata) then
		return false
	end

	-- to_entity stores the requested transition until the entity is fully
	-- set up (the door node is already removed by then): it is present
	-- exactly on the first activation of a fresh spawn — a saved entity
	-- always has it consumed already
	if self.pending_action then
		local action = self.pending_action
		self.pending_action = nil
		self:set_action(action)
	elseif self.action then
		-- The transition was interrupted by the reactivation (a restart or
		-- a mapblock unload in the middle of the swing): the animation
		-- timer is recreated fresh and not armed, so the swing would never
		-- reach its end — the 3-second validator would drop the entity
		-- with the door node still absent. Finish it right away instead:
		-- 'cur_bone_offset' already holds the target, so the transition
		-- has a zero delta and ends on the very next step
		self:set_action(self.action)
	end

	return true
end

-- The door node is intentionally absent while the entity animates: the
-- entity is valid exactly during the transition (the timer armed or a
-- pending action)
function NodeDoorEntity:check_node_valid()
	if not self.attached_to then
		return false
	end

	-- no timer running == no running transition
	return (self.anim_timer and self.anim_timer:is_started()) or self.pending_action ~= nil
end

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

-- Removes the door node and spawns the animating NodeDoorEntity in its place.
-- 'action' is the transition target ("open"/"close"), 'owner' is kept for locked doors
function NodeDoorEntity.to_entity(pos, action, owner)
	local node_def = common.ndef(pos)
	local add_data = node_def.add_properties
	local door_data = add_data.door
	local dtype = door_data.type
	local is_regular = dtype == "regular"

	-- The plain engine dir of the door node
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
	-- the dummy model looks against the node dir, so the node frame box
	-- reaches it mirrored
	bbox:mirror_h()
	if is_regular then
		-- the box is re-centered around the hinge corner the entity sits at
		bbox:shift(0.5, 0, -bbox:center().z)
	end

	local model_params = {
		size = door_data.size or {x=5, y=5, z=5},
		-- the animating leaf of a regular door is the "_activated" model: it
		-- is authored with the hinge at its origin so the entity hanging at
		-- the hinge corner swings the leaf around it (the 1.3.x behaviour;
		-- the base mesh is node-centered and used by the resting door nodes
		-- and by the sliding panels)
		mesh = is_regular and base_def.mesh:gsub("%.[^.]+$", "_activated%0")
			or base_def.mesh,
		textures = base_def.tiles,
		box = bbox,
		pos = vector.new(door_data.object_offset or {x=-0.495, y=0, z=-0.45}),
		-- the models show their front side to the player: relative to the
		-- engine dir (pointing at the node's back) the regular door leaf
		-- carries the half turn, the sliding panel does not
		rot = vector.new(0, is_regular and math.pi or 0, 0),
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
			velocity = math.rad(door_data.vel),
			acc = door_data.acc or 0
		}
	else
		local offset, move_axis = get_target_offset(false, dir, true, is_mir)
		anim_params = {
			rotate = false,
			target_axis = move_axis,
			target_offset = offset,
			velocity = door_data.vel,
			acc = door_data.acc or 0
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
		cur_mode = is_open_model and "open" or "closed"
	}

	local spawn_pos, spawn_rot = DoorEntity.get_base_transform(pos, model_params, dir)

	core.remove_node(pos)

	return FurnitureManager.add(NodeDoorEntity.name, pos, base_name, spawn_pos, spawn_rot, data)
end

-- Restores the door node from the finished NodeDoorEntity
function NodeDoorEntity.from_entity(door_ent)
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

	-- The base and "_open" slabs are both authored with their leaf against the
	-- local -Z side of the model, so the resting node states are quarter-turned
	-- per state (the 1.3.x behaviour): a plain door turns its param2 by
	-- -90 deg (facedir - 1) when it opens and back when it closes; a mirrored
	-- counterpart rests at one turned param2 for both states and never rotates
	local p2 = door_ent.node_param2
	if door_ent.door_type == "regular" and not is_mir then
		p2 = dir_ops.rotate_param2_y(base_name, p2,
			action == "open" and math.pi/2 or -math.pi/2)
	end

	FurnitureManager.remove_by_object(obj)
	-- The object may be untracked (a restart orphan); remove it directly then
	if obj and obj:is_valid() then
		obj:remove()
	end

	core.set_node(pos, {name=name, param2=p2})

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

-- The swing is over: restore the door node from the finished entity
function NodeDoorEntity:on_animation_end()
	if self.convert_on_end and self.action then
		Door.from_entity(self)
	end
end

-- A node door entity without its node (a server restart during the
-- transition): the swing cannot resume with its node absent, so the node is
-- restored right away
function NodeDoorEntity:on_orphan()
	if self.convert_on_end then
		Door.from_entity(self)
	elseif self.object and self.object:is_valid() then
		self.object:remove()
	end
end

FurnitureManager.register(NodeDoorEntity.name, NodeDoorEntity)

-- Door: manages the door node in its inactive (resting) state.
-- Converts the node to NodeDoorEntity on interaction and back on animation
-- end. The namespace keeps the historical interface used by the node
-- callbacks; NodeDoorEntity's transition end/orphan handling routes through
-- it as well.
--------------------------------------------------------------------------------

Door.to_entity = NodeDoorEntity.to_entity
Door.from_entity = NodeDoorEntity.from_entity

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

	NodeDoorEntity.to_entity(pos, action, owner)
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
			-- the open slab of the mirrored pair is turned towards the
			-- player; sliding doors keep the plain engine dir
			local swap_param2 = is_regular and
				dir_ops.rotate_param2_y(node.name, node.param2, math.pi) or
				dir_ops.from_dir_get_param2(node.name, node.param2, dir)

			core.swap_node(pos, {
				name = "multidecor:" .. swap_name,
				param2 = swap_param2
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

return { DoorEntity, NodeDoorEntity, Door, doors }
