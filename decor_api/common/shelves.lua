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

local dir_ops = require("decor_api.helpers.dir_ops")
local common = require("decor_api.helpers.common")
local BBox = require("decor_api.helpers.box")
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureManager = furniture_t[3]
local DoorEntity = require("decor_api.furniture.door")[1]

local shelves_api = {}

-- Shelf: manages one shelf of a furniture node — its detached inventory,
-- lock/share info, cooking and one or two DoorEntity doors
--------------------------------------------------------------------------------
local Shelf = {}
Shelf.__index = Shelf

-- Runtime registry: [pos_str] = { [shelf_i] = Shelf }
local shelves_registry = {}

-- Players currently having a shelf formspec open: [playername] = Shelf
local open_shelves = {}

-- Nodes with cooking in progress: [pos_str] = true
local cooking_shelves = {}


function Shelf.get_or_new(node_pos, shelf_i)
	local node = core.get_node(node_pos)
	local def = core.registered_nodes[node.name]

	if not def or not def.add_properties or not def.add_properties.shelves_data then
		return nil
	end

	local shelves_data = def.add_properties.shelves_data
	if not shelves_data[shelf_i] then
		return nil
	end

	local pos_str = core.pos_to_string(node_pos)
	local reg = shelves_registry[pos_str]
	if reg and reg[shelf_i] then
		return reg[shelf_i]
	end

	local self = setmetatable({}, Shelf)
	self.node_pos = vector.new(node_pos)
	self.node_name = node.name
	self.shelves_data = shelves_data
	self.shelf_data = shelves_data[shelf_i]
	self.shelf_i = shelf_i

	local state = core.deserialize(core.get_meta(node_pos):get_string("shelf_" .. shelf_i .. "_state")) or {}
	self.inv_list = state.inv_list or {}
	self.lock_info = state.lock_info
	self.cook_info = state.cook_info
	self.is_open = false

	if not reg then
		shelves_registry[pos_str] = {}
	end
	shelves_registry[pos_str][shelf_i] = self

	return self
end

function Shelf:inv_name()
	return common.build_name_from_tmp(self.shelves_data.common_name, "inv", self.shelf_i, self.node_pos)
end

function Shelf:list_name()
	return common.build_name_from_tmp(self.shelves_data.common_name, "list", self.shelf_i, self.node_pos)
end

function Shelf:formspec_name()
	return common.build_name_from_tmp(self.shelves_data.common_name, "fs", self.shelf_i, self.node_pos)
end

function Shelf:save_state()
	local inv = core.get_inventory({type="detached", name=self:inv_name()})
	if inv then
		local inv_list = {}
		local list = inv:get_list(self:list_name())

		for _, stack in ipairs(list) do
			table.insert(inv_list, {name=stack:get_name(), count=stack:get_count(), wear=stack:get_wear()})
		end

		self.inv_list = inv_list
	end

	local infotext = shelves_api.build_infotext(self.lock_info)
	for _, lua_ent in ipairs(self:get_door_entities()) do
		if lua_ent.dummy_entity and lua_ent.dummy_entity:is_valid() then
			lua_ent.dummy_entity:set_properties({infotext=infotext})
		end
	end

	core.get_meta(self.node_pos):set_string("shelf_" .. self.shelf_i .. "_state", core.serialize({
		inv_list = self.inv_list,
		lock_info = self.lock_info,
		cook_info = self.cook_info
	}))
end

function Shelf:create_inventory()
	local inv_name = self:inv_name()
	if core.get_inventory({type="detached", name=inv_name}) then
		return
	end

	local shelf = self

	local inv = core.create_detached_inventory(inv_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,
		allow_put = function(inv, listname, index, stack, player)
			local c = stack:get_count()

			if shelf.shelf_data.invlist_type == "cooker" then
				local output = core.get_craft_result({method="cooking", width=1, items={stack}})

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
			if shelf.shelf_data.invlist_type == "trash" then
				inv:remove_item(listname, inv:get_stack(listname, 1))
				core.sound_play("multidecor_trash", {to_player=playername})
			elseif shelf.shelf_data.invlist_type == "cooker" then
				shelf:start_cooking(inv, listname, stack, playername)
			end
		end
	})

	local inv_list = {}
	for _, stack_t in ipairs(self.inv_list) do
		local stack = ItemStack(stack_t.name)
		stack:set_count(stack_t.count)
		stack:set_wear(stack_t.wear)

		table.insert(inv_list, stack)
	end

	local list_type = self.shelf_data.invlist_type or "storage"
	local invsize = list_type == "storage" and self.shelf_data.inv_size or {w=1, h=1}
	inv:set_list(self:list_name(), inv_list)
	inv:set_size(self:list_name(), invsize.w*invsize.h)
	inv:set_width(self:list_name(), invsize.w)

	inv:set_size("main", 32)
	inv:set_width("main", 8)
