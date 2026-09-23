require("decor_api.helpers.common")
local Timer = require("decor_api.helpers.timer")

local FurnitureManager = {
	registered_entities = {},
	descriptors = {},
	guid_to_desc = {},  -- [object_guid] = FurnitureDescriptor (for immediate search, O(1))
	CHECK_INTERVAL = 3.0
}

-- FurnitureEntity
--------------------------------------
local FurnitureEntity = {
	name = "decor_api:base_furniture",
	attached_to = nil, -- table {pos = vector, name = string}
}
FurnitureEntity.__index = FurnitureEntity

function FurnitureEntity.new(node_pos, node_name, data)
	local self = setmetatable({}, FurnitureEntity)
	self.attached_to = { pos = vector.new(node_pos), name = node_name }
	if data then
		table.copy_to(data, self)
	end

	return self
end

function FurnitureEntity:extend(name)
	local child = {}
	child.__index = child
	child.name = name

	setmetatable(child, { __index = self })
	return child
end

function FurnitureEntity.spawn(entity_name, node_pos, node_name, pos, rot, data)
	local serialize_t = FurnitureEntity.new(node_pos, node_name, data)
	local entity = core.add_entity(pos, entity_name, core.serialize(serialize_t))
	if entity then
		entity:set_rotation(rot)
	end
	return entity
end

function FurnitureEntity:on_activate(staticdata)
	if staticdata and staticdata ~= "" then
		local data = core.deserialize(staticdata)
		if data and data.attached_to then
			table.copy_to(data, self)
			return true
		end
	end

	self.object:set_armor_groups({immortal=true})
	return false
end

function FurnitureEntity:on_deactivate(removal)
	local desc = FurnitureManager.get_by_object(self.object)
	if desc then
		desc.removed = removal
	end
end

function FurnitureEntity:get_staticdata()
	local serialize_t = {}

	table.copy_to(self, serialize_t)
	serialize_t.name = nil
	serialize_t.object = nil

	return core.serialize(serialize_t)
end

function FurnitureEntity:check_node_valid()
	if not self.attached_to then
		return false
	end

	local cur_node = core.get_node_or_nil(self.attached_to.pos)
	if not cur_node or cur_node.name ~= self.attached_to.name then
		return false
	end
	return true
end

function FurnitureEntity.build_definition(class_table, override_def)
	local def = {
		physical = false,
		static_save = true,
		on_activate = function(self, staticdata)
			setmetatable(self, class_table)
			if class_table.on_activate then
				class_table.on_activate(self, staticdata)
			end
		end,
		get_staticdata = function(self)
			if class_table.get_staticdata then
				return class_table.get_staticdata(self)
			end
			return ""
		end,
		on_step = function(self, dtime)
			if class_table.on_step then
				class_table.on_step(self, dtime)
			end
		end
	}
	if override_def then
		for k, v in pairs(override_def) do def[k] = v end
	end
	return def
end

-- FurnitureDescriptor (handles one entity)
-------------------------------------------------
local FurnitureDescriptor = {}
FurnitureDescriptor.__index = FurnitureDescriptor

function FurnitureDescriptor.new(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)
	local self = setmetatable({}, FurnitureDescriptor)

	self.entity_name = entity_name
	self.node_pos = vector.new(node_pos)
	self.node_name = node_name
	self.spawn_pos = spawn_pos and vector.new(spawn_pos) or vector.new(node_pos)
	self.spawn_rot = spawn_rot and vector.new(spawn_rot) or vector.new()
	self.data = data or {}

	local class_table = FurnitureManager.registered_entities[self.entity_name]
	self.object = class_table.spawn(
		entity_name, self.node_pos, self.node_name, self.spawn_pos, self.spawn_rot, self.data)

	return self
end

-- If "self.removed=true" or the object is invalid, it doesn't exist,
-- if "self.removed=false" the object was just unloaded from the memory, but actually exists in the map 
function FurnitureDescriptor:exists()
	if self.removed == false then
		return true
	end
	return self.object and self.object:is_valid() and self.object:get_luaentity()
end

