-- ShelfFormspec binds the generic Formspec builder (common/formspec.lua)
-- to one shelf and one viewing player and composes the forms of that shelf:
-- the main inventory form and the share group form, reading every input
-- from the shelf itself.

local common = require("decor_api.helpers.common")
local Formspec = require("decor_api.common.formspec")

-- ShelfFormspec
------------------------------------------------------

local ShelfFormspec = Formspec:extend()

function ShelfFormspec.new(shelf, playername)
	local self = setmetatable({}, ShelfFormspec)
	self.shelf = shelf
	self.playername = playername
	return self
end

-- The lock/share buttons are shown to the owner only
-- (and when there is no lock at all)
function ShelfFormspec:show_lock_buttons()
	local lock_info = self.shelf.lock_info
	return not lock_info or lock_info.owner == self.playername
end

-- The main inventory form of the shelf: the list grid (with the cooker
-- progress or the trash icon), the player inventory and the lock/share buttons
function ShelfFormspec:build()
	local shelf = self.shelf
	local data = shelf.shelf_data
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

	local percents = shelf.cook_info and shelf.cook_info.percent or 0.0

	local fs = Formspec.new()
		:size(fs_size.w+1, fs_size.h)
		:list("current_player", "main", 0.5, player_list_y, 8, 4)

	if list_type == "cooker" then
		local cook_list_w = 9+7*padding
		local cook_list_x = cook_list_w/2-0.5

		fs:image(cook_list_x, 1, 1, 1,
			("multidecor_cooker_active_bg.png^[lowpart:%f:multidecor_cooker_active_fs.png"):format(percents))
	end

	fs:list("detached:" .. shelf:inv_name(), shelf:list_name(), list_x, list_y, list_w, list_h)

	if list_type == "trash" then
		fs:image(0.5, 0.5, 1, 1, "multidecor_trash_icon.png")
	end

	if list_type == "cooker" then
		fs:image(0.5, 1, 1, 1, "multidecor_cooker_fire_off.png")
		fs:image(0.5, 1, 1, 1, "multidecor_cooker_fire_on.png")
		fs:style_type("label", {font = "bold", font_size = "*2"})
		fs:label(7, 1.5, tostring(math.round(percents)) .. " %")
	end

	if self:show_lock_buttons() then
		local locked = shelf.lock_info ~= nil
		local lock_name = locked and "unlock_button" or "lock_button"
		local lock_img = locked and "multidecor_unlock_icon.png" or "multidecor_lock_icon.png"
		local lock_tooltip = locked and
			common.translator("Unlock Shelf\n(do it accessible by everyone)") or
			common.translator("Lock Shelf\n(do it accessible only by you and everyone from the share group)")

		fs:image_button(fs_size.w-padding, 0.5, 1, 1, lock_img, lock_name)
			:tooltip(lock_name, lock_tooltip)

		if locked then
			fs:image_button(fs_size.w-padding, 2.0, 1, 1, "multidecor_share_icon.png", "share_button")
				:tooltip("share_button",
					common.translator("Share access\n(provide access to certain players)"))
		end
	end

	return fs:to_string()
end

-- The share group management form: the member list with the remove buttons,
-- the add field and the scrollbar tuned to the member count
function ShelfFormspec:build_share()
	local lock_info = self.shelf.lock_info
	local members = lock_info and lock_info.share or {}

	local steps_c
	if #members <= 3 then
		steps_c = 0
	else
		steps_c = math.ceil((#members-3)+(#members-2)*0.25)
	end

	steps_c = steps_c / 0.1

	local fs = Formspec.new()
		:size(8, 6.5)
		:image_button(7.25, 0.25, 0.5, 0.5, "multidecor_remove_icon.png", "share_close_button")
		:box(0.25, 1, 7, 4, "gray")
		:scrollbaroptions({min = 0, max = steps_c, smallstep = steps_c/7, largestep = steps_c/7})
		:scrollbar(7.3, 1, 0.2, 4, "vertical", "share_scrlbar")
		:scroll_container(0.25, 1, 7, 4, "share_scrlbar", "vertical")

	local cur_h = 0.25
	for _, member in ipairs(members) do
		local player = core.get_player_by_name(member)

		local member_img = ""
		if player then
			member_img = player:get_properties().textures[1] .. "^[sheet:8x4:1,1"
		end

		fs:image(0.25, cur_h, 1, 1, member_img)
			:label(2.25, cur_h+0.25, member)
			:image_button(5.75, cur_h, 0.5, 0.5, "multidecor_remove_icon.png", "share_remove_" .. member)

		cur_h = cur_h + 1.25
	end

	fs:scroll_container_end()
		:field(1, 5.5, 5, 0.5, "share_add_field",
			common.translator("Enter name of player to add to the group"))
		:button(6, 5.5, 1, 0.5, "share_add_button", "Add")

	return fs:to_string()
end

-- The infotext of a shelf: the lock owner and the share group members.
-- Kept a plain function: it is not a form, it is shown by the door entities
function ShelfFormspec.build_infotext(lock_info)
	local infotext = ""

	if lock_info then
		infotext = common.translator("Owned by ") .. lock_info.owner .. common.translator("\nShare group:\n")

		for _, member in ipairs(lock_info.share) do
			infotext = infotext .. "\t" .. member .. "\n"
		end
	end

	return infotext
end

return ShelfFormspec
