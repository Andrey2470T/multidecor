local default_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local add_props = minetest.registered_nodes[node.name].add_properties

	if not add_props then
		return
	end

	local bed_dir = helpers.get_dir(pos)

	local lpos = add_props.lay_pos1 or {x=0, y=0, z=0}
	lpos = pos + vector.rotate_around_axis(lpos, {x=0, y=1, z=0}, vector.dir_to_rotation(bed_dir).y)

	local lpos2 = add_props.lay_pos2
	lpos2 = lpos2 and pos + vector.rotate_around_axis(lpos2, {x=0, y=1, z=0}, vector.dir_to_rotation(bed_dir).y)

	local is_lpos_fr = true
	local is_lpos2_fr = true

	for _, bpos in pairs(beds.bed_position) do
		if vector.equals(lpos, bpos) then
			is_lpos_fr = false
		elseif lpos2 and vector.equals(lpos2, bpos) then
			is_lpos2_fr = false
		end
	end

	local tpos = is_lpos_fr and lpos or is_lpos2_fr and lpos2

	if not tpos then
		minetest.chat_send_player(clicker:get_player_name(), "This bed is already occupied!")
		return
	end

	beds.on_rightclick(tpos, clicker)

	return itemstack
end

local default_can_dig = function(pos)
	local add_props = minetest.registered_nodes[minetest.get_node(pos).name].add_properties

	if not add_props then
		return
	end

	local bed_dir = helpers.get_dir(pos)

	local lpos = add_props.lay_pos1 or {x=0, y=0, z=0}
	lpos = pos + vector.rotate_around_axis(lpos, {x=0, y=1, z=0}, vector.dir_to_rotation(bed_dir).y)

	return beds.can_dig(lpos)
end

function register.register_bed(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "bed"
	def.paramtype = "facedir"

	if add_def then
		if add_def.recipe then
			craft_def = table.copy(add_def)
		else
			def.add_properties = table.copy(add_def)
		end
	end

	local mtg_bed_def = minetest.registered_nodes["beds:bed_bottom"]
	if def.callbacks then
		def.callbacks.after_destruct = nil
		def.callbacks.after_dig_node = nil
		def.callbacks.on_rightclick = def.callbacks.on_rightclick or default_on_rightclick
		def.callbacks.on_destruct = def.callbacks.on_destruct or mtg_bed_def.on_destruct
		def.callbacks.can_dig = def.callbacks.can_dig or default_can_dig
	else
		def.callbacks = {
			on_rightclick = default_on_rightclick,
			on_destruct = mtg_bed_def.on_destruct,
			can_dig = default_can_dig
		}
	end

	if def.add_properties then
		def.add_properties.lay_pos2 = nil
	end

	register.register_furniture_unit(name, def, craft_def)

	if add_def.double then
		local def2 = table.copy(def)
		def2.description = add_def.double.description
		def2.inventory_image = add_def.double.inv_image
		def2.mesh = add_def.double.mesh
		def2.drop = "multidecor:" .. add_def.common_name

		if def2.groups then
			def2.groups.not_in_creative_inventory = 1
		else
			def2.groups = {not_in_creative_inventory=1}
		end

		if add_def.double.mutable_bounding_box_indices then
			for i=1, #add_def.double.mutable_bounding_box_indices do
				def2.bounding_boxes[i][4] = def2.bounding_boxes[i][4] + 1
			end
		end

		if base_def.callbacks then
			def2.callbacks.on_construct = nil
			def2.callbacks.after_destruct = base_def.callbacks.after_destruct
			def2.callbacks.after_dig_node = base_def.callbacks.after_dig_node
		end

		if def2.add_properties then
			def2.add_properties.lay_pos2 = add_def.lay_pos2
		end
		register.register_furniture_unit(name .. "_double", def2)
	end
end
