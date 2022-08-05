multidecor.helpers = {}

helpers = multidecor.helpers

-- Returns a direction of the node with 'pos' position
function helpers.get_dir(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local dir = def.paramtype2 == "facedir" and vector.copy(minetest.facedir_to_dir(node.param2)) or
			def.paramtype2 == "wallmounted" and vector.copy(minetest.wallmounted_to_dir(node.param2))
	dir = dir*-1
	return dir
end

function helpers.clamp(s, e, v)
	local start_v = s
	local end_v = e

	if s > e then
		start_v = e
		end_v = s
	end

	return v < start_v and start_v or v > end_v and end_v or v
end