end

function Shelf:start_cooking(inv, listname, stack, playername)
	local output = core.get_craft_result({method="cooking", width=1, items=inv:get_list(listname)})
	output.item = {
		name=output.item:get_name(),
		count=output.item:get_count()*stack:get_count(),
		wear=output.item:get_wear()
	}
	local total_time = output.time*stack:get_count()

	core.swap_node(self.node_pos, {
		name="multidecor:" .. self.shelves_data.common_name .. "_activated",
		param2=core.get_node(self.node_pos).param2
	})

	local meta = core.get_meta(self.node_pos)
	self.cook_info = {output, 0, total_time, 0}
	meta:set_string("sound_handle", core.serialize(core.sound_play(
		"multidecor_hum",
		{pos=self.node_pos, fade=1.0, max_hear_distance=10, loop=true}
	)))

	cooking_shelves[core.pos_to_string(self.node_pos)] = true
end

function Shelf:stop_cooking()
	local meta = core.get_meta(self.node_pos)
	self.cook_info = nil
	meta:set_string("cook_info", "")
	meta:set_string("infotext", "")

	local sound_handle = core.deserialize(meta:get_string("sound_handle"))
	core.sound_stop(sound_handle)

	core.swap_node(self.node_pos, {
		name="multidecor:" .. self.shelves_data.common_name,
		param2=core.get_node(self.node_pos).param2
	})

	cooking_shelves[core.pos_to_string(self.node_pos)] = nil
end

function Shelf:cook_step(dtime)
	local inv = core.get_inventory({type="detached", name=self:inv_name()})
	if not inv then
		cooking_shelves[core.pos_to_string(self.node_pos)] = nil
		return
	end

	local cook_info = self.cook_info
	if not cook_info then
		return
	end

	cook_info[2] = cook_info[2] + dtime
	cook_info[4] = cook_info[2]/cook_info[3]*100

	local meta = core.get_meta(self.node_pos)
	meta:set_string("infotext", multidecor.S("Cooked to: ") .. tostring(math.round(cook_info[4])) .. " %")

	local list_name = self:list_name()
	local time_elapsed = cook_info[2] >= cook_info[3]
	local is_empty = inv:is_empty(list_name)

	if is_empty or time_elapsed then
		if time_elapsed then
			local output = ItemStack(cook_info[1].item.name)
			output:set_count(cook_info[1].item.count)
			output:set_wear(cook_info[1].item.wear)
			inv:set_stack(list_name, 1, output)
		end

		cook_info[4] = 0
		self:stop_cooking()
	end

	local i, f = math.modf(cook_info[2])
	local playername, fs

	if (f > 0 and f < 0.05) or is_empty then
		for pl_name, open_shelf in pairs(open_shelves) do
			if open_shelf == self then
				playername = pl_name
				fs = shelves_api.build_main_formspec(
					self.node_pos,
					self.shelves_data.common_name,
					self.shelf_data,
					self.shelf_i,
					self.lock_info ~= nil,
					shelves_api.show_lock_buttons(self.lock_info, pl_name),
					cook_info[4]
				)
				break
			end
		end
	end

	if fs and playername then
		core.show_formspec(playername, self:formspec_name(), fs)
	end
end

local function get_dominant_axis(dir)
	if dir.x ~= 0 then return "x"
	elseif dir.y ~= 0 then return "y"
	else return "z" end
end

