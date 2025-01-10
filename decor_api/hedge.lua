multidecor.hedge = {}

function multidecor.hedge.on_construct_dir(pos)
	multidecor.connecting.update_adjacent_nodes_connection(pos, "directional")
end

function multidecor.hedge.after_destruct_dir(pos, oldnode)
	multidecor.connecting.update_adjacent_nodes_connection(pos, "directional", true, oldnode)
end

function multidecor.hedge.on_construct_pair(pos)
	multidecor.connecting.update_adjacent_nodes_connection(pos, "pair")
end

function multidecor.hedge.after_destruct_pair(pos, oldnode)
	multidecor.connecting.update_adjacent_nodes_connection(pos, "pair", true, oldnode)
end


function multidecor.register.register_hedge(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "hedge"
	def.paramtype = "facedir"

	if add_def then
		if add_def.recipe then
			craft_def = table.copy(add_def)
		else
			def.add_properties = table.copy(add_def)
		end
	end

	def.callbacks = def.callbacks or {}

	if add_def.connect_parts then
		def.callbacks.on_construct = def.callbacks.on_construct or multidecor.hedge.on_construct_dir
		def.callbacks.after_dig_node = def.callbacks.after_dig_node or multidecor.hedge.after_destruct_dir
	elseif add_def.double then
		def.callbacks.on_construct = def.callbacks.on_construct or multidecor.hedge.on_construct_pair
	end

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if add_def.connect_parts then
		multidecor.connecting.register_connect_parts(def)
	elseif add_def.double then
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

		if def2.callbacks then
			def2.callbacks.on_construct = nil
			def2.callbacks.after_dig_node = base_def.callbacks and base_def.callbacks.after_dig_node or multidecor.hedge.after_destruct_pair
		end
		multidecor.register.register_furniture_unit(name .. "_double", def2)
	end
end
