multidecor.lighting = {}

function multidecor.lighting.on_rightclick(pos)
	local node = minetest.get_node(pos)
	local add_props = minetest.registered_nodes[node.name].add_properties

	if not add_props or not add_props.swap_light then
		return
	end

	minetest.set_node(pos, {name="multidecor:" .. add_props.swap_light.name, param2=node.param2})
	minetest.sound_play({name=add_props.swap_light.sound, gain=0.2}, {
		pos = pos,
		max_hear_distance = 8
	})
end


function multidecor.register.register_light(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "light"
	def.paramtype2 = def.paramtype2 or "facedir"

	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	def.callbacks = def.callbacks or {}
	def.callbacks.on_rightclick = def.callbacks.on_rightclick or multidecor.lighting.on_rightclick

	local sound_off
	local are_props = def.add_properties and def.add_properties.swap_light
	if are_props then
		sound_off = def.add_properties.swap_light.sound_off or "multidecor_light_off"
		def.add_properties.swap_light.sound = def.add_properties.swap_light.sound_on or "multidecor_light_on"
		def.add_properties.swap_light.sound_on = nil
		def.add_properties.swap_light.sound_off = nil
	end

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if are_props then
		local def2 = table.copy(def)
		local swap_light_name = def2.add_properties.swap_light.name
		def2.light_source = def2.add_properties.swap_light.light_level or 8
		def2.drop = "multidecor:" .. name

		if def2.groups then
			def2.groups.not_in_creative_inventory = 1
		else
			def2.groups = {not_in_creative_inventory = 1}
		end
		def2.add_properties.swap_light = {name=name, sound=sound_off}

		multidecor.register.register_furniture_unit(swap_light_name, def2)
	end
end