-- Builds the DoorEntity spawn data for one shelf door/drawer.
-- 'rel_pos' is the door position relative to the node, 'mirrored' flips the
-- dummy model horizontally (the second door of "sym_doors")
function Shelf:build_door_data(rel_pos, mirrored)
	local sd = self.shelf_data
	local obj_def = sd.def or core.registered_entities[sd.object]
	if not obj_def then
		return nil
	end

	local size = vector.new(obj_def.visual_size or {x=5, y=5, z=5})
	if sd.visual_size_adds then
		size = vector.add(size, sd.visual_size_adds)
	end

	local model_params = {
		size = size,
		mesh = obj_def.mesh,
		textures = obj_def.textures,
		box = BBox.from_box(obj_def.selectionbox or obj_def.collisionbox or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}),
		pos = vector.new(rel_pos),
		rot = vector.new(sd.orig_angle or {x=0, y=0, z=0}),
		mirrored = mirrored,
		bone = "Door",
		use_texture_alpha = obj_def.use_texture_alpha,
		backface_culling = obj_def.backface_culling
	}

	if sd.base_texture then
		model_params.textures = table.copy(obj_def.textures)
		model_params.textures[1] = sd.base_texture
	end

	local dir = dir_ops.get_dir(self.node_pos)
	local anim_params

	if sd.type == "drawer" then
		local move_dist = 2/3*(sd.length or 0.5)

		if sd.orig_angle then
			dir = vector.rotate(dir, sd.orig_angle)
		end
		local axis = get_dominant_axis(dir)
		local sign = dir[axis] > 0 and 1 or -1

		anim_params = {
			rotate = false,
			target_axis = axis,
			target_offset = sign*move_dist,
			velocity = 0.6
		}
	else
		local move_dist
		if sd.type == "door" then
			move_dist = (sd.side == "left" or sd.side == "down") and -math.pi/2 or math.pi/2
			if mirrored then
				move_dist = -move_dist
			end
		else
			move_dist = (mirrored and 1 or -1)*math.pi/2
		end

		local axis = (sd.side == "up" or sd.side == "down") and "x" or "y"

		anim_params = {
			rotate = true,
			target_axis = axis,
			target_offset = move_dist,
			velocity = math.rad(sd.vel or 30)
		}
	end

	return {
		model_params = model_params,
		anim_params = anim_params,
		sound_defs = sd.sounds,
		shelf_i = self.shelf_i,
		node_pattern = self.shelves_data.common_name,
		cur_mode = "closed",
		convert_on_end = false,
		persistent = true
	}
end

-- Spawns the DoorEntity doors of this shelf (one door, two sym doors or a drawer)
function Shelf:spawn_doors()
	local sd = self.shelf_data

	if sd.type ~= "door" and sd.type ~= "sym_doors" and sd.type ~= "drawer" then
		return
	end

	local data = self:build_door_data(sd.pos, false)
	if not data then
		return
	end

	local dir = dir_ops.get_dir(self.node_pos)
	local model_params = data.model_params

	local spawn_pos = self.node_pos + dir_ops.rotate_to_dir(vector.new(model_params.pos), dir)
	local spawn_rot = vector.new(model_params.rot)
	spawn_rot.y = spawn_rot.y + dir_ops.get_rot_y(dir)

	FurnitureManager.add(DoorEntity.name, self.node_pos, self.node_name, spawn_pos, spawn_rot, data)

	if sd.type == "sym_doors" then
		local data2 = self:build_door_data(sd.pos2, true)
		if data2 then
			local spawn_pos2 = self.node_pos + dir_ops.rotate_to_dir(vector.new(data2.model_params.pos), dir)
			local spawn_rot2 = vector.new(data2.model_params.rot)
			spawn_rot2.y = spawn_rot2.y + dir_ops.get_rot_y(dir)

			FurnitureManager.add(DoorEntity.name, self.node_pos, self.node_name, spawn_pos2, spawn_rot2, data2)
		end
	end
end

-- Returns the DoorEntity luaentities of this shelf
function Shelf:get_door_entities()
	local result = {}

	for _, desc in ipairs(FurnitureManager.get(self.node_pos)) do
		if desc.entity_name == DoorEntity.name and desc:exists() then
			local lua_ent = desc.object:get_luaentity()
			if lua_ent and lua_ent.shelf_i == self.shelf_i then
				table.insert(result, lua_ent)
			end
		end
	end

	return result
