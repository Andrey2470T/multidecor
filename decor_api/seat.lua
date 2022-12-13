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

local default_on_construct = function(pos)
	minetest.get_meta(pos):set_string("is_busy", "")
end

local default_on_destruct = function(pos)
	multidecor.sitting.standup_player(minetest.get_player_by_name(minetest.get_meta(pos):get_string("is_busy")), pos)
end

local default_on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	local bool = multidecor.sitting.sit_player(clicker, pos)

	if not bool then
		multidecor.sitting.standup_player(clicker, pos)
	end
end

function multidecor.register.register_seat(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "seat"
	def.paramtype2 = "facedir"

	-- additional properties
	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	if def.callbacks then
		def.callbacks.on_construct = def.callbacks.on_construct or default_on_construct
		def.callbacks.on_destruct = def.callbacks.on_destruct or default_on_destruct
		def.callbacks.on_rightclick = def.callbacks.on_rightclick or default_on_rightclick
	else
		def.callbacks = {
			on_construct = default_on_construct,
			on_destruct = default_on_destruct,
			on_rightclick = default_on_rightclick
		}
	end

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if def.add_properties and def.add_properties.connect_parts then
		multidecor.connecting.register_connect_parts(def)
	end
end
