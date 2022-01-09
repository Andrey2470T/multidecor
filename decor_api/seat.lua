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

function register.register_seat(name, base_def, seat_def, craft_def)
	local def = table.copy(base_def)
    
	def.type = "seat"
	def.paramtype2 = "facedir"
    
	def.add_properties = {
		seat_data = seat_def
	}
	
	if not def.callbacks then
		def.callbacks = {}
		def.callbacks.on_construct = function(pos)
			minetest.get_meta(pos):set_string("is_busy", "")
		end
		
		def.callbacks.on_destruct = function(pos)
			sitting.standup_player(minetest.get_player_by_name(minetest.get_meta(pos):get_string("is_busy")), pos)
		end
		
		def.callbacks.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local bool = sitting.sit_player(clicker, pos)
			
			if not bool then
				sitting.standup_player(clicker, pos)
			end
		end
	end
	
	register.register_furniture_unit(name, def, craft_def)
end
