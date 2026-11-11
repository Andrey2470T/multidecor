--[[
	'shelves_data' is the array part of add_properties.shelves_data: its
	'common_name' field names the whole node family, each array element
	describes one shelf of the node:
	{
		type = "door"/"sym_doors"/"drawer",		-- omit for a plain shelf without moving parts
		def = {									-- the door/drawer model definition:
			mesh = <filename>,					-- mesh, textures, visual_size (optional),
			textures = {...},					-- selectionbox, use_texture_alpha (optional),
			visual_size = {...},				-- backface_culling (optional)
			selectionbox = {...}
		},
		pos = <position>,						-- door/drawer attach pos (node-relative)
		pos2 = <position>,						-- the second door, present if type == "sym_doors"
		side = "left"/"right"/"up"/"down",		-- hinge side, present if type == "door"
		invlist_type = "storage"/"trash"/"cooker",	-- default is "storage"
		inv_size = {w=<number>, h=<number>},	-- storage slot grid
		length = <number>,						-- max distance the drawer is pushed out
		orig_angle = <rotation>,				-- initial model rotation (node-relative)
		vel = <number>,							-- door speed in degrees/sec, default 30
		visual_size_adds = <addendums vector>,
		base_texture = <texture name>,			-- replaces the first texture of the model
		sounds = {
			open = <sound name>,
			close = <sound name>
		}
	}
]]

local dir_ops = require("decor_api.helpers.dir_ops")
local common = require("decor_api.helpers.common")
local BBox = require("decor_api.helpers.box")
local furniture_t = require("decor_api.common.furniture_entity")
local FurnitureManager = furniture_t[3]
local DoorEntity = require("decor_api.furniture.door")[1]
local ShelfFormspec = require("decor_api.common.shelves_formspec")

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
	local def = common.ndef(node_pos)
	local shelves_data = def and def.add_properties and def.add_properties.shelves_data

	if not shelves_data or not shelves_data[shelf_i] then
		return nil
	end

	local pos_str = core.pos_to_string(node_pos)
	local reg = shelves_registry[pos_str]
	if reg and reg[shelf_i] then
		return reg[shelf_i]
	end

	local self = setmetatable({}, Shelf)
	self.node_pos = vector.new(node_pos)
	self.node_name = def.name
	self.common_name = shelves_data.common_name
	self.shelves_data = shelves_data
	self.shelf_data = shelves_data[shelf_i]
	self.shelf_i = shelf_i
	self.inv_list = {}
	self.lock_info = nil
	self.cook_info = nil
	self.is_open = false

	shelves_registry[pos_str] = shelves_registry[pos_str] or {}
	shelves_registry[pos_str][shelf_i] = self

	return self
end

-- Inventory, list and formspec names of this shelf
function Shelf:inv_name()
	return common.build_name_from_tmp(self.common_name, "inv", self.shelf_i, self.node_pos)
end

function Shelf:list_name()
	return common.build_name_from_tmp(self.common_name, "list", self.shelf_i, self.node_pos)
end

function Shelf:formspec_name()
	return common.build_name_from_tmp(self.common_name, "fs", self.shelf_i, self.node_pos)
end

-- Shows the main inventory formspec of this shelf to 'playername'
function Shelf:show_formspec(playername)
	core.show_formspec(playername, self:formspec_name(), ShelfFormspec.new(self, playername):build())
end

-- Shows the share group management formspec of this shelf to 'playername'
function Shelf:show_share_formspec(playername)
	core.show_formspec(playername, self:formspec_name(), ShelfFormspec.new(self, playername):build_share())
end

-- Stores the inventory contents into the runtime state and refreshes the
-- lock infotext shown by the door entities
function Shelf:save_state()
	local inv = core.get_inventory({type="detached", name=self:inv_name()})
	if inv then
		local inv_list = {}
		for _, stack in ipairs(inv:get_list(self:list_name())) do
			table.insert(inv_list, stack:to_table())
		end

		self.inv_list = inv_list
	end

	local infotext = ShelfFormspec.build_infotext(self.lock_info)
	for _, lua_ent in ipairs(self:get_door_entities()) do
		if lua_ent.dummy_entity and lua_ent.dummy_entity:is_valid() then
			lua_ent.dummy_entity:set_properties({infotext=infotext})
		end
	end