-- Self-validates. Removes the underlying entity if the node is not valid, otherwise
-- if the entity itself doesn't exist, respawns it
function FurnitureDescriptor:validate_entity()
	if self:exists() then
		if not self.object:get_luaentity():check_node_valid() then
			self.object:remove()
			return false
		end

		-- Prevents the unintentional entity position and rotation change (may be caused by external mod)
		if self.spawn_pos ~= self.object:get_pos() then
			self.object:set_pos(self.spawn_pos)
		end
		if self.spawn_rot ~= self.object:get_rotation() then
			self.object:set_rotation(self.spawn_rot)
		end
	else
		local class_table = FurnitureManager.registered_entities[self.entity_name]

		if self.object then
			FurnitureManager.guid_to_desc[self.object:get_guid()] = nil
		end

		self.object = class_table.spawn(
			self.entity_name, self.node_pos, self.node_name, self.spawn_pos, self.spawn_rot, self.data)

		if self.object then
			FurnitureManager.guid_to_desc[self.object:get_guid()] = self
		end
	end
	self.removed = nil

	return true
end

-- FurnitureManager
------------------------------------------------------

function FurnitureManager.register(name, class)
	FurnitureManager.registered_entities[name] = class
	core.register_entity(name, FurnitureEntity.build_definition(class))
end

function FurnitureManager.add(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)
	local pos_str = core.pos_to_string(node_pos)
	local desc = FurnitureDescriptor.new(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)

	if desc.object then
		if not FurnitureManager.descriptors[pos_str] then
			FurnitureManager.descriptors[pos_str] = {}
		end

		table.insert(FurnitureManager.descriptors[pos_str], desc)
		FurnitureManager.guid_to_desc[desc.object:get_guid()] = desc
	end
end

-- Removes all descriptors at "node_pos"
function FurnitureManager.remove(node_pos)
	local pos_str = core.pos_to_string(node_pos)
	local list = FurnitureManager.descriptors[pos_str]
	if list then
		for _, desc in ipairs(list) do
			if desc:exists() then
				FurnitureManager.guid_to_desc[desc.object:get_guid()] = nil
				desc.object:remove()
			end
		end
		FurnitureManager.descriptors[pos_str] = nil
	end
end

-- Removes only one descriptor using "guid_to_desc" mapping table
function FurnitureManager.remove_by_object(object)
	if not object or not object:is_valid() then return end
	local guid = object:get_guid()
	local desc = FurnitureManager.guid_to_desc[guid]

	if desc then
		local pos_str = core.pos_to_string(desc.node_pos)
		local list = FurnitureManager.descriptors[pos_str]

		if list then
			for i = #list, 1, -1 do
				if list[i] == desc then
					table.remove(list, i)
					break
				end
			end
			if #list == 0 then
				FurnitureManager.descriptors[pos_str] = nil
			end
		end

		FurnitureManager.guid_to_desc[guid] = nil
		object:remove()
	end
end

-- Returns the array of all descriptors at "node_pos"
function FurnitureManager.get(node_pos)
	local pos_str = core.pos_to_string(node_pos)
	return FurnitureManager.descriptors[pos_str] or {}
end

-- Returns the descriptor for "object" using the "guid_to_desc" mapping table (O(1))
function FurnitureManager.get_by_object(object)
	if not object or not object:is_valid() then return nil end
	return FurnitureManager.guid_to_desc[object:get_guid()]
end

function FurnitureManager.on_step()
	for pos_str, list in pairs(FurnitureManager.descriptors) do
		for i = #list, 1, -1 do
			local desc = list[i]
			local result = desc:validate_entity()
			if not result then
				if desc.object then
					FurnitureManager.guid_to_desc[desc.object:get_guid()] = nil
				end
				table.remove(list, i)
			end
		end
		if #list == 0 then
			FurnitureManager.descriptors[pos_str] = nil
		end
	end
end

FurnitureManager.register(FurnitureEntity.name, FurnitureEntity)

FurnitureManager.timer = Timer.new(
	FurnitureManager.CHECK_INTERVAL,
	true,
	{end_callback = FurnitureManager.on_step}
)
FurnitureManager.timer:start()

core.register_globalstep(function (dtime)
	FurnitureManager.timer:tick(dtime)
end)

return { FurnitureEntity, FurnitureDescriptor, FurnitureManager }
