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
		side = "left"/"right"/"up"/"down",			-- present if type == "door"
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
	local sbox = hlpfuncs.rotate_bbox(def.selectionbox, dir)
	obj:set_properties({
		selectionbox = sbox
	})
end

-- Builds formspec string for the shelf with 'shelf_num' number. The inventory can be detached and node.
function multidecor.shelves.build_main_formspec(pos, common_name, data, shelf_num, locked, show_lock_btns, percents)
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
		("formspec_version[4]size[%f,%f]"):format(fs_size.w+1, fs_size.h) ..
		("list[current_player;main;0.5,%f;8,4;]"):format(player_list_y)

	if list_type == "cooker" then
		local cook_list_w = 9+7*padding
		local cook_list_x = cook_list_w/2-0.5

		fs = fs .. ("image[%f,1;1,1;multidecor_cooker_active_bg.png^[lowpart:%f:multidecor_cooker_active_fs.png]"):format(
			cook_list_x, percents)
	end

	fs = fs .. ("list[detached:%s;%s;%f,%f;%f,%f;]"):format(inv_name, list_name, list_x, list_y, list_w, list_h)

	if list_type == "trash" then
		fs = fs .. "image[0.5,0.5;1,1;multidecor_trash_icon.png;]"
	end

	if list_type == "cooker" then
		fs = fs .. "image[0.5,1;1,1;multidecor_cooker_fire_off.png;]"

		local str_perc = tostring(math.round(percents)) .. " %"
		fs = fs .. ("image[0.5,1;1,1;multidecor_cooker_fire_on.png]style_type[label;font=bold;font_size=*2]label[7,1.5;%s]"):format(str_perc)
	end

	if show_lock_btns then
		local lock_img_name = locked and "multidecor_unlock_icon.png" or "multidecor_lock_icon.png"
		local lock_name = locked and "unlock_button" or "lock_button"
		local lock_tooltip = locked and multidecor.S("Unlock Shelf\n(do it accessible by everyone)") or
			multidecor.S("Lock Shelf\n(do it accessible only by you and everyone from the share group)")

		fs = fs .. ("image_button[%f,0.5;1,1;%s;%s;]"):format(fs_size.w-padding, lock_img_name, lock_name) ..
			("tooltip[%s;%s]"):format(lock_name, lock_tooltip)

		if locked then
			fs = fs .. ("image_button[%f,2.0;1,1;multidecor_share_icon.png;share_button;]"):format(fs_size.w-padding) ..
				"tooltip[share_button;" .. multidecor.S("Share access\n(provide access to certain players)") .. "]"
		end
	end

	return fs
end

