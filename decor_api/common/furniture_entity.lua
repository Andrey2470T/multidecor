require("decor_api.helpers.common")

local FurnitureDescriptor = {}
FurnitureDescriptor.__index = FurnitureDescriptor

function FurnitureDescriptor.new(lua_entity, entity_name, pos, node_name, model_params, anim_params)
	local self = setmetatable({}, FurnitureDescriptor)

	self.entity_name = entity_name
	self.nodepos = vector.new(pos)
	self.node_name = node_name

	self.model_params = table.copy(model_params or {})
	self.anim_params = table.copy(anim_params or {})

	self.lua_entity = lua_entity
	self.object = lua_entity.object

	return self
end

function FurnitureDescriptor:update_entity(lua_entity)
	self.lua_entity = lua_entity
	self.object = lua_entity.object
end

local FurnitureEntity = {
	name = "decor_api:base_furniture",
	attached_to = nil, -- table {pos = vector, name = string}
}
FurnitureEntity.__index = FurnitureEntity

function FurnitureEntity.new(pos, node_name, data)
	local self = setmetatable({}, FurnitureEntity)
	self.attached_to = { pos = vector.new(pos), name = node_name }
    self.data = data or {}

	return self
end

function FurnitureEntity:on_activate(staticdata)
	if staticdata and staticdata ~= "" then
		local data = core.deserialize(staticdata)
		if data and data.attached_to then
            self.attached_to = data.attached_to
            self.model_params = data.model_params
			self.anim_params = data.anim_params
            self.data = data.data or {}
			return true
		end
	end

    self.object:set_armor_groups({immortal=true})

	return false
end

function FurnitureEntity:get_staticdata()
	return core.serialize({
        attached_to = self.attached_to, model_params = self.model_params,
        anim_params = self.anim_params, data = self.data
    })
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

function FurnitureEntity.build_definition(class_table, override_def)
	local def = {
		physical = false,
		static_save = true,
		on_activate = function(self, staticdata)
			setmetatable(self, class_table)
			class_table.on_activate(self, staticdata)
		end,
		get_staticdata = function(self)
			return class_table.get_staticdata(self)
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

