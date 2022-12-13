function multidecor.register.register_table(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "table"

	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			c_def.add_properties = add_def
		end
	end

	multidecor.register.register_furniture_unit(name, c_def, craft_def)

	if c_def.add_properties and c_def.add_properties.connect_parts then
		multidecor.connecting.register_connect_parts(c_def)
	end
end
