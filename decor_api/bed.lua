function register.register_bed(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "bed"
	def.paramtype = "facedir"

	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	if def.callbacks then
		def.callbacks.after_destruct = nil
		def.callbacks.after_dig_node = nil
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

		register.register_furniture_unit(name .. "_double", def2)
	end
end