function multidecor.shelves.build_share_formspec(members)
	local steps_c

	if #members <= 3 then
		steps_c = 0
	else
		steps_c = math.ceil((#members-3)+(#members-2)*0.25)
	end

	steps_c = steps_c / 0.1

	local fs = table.concat({
		"formspec_version[4]size[8,6.5]",
		"image_button[7.25,0.25;0.5,0.5;multidecor_remove_icon.png;share_close_button;]",
		"box[0.25,1;7,4;gray]",
		("scrollbaroptions[min=0;max=%d;smallstep=%d;largestep=%d]"):format(steps_c, steps_c/7, steps_c/7),
		"scrollbar[7.3,1;0.2,4;vertical;share_scrlbar;]",
		"scroll_container[0.25,1;7,4;share_scrlbar;vertical]"
	})

	local cur_h = 0.25
	for _, member in ipairs(members) do
		local player = minetest.get_player_by_name(member)

		local member_img = ""
		if player then
			member_img = player:get_properties().textures[1] .. "^[sheet:8x4:1,1"
		end

		fs = fs .. table.concat({
			("image[0.25,%f;1,1;%s;]"):format(cur_h, member_img),
			("label[2.25,%f;%s]"):format(cur_h+0.25, member),
			("image_button[5.75,%f;0.5,0.5;multidecor_remove_icon.png;share_remove_%s;]"):format(cur_h, member)
		})

		cur_h = cur_h + 1.25
	end

	fs = fs .. table.concat({
		"scroll_container_end[]",
		"field[1,5.5;5,0.5;share_add_field;" .. multidecor.S("Enter name of player to add to the group") .. ";]",
		"button[6,5.5;1,0.5;share_add_button;Add]"
	})

	return fs
end

function multidecor.shelves.build_infotext(lock_info)
	local infotext = ""

	if lock_info then
		infotext = multidecor.S("Owned by ") .. lock_info.owner .. multidecor.S("\nShare group:\n")

		for _, member in ipairs(lock_info.share) do
			infotext = infotext .. "\t" .. member .. "\n"
		end
	end

	return infotext
end

function multidecor.shelves.get_opposite_symdoor(self, shelf)
	if shelf.type ~= "sym_doors" then return end

	local tpos = self.is_flip_x_scale and shelf.pos or shelf.pos2
	tpos = self.connected_to.pos + multidecor.helpers.rotate_to_node_dir(self.connected_to.pos, tpos)

	local tobj = minetest.get_objects_inside_radius(tpos, 0.05)[1]

	if not tobj then return end

	return tobj:get_luaentity()
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
	elseif shelf.type == "sym_doors" then
		local self2 = multidecor.shelves.get_opposite_symdoor(self, shelf)

		if self2 and self.name == self2.name then
			self2.dir = dir_sign
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
		local obj = minetest.add_entity(vector.add(pos, shelf_data.pos), shelf_data.object, minetest.serialize({{name=node.name, pos=pos}, 0, i}))

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
			local obj2 = minetest.add_entity(vector.add(pos, shelf_data.pos2), shelf_data.object, minetest.serialize({{name=node.name, pos=pos}, 0, i}))

			local vis_size = obj2:get_properties().visual_size
			obj2:set_properties({visual_size={x=vis_size.x*-1, y=vis_size.y, z=vis_size.z}})
			obj2:get_luaentity().is_flip_x_scale = true

			multidecor.shelves.rotate_shelf(pos, obj2, false, shelf_data.side, math.pi/2, shelf_data.orig_angle)
		end
	end
end

multidecor.shelves.check_for_formname = function(formname)
	local shelf_i = formname:find("%d+")

	if not shelf_i then
		return false
	end

	local name = formname:sub(1, shelf_i-2)
	local def = minetest.registered_nodes[name]

	if not def then
		return false
	end

	if not name:sub(1, name:find(":")-1) == "multidecor" then
		return false
	end

	return true
end

multidecor.shelves.has_access = function(lock_info, playername)
	local success = false

	if lock_info then
		if lock_info.owner == playername then
			success = true
		else
			for _, member in ipairs(lock_info.share) do
				if member == playername then
					success = true
					break
				end
			end
		end
	else
		success = true
	end

	return success
end

multidecor.shelves.show_lock_buttons = function(lock_info, playername)
	local show = true
	local has_access = multidecor.shelves.has_access(lock_info, playername)

	if has_access and lock_info and lock_info.owner ~= playername then
		show = false
	end

	return show
end

multidecor.shelves.create_detached_inventory = function(pos, shelf_i, shelves_data, obj)
	local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", shelf_i, pos)
	local inv = minetest.get_inventory({type="detached", name=inv_name})

	if not inv then
		local shelf_data = shelves_data[shelf_i]
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
				local playername = player:get_player_name()
				if shelf_data.invlist_type == "trash" then
					inv:remove_item(listname, inv:get_stack(listname, 1))
					minetest.sound_play("multidecor_trash", {to_player=playername})
				elseif shelf_data.invlist_type == "cooker" then
					local name = stack:get_name()

					local output = minetest.get_craft_result({method="cooking", width=1, items=inv:get_list(listname)})
					output.item = {
						name=output.item:get_name(),
						count=output.item:get_count()*stack:get_count(),
						wear=output.item:get_wear()
					}
					local total_time = output.time*stack:get_count()

					minetest.swap_node(pos, {
						name="multidecor:" ..shelves_data.common_name .. "_activated",
						param2=minetest.get_node(pos).param2
					})

					local meta = minetest.get_meta(pos)
					local cook_data = {output, 0, total_time, 0}

					if open_shelves[playername] then
						local self = open_shelves[playername]:get_luaentity()
						self.cook_info = cook_data

						local self2 = multidecor.shelves.get_opposite_symdoor(self, shelf_data)

						if self2 then
							self2.cook_info = cook_data
						end
					else
						meta:set_string("cook_info", minetest.serialize(cook_data))
					end
					meta:set_string("sound_handle", minetest.serialize(minetest.sound_play(
						"multidecor_hum",
						{pos=pos, fade=1.0, max_hear_distance=10, loop=true}
					)))
				end
			end
		})

		local list_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", shelf_i, pos)
		local inv_list = {}

		local cur_inv_list

		if obj then
			local self = obj:get_luaentity()
			cur_inv_list = self.inv_list
		else
			cur_inv_list = minetest.deserialize(minetest.get_meta(pos):get_string("inv_list"))
		end

		for _, stack_t in ipairs(cur_inv_list) do
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


