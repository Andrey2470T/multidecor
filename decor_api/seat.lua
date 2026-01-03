--[[
	'seat_def' is table:
	{
		pos = <attach position>
		rot = <attach rotation>
		models = {
			[1] = {
				mesh = <filename>,
				anim = {range = <table>, speed = <float>, blend = <bool>, loop = <bool>}
			}
			...
		}
	}
]]

core.register_entity("decor_api:seat", {
    initial_properties = {
        visual = "cube",
        textures = {"blank.png", "blank.png", "blank.png", "blank.png", "blank.png", "blank.png"},
        collisionbox = {0,0,0,0,0,0},
        selectionbox = {0,0,0,0,0,0},
        physical = false,
        pointable = false,
    },
    seat = nil,
    on_punch = function(self)
        self.object:remove()
    end,
})

local p2r_facedir = {
    [0] = 180*math.pi/180,
    [1] = 90*math.pi/180,
    [2] = 0*math.pi/180,
    [3] = 270*math.pi/180,
}

-- @param pos Node position
-- @param node NodeRef
-- @param clicker Player
local function sit_player(pos, node, clicker, base_def)
    local sit_pos = {x = pos.x, y = pos.y + 0.3, z = pos.z}
    local entity = core.add_entity(sit_pos, "decor_api:seat")
    local nodedef = core.registered_nodes[node.name]
    local seat_data = nodedef.add_properties.seat_data

    if not entity then return end

    local entity_table = entity:get_luaentity()
    if not entity_table then return end

    clicker:set_attach(entity, "", seat_data.pos, {x=0,y=0,z=0}, true)

    clicker:set_pos(sit_pos)
    entity:set_rotation({x = 0, y = p2r_facedir[node.param2 % 4], z = 0})

    entity_table.seat = clicker
end

local function after_destruct(pos, oldnode)
    for _, obj in ipairs(core.get_objects_inside_radius(pos, 1)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "decor_api:seat" then
            obj:remove()
        end
    end
end

local function on_rightclick(pos, node, clicker)
    local name = clicker:get_player_name()

    for _, obj in ipairs( core.get_objects_inside_radius(pos, 1) ) do --Search entity
        local entity_table = obj:get_luaentity()

        if entity_table and entity_table.name == "decor_api:seat" then
            if entity_table.seat == clicker then
                clicker:set_detach()
                player_api.player_attached[name] = nil
                player_api.set_animation(clicker, "stand", 0)

                entity_table.seat = nil
                obj:remove()
                return itemstack  -- нашли нужную сущность
            end
        end
    end

    player_api.set_animation(clicker, "sit", 30)
    player_api.player_attached[name] = true
    sit_player(pos, node, clicker)
end

local can_dig = function(pos, player)
    for _, obj in ipairs(core.get_objects_inside_radius(pos, 1)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "decor_api:seat" and ent.seat then
            return false
        end
    end
    return true
end

function multidecor.register.register_seat(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "seat"
	def.paramtype2 = def.paramtype2 or "facedir"

	-- additional properties
	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	def.callbacks = def.callbacks or {}

    def.callbacks.on_construct = def.callbacks.on_construct or multidecor.sitting.on_construct
    def.callbacks.on_destruct = def.callbacks.on_destruct or multidecor.sitting.on_destruct
    def.callbacks.after_destruct = after_destruct
    def.callbacks.on_rightclick = on_rightclick
    def.callbacks.can_dig = can_dig

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if def.add_properties and def.add_properties.connect_parts then
		multidecor.connecting.register_connect_parts(def)
	end
end
