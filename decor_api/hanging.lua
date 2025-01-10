multidecor.hanging = {}
multidecor.hanging.hangers = {}

function multidecor.hanging.check_for_up_node(pos, place_part, place_part_cmn_name)
	local def = hlpfuncs.ndef(pos)

	if not def.walkable then
		return false
	end

	if place_part == "top" then
		return true
	end

	if not def.add_properties then
		return false
	end

	if def.add_properties.common_name ~= place_part_cmn_name then
		return false
	end

	return true
end

function multidecor.hanging.define_correct_hanger_parts(pos, cmn_name)
	local up_part = ""
	local part = ""

	local can_be_placed = multidecor.hanging.check_for_up_node(pos, "top", cmn_name)

	if not can_be_placed then
		return up_part, part
	end

	local def = hlpfuncs.ndef(pos)

	if def.groups.hanger_top == 1 or def.groups.hanger_medium == 1 then
		if not multidecor.hanging.hangers[cmn_name].bottom then
			part = "medium"
		else
			part = "bottom"
		end
	elseif def.groups.hanger_bottom == 1 then
		up_part = "medium"

		if not multidecor.hanging.hangers[cmn_name].bottom then
			part = "medium"
		else
			part = "bottom"
		end
	else
		part = "top"
	end

	return up_part, part
end

function multidecor.hanging.after_place_node(pos)
	local node = minetest.get_node(pos)
	local def = hlpfuncs.ndef(pos)

	if not def.add_properties or not def.add_properties.common_name then
		return
	end

	local is_top = def.groups.hanger_top == 1
	local is_medium = def.groups.hanger_medium == 1
	local is_bottom = def.groups.hanger_bottom == 1

	local up_pos = {x=pos.x, y=pos.y+1, z=pos.z}
	local cmn_name = def.add_properties.common_name

	if is_top then
		local up_part, part = multidecor.hanging.define_correct_hanger_parts(up_pos, cmn_name)

		if part == "" then
			minetest.remove_node(pos)
		elseif multidecor.hanging.hangers[cmn_name] then
			if multidecor.hanging.hangers[cmn_name][up_part] then
				minetest.set_node(up_pos, {name=multidecor.hanging.hangers[cmn_name][up_part], param2=node.param2})
			end

			if multidecor.hanging.hangers[cmn_name][part] then
				minetest.set_node(pos, {name=multidecor.hanging.hangers[cmn_name][part], param2=node.param2})
			end
		end
	elseif is_medium or is_bottom then
		local place_part = is_medium and "medium" or "bottom"
		local can_be_placed = multidecor.hanging.check_for_up_node(up_pos, place_part, cmn_name)

		if not can_be_placed then
			minetest.remove_node(pos)
		end
	end
end