-- Callbacks for shelves having objects attached (doors, drawers)
multidecor.shelves.on_activate = function(self, staticdata)
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)

		-- The code below is for backwards compatibility with versions < 1.2.5
		local ind_incr = 0
		if type(data[1]) == "string" then
			ind_incr = 1
		end
		--end
		self.connected_to = data[1+ind_incr]
		self.dir = data[2+ind_incr]
		self.shelf_data_i = data[3+ind_incr]
		self.inv_list = data[4+ind_incr] or {}
		self.start_v = data[5+ind_incr]
		self.end_v = data[6+ind_incr]
		self.is_flip_x_scale = data[7+ind_incr]
		self.rotate_x = data[8+ind_incr]
		self.cook_info = data[9+ind_incr]
		self.lock_info = data[10+ind_incr]		-- table containing name of the owner locked the shelf and share group members
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

	obj_props.infotext = multidecor.shelves.build_infotext(self.lock_info)

	self.object:set_properties(obj_props)
	self.object:set_armor_groups({immortal=1})

	multidecor.shelves.rotate_shelf_bbox(self.object)

	multidecor.shelves.create_detached_inventory(self.connected_to.pos, self.shelf_data_i, shelves_data, self.object)
end

multidecor.shelves.get_staticdata = function(self)
	return minetest.serialize({
		self.connected_to, self.dir,
		self.shelf_data_i, self.inv_list,
		self.start_v, self.end_v, self.is_flip_x_scale,
		self.rotate_x, self.cook_info, self.lock_info
	})
end

