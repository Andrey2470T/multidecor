multidecor.helpers = {}


-- Returns a direction of the node with 'pos' position
function multidecor.helpers.get_dir(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local dir = def.paramtype2 == "facedir" and vector.copy(minetest.facedir_to_dir(node.param2)) or
			def.paramtype2 == "wallmounted" and vector.copy(minetest.wallmounted_to_dir(node.param2))
	dir = dir*-1

	return dir
end

function multidecor.helpers.clamp(s, e, v)
	local start_v = s
	local end_v = e

	if s > e then
		start_v = e
		end_v = s
	end

	return v < start_v and start_v or v > end_v and end_v or v
end

function multidecor.helpers.upper_first_letters(s)
	local new_s = ""

	for substr in s:gmatch("%a+") do
		new_s = new_s .. substr:sub(1, 1):upper() .. substr:sub(2) .. " "
	end

	return new_s
end

function multidecor.helpers.build_name_from_tmp(name, type, i)
	local res = name .. "_" .. i .. "_".. type

	if not name:match("multidecor:") then
		res = "multidecor:" .. res
	end
	return res
end
