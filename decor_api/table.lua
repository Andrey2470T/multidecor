--[[
	'shelves_data' is table containing:
	{
		type = "drawer",
		pos = <position> (relative),
		object = <object_name>,
		inventory = <formspec_string>,
		length = <number>
	}

	or

	{
		type = "door",
		pos = <position> (relative),
		object = <object_name>,
		inventory = <formspec_string>,
		side = "left"/"right"
	}
]]

shelves = {}

-- Temporary saving objects of current "open" shelves in the following format: ["playername"] = objref
local open_shelves = {}

-- Rotates the shelf 'obj' around 'pos' position of the node
function shelves.rotate_shelf(pos, obj, is_drawer, move_dist)
	if not obj:get_luaentity() then
		return
	end

	local dir = shelves.get_dir(pos)
	local rot_y = vector.dir_to_rotation(dir).y

	local rel_obj_pos = vector.subtract(obj:get_pos(), pos)
	rel_obj_pos = vector.rotate_around_axis(rel_obj_pos, {x=0, y=1, z=0}, rot_y)
	obj:set_pos(vector.add(pos, rel_obj_pos))
	local rot = obj:get_rotation()
	obj:set_rotation({x=rot.x, y=rot_y, z=rot.z})

	local self = obj:get_luaentity()
	if is_drawer then
		self.start_v = vector.add(pos, rel_obj_pos)
		self.end_v = vector.add(pos, vector.add(rel_obj_pos, vector.multiply(dir, move_dist)))
	else
		self.start_v = rot_y
		self.end_v = rot_y+move_dist
	end
end

