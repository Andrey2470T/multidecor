multidecor.tap = {}

local mod_channel = core.mod_channel_join("decor_api:tap_on")

function multidecor.tap.is_on(pos)
	return minetest.get_meta(pos):get_string("water_stream_id") ~= ""
end

function multidecor.tap.on_rightclick(pos)
	local tap_on_data = {
		pos = pos,
		force_off = false
	}
	mod_channel:send_all(minetest.serialize(tap_on_data))
end

function multidecor.tap.on_destruct(pos)
	local tap_on_data = {
		pos = pos,
		force_off = true
	}
	mod_channel:send_all(minetest.serialize(tap_on_data))
end

function multidecor.tap.on_timer(pos, elapsed)
	local down_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	local down_node2 = minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z})

	if multidecor.tap.is_on(pos) and
		minetest.get_item_group(down_node.name, "sink") ~= 1 and minetest.get_item_group(down_node2.name, "sink") ~= 1 then

		local tap_on_data = {
			pos = pos,
			force_off = true
		}
	mod_channel:send_all(minetest.serialize(tap_on_data))
	end

	return true
end
