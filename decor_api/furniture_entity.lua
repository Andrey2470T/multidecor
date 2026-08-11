local hlpfuncs = multidecor.helpers

multidecor.FurnitureEntities = {list = {}}

function multidecor.FurnitureEntities:add(new_func, ...)
	table.insert(self.list, new_func(...))
end

function multidecor.FurnitureEntities:remove(id)
	self.list[id] = nil
end

function multidecor.FurnitureEntities:get_count()
	return #self.list
end

function multidecor.FurnitureEntities:get(id)
	return self.list[id]
end

function multidecor.FurnitureEntities:update_all()
	for _, furniture_entity in ipairs(self.list) do
		furniture_entity:update_orientation()
		furniture_entity:restore_entity()
	end
end

core.register_globalstep(function(dtime)
	multidecor.FurnitureEntities:update_all()
end)


-- Bone entity class for some furniture units
------------------------------------------------------

multidecor.FurnitureEntity = {
	name = "decor_api:furniture_entity",
	model_params = {
		size = {x=1, y=1, z=1},
		mesh = "",
		textures = {},
		box = hlpfuncs.BBox.from_default(),
		pos = vector.new(),
		rot = vector.new()
	},
	nodepos = vector.new(),
	entity = nil,
	timer = hlpfuncs.Timer.new(0, true, function (data)
		if data.callback then
			data.callback(data.entity)
		end
	end, {})
}

multidecor.FurnitureEntity.__index = multidecor.FurnitureEntity

local function add_entity(id, pos, rot)
	local serialize_data = {id = id}
	local entity = core.add_entity(pos, multidecor.FurnitureEntity.name, core.serialize(serialize_data))
	entity:set_rotation(rot)

	return entity
end

function multidecor.FurnitureEntity.new(_nodepos, _model_params, _step_callback)
    local self = setmetatable({}, multidecor.FurnitureEntity)

	self.nodepos = _nodepos

	self.id = multidecor.FurnitureEntities:get_count() + 1
	self.model_params.size = _model_params.size or self.model_params.size
	self.model_params.mesh = _model_params.mesh or self.model_params.mesh
	self.model_params.textures = _model_params.textures or self.model_params.textures
	self.model_params.box = _model_params.box or self.model_params.box
	self.model_params.pos = _model_params.pos or self.model_params.pos
	self.model_params.rot = _model_params.rot or self.model_params.rot

	self.pos = self.nodepos + self.model_params.pos
	self.rot = self.model_params.rot

	self.entity = add_entity(self.id, self.pos, self.rot)

	self.timer.callback_data = {
		entity=self.entity, box=self.model_params.box, callback=_step_callback
	}

	self:update_orientation()

    return self
end

function multidecor.FurnitureEntity:is_valid()
    return self.entity and self.entity:get_pos() ~= nil
end

function multidecor.FurnitureEntity:update_model()
	if not self:is_valid() then return end

	self.entity:set_properties({
		visual_size = self.model_params.size,
		mesh = self.model_params.mesh,
		textures = self.model_params.textures
	})
end

function multidecor.FurnitureEntity:update_orientation()
    if not self:is_valid() then return end

	local dir = hlpfuncs.get_dir(self.nodepos)

	if dir == self.dir then
		return
	end
	self.dir = dir

    self.pos = self.nodepos + hlpfuncs.rotate_to_dir(dir, self.model_params.pos)
	self.rot = self.model_params.rot + vector.new(0, hlpfuncs.get_rot_y(dir), 0)

    self.entity:set_pos(self.pos)
    self.entity:set_rotation(self.rot)

	self.model_params.box:rotate(dir)
	self.entity:set_properties({
		collisionbox = self.model_params.box:get_coords(),
		selectionbox = self.model_params.box:get_coords()
	})
end

function multidecor.FurnitureEntity:restore_entity()
	if self:is_valid() then return end

	local found_entities = core.get_objects_inside_radius(self.pos, 0.1)

	for _, obj in ipairs(found_entities) do
		local luaent = obj:get_luaentity()
		if luaent and luaent.name == multidecor.FurnitureEntity.name then
			local furniture_entity = multidecor.FurnitureEntities:get(luaent.id)
			if furniture_entity and furniture_entity.nodepos == self.nodepos then
				self.entity = obj
				return
			end
		end
	end

	self.entity = add_entity(self.id, self.pos, self.rot)
end

--[[function multidecor.FurnitureEntity:remove(meta_key_to_clear)
    if meta_key_to_clear then
        core.get_meta(self.nodepos):set_string(meta_key_to_clear, "")
    end
    if self:is_valid() then
        self.entity:remove()
    end
end]]

local function on_activate(self, staticdata)
	if staticdata ~= "" then
		local data = core.deserialize(staticdata)
		self.id = data.id
	end

	local furniture_entity = multidecor.FurnitureEntities:get(self.id)
	if furniture_entity then
		furniture_entity.entity = self.object
		furniture_entity:update_model()
	end

	self.object:set_armor_groups({immortal=1})
end

local function on_step(self, dtime)
	local furniture_entity = multidecor.FurnitureEntities:get(self.id)
	if furniture_entity then
		furniture_entity.timer:tick(dtime)
	end
end

local function get_staticdata(self)
	return core.serialize({id = self.id})
end

-- Registers the dummy entity (single bone) for attaching various kinds of doors/drawers
core.register_entity(multidecor.FurnitureEntity.name, {
	visual_size = multidecor.FurnitureEntity.model_params.size,
	visual = "mesh",
	mesh = "door_dummy.glb",
	physical = true,
	use_texture_alpha = "blend",
	backface_culling = false,
	static_save = true,
	on_activate = on_activate,
	on_step = on_step,
	get_staticdata = get_staticdata
})
