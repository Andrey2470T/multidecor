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

multidecor.shelves = {}

shelves = multidecor.shelves

-- Temporary saving objects of current "open" shelves in the following format: ["playername"] = objref
local open_shelves = {}

function shelves.build_name_from_tmp(name, type, i)
	return name .. "_" .. i .. "_" .. type
end

-- Rotates the shelf 'obj' around 'pos' position of the node
function shelves.rotate_shelf(pos, obj, is_drawer, move_dist)
	local dir = helpers.get_dir(pos)
	--doors.rotate(obj, dir, pos)
	local new_pos, rot = doors.rotate(obj:get_pos(), dir, pos)
	obj:set_pos(new_pos)
	obj:set_rotation(rot)

	local self = obj:get_luaentity()
	if is_drawer then
		local rel_obj_pos = vector.subtract(obj:get_pos(), pos)
		self.start_v = vector.add(pos, rel_obj_pos)
		self.end_v = vector.add(pos, vector.add(rel_obj_pos, vector.multiply(dir, move_dist)))
	else
		local rot_y = vector.dir_to_rotation(dir).y
		self.start_v = rot_y
		self.end_v = rot_y+move_dist
	end
end

-- Rotates the obj`s selectionbox depending on the connected node rotation
function shelves.rotate_shelf_bbox(obj)
	local self = obj:get_luaentity()
	if not self then return end

	local dir = helpers.get_dir(self.connected_to.pos)
	local shelf = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data[self.shelf_data_i]

	if shelf.type == "sym_doors" and
			vector.round(vector.subtract(obj:get_pos(), self.connected_to.pos)) == vector.round(shelf.pos2) or self.is_flip_x_scale then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi)
	end
	local def = minetest.registered_entities[self.name]
	local sbox, cbox = doors.rotate_bbox(def.selectionbox, nil, dir)
	obj:set_properties({
		collisionbox = cbox,
		selectionbox = sbox
	})
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
	local shelf = minetest.registered_nodes[node_name].add_properties.shelves_data[self.shelf_data_i]
	local dir = helpers.get_dir(self.connected_to.pos)

	self.dir = dir_sign
	if shelf.type == "drawer" then
		-- Will pull out the drawer at the distance equal to 2/3 its length
		obj:set_velocity(vector.multiply(dir*dir_sign, 0.6))
	end

	if shelf.type == "sym_doors" then
		local tpos = self.is_flip_x_scale and shelf.pos or shelf.pos2
		tpos = self.connected_to.pos + vector.rotate_around_axis(tpos, {x=0, y=1, z=0}, vector.dir_to_rotation(dir).y)
		local obj2 = minetest.get_objects_inside_radius(tpos, 0.05)[1]

		if obj2 then
			local self2 = obj2:get_luaentity()

			if self2 and self.name == self2.name then
				self2.dir = dir_sign
			end
		end
	end

	if shelf.sounds then
		local play_sound = dir_sign == 1 and shelf.sounds.open or shelf.sounds.close

		minetest.sound_play(play_sound, {pos=obj:get_pos(), fade=1.0, max_hear_distance=10})
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
		local inv_name = shelves.build_name_from_tmp(node.name, "inv", i)
		local list_name = shelves.build_name_from_tmp(node.name, "list", i)

		local padding = 0.25
		local width = shelf_data.inv_size.w > 8 and shelf_data.inv_size.w or 8
		local fs_size = {
			w = width+1+(width-1)*padding,
			h = shelf_data.inv_size.h+5.5+(shelf_data.inv_size.h-1)*padding+3*padding
		}
		local player_list_y = shelf_data.inv_size.h+1+(shelf_data.inv_size.h-1)*padding

		local fs = ("formspec_version[4]size[%f,%f]" ..
				"list[detached:%s;%s;0.5,0.5;%f,%f;]" ..
				"list[current_player;main;0.5,%f;8,4;]"):format(
					fs_size.w, fs_size.h,
					inv_name, list_name,
					shelf_data.inv_size.w, shelf_data.inv_size.h, player_list_y)
		local obj = minetest.add_entity(vector.add(pos, shelf_data.pos), shelf_data.object, minetest.serialize({fs, {name=node.name, pos=pos}, 0, i}))

		local move_dist

		if shelf_data.type == "drawer" then
			move_dist = 2/3*shelf_data.length
		elseif shelf_data.type == "door" then
			move_dist = shelf_data.side == "left" and -math.pi/2 or math.pi/2
		elseif shelf_data.type == "sym_doors" then
			move_dist = -math.pi/2
		end
		shelves.rotate_shelf(pos, obj, shelf_data.type == "drawer", move_dist)

		if shelf_data.type == "sym_doors" then
			local obj2 = minetest.add_entity(vector.add(pos, shelf_data.pos2), shelf_data.object, minetest.serialize({fs, {name=node.name, pos=pos}, 0, i}))

			local vis_size = obj2:get_properties().visual_size
			obj2:set_properties({visual_size={x=vis_size.x*-1, y=vis_size.y, z=vis_size.z}})
			obj2:get_luaentity().is_flip_x_scale = true

			shelves.rotate_shelf(pos, obj2, false, math.pi/2)
		end
	end
end

shelves.default_on_activate = function(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		self.inv = data[1]
		self.connected_to = data[2]
		self.dir = data[3]
		self.shelf_data_i = data[4]
		self.inv_list = data[5] or {}
		self.start_v = data[6]
		self.end_v = data[7]
		self.is_flip_x_scale = data[8]
	end

	local node = minetest.get_node(self.connected_to.pos)

	if node.name ~= self.connected_to.name then
		self.object:remove()
		return
	end

	local shelf_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data[self.shelf_data_i]
	local obj_props = {}

	obj_props.visual_size = self.object:get_properties().visual_size
	-- Addendums for 'visual_size' multipliers
	if shelf_data.visual_size_adds then
		obj_props.visual_size = vector.add(obj_props.visual_size, shelf_data.visual_size_adds)
	end

	if self.is_flip_x_scale then
		obj_props.visual_size.x = obj_props.visual_size.x * -1
	end
	-- Usually means a material which the shelf is made of
	if shelf_data.base_texture then
		obj_props.textures = self.object:get_properties().textures
		obj_props.textures[1] = shelf_data.base_texture
	end
	self.object:set_properties(obj_props)
	self.object:set_armor_groups({immortal=1})

	shelves.rotate_shelf_bbox(self.object)

	local inv_name = shelves.build_name_from_tmp(self.connected_to.name, "inv", self.shelf_data_i)
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
	local inv_list = {}

	for _, stack_t in ipairs(self.inv_list) do
		local stack = ItemStack(stack_t.name)
		stack:set_count(stack_t.count)
		stack:set_wear(stack_t.wear)

		table.insert(inv_list, stack)
	end

	local list_name = shelves.build_name_from_tmp(self.connected_to.name, "list", self.shelf_data_i)
	inv:set_list(list_name, inv_list)
	inv:set_size(list_name, shelf_data.inv_size.w*shelf_data.inv_size.h)
	inv:set_width(list_name, shelf_data.inv_size.w)

	inv:set_size("main", 32)
	inv:set_width("main", 8)
end

shelves.default_get_staticdata = function(self)
	return minetest.serialize({self.inv, self.connected_to, self.dir, self.shelf_data_i, self.inv_list, self.start_v, self.end_v, self.is_flip_x_scale})
end

shelves.default_on_rightclick = function(self, clicker)
	open_shelves[clicker:get_player_name()] = self.object
	minetest.show_formspec(clicker:get_player_name(), shelves.build_name_from_tmp(self.connected_to.name, "fs", self.shelf_data_i), self.inv)

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

	if dist <= 0.05 then
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

	local shelf_data = minetest.registered_nodes[node.name].add_properties.shelves_data[self.shelf_data_i]
	doors.smooth_rotate_step(self, dtime, shelf_data.vel or 30, shelf_data.acc or 0)
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

		local self = shelf:get_luaentity()
		local inv_name = shelves.build_name_from_tmp(self.connected_to.name, "inv", self.shelf_data_i)
		local inv = minetest.get_inventory({type="detached", name=inv_name})
		local shelf_data = def.add_properties.shelves_data[self.shelf_data_i]
		local list = inv:get_list(shelves.build_name_from_tmp(self.connected_to.name, "list", self.shelf_data_i))

		for _, stack in ipairs(list) do
			table.insert(self.inv_list, {name=stack:get_name(), count=stack:get_count(), wear=stack:get_wear()})
		end

		shelves.open_shelf(shelf, -1)
	end
end

minetest.register_on_player_receive_fields(shelves.default_on_receive_fields)
