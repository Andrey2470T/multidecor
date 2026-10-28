-- Seat registration
--------------------------------------------------------------

local register = require("decor_api.common.register")
local sitting = require("decor_api.common.sitting")[2]
local connecting = require("decor_api.common.connecting")

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

-- Extends the registration API with "register_seat", has no own exports
function register.register_seat(name, base_def, add_def, craft_def)
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

	def.callbacks.on_destruct = def.callbacks.on_destruct or sitting.on_destruct
	def.callbacks.on_rightclick = def.callbacks.on_rightclick or sitting.on_rightclick

	register.register_furniture_unit(name, def, craft_def)

	if def.add_properties and def.add_properties.connect_parts then
		connecting.register_connect_parts(def)
	end
end