end

function Shelf:create_inventory()
	local inv_name = self:inv_name()
	if core.get_inventory({type="detached", name=inv_name}) then
		return
	end

	local shelf = self

	local inv = core.create_detached_inventory(inv_name, {
		allow_put = function(inv, listname, index, stack, player)
			local count = stack:get_count()

			if shelf.shelf_data.invlist_type == "cooker" then
				-- only cookable stacks go into the cooker slot
				local output = core.get_craft_result({method="cooking", width=1, items={stack}})
				if not output or output.time == 0 then
					count = 0
				end
			end

			return count
		end,
		on_put = function(inv, listname, index, stack, player)
			if shelf.shelf_data.invlist_type == "trash" then
				inv:remove_item(listname, inv:get_stack(listname, 1))
				core.sound_play("multidecor_trash", {to_player=player:get_player_name()})
			elseif shelf.shelf_data.invlist_type == "cooker" then
				shelf:start_cooking(inv, listname, stack)
			end
		end
	})

	-- The list contents kept in the runtime state, if any
	local inv_list = {}
	for _, stack_t in ipairs(self.inv_list) do
		table.insert(inv_list, ItemStack(stack_t))
	end

	-- The non-storage list types work with a single slot
	local invsize = self.shelf_data.invlist_type == "storage" and self.shelf_data.inv_size or {w=1, h=1}
	inv:set_list(self:list_name(), inv_list)
	inv:set_size(self:list_name(), invsize.w*invsize.h)
	inv:set_width(self:list_name(), invsize.w)
end

-- Cooking (invlist_type == "cooker")
--------------------------------------------------------------------------

-- Starts cooking the just put stack: swaps the node to the "_activated"
-- variant and starts the hum sound
function Shelf:start_cooking(inv, listname, stack)
	local output = core.get_craft_result({method="cooking", width=1, items=inv:get_list(listname)})
	output.item = {
		name = output.item:get_name(),
		count = output.item:get_count()*stack:get_count(),
		wear = output.item:get_wear()
	}

	core.swap_node(self.node_pos, {
		name = "multidecor:" .. self.common_name .. "_activated",
		param2 = core.get_node(self.node_pos).param2
	})

	self.cook_info = {
		output = output,
		elapsed = 0,
		total = output.time*stack:get_count(),
		percent = 0,
		sound_handle = core.sound_play("multidecor_hum",
			{pos=self.node_pos, fade=1.0, max_hear_distance=10, loop=true})
	}

	cooking_shelves[core.pos_to_string(self.node_pos)] = true
end

function Shelf:stop_cooking()
	core.sound_stop(self.cook_info.sound_handle)
	self.cook_info = nil

	core.get_meta(self.node_pos):set_string("infotext", "")
	core.swap_node(self.node_pos, {
		name = "multidecor:" .. self.common_name,
		param2 = core.get_node(self.node_pos).param2
	})

	cooking_shelves[core.pos_to_string(self.node_pos)] = nil
end

-- Advances the running cooking: updates the progress infotext, finishes
-- when the time is over or the cooked stack was taken away
function Shelf:cook_step(dtime)
	local inv = core.get_inventory({type="detached", name=self:inv_name()})
	if not inv then
		cooking_shelves[core.pos_to_string(self.node_pos)] = nil
		return
	end

	local cook = self.cook_info
	if not cook then
		return
	end

	cook.elapsed = cook.elapsed + dtime
	cook.percent = math.min(cook.elapsed/cook.total*100, 100)

	core.get_meta(self.node_pos):set_string("infotext",
		common.translator("Cooked to: ") .. tostring(math.round(cook.percent)) .. " %")

	local is_empty = inv:is_empty(self:list_name())
	local is_done = cook.elapsed >= cook.total

	if is_empty or is_done then
		if is_done then
			local item = cook.output.item
			local output = ItemStack(item.name)
			output:set_count(item.count)
			output:set_wear(item.wear)
			inv:set_stack(self:list_name(), 1, output)
		end

		self:stop_cooking()
	end

	-- Refresh the formspec of the player having this shelf open
	-- about once per second
	local whole_secs = math.floor(cook.elapsed)
	if is_empty or is_done or whole_secs ~= math.floor(cook.elapsed - dtime) then
		for pl_name, open_shelf in pairs(open_shelves) do
			if open_shelf == self then
				self:show_formspec(pl_name)
				break
			end
		end
	end