end

-- Animates all doors of the shelf to the open or closed state
function Shelf:set_doors_open(is_open)
	for _, lua_ent in ipairs(self:get_door_entities()) do
		lua_ent:set_action(is_open and "open" or "close")
	end
	self.is_open = is_open
end

function Shelf:open_for(clicker)
	local playername = clicker:get_player_name()

	if not shelves_api.has_access(self.lock_info, playername) then
		return
	end

	open_shelves[playername] = self
	self:create_inventory()

	local fs = shelves_api.build_main_formspec(
		self.node_pos,
		self.shelves_data.common_name,
		self.shelf_data,
		self.shelf_i,
		self.lock_info ~= nil,
		shelves_api.show_lock_buttons(self.lock_info, playername),
		self.cook_info and self.cook_info[4] or 0.0
	)
	core.show_formspec(playername, self:formspec_name(), fs)

	if not self.is_open then
		self:set_doors_open(true)
	end
end

function Shelf:close_and_save()
	if self.is_open then
		self:set_doors_open(false)
	end
	self:save_state()
end

function Shelf:remove_inventory()
	core.remove_detached_inventory(self:inv_name())
end

-- Removes the Shelf from the registry together with the whole node entry
-- when it is the last shelf of the node
function Shelf:unregister()
	local pos_str = core.pos_to_string(self.node_pos)
	local reg = shelves_registry[pos_str]

	if not reg then return end
	reg[self.shelf_i] = nil

	if not next(reg) then
		shelves_registry[pos_str] = nil
		cooking_shelves[pos_str] = nil
	end
end

-- Static helpers (kept on the API table, they do not need a Shelf instance)
--------------------------------------------------------------------------

function shelves_api.has_access(lock_info, playername)
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

function shelves_api.show_lock_buttons(lock_info, playername)
	local show = true
	local has_access = shelves_api.has_access(lock_info, playername)

	if has_access and lock_info and lock_info.owner ~= playername then
		show = false
	end

	return show
end

-- Node callbacks
--------------------------------------------------------------------------

-- Adds shelves for the node at 'pos' (wired as on_construct by register_garniture)
function shelves_api.set_shelves(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]

	if not def or not def.add_properties or not def.add_properties.shelves_data then
		return
	end

	local shelves_data = def.add_properties.shelves_data

	for i in ipairs(shelves_data) do
		local shelf = Shelf.get_or_new(pos, i)
		if shelf then
			shelf:create_inventory()
			shelf:spawn_doors()
		end
	end
end

