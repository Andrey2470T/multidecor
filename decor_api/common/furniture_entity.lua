require("decor_api.helpers.common")
local Timer = require("decor_api.helpers.timer")

local FurnitureManager

-- FurnitureEntity
--------------------------------------
local FurnitureEntity = {
	name = "decor_api:base_furniture",
	attached_to = nil, -- table {pos = vector, name = string}
}
FurnitureEntity.__index = FurnitureEntity

function FurnitureEntity.new(pos, node_name, data)
	local self = setmetatable({}, FurnitureEntity)
	self.attached_to = { pos = vector.new(node_pos), name = node_name }
    if data then
		table.copy_to(data, self)
	end

	return self
end

function FurnitureEntity.spawn(entity_name, node_pos, node_name, pos, rot, data)
	local serialize_t = FurnitureEntity.new(node_pos, node_name, data)
	local entity = core.add_entity(pos, entity_name, core.serialize(serialize_t))
	entity:set_rotation(rot)

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
	local desc = FurnitureManager.get(self.attached_to.pos)
	-- if removed=true, the entity is entirely removed, if removed=false it was unloaded,
	-- otherwise it means the callback wasnt called (in case of core.clear_objects it may stay nil)
	desc.removed = removal
end

function FurnitureEntity:get_staticdata()
	local serialize_t = {}

	table.copy_to(self, serialize_t)
	serialize_t.name = nil
	serialize_t.object = nil

	return core.serialize(serialize_t)
end

-- Check if the attaching node still exists, remove the object if doesn't
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

-- Creates and fills the entity registration table for "core.register_entity"
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

-- FurnitureDescriptor
-------------------------------------------------
local FurnitureDescriptor = {}
FurnitureDescriptor.__index = FurnitureDescriptor

function FurnitureDescriptor.new(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)
	local self = setmetatable({}, FurnitureDescriptor)

	self.entity_name = entity_name
	self.node_pos = vector.new(node_pos)
	self.node_name = node_name
	self.spawn_pos = spawn_pos and vector.new(spawn_pos) or vector.new(node_pos)
	self.spawn_rot = spawn_rot and vector.new(spawn_rot) or vector.new({x=0, y=0, z=0})
	self.data = data or {}

	local class_table = FurnitureManager.registered_entities[entity_name]
	self.object = class_table.spawn(
		entity_name, self.node_pos, self.node_name, self.spawn_pos, self.spawn_rot, self.data)

	return self
end

function FurnitureDescriptor:exists()
	if self.removed == false then
		return true
	end
	return self.object and self.object:is_valid() and self.object:get_luaentity()
end

function FurnitureDescriptor:validate_entity()
	if self:exists() then
		if not self.object:get_luaentity():check_node_valid() then
			self.object:remove()
			return false
		end
	else
		local class_table = FurnitureManager.registered_entities[self.entity_name]
		self.object = class_table.spawn(
			self.entity_name, self.node_pos, self.node_name, self.spawn_pos, self.spawn_rot, self.data)
	end
	self.removed = nil

	return true
end

-- FurnitureManager
------------------------------------------------------
FurnitureManager = {
	registered_entities = {},
	descriptors = {}, -- table in view: [pos_string] = FurnitureDescriptor
	CHECK_INTERVAL = 3.0 -- Check for entity validity per 3 seconds
}

function FurnitureManager.register(name, class)
	FurnitureManager.registered_entities[name] = class
	core.register_entity(name, FurnitureEntity.build_definition(class))
end

-- Adds the descriptor (called when the node was added to which its entity was attached)
function FurnitureManager.add(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)
	local pos_str = core.pos_to_string(node_pos)
	local desc = FurnitureDescriptor.new(entity_name, node_pos, node_name, spawn_pos, spawn_rot, data)
	FurnitureManager.descriptors[pos_str] = desc
end

-- Removes the descriptor (called when the node was removed to which its entity was attached or in on_step)
function FurnitureManager.remove(node_pos)
	local pos_str = core.pos_to_string(node_pos)
	local desc = FurnitureManager.descriptors[pos_str]
	if desc then
		if desc:exists() then
			desc.object:remove()
		end
		FurnitureManager.descriptors[pos_str] = nil
	end
end

function FurnitureManager.get(node_pos)
	local pos_str = core.pos_to_string(node_pos)
	return FurnitureManager.descriptors[pos_str]
end

function FurnitureManager.on_step()
	for _, desc in pairs(FurnitureManager.descriptors) do
		local result = desc:validate_entity()
		if not result then FurnitureManager.remove(desc.node_pos) end
	end
end

-- Registers the "decor_api:base_furniture" entity
FurnitureManager.register(FurnitureEntity.name, FurnitureEntity)

FurnitureManager.timer = Timer.new(
	FurnitureManager.CHECK_INTERVAL,
	true,
	{end_callback=FurnitureManager.on_step}
)
FurnitureManager.timer:start()

core.register_globalstep(function (dtime)
	FurnitureManager.timer:tick(dtime)
end)

return { FurnitureEntity, FurnitureDescriptor, FurnitureManager }