-- Returns a direction of the node with 'pos' position
function shelves.get_dir(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local dir = def.paramtype2 == "facedir" and vector.copy(minetest.facedir_to_dir(node.param2)) or
			def.paramtype2 == "wallmounted" and vector.copy(minetest.wallmounted_to_dir(node.param2))
	dir = dir*-1
	return dir
end

-- Animates opening or closing the shelf 'obj'. The action directly depends on 'dir_sign' value ('1' is open, '-1' is close)
function shelves.open_shelf(obj, dir_sign)
	local self = obj:get_luaentity()

	if not self then
		return
	end

	if not self.connected_to then
		return
	end

	local node_name = self.connected_to.name

	local shelf_i
	for i, data in ipairs(minetest.registered_nodes[node_name].add_properties.shelves_data) do
		if self.name == data.object then
			shelf_i = i
		end
	end

	local shelf = minetest.registered_nodes[node_name].add_properties.shelves_data[shelf_i]
	local dir = shelves.get_dir(self.connected_to.pos)

	self.dir = dir_sign
	if shelf.type == "drawer" then
		-- Will pull out the drawer at the distance equal to 2/3 its length
		obj:set_velocity(vector.multiply(dir*dir_sign, 0.4))
	end
end

-- Adds shelf objects for the node with 'pos' position. They should save formspec inventory and position of the node which they are connected to
function shelves.set_shelves(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	if not def.add_properties or not def.add_properties.shelves_data then
		return
	end

	local dir = def.paramtype2 == "facedir" and minetest.facedir_to_dir(node.param2) or
			def.paramtype2 == "wallmounted" and minetest.wallmounted_to_dir(node.param2)
	local rot_y = vector.dir_to_rotation(dir)

	for i, shelf_data in ipairs(def.add_properties.shelves_data) do
		local obj = minetest.add_entity(vector.add(pos, shelf_data.pos), shelf_data.object, minetest.serialize({shelf_data.inventory, {name=node.name, pos=pos}, 0}))
		local move_dist

		if shelf_data.type == "drawer" then
			move_dist = 2/3*shelf_data.length
		else
			move_dist = shelf_data.side == "left" and -math.pi/2 or math.pi/2
		end
		shelves.rotate_shelf(pos, obj, shelf_data.type == "drawer", move_dist)
		local inv_name = node.name:gsub(":", "_") .. "_" .. i .. "_inv"
		minetest.debug(inv_name)
		minetest.create_detached_inventory(inv_name, {
			allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				return count
			end,
			allow_put = function(inv, listname, index, stack, player)
				return stack:get_count()
			end,
			allow_take = function(inv, listname, index, stack, player)
				return stack:get_count()
			end
		})

		local inv = minetest.get_inventory({type="detached", name=inv_name})
		local list_name = node.name:gsub(node.name:sub(1, node.name:find(":")), "") .. "_" .. shelf_data.type
		inv:set_list(list_name, {})
		inv:set_size(list_name, shelf_data.inv_size.w*shelf_data.inv_size.h)
		inv:set_width(list_name, shelf_data.inv_size.w)
	end
end

shelves.default_on_activate = function(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		self.inv = data[1]
		self.connected_to = data[2]
		self.dir = data[3]
		self.start_v = data[4]
		self.end_v = data[5]
	end
end

shelves.default_get_staticdata = function(self)
	return minetest.serialize({self.inv, self.connected_to, self.dir, self.start_v, self.end_v})
end

shelves.default_on_rightclick = function(self, clicker)
	local def = minetest.registered_nodes[self.connected_to.name]
	local shelf_i

	for i, data in ipairs(def.add_properties.shelves_data) do
		if self.name == data.object then
			shelf_i = i
			break
		end
	end

	open_shelves[clicker:get_player_name()] = self.object
	minetest.show_formspec(clicker:get_player_name(), self.connected_to.name .. "_" .. shelf_i .. "_fs", self.inv)

	if self.dir == 0 then
		shelves.open_shelf(self.object, 1)
	end
end

shelves.default_drawer_on_step = function(self)
	local node = minetest.get_node(self.connected_to.pos)

	if node.name ~= self.connected_to.name then
		self.object:remove()
		return
	end
	if self.dir == 0 then
		return
	end

	local target_pos = self.dir == 1 and self.end_v or self.start_v
	local dist = vector.distance(self.object:get_pos(), target_pos)

	if dist <= 0.1 then
		self.dir = 0
		self.object:set_velocity(vector.zero())
		self.object:set_pos(target_pos)
	end
end

shelves.default_door_on_step = function(self, dtime)
	local node = minetest.get_node(self.connected_to.pos)

	if node.name ~= self.connected_to.name then
		self.object:remove()
		return
	end

	if self.dir == 0 then
		return
	end

	local rot = self.object:get_rotation()
	local target_rot = self.dir == 1 and self.end_v or self.start_v

	if math.abs(target_rot-rot.y) <= math.rad(10) then
		self.dir = 0
		self.object:set_rotation({x=rot.x, y=target_rot, z=rot.z})
		return
	end

	-- Rotation speed is 45 degrees/sec
	self.object:set_rotation({x=rot.x, y=rot.y+(-self.dir)*math.pi/3*dtime, z=rot.z})
end

shelves.default_on_receive_fields = function(player, formname, fields)
	local is_table_inv = formname:find("%d+", -10)

	if not is_table_inv then
		return
	end

	local name = formname:sub(1, is_table_inv-2)
	local def = minetest.registered_nodes[name]

	if not def then
		return
	end

	local is_table = false

	for n, val in pairs(def.groups) do
		if n == "table" then
			is_table = true
			break
		end
	end

	if not name:sub(1, name:find(":")-1) == "multidecor" or not is_table then
		return
	end

	local shelf = open_shelves[player:get_player_name()]
	if fields.quit == "true" and shelf then
		open_shelves[player:get_player_name()] = nil
		shelves.open_shelf(shelf, -1)
	end
end

function register.register_table(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "table"

	c_def.add_properties = add_def

	--[[if c_def.callbacks then
		c_def.callbacks.on_construct = c_def.callbacks.on_construct or default_on_construct
	else
		c_def.callbacks = {on_construct = default_on_construct}
	end]]
	register.register_furniture_unit(name, c_def, craft_def)
end

minetest.register_on_player_receive_fields(shelves.default_on_receive_fields)
