local dir_ops = require("decor_api.helpers.dir_ops")
local BBox = require("decor_api.helpers.box")
require("decor_api.helpers.common")
local AnimatedEntity = require("decor_api.common.animation")[1]
local FurnitureManager = require("decor_api.common.furniture_entity")[3]

local Door

-- DoorEntity: the door in its active (animating) state.
-- Exists only while the transition runs, then converts back to the door node.
--------------------------------------------------------------------------------
local DoorEntity = AnimatedEntity:extend("decor_api:door_dummy")

function DoorEntity:on_activate(staticdata)
	if not AnimatedEntity.on_activate(self, staticdata) then
		return false
	end

	self.anim_params = self.anim_params or {}
	self.anim_params.rotate = self.anim_params.rotate ~= false
	self.anim_params.target_axis = self.anim_params.target_axis or "y"
	self.anim_params.target_offset = self.anim_params.target_offset or math.pi/2
	self.anim_params.velocity = self.anim_params.velocity or math.pi/1.5
	self.anim_params.rotate_dir = self.anim_params.rotate_dir or "inward"

	self.cur_mode = self.cur_mode or "closed"

	if not self.initialized then
		self.initialized = true
		self:update_door_state(self.cur_mode)
		self:apply_bone_override(false)

		if self.pending_action then
			local action = self.pending_action
			self.pending_action = nil
			self:set_action(action)
		end
	end

	return true
end

-- The door node is intentionally absent while the entity animates:
-- non-persistent entities are valid only during the transition, persistent ones
-- (shelf doors) validate against their node as usual
function DoorEntity:check_node_valid()
	if not self.attached_to then
		return false
	end
	if self.persistent then
		local cur_node = core.get_node_or_nil(self.attached_to.pos)
		if not cur_node then
			return false
		end
		if self.node_pattern then
			return cur_node.name:match(self.node_pattern) ~= nil
		end
		return cur_node.name == self.attached_to.name
	end
	return self.anim_timer:is_started() or self.pending_action ~= nil
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
	self:animate_door()
end

-- Recalculates the entity base transform (always the "closed" rest pose)
-- and the bone target offset for 'new_mode'
function DoorEntity:update_door_state(new_mode)
	-- The door node is absent during the transition, so the direction
	-- comes from the spawn data
	local dir = self.node_dir and vector.new(self.node_dir) or dir_ops.get_dir(self.attached_to.pos)
	local mparams = self.model_params
	local aparams = self.anim_params

	local pos = vector.new(mparams.pos)
	if mparams.hinge_shifted then
		pos.x = pos.x + mparams.box:width() * 2
	end

	self.cur_pos = self.attached_to.pos + dir_ops.rotate_to_dir(pos, dir)
	self.cur_rot = vector.new(mparams.rot)
	self.cur_rot.y = self.cur_rot.y + dir_ops.get_rot_y(dir)
	self.cur_mode = new_mode

	self.bone_offset = new_mode == "closed" and 0 or aparams.target_offset

	mparams.box:rotate(dir)

	self.object:set_pos(self.cur_pos)
	self.object:set_rotation(self.cur_rot)
end

function DoorEntity:apply_bone_override(interpolate)
	if not self.object then return end

	local aparams = self.anim_params
	local vec = vector.new()
	vec[aparams.target_axis] = self.bone_offset

	local time = interpolate and math.abs(self.bone_offset - (self.cur_bone_offset or 0))
		/ math.max(0.001, aparams.velocity) or 0

	local override
	if aparams.rotate then
		override = {rotation = {vec = vec, interpolation = time}}
	else
		override = {position = {vec = vec, interpolation = time}}
	end

	self.object:set_bone_override("Door", override)
	self.cur_bone_offset = self.bone_offset

	return time
end

function DoorEntity:animate_door()
	local time = self:apply_bone_override(true)
	self.anim_timer:start(math.max(time, 0))
end

function DoorEntity:on_animation_end()
	if self.object and self.model_params.box then
		local coords = self.model_params.box:get_coords()
		self.object:set_properties({collisionbox = coords, selectionbox = coords})
	end

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

FurnitureManager.register(DoorEntity.name, DoorEntity, {
	visual = "mesh",
	mesh = "door_dummy.glb",
	physical = true,
	static_save = true
})

-- Door: manages the door node in its inactive (resting) state.
-- Converts the node to DoorEntity on interaction and back on animation end.
--------------------------------------------------------------------------------
Door = {}
Door.__index = Door

local function get_rotation_dir(dir, is_open, is_mirrored)
	local movedir_rot = is_open and math.pi/2 or -math.pi/2
	movedir_rot = is_mirrored and -movedir_rot or movedir_rot

	return dir_ops.rotate_y(dir, movedir_rot)
