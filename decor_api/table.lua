function register.register_table(name, base_def, add_def, craft_def)
	local c_def = table.copy(base_def)

	c_def.type = "table"

	c_def.add_properties = add_def

	register.register_furniture_unit(name, c_def, craft_def)
end