multidecor.shelves.on_rightclick = function(self, clicker)
	local playername = clicker:get_player_name()
	local has = multidecor.shelves.has_access(self.lock_info, playername)

	if not has then return end

	open_shelves[playername] = self.object
	local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data

	local fs = multidecor.shelves.build_main_formspec(
		self.connected_to.pos,
		shelves_data.common_name,
		shelves_data[self.shelf_data_i],
		self.shelf_data_i,
		self.lock_info ~= nil,
		multidecor.shelves.show_lock_buttons(self.lock_info, playername),
		self.cook_info and self.cook_info[4] or 0.0
	)
	minetest.show_formspec(playername,
		multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", self.shelf_data_i, self.connected_to.pos), fs)

	if self.dir == 0 then
		multidecor.shelves.open_shelf(self.object, 1)
	end
end


local function cook_step(pos, shelf_i, lock_info, dtime, obj)
	local cook_info

	if obj then
		cook_info = obj:get_luaentity().cook_info
	else
		cook_info = minetest.deserialize(minetest.get_meta(pos):get_string("cook_info"))
	end

	if not cook_info then
		return
	end

	cook_info[2] = cook_info[2] + dtime
	cook_info[4] = cook_info[2]/cook_info[3]*100

	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", multidecor.S("Cooked to: ") .. tostring(math.round(cook_info[4])) .. " %")

	local name = minetest.get_node(pos).name
	local shelves_data = minetest.registered_nodes[name].add_properties.shelves_data
	local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", shelf_i, pos)
	local inv_list = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", shelf_i, pos)
	local inv = minetest.get_inventory({type="detached", name=inv_name})


	local time_elapsed = cook_info[2] >= cook_info[3]
	local is_empty = inv:is_empty(inv_list)
	if is_empty or time_elapsed then
		if time_elapsed then
			local output = ItemStack(cook_info[1].item.name)
			output:set_count(cook_info[1].item.count)
			output:set_wear(cook_info[1].item.wear)
			inv:set_stack(inv_list, 1, output)
		end

		cook_info[4] = 0

		if obj then
			obj:get_luaentity().cook_info = nil
		else
			minetest.get_meta(pos):set_string("cook_info", "")
		end
		meta:set_string("infotext", "")
		local sound_handle = minetest.deserialize(minetest.get_meta(pos):get_string("sound_handle"))
		minetest.sound_stop(sound_handle)
		minetest.swap_node(pos, {
			name="multidecor:" .. shelves_data.common_name,
			param2=minetest.get_node(pos).param2
		})
	end

	local i, f = math.modf(cook_info[2])
	local fs

	if (f > 0 and f < 0.05) or is_empty then
		fs = multidecor.shelves.build_main_formspec(
			pos,
			shelves_data.common_name,
			shelves_data[shelf_i],
			shelf_i,
			lock_info ~= nil,
			multidecor.shelves.show_lock_buttons(lock_info, playername),
			cook_info[4]
		)
	end

	if fs then
		local fs_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", shelf_i, pos)
		if obj then
			for pl_name, o in pairs(open_shelves) do
				if o == obj then
					minetest.show_formspec(pl_name, fs_name, fs)
				end
			end
		else
			local players = minetest.get_connected_players()

			for _, player in ipairs(players) do
				local open_shelf = vector.from_string(player:get_meta():get_string("open_shelf"))

				if vector.equals(open_shelf, pos) then
					minetest.show_formspec(player:get_player_name(), fs_name, fs)
				end
			end
		end
	end
end

multidecor.shelves.drawer_on_step = function(self, dtime)
	local node = minetest.get_node(self.connected_to.pos)
	local data = minetest.registered_nodes[node.name].add_properties and minetest.registered_nodes[node.name].add_properties.shelves_data

	if not data or not self.connected_to.name:match(data.common_name) then
		self.object:remove()
		return
	end
	if self.dir == 0 then
		return
	end

	local shift = vector.subtract(self.end_v, self.start_v)
	local cur_shift = vector.subtract(self.object:get_pos(), self.start_v)
	local shift_len = vector.length(shift)
	local cur_shift_len = vector.length(cur_shift)
	local target_pos = self.dir == 1 and self.end_v or self.start_v

	if cur_shift_len >= shift_len or cur_shift_len ~= 0 and vector.angle(shift, cur_shift) ~= 0 then
		self.dir = 0
		self.object:set_velocity(vector.zero())
		self.object:set_pos(target_pos)
	end

	cook_step(self.connected_to.pos, self.shelf_data_i, self.lock_info, dtime, self.object)
end

multidecor.shelves.door_on_step = function(self, dtime)
	local node = minetest.get_node(self.connected_to.pos)
	local data = minetest.registered_nodes[node.name].add_properties and minetest.registered_nodes[node.name].add_properties.shelves_data

	if not data or not self.connected_to.name:match(data.common_name) then
		self.object:remove()
		return
	end

	local shelf_data = minetest.registered_nodes[node.name].add_properties.shelves_data[self.shelf_data_i]
	multidecor.doors.smooth_rotate_step(self, dtime, shelf_data.vel or 30, shelf_data.acc or 0)

	cook_step(self.connected_to.pos, self.shelf_data_i, self.lock_info, dtime, self.object)
end

multidecor.shelves.on_deactivate = function(self, removal)
	if not removal then return end

	local shelves_data = minetest.registered_nodes[self.connected_to.name].add_properties.shelves_data

	local inv_name = multidecor.helpers.build_name_from_tmp(
		shelves_data.common_name, "inv",
		self.shelf_data_i, self.connected_to.pos)
	minetest.remove_detached_inventory(inv_name)
end


-- Callbacks for nodes having one shelf (without doors, drawers)
multidecor.shelves.on_construct = function(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("connected_to", minetest.serialize({pos=pos,name=node.name}))
	meta:set_string("inv_list", minetest.serialize({}))
	local shelves_data = minetest.registered_nodes[node.name].add_properties.shelves_data

	multidecor.shelves.create_detached_inventory(pos, 1, shelves_data)
end

multidecor.shelves.on_destruct = function(pos)
	local meta = minetest.get_meta(pos)
	local connected_to = minetest.deserialize(meta:get_string("connected_to"))

	if not connected_to then return end
	local shelves_data = minetest.registered_nodes[connected_to.name].add_properties.shelves_data

	local inv_name = multidecor.helpers.build_name_from_tmp(
		shelves_data.common_name, "inv",1, pos)
	minetest.remove_detached_inventory(inv_name)

end

multidecor.shelves.node_on_rightclick = function(pos, node, clicker)
	local playername = clicker:get_player_name()

	local meta = minetest.get_meta(pos)
	local lock_info = minetest.deserialize(meta:get_string("lock_info"))
	local has = multidecor.shelves.has_access(lock_info, playername)

	if not has then return end

	local connected_to = minetest.deserialize(meta:get_string("connected_to"))

	if not connected_to then
		minetest.set_node(pos, minetest.get_node(pos))
		return
	end
	clicker:get_meta():set_string("open_shelf", vector.to_string(pos))

	local cook_info = minetest.deserialize(meta:get_string("cook_info"))
	local shelves_data = minetest.registered_nodes[connected_to.name].add_properties.shelves_data

	multidecor.shelves.create_detached_inventory(pos, 1, shelves_data)
	local fs = multidecor.shelves.build_main_formspec(
		connected_to.pos,
		shelves_data.common_name,
		shelves_data[1],
		1,
		lock_info ~= nil,
		multidecor.shelves.show_lock_buttons(lock_info, playername),
		cook_info and cook_info[4] or 0.0
	)
	minetest.show_formspec(playername,
		multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", 1, connected_to.pos), fs)
end

multidecor.shelves.on_receive_fields = function(player, formname, fields)
	local correct_formname = multidecor.shelves.check_for_formname(formname)

	if not correct_formname then return end

	local playername = player:get_player_name()
	local connected_to, shelf_i, lock_info, cook_info

	local shelf = open_shelves[playername]

	if shelf then
		local self = shelf:get_luaentity()

		if not self then return end
		connected_to = self.connected_to
		shelf_i = self.shelf_data_i
		lock_info = self.lock_info
		cook_info = self.cook_info
	else
		shelf = vector.from_string(player:get_meta():get_string("open_shelf"))

		if not shelf then return end

		local meta = minetest.get_meta(shelf)
		connected_to = minetest.deserialize(meta:get_string("connected_to"))
		shelf_i = 1
		lock_info = minetest.deserialize(meta:get_string("lock_info"))
		cook_info = minetest.deserialize(meta:get_string("cook_info"))
	end

	local shelves_data = minetest.registered_nodes[connected_to.name].add_properties.shelves_data
	if fields.quit == "true" then
		local inv_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "inv", shelf_i, connected_to.pos)
		local inv = minetest.get_inventory({type="detached", name=inv_name})
		local list = inv:get_list(multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "list", shelf_i, connected_to.pos))

		open_shelves[playername] = nil

		local inv_list = {}
		for _, stack in ipairs(list) do
			table.insert(inv_list, {name=stack:get_name(), count=stack:get_count(), wear=stack:get_wear()})
		end

		if type(shelf) == "userdata" then
			open_shelves[playername] = nil
			local self = shelf:get_luaentity()
			self.inv_list = inv_list

			local self2 = multidecor.shelves.get_opposite_symdoor(self, shelves_data[shelf_i])

			if self2 then
				self2.inv_list = inv_list
			end
			multidecor.shelves.open_shelf(shelf, -1)
		else
			player:get_meta():set_string("open_shelf", "")
			minetest.get_meta(shelf):set_string("inv_list", minetest.serialize(inv_list))
		end

		return true
	end

	local fs_name = multidecor.helpers.build_name_from_tmp(shelves_data.common_name, "fs", shelf_i, connected_to.pos)

	if fields.lock_button or fields.unlock_button then
		local new_fs = multidecor.shelves.build_main_formspec(
			connected_to.pos,
			shelves_data.common_name,
			shelves_data[shelf_i],
			shelf_i,
			fields.lock_button,
			true,
			cook_info and cook_info[4] or 0.0
		)

		if fields.lock_button then
			lock_info = {
				owner = playername,
				share = {}
			}
		else
			lock_info = nil
		end

		local infotext = multidecor.shelves.build_infotext(lock_info)
		if type(shelf) == "userdata" then
			local self = shelf:get_luaentity()
			self.lock_info = lock_info
			shelf:set_properties({infotext=infotext})

			local self2 = multidecor.shelves.get_opposite_symdoor(self, shelves_data[shelf_i])

			if self2 then
				self2.lock_info = lock_info
				self2.object:set_properties({infotext=infotext})
			end
		else
			local meta = minetest.get_meta(shelf)
			meta:set_string("infotext", infotext)
			meta:set_string("lock_info", minetest.serialize(lock_info))
		end

		minetest.show_formspec(playername, fs_name, new_fs)

		return true
	end

	if fields.share_button then
		local new_fs = multidecor.shelves.build_share_formspec(lock_info.share)

		minetest.show_formspec(playername, fs_name, new_fs)

		return true
	end

	if fields.share_close_button then
		local new_fs = multidecor.shelves.build_main_formspec(
			connected_to.pos,
			shelves_data.common_name,
			shelves_data[shelf_i],
			shelf_i,
			lock_info,
			true,
			cook_info and cook_info[4] or 0.0
		)

		minetest.show_formspec(playername, fs_name, new_fs)

		return true
	end

	if fields.share_add_button then
		table.insert(lock_info.share, fields.share_add_field)

		local infotext = multidecor.shelves.build_infotext(lock_info)
		if type(shelf) == "userdata" then
			local self = shelf:get_luaentity()
			shelf:set_properties({infotext=infotext})

			local self2 = multidecor.shelves.get_opposite_symdoor(self, shelves_data[shelf_i])

			if self2 then
				self2.lock_info = lock_info
				self2.object:set_properties({infotext=infotext})
			end
		else
			local meta = minetest.get_meta(shelf)
			meta:set_string("infotext", infotext)
			meta:set_string("lock_info", minetest.serialize(lock_info))
		end

		local new_fs = multidecor.shelves.build_share_formspec(lock_info.share)

		minetest.show_formspec(playername, fs_name, new_fs)

		return true
	end

	for i, member in ipairs(lock_info.share) do
		if fields["share_remove_" .. member] then
			table.remove(lock_info.share, i)

			local infotext = multidecor.shelves.build_infotext(lock_info)
			if type(shelf) == "userdata" then
				local self = shelf:get_luaentity()
				shelf:set_properties({infotext=infotext})

				local self2 = multidecor.shelves.get_opposite_symdoor(self, shelves_data[shelf_i])

				if self2 then
					self2.lock_info = lock_info
					self2.object:set_properties({infotext=infotext})
				end
			else
				local meta = minetest.get_meta(shelf)
				meta:set_string("infotext", infotext)
				meta:set_string("lock_info", minetest.serialize(lock_info))
			end

			local new_fs = multidecor.shelves.build_share_formspec(lock_info.share)

			minetest.show_formspec(playername, fs_name, new_fs)

			return true
		end
	end
end


multidecor.shelves.can_dig = function(pos)
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

minetest.register_on_player_receive_fields(multidecor.shelves.on_receive_fields)