function shelves_api.can_dig(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if not def or not def.add_properties or not def.add_properties.shelves_data then
		return true
	end

	local shelves_data = def.add_properties.shelves_data

	local is_all_empty = true
	for i, _ in ipairs(shelves_data) do
		local shelf = Shelf.get_or_new(pos, i)
		if shelf then
			local inv = core.get_inventory({type="detached", name=shelf:inv_name()})
			if inv then
				is_all_empty = is_all_empty and inv:is_empty(shelf:list_name())
			end
		end
	end

	return is_all_empty
end

-- Callbacks for shelves without doors/drawers (plain node inventory)
function shelves_api.on_construct(pos)
	local shelf = Shelf.get_or_new(pos, 1)
	if shelf then
		shelf:save_state()
		shelf:create_inventory()
	end
end

function shelves_api.on_destruct(pos)
	local pos_str = core.pos_to_string(pos)
	local reg = shelves_registry[pos_str]

	if reg then
		for _, shelf in pairs(reg) do
			shelf:save_state()
			shelf:remove_inventory()
		end
		shelves_registry[pos_str] = nil
		cooking_shelves[pos_str] = nil
	end

	FurnitureManager.remove(pos)
end

function shelves_api.node_on_rightclick(pos, node, clicker)
	local shelf = Shelf.get_or_new(pos, 1)
	if shelf then
		shelf:open_for(clicker)
	end
end

-- DoorEntity integration
--------------------------------------------------------------------------

-- Called by DoorEntity:on_rightclick for shelf doors
function shelves_api.handle_door_click(door_ent, clicker)
	local shelf = Shelf.get_or_new(door_ent.attached_to.pos, door_ent.shelf_i)
	if shelf then
		shelf:open_for(clicker)
	end
end

-- Called by DoorEntity:on_deactivate for shelf doors
function shelves_api.on_door_deactivated(door_ent, removal)
	local shelf = Shelf.get_or_new(door_ent.attached_to.pos, door_ent.shelf_i)
	if not shelf then return end

	if removal then
		shelf.is_open = false
		shelf:save_state()
		shelf:remove_inventory()
		shelf:unregister()
	end
end

-- Formspecs (ported as-is from the legacy implementation)
--------------------------------------------------------------------------

function shelves_api.build_main_formspec(pos, common_name, data, shelf_num, locked, show_lock_btns, percents)
	local inv_name = common.build_name_from_tmp(common_name, "inv", shelf_num, pos)
	local list_name = common.build_name_from_tmp(common_name, "list", shelf_num, pos)
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

function shelves_api.build_share_formspec(members)
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
		local player = core.get_player_by_name(member)

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

function shelves_api.build_infotext(lock_info)
	local infotext = ""

	if lock_info then
		infotext = multidecor.S("Owned by ") .. lock_info.owner .. multidecor.S("\nShare group:\n")

		for _, member in ipairs(lock_info.share) do
			infotext = infotext .. "\t" .. member .. "\n"
		end
	end

	return infotext
end

-- Formspec fields handling
--------------------------------------------------------------------------

function shelves_api.on_receive_fields(player, formname, fields)
	local shelf = open_shelves[player:get_player_name()]

	if not shelf then
		return
	end

	local playername = player:get_player_name()
	local fs_name = shelf:formspec_name()

	if fields.quit == "true" then
		open_shelves[playername] = nil
		shelf:close_and_save()
		return true
	end

	if fields.lock_button or fields.unlock_button then
		if fields.lock_button then
			shelf.lock_info = {
				owner = playername,
				share = {}
			}
		else
			shelf.lock_info = nil
		end

		local new_fs = shelves_api.build_main_formspec(
			shelf.node_pos,
			shelf.shelves_data.common_name,
			shelf.shelf_data,
			shelf.shelf_i,
			fields.lock_button,
			true,
			shelf.cook_info and shelf.cook_info[4] or 0.0
		)

		core.show_formspec(playername, fs_name, new_fs)
		return true
	end

	if fields.share_button then
		local new_fs = shelves_api.build_share_formspec(shelf.lock_info.share)
		core.show_formspec(playername, fs_name, new_fs)
		return true
	end

	if fields.share_close_button then
		local new_fs = shelves_api.build_main_formspec(
			shelf.node_pos,
			shelf.shelves_data.common_name,
			shelf.shelf_data,
			shelf.shelf_i,
			shelf.lock_info ~= nil,
			true,
			shelf.cook_info and shelf.cook_info[4] or 0.0
		)

		core.show_formspec(playername, fs_name, new_fs)
		return true
	end

	if fields.share_add_button then
		table.insert(shelf.lock_info.share, fields.share_add_field)

		local new_fs = shelves_api.build_share_formspec(shelf.lock_info.share)
		core.show_formspec(playername, fs_name, new_fs)
		return true
	end

	if shelf.lock_info then
		for i, member in ipairs(shelf.lock_info.share) do
			if fields["share_remove_" .. member] then
				table.remove(shelf.lock_info.share, i)

				local new_fs = shelves_api.build_share_formspec(shelf.lock_info.share)
				core.show_formspec(playername, fs_name, new_fs)
				return true
			end
		end
	end
end

core.register_on_player_receive_fields(shelves_api.on_receive_fields)

-- Cooking global step
--------------------------------------------------------------------------

core.register_globalstep(function(dtime)
	for pos_str in pairs(cooking_shelves) do
		local reg = shelves_registry[pos_str]
		if not reg then
			cooking_shelves[pos_str] = nil
		else
			for _, shelf in pairs(reg) do
				if shelf.cook_info then
					shelf:cook_step(dtime)
				end
			end
		end
	end
end)

return { Shelf, shelves_api }