end

-- Returns the signed target offset for the door bone;
-- for sliding doors also the movement axis
local function get_target_offset(door_type, dir, is_open, is_mirrored)
	if door_type == "regular" then
		local rot_offset = is_open and -math.pi/2 or math.pi/2
		rot_offset = is_mirrored and -rot_offset or rot_offset

		return rot_offset
	end

	local movedir = get_rotation_dir(dir, is_open, is_mirrored)

	local move_axis
	if movedir.x ~= 0 then move_axis = "x"
	elseif movedir.y ~= 0 then move_axis = "y"
	else move_axis = "z"
	end

	return movedir[move_axis], move_axis
end

-- Removes the door node and spawns the animating DoorEntity in its place.
-- 'action' is the transition target ("open"/"close")
function Door.to_entity(pos, action, owner)
	local node = core.get_node(pos)
	local node_def = core.registered_nodes[node.name]
	local add_data = node_def.add_properties
	local door_data = add_data.door
	local dtype = door_data.type

	local dir = dir_ops.get_dir(pos)
	local meta = core.get_meta(pos)
	local is_mir = meta:get_string("mirrored_counterpart") == "true"
	local mode = meta:get_string("door_mode")

	local is_open_model = mode == "open"
	if dtype == "regular" then
		is_open_model = (not is_mir and mode == "open") or (is_mir and mode == "closed")
	end

	local base_name = "multidecor:" .. add_data.common_name
	local base_def = core.registered_nodes[base_name]

	local bbox = table.copy(base_def.collision_box.fixed[1])
	if dtype == "regular" then
		local z_center = (bbox[3]+bbox[6])/2
		bbox[3] = bbox[3] - z_center
		bbox[6] = bbox[6] - z_center
		bbox[1] = bbox[1] - 0.5
		bbox[4] = bbox[4] - 0.5
	end

	local model_params = {
		size = door_data.size or {x=5, y=5, z=5},
		mesh = base_def.mesh,
		textures = base_def.tiles,
		box = BBox.from_box(bbox),
		pos = vector.new(door_data.object_offset or {x=0.495, y=0, z=0.45}),
		rot = {x=0, y = dtype == "sliding" and math.pi or 0, z=0},
		mirrored = is_mir,
		hinge_shifted = is_mir,
		bone = "Door",
		use_texture_alpha = base_def.use_texture_alpha == "blend",
		backface_culling = false
	}

	local anim_params
	if dtype == "regular" then
		anim_params = {
			rotate = true,
			target_axis = "y",
			target_offset = get_target_offset(dtype, dir, true, is_mir),
			velocity = math.rad(door_data.vel or 120),
			rotate_dir = "inward"
		}
	else
		local offset, move_axis = get_target_offset(dtype, dir, true, is_mir)
		anim_params = {
			rotate = false,
			target_axis = move_axis,
			target_offset = offset,
			velocity = door_data.vel or 1
		}
	end

	local data = {
		model_params = model_params,
		anim_params = anim_params,
		sound_defs = door_data.sounds,
		door_type = dtype,
		node_param2 = node.param2,
		node_dir = vector.new(dir),
		owner = owner ~= "" and owner or nil,
		pending_action = action,
		cur_mode = is_open_model and "open" or "closed",
		convert_on_end = true,
		persistent = false
	}

	local pos_rel = vector.new(model_params.pos)
	if model_params.hinge_shifted then
		pos_rel.x = pos_rel.x + model_params.box:width() * 2
	end
	local spawn_pos = pos + dir_ops.rotate_to_dir(pos_rel, dir)
	local spawn_rot = vector.new(model_params.rot)
	spawn_rot.y = spawn_rot.y + dir_ops.get_rot_y(dir)

	core.remove_node(pos)

	return FurnitureManager.add(DoorEntity.name, pos, base_name, spawn_pos, spawn_rot, data)
end

-- Restores the door node from the finished DoorEntity
function Door.from_entity(door_ent)
	local obj = door_ent.object
	-- The entity sits at the hinge corner; the node position is exact
	local pos = vector.new(door_ent.attached_to.pos)
	local action = door_ent.action or "close"
	local base_name = door_ent.attached_to.name
	local dtype = door_ent.door_type
	local is_mir = door_ent.model_params.mirrored == true

	local name = base_name
	if dtype == "regular" then
		if (action == "open" and not is_mir) or (action == "close" and is_mir) then
			name = name .. "_open"
		end
	elseif dtype == "sliding" and is_mir then
		name = name .. "_mirrored"
	end

	FurnitureManager.remove_by_object(obj)

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

