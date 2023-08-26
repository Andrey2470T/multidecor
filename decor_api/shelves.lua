--[[
	'shelves_data' is table containing:
	{
		type = "drawer"/"door"/"sym_doors",
		pos = <position>							-- relative
		pos2 = <position> (relative),				-- relative, present if type == "sym_doors"
		object = <object_name>,
		base_texture = <texture name>,				-- applied to the object as first tile
		invlist_type = "storage"/"trash"/"cooker",	-- default is "storage"
		inv_size = {w=<number>, h=<number>},		-- count of slots along width (w) and height (h), present if type == "storage"
		length = <number>,							-- max distance that drawer object is pushed out, present if type == "drawer"
		side = "left"/"right"/"centered",			-- present if type == "door"
		orig_angle = <rotation>,					-- relative
		visual_size_adds = <addendums vector>,
		acc = <number>,
		sounds = {
			open = "sound name",
			close = "sound name"
		}
	}
]]

multidecor.shelves = {}


-- Temporary saving objects of current "open" shelves in the following format: ["playername"] = objref
local open_shelves = {}

-- Rotates the shelf 'obj' around 'pos' position of the node
function multidecor.shelves.rotate_shelf(pos, obj, is_drawer, side, move_dist, orig_angle)
	orig_angle = orig_angle or {x=0, y=0, z=0}
	local dir = multidecor.helpers.get_dir(pos)
	--doors.rotate(obj, dir, pos)
	local new_pos, rot = multidecor.doors.rotate(obj:get_pos(), dir, pos)
	rot = vector.add(rot, orig_angle)
	obj:set_pos(new_pos)
	obj:set_rotation(rot)

	dir = vector.rotate(dir, orig_angle)

	local self = obj:get_luaentity()
	if is_drawer then
		local rel_obj_pos = vector.subtract(obj:get_pos(), pos)
		self.start_v = vector.add(pos, rel_obj_pos)
		self.end_v = vector.add(pos, vector.add(rel_obj_pos, vector.multiply(dir, move_dist)))
	else
		local rot = vector.dir_to_rotation(dir)
		if side == "down" or side == "up" then
			self.rotate_x = true
			self.start_v = rot.x
			self.end_v = rot.x+move_dist
		else
			self.rotate_x = false
			self.start_v = rot.y
			self.end_v = rot.y+move_dist
		end
	end
end

