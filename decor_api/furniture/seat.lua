--[[
	'seat_def' is table:
	{
		pos = <attach position>
		rot = <attach rotation>
		models = {
			[1] = {
				mesh = <filename>,
				anim = {range = <table>, speed = <float>, blend = <bool>, loop = <bool>}
			}
			...
		}
	}
]]

function multidecor.register.register_seat(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "seat"
	def.paramtype2 = def.paramtype2 or "facedir"

	-- additional properties
	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	def.callbacks = def.callbacks or {}

	def.callbacks.on_construct = def.callbacks.on_construct or multidecor.sitting.on_construct
	def.callbacks.on_destruct = def.callbacks.on_destruct or multidecor.sitting.on_destruct
	def.callbacks.on_rightclick = def.callbacks.on_rightclick or multidecor.sitting.on_rightclick

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if def.add_properties and def.add_properties.connect_parts then
		multidecor.connecting.register_connect_parts(def)
	end
end