local doors = {}
function doors.node_on_rightclick(pos, node, clicker)
	local def = core.registered_nodes[node.name]

	if not def.add_properties or not def.add_properties.door then
		core.log("error", "Node at " .. core.pos_to_string(pos) .. " has no add_properties.door!")
		return
	end

	local door_data = def.add_properties.door
	local meta = core.get_meta(pos)
	local owner = meta:get_string("owner")
	local cur_mode = meta:get_string("door_mode")
	local is_mir_cpart = meta:get_string("mirrored_counterpart") == "true"

	if door_data.has_lock then
		local playername = clicker:get_player_name()
		if owner ~= playername then
			core.chat_send_player(playername, multidecor.S("This door has locked!"))
			return
		end
	end

	local action = cur_mode == "closed" and "open" or "close"

	if door_data.type == "sliding" then
		local node_dir = dir_ops.get_dir(pos)
		local move_dir = get_rotation_dir(node_dir, action == "open", is_mir_cpart)

		local place_check = multidecor.placement.check_for_placement(pos + move_dir, node.name)
		local next_node_free = multidecor.placement.is_free_space(pos + move_dir)
		if not place_check or not next_node_free then
			core.chat_send_player(clicker:get_player_name(), "Not enough free place to move the door!")
			return
		end
	end

	Door.to_entity(pos, action, owner)
end

function doors.after_place_node(pos, placer)
	local add_props = core.registered_nodes[core.get_node(pos).name].add_properties

	local meta = core.get_meta(pos)
	meta:set_string("door_mode", "closed")

	if add_props.door.has_mirrored_counterpart then
		local dir = dir_ops.get_dir(pos)

		local to_left = dir_ops.rotate_y(dir, -math.pi/2)
		local left_nodedef = core.registered_nodes[core.get_node(pos + to_left).name]

		if left_nodedef.add_properties and left_nodedef.add_properties.common_name ==
			add_props.common_name and vector.equals(dir, dir_ops.get_dir(pos + to_left)) then

			local mirrored_door_name = add_props.door.type == "regular" and add_props.common_name .. "_open" or
				add_props.common_name .. "_mirrored"
			dir = add_props.door.type == "sliding" and dir*-1 or dir
			local mirrored_door_param2 = core.dir_to_facedir(dir)

			core.swap_node(pos, {name="multidecor:" .. mirrored_door_name, param2=mirrored_door_param2})
			meta:set_string("mirrored_counterpart", "true")
		end
	end

	if add_props.door.has_lock then
		local playername = placer:get_player_name()
		meta:set_string("owner", playername)
		meta:set_string("infotext", "Owned by " .. playername)
	end
end

function multidecor.register.register_door(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "door"

	if not add_def or not add_def.door then
		return
	end

	c_def.add_properties = add_def
	c_def.add_properties.door.type = c_def.add_properties.door.type or "regular"

	if c_def.add_properties.door.type == "regular" then
		c_def.add_properties.door.vel = c_def.add_properties.door.vel or 2*math.pi/3
	else
		c_def.add_properties.door.vel = c_def.add_properties.door.vel or 1
	end

	c_def.callbacks = c_def.callbacks or {}
	c_def.callbacks.on_rightclick = c_def.callbacks.on_rightclick or doors.node_on_rightclick
	c_def.callbacks.after_place_node = c_def.callbacks.after_place_node or doors.after_place_node

	multidecor.register.register_furniture_unit(name, c_def, craft_def)

	local type = c_def.add_properties.door.type
	local mesh_format = "." .. (c_def.add_properties.door.format or "b3d")

	local c_def2 = table.copy(c_def)

	if type == "regular" or (type == "sliding" and c_def.add_properties.door.has_mirrored_counterpart) then
		local endformat = type == "regular" and "_open" or ""
		c_def2.mesh = c_def2.mesh:gsub(mesh_format, endformat .. mesh_format)
		c_def2.drop = "multidecor:" .. name

		if type == "regular" then
			c_def2.bounding_boxes[1][3] = c_def2.bounding_boxes[1][3] * -1
			c_def2.bounding_boxes[1][6] = c_def2.bounding_boxes[1][6] * -1
		end

		c_def2.groups = c_def2.groups or {}
		c_def2.groups.not_in_creative_inventory = 1

		c_def2.callbacks.after_place_node = nil

		local endname = type == "regular" and "_open" or "_mirrored"
		multidecor.register.register_furniture_unit(name .. endname, c_def2)
	end
end

return { DoorEntity, Door, doors }