-- Rotates the obj`s selectionbox depending on the connected node rotation
function multidecor.shelves.rotate_shelf_bbox(obj)
	local self = obj:get_luaentity()
	if not self then return end

	local dir = multidecor.helpers.get_dir(self.connected_to.pos)
	local shelf = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data[self.shelf_data_i]

	if shelf.type == "sym_doors" and
			vector.round(vector.subtract(obj:get_pos(), self.connected_to.pos)) == vector.round(shelf.pos2) or self.is_flip_x_scale then
		dir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi)
	end
	local def = minetest.registered_entities[self.name]
	local sbox, cbox = multidecor.doors.rotate_bbox(def.selectionbox, nil, dir)
	obj:set_properties({
		collisionbox = cbox,
		selectionbox = sbox
	})
end

-- Builds formspec string for the shelf with 'shelf_num' number. The inventory can be detached and node.
function multidecor.shelves.build_formspec(pos, common_name, data, shelf_num, detached)
	if detached == nil then
		detached = true
	end

	local inv_name = multidecor.helpers.build_name_from_tmp(common_name, "inv", shelf_num, pos)
	local list_name = multidecor.helpers.build_name_from_tmp(common_name, "list", shelf_num, pos)
	local list_type = data.invlist_type or "storage"

	local padding = 0.25
	local list_w = list_type == "storage" and data.inv_size.w or 1
	local list_h = list_type == "storage" and data.inv_size.h or 1
	local width = list_w > 8 and list_w or 8
	local fs_size = {
		w = width+1+(width-1)*padding,
		h = list_h+5.5+(list_h-1)*padding+3*padding
	}
	fs_size.h = list_type == "cooker" and fs_size.h + 1 or fs_size.h
	local player_list_y = list_h+1+(list_h-1)*padding + (list_type == "cooker" and 1 or 0)
	local list_x = list_type == "cooker" and fs_size.w/2-0.5 or 0.5
	local list_y = list_type == "cooker" and 1 or 0.5

	local fs =
		("formspec_version[4]size[%f,%f]"):format(fs_size.w, fs_size.h) ..
		("list[current_player;main;0.5,%f;8,4;]"):format(player_list_y)

	if detached then
		fs = fs .. ("list[detached:%s;%s;%f,%f;%f,%f;]"):format(inv_name, list_name, list_x, list_y, list_w, list_h)
	else
		fs = fs .. ("list[nodemeta:%f,%f,%f;%s;0.5,0.5;%u,%u;]"):format(pos.x, pos.y, pos.z, list_name, list_w, list_h)
	end

	if list_type == "trash" then
		fs = fs .. "image[0.5,0.5;1,1;multidecor_trash_icon.png;]"
	end

	if list_type == "cooker" then
		fs = fs .. "image[0.5,1;1,1;multidecor_cooker_fire_off.png;]"
	end

	return fs
end

-- Animates opening or closing the shelf 'obj'. The action directly depends on 'dir_sign' value ('1' is open, '-1' is close)
function multidecor.shelves.open_shelf(obj, dir_sign)
	local self = obj:get_luaentity()

	if not self then
		return
	end

	if not self.connected_to then
		return
	end

	local node_name = self.connected_to.name
	local shelf = minetest.registered_nodes[node_name].add_properties.shelves_data[self.shelf_data_i]
	local dir = multidecor.helpers.get_dir(self.connected_to.pos)

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
function multidecor.shelves.set_shelves(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	if not def.add_properties or not def.add_properties.shelves_data then
		return
	end

	for i, shelf_data in ipairs(def.add_properties.shelves_data) do
		local fs = multidecor.shelves.build_formspec(
			pos,
			def.add_properties.shelves_data.common_name,
			shelf_data,
			i
		)

		local obj = minetest.add_entity(vector.add(pos, shelf_data.pos), shelf_data.object, minetest.serialize({fs, {name=node.name, pos=pos}, 0, i}))

		local move_dist

		if shelf_data.type == "drawer" then
			move_dist = 2/3*shelf_data.length
		elseif shelf_data.type == "door" then
			move_dist = (shelf_data.side == "left" or shelf_data.side == "down") and -math.pi/2 or math.pi/2
		elseif shelf_data.type == "sym_doors" then
			move_dist = -math.pi/2
		end
		multidecor.shelves.rotate_shelf(pos, obj, shelf_data.type == "drawer", shelf_data.side, move_dist, shelf_data.orig_angle)

		if shelf_data.type == "sym_doors" then
			local obj2 = minetest.add_entity(vector.add(pos, shelf_data.pos2), shelf_data.object, minetest.serialize({fs, {name=node.name, pos=pos}, 0, i}))

			local vis_size = obj2:get_properties().visual_size
			obj2:set_properties({visual_size={x=vis_size.x*-1, y=vis_size.y, z=vis_size.z}})
			obj2:get_luaentity().is_flip_x_scale = true

			multidecor.shelves.rotate_shelf(pos, obj2, false, shelf_data.side, math.pi/2, shelf_data.orig_angle)
		end
	end
end

multidecor.shelves.default_on_activate = function(self, staticdata)
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
		self.rotate_x = data[9]
		self.cook_info = data[10]
	end

	local node = minetest.get_node(self.connected_to.pos)

	local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data
	if not node.name:match(shelves_data.common_name) then
		self.object:remove()
		return
	end

	local shelf_data = shelves_data[self.shelf_data_i]
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

	multidecor.shelves.rotate_shelf_bbox(self.object)

	local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", self.shelf_data_i, self.connected_to.pos)
	local inv = minetest.get_inventory({type="detached", name=inv_name})

	if not inv then
		inv = minetest.create_detached_inventory(inv_name, {
			allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				return count
			end,
			allow_put = function(inv, listname, index, stack, player)
				local c = stack:get_count()

				if shelf_data.invlist_type == "cooker" then
					local output = minetest.get_craft_result({method="cooking", width=1, items={stack}})

					if not output or output.time == 0 then
						c = 0
					end
				end
				return c
			end,
			allow_take = function(inv, listname, index, stack, player)
				return stack:get_count()
			end,
			on_put = function(inv, listname, index, stack, player)
				if shelf_data.invlist_type == "trash" then
					stack:clear()
					inv:remove_item(listname, inv:get_stack(listname, 1))
					minetest.sound_play("multidecor_trash", {to_player=player:get_player_name()})
				elseif shelf_data.invlist_type == "cooker" then
					local name = stack:get_name()

					local output = minetest.get_craft_result({method="cooking", width=1, items=inv:get_list(listname)})
					output.item = {name=output.item:get_name(), count=output.item:get_count()*stack:get_count(), wear=output.item:get_wear()}
					local total_time = output.time*stack:get_count()

					local obj = open_shelves[player:get_player_name()]
					local self = obj:get_luaentity()

					local padding = 0.25
					local list_w = 9+7*padding
					local list_x = list_w/2-0.5

					local fire_fs = "image[0.5,1;1,1;multidecor_cooker_fire_on.png]style_type[label;font=bold;font_size=*2]label[7,1.5;%s]"
					local cook_active_fs = "image[" .. list_x .. ",1;1,1;multidecor_cooker_active_bg.png^[lowpart:%f:multidecor_cooker_active_fs.png]"

					minetest.swap_node(self.connected_to.pos, {
						name="multidecor:" ..shelves_data.common_name .. "_activated",
						param2=minetest.get_node(self.connected_to.pos).param2
					})

					local sound_handle = minetest.sound_play("multidecor_hum", {object=obj, fade=1.0, max_hear_distance=10, loop=true})
					minetest.get_meta(self.connected_to.pos):set_string("sound_handle", minetest.serialize(sound_handle))
					self.cook_info = {output, 0, total_time, self.inv, fire_fs, cook_active_fs}
				end
			end
		})

		local list_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", self.shelf_data_i, self.connected_to.pos)
		local inv_list = {}

		for _, stack_t in ipairs(self.inv_list) do
			local stack = ItemStack(stack_t.name)
			stack:set_count(stack_t.count)
			stack:set_wear(stack_t.wear)

			table.insert(inv_list, stack)
		end

		local list_type = shelf_data.invlist_type or "storage"
		local invsize = list_type == "storage" and shelf_data.inv_size or {w=1, h=1}
		inv:set_list(list_name, inv_list)
		inv:set_size(list_name, invsize.w*invsize.h)
		inv:set_width(list_name, invsize.w)

		inv:set_size("main", 32)
		inv:set_width("main", 8)
	end
end

multidecor.shelves.default_get_staticdata = function(self)
	return minetest.serialize({self.inv, self.connected_to, self.dir, self.shelf_data_i, self.inv_list, self.start_v, self.end_v, self.is_flip_x_scale, self.rotate_x, self.cook_info})
end

multidecor.shelves.default_on_rightclick = function(self, clicker)
	open_shelves[clicker:get_player_name()] = self.object
	local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data
	minetest.show_formspec(clicker:get_player_name(), multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", self.shelf_data_i, self.connected_to.pos), self.inv)

	if self.dir == 0 then
		multidecor.shelves.open_shelf(self.object, 1)
	end
end


local function cook_step(self, dtime)
	if not self.cook_info then
		return
	end

	self.cook_info[2] = self.cook_info[2] + dtime
	local elapsed_time = self.cook_info[2]

	local percents = self.cook_info[2]/self.cook_info[3]*100
	local i = self.cook_info[4]:find("list%[")
	local str_perc = tostring(math.round(percents)) .. " %"
	self.inv = self.cook_info[4]:sub(1, i-1) .. self.cook_info[6]:format(percents) .. self.cook_info[4]:sub(i) .. self.cook_info[5]:format(str_perc)


	local meta = minetest.get_meta(self.connected_to.pos)
	meta:set_string("infotext", "Cooked to: " .. str_perc)

	local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data
	local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", self.shelf_data_i, self.connected_to.pos)
	local inv_list = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", self.shelf_data_i, self.connected_to.pos)
	local inv = minetest.get_inventory({type="detached", name=inv_name})


	local time_elapsed = self.cook_info and self.cook_info[2] >= self.cook_info[3]
	if inv:is_empty(inv_list) or time_elapsed then
		if time_elapsed then
			local output = ItemStack(self.cook_info[1].item.name)
			output:set_count(self.cook_info[1].item.count)
			output:set_wear(self.cook_info[1].item.wear)
			inv:set_stack(inv_list, 1, output)
		end

		self.inv = self.cook_info[4]
		self.cook_info = nil
		meta:set_string("infotext", "")
		local sound_handle = minetest.deserialize(minetest.get_meta(self.connected_to.pos):get_string("sound_handle"))
		minetest.sound_stop(sound_handle)
		minetest.swap_node(self.connected_to.pos, {
			name="multidecor:" .. shelves_data.common_name,
			param2=minetest.get_node(self.connected_to.pos).param2
		})
	end

	local show_to

	for pl_name, obj in pairs(open_shelves) do
		if obj == self.object then
			show_to = pl_name
			break
		end
	end

	local i, f = math.modf(elapsed_time)

	if show_to and (f > 0 and f < 0.05) then
		minetest.show_formspec(show_to, multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", self.shelf_data_i, self.connected_to.pos), self.inv)
	end
end

multidecor.shelves.default_drawer_on_step = function(self, dtime)
	local node = minetest.get_node(self.connected_to.pos)
	local data = minetest.registered_nodes[node.name].add_properties and minetest.registered_nodes[node.name].add_properties.shelves_data

	if not data or not self.connected_to.name:match(data.common_name) then
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

	cook_step(self, dtime)
end

multidecor.shelves.default_door_on_step = function(self, dtime)
	local node = minetest.get_node(self.connected_to.pos)
	local data = minetest.registered_nodes[node.name].add_properties and minetest.registered_nodes[node.name].add_properties.shelves_data

	if not data or not self.connected_to.name:match(data.common_name) then
		self.object:remove()
		return
	end

	local shelf_data = minetest.registered_nodes[node.name].add_properties.shelves_data[self.shelf_data_i]
	multidecor.doors.smooth_rotate_step(self, dtime, shelf_data.vel or 30, shelf_data.acc or 0)

	cook_step(self, dtime)
end

multidecor.shelves.default_on_receive_fields = function(player, formname, fields)
	local shelf_i = formname:find("%d+")

	if not shelf_i then
		return
	end

	local name = formname:sub(1, shelf_i-2)
	local def = minetest.registered_nodes[name]

	if not def then
		return
	end

	if not name:sub(1, name:find(":")-1) == "multidecor" then
		return
	end

	local shelf = open_shelves[player:get_player_name()]
	if fields.quit == "true" and shelf then
		open_shelves[player:get_player_name()] = nil

		local self = shelf:get_luaentity()
		local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data
		local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", self.shelf_data_i, self.connected_to.pos)
		local inv = minetest.get_inventory({type="detached", name=inv_name})
		local list = inv:get_list(multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", self.shelf_data_i, self.connected_to.pos))

		self.inv_list = {}
		for _, stack in ipairs(list) do
			table.insert(self.inv_list, {name=stack:get_name(), count=stack:get_count(), wear=stack:get_wear()})
		end

		multidecor.shelves.open_shelf(shelf, -1)
	end
end

multidecor.shelves.default_can_dig = function(pos)
	local name = minetest.get_node(pos).name
	local shelves_data = minetest.registered_nodes[name].add_properties.shelves_data

	local is_all_empty = true
	for i, shelf in ipairs(shelves_data) do
		local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", i, pos)
		local list_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", i, pos)
		local inv = minetest.get_inventory({type="detached", name=inv_name})

		if inv then
			is_all_empty = is_all_empty and inv:is_empty(list_name)
		end
	end

	return is_all_empty
end

minetest.register_on_player_receive_fields(multidecor.shelves.default_on_receive_fields)