end

-- DoorEntity doors
--------------------------------------------------------------------------

-- Builds the DoorEntity spawn data for one shelf door/drawer at the
-- node-relative 'rel_pos'. 'mirrored' flips the dummy model horizontally
-- (the second door of "sym_doors")
function Shelf:build_door_data(rel_pos, mirrored)
	local sd = self.shelf_data
	local obj_def = sd.def
	if not obj_def then
		return nil
	end

	local size = vector.new(obj_def.visual_size or {x=5, y=5, z=5})
	if sd.visual_size_adds then
		size = vector.add(size, sd.visual_size_adds)
	end

	local textures = obj_def.textures
	if sd.base_texture then
		textures = table.copy(obj_def.textures)
		textures[1] = sd.base_texture
	end

	-- Drawers with an initial rotation (corner cabinets) pull out along the
	-- rotated direction: against the (rotated) dir, to the player-facing side
	local anim_params
	if sd.type == "drawer" then
		local dir = dir_ops.get_dir(self.node_pos)
		if sd.orig_angle then
			dir = vector.rotate(dir, sd.orig_angle)
		end

		local move_dist = 2/3*(sd.length or 0.5)
		local axis = dir_ops.get_dominant_axis(dir)

		anim_params = {
			rotate = false,
			target_axis = axis,
			-- against the (rotated) dir: to the player-facing side
			target_offset = (dir[axis] < 0 and 1 or -1)*move_dist,
			velocity = 0.6
		}
	else
		local move_dist
		if sd.type == "door" then
			move_dist = (sd.side == "left" or sd.side == "down") and -math.pi/2 or math.pi/2
			if mirrored then
				move_dist = -move_dist
			end
		else -- "sym_doors": the sign comes from the door side itself
			move_dist = (mirrored and 1 or -1)*math.pi/2
		end

		anim_params = {
			rotate = true,
			target_axis = (sd.side == "up" or sd.side == "down") and "x" or "y",
			target_offset = move_dist,
			velocity = math.rad(sd.vel or 30)
		}
	end

	local box = BBox.from_box(obj_def.selectionbox or obj_def.collisionbox or
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5})
	-- the dummy model looks against the node dir, so the authored box
	-- reaches it mirrored
	box:mirror_h()

	-- the door/drawer models show their front side to the player: the half
	-- turn against the engine dir comes on top of any authored initial
	-- rotation
	local rot = vector.new(sd.orig_angle or {x=0, y=0, z=0})
	rot.y = rot.y + math.pi

	return {
		model_params = {
			size = size,
			mesh = obj_def.mesh,
			textures = textures,
			box = box,
			pos = vector.new(rel_pos),
			rot = rot,
			mirrored = mirrored,
			use_texture_alpha = obj_def.use_texture_alpha,
			backface_culling = obj_def.backface_culling
		},
		anim_params = anim_params,
		sound_defs = sd.sounds,
		shelf_i = self.shelf_i,
		node_pattern = self.common_name,
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

	-- The plain engine dir of the shelf node: the model data is authored
	-- in the engine frame already
	local dir = dir_ops.get_dir(self.node_pos)

	local door_positions = sd.type == "sym_doors" and {sd.pos, sd.pos2} or {sd.pos}
	for i, rel_pos in ipairs(door_positions) do
		local data = self:build_door_data(rel_pos, i == 2)
		if data then
			local spawn_pos, spawn_rot = DoorEntity.get_base_transform(self.node_pos, data.model_params, dir)

			FurnitureManager.add(DoorEntity.name, self.node_pos, self.node_name, spawn_pos, spawn_rot, data)
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

-- Opening and closing
--------------------------------------------------------------------------

-- Returns whether 'playername' may open this shelf: no lock, the owner
-- or a member of the share group
function Shelf:has_access(playername)
	local lock_info = self.lock_info
	if not lock_info then
		return true
	end
	if lock_info.owner == playername then
		return true
	end

	return table.indexof(lock_info.share, playername) ~= -1
end

function Shelf:open_for(clicker)
	local playername = clicker:get_player_name()

	if not self:has_access(playername) then
		return
	end

	open_shelves[playername] = self
	self:create_inventory()

	self:show_formspec(playername)

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

-- Drops the runtime registry entry of the node
local function clear_node_shelves(pos)
	local pos_str = core.pos_to_string(pos)
	shelves_registry[pos_str] = nil
	cooking_shelves[pos_str] = nil
end

-- Removes the Shelf from the registry together with the whole node entry
-- when it is the last shelf of the node
function Shelf:unregister()
	local reg = shelves_registry[core.pos_to_string(self.node_pos)]
	if not reg then
		return
	end

	reg[self.shelf_i] = nil
	if not next(reg) then
		clear_node_shelves(self.node_pos)
	end
end

-- Iterates all shelves of the node at 'pos' calling 'fn' for each
-- (nodes without shelves_data are skipped)
local function for_each_shelf(pos, fn)
	local def = common.ndef(pos)
	local shelves_data = def and def.add_properties and def.add_properties.shelves_data

	for i in ipairs(shelves_data or {}) do
		local shelf = Shelf.get_or_new(pos, i)
		if shelf then
			fn(shelf)
		end
	end
end

-- Node callbacks
--------------------------------------------------------------------------

-- Adds shelves for the node at 'pos' (wired as on_construct by register_garniture)
function shelves_api.set_shelves(pos)
	for_each_shelf(pos, function(shelf)
		shelf:create_inventory()
		shelf:spawn_doors()
	end)
end

function shelves_api.can_dig(pos)
	local is_all_empty = true

	for_each_shelf(pos, function(shelf)
		local inv = core.get_inventory({type="detached", name=shelf:inv_name()})
		if inv and not inv:is_empty(shelf:list_name()) then
			is_all_empty = false
		end
	end)

	return is_all_empty
end

-- Callbacks for shelves without doors/drawers (plain node inventory)
function shelves_api.on_construct(pos)
	local shelf = Shelf.get_or_new(pos, 1)
	if shelf then
		shelf:create_inventory()
	end
end

function shelves_api.on_destruct(pos)
	local reg = shelves_registry[core.pos_to_string(pos)]

	if reg then
		for _, shelf in pairs(reg) do
			shelf:save_state()
			shelf:remove_inventory()
		end
	end

	clear_node_shelves(pos)
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
	if not removal then
		return
	end

	local shelf = Shelf.get_or_new(door_ent.attached_to.pos, door_ent.shelf_i)
	if shelf then
		shelf.is_open = false
		shelf:save_state()
		shelf:remove_inventory()
		shelf:unregister()
	end
end

-- Formspec fields handling
--------------------------------------------------------------------------

function shelves_api.on_receive_fields(player, formname, fields)
	local playername = player:get_player_name()
	local shelf = open_shelves[playername]

	if not shelf or formname ~= shelf:formspec_name() then
		return
	end

	if fields.quit == "true" then
		open_shelves[playername] = nil
		shelf:close_and_save()
		return true

	elseif fields.lock_button or fields.unlock_button then
		if fields.lock_button then
			shelf.lock_info = {owner = playername, share = {}}
		else
			shelf.lock_info = nil
		end
		shelf:show_formspec(playername)
		return true

	elseif fields.share_button then
		shelf:show_share_formspec(playername)
		return true

	elseif fields.share_close_button then
		shelf:show_formspec(playername)
		return true

	elseif fields.share_add_button then
		local new_member = fields.share_add_field
		if new_member ~= "" and table.indexof(shelf.lock_info.share, new_member) == -1 then
			table.insert(shelf.lock_info.share, new_member)
		end
		shelf:show_share_formspec(playername)
		return true

	elseif shelf.lock_info then
		for _, member in ipairs(shelf.lock_info.share) do
			if fields["share_remove_" .. member] then
				table.remove(shelf.lock_info.share, table.indexof(shelf.lock_info.share, member))
				shelf:show_share_formspec(playername)
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
