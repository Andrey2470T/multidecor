multidecor.helpers = {}
local helpers = multidecor.helpers

hlpfuncs = helpers

local function zero_vector()
	return vector.new(0, 0, 0)
end

local PARAM2_TO_DIR = {
	facedir = function(param2)
		return minetest.facedir_to_dir(param2)
	end,
	wallmounted = function(param2)
		return minetest.wallmounted_to_dir(param2)
	end,
	colorfacedir = function(param2)
		return minetest.facedir_to_dir(param2 % 32)
	end,
	colorwallmounted = function(param2)
		return minetest.wallmounted_to_dir(param2 % 8)
	end
}

local function get_node_definition(name)
	return name and minetest.registered_nodes[name] or nil
end

local function resolve_direction(name, param2)
	local def = get_node_definition(name)

	if not def then
		return zero_vector()
	end

	local resolver = PARAM2_TO_DIR[def.paramtype2]

	if not resolver then
		return zero_vector()
	end

	local dir = resolver(param2)

	return dir * -1
end

function helpers.get_dir_from_param2(name, param2)
	return resolve_direction(name, param2)
end

function helpers.get_dir(pos)
	local node = minetest.get_node(pos)

	return resolve_direction(node.name, node.param2)
end

function helpers.from_dir_get_param2(name, old_param2, dir)
	local param2 = minetest.dir_to_facedir(dir)
	local def = get_node_definition(name)

	if def and def.paramtype2 == "colorfacedir" then
		local palette_index = math.floor(old_param2 / 32)

		return param2 + palette_index * 32
	end

	return param2
end

function helpers.ndef(pos)
	local node = minetest.get_node(pos)

	return minetest.registered_nodes[node.name]
end

function helpers.rot(pos, angle)
	return vector.rotate_around_axis(pos, vector.new(0, 1, 0), angle)
end

local function is_zero_dir(dir)
	return dir.x == 0 and dir.z == 0
end

function helpers.rotate_to_dir(pos, dir)
	if is_zero_dir(dir) then
		return zero_vector()
	end

	local rot_y = vector.dir_to_rotation(dir).y

	return helpers.rot(pos, rot_y)
end

function helpers.rotate_to_node_dir(pos, rel_pos)
	local dir = helpers.get_dir(pos)

	return helpers.rotate_to_dir(rel_pos, dir)
end

function helpers.rotate_bbox(bbox, dir)
	local min_corner = {x=bbox[1], y=bbox[2], z=bbox[3]}
	local max_corner = {x=bbox[4], y=bbox[5], z=bbox[6]}

	min_corner = helpers.rotate_to_dir(min_corner, dir)
	max_corner = helpers.rotate_to_dir(max_corner, dir)

	return {
		min_corner.x, min_corner.y, min_corner.z,
		max_corner.x, max_corner.y, max_corner.z
	}
end

function helpers.swap(a, b, criteria)
	if criteria == nil or criteria == true then
		return b, a
	end

	return a, b
end

function helpers.clamp(s, e, v)
	local start_v, end_v = helpers.swap(s, e, s > e)

	if v < start_v then
		return start_v
	end

	if v > end_v then
		return end_v
	end

	return v
end

function helpers.upper_first_letters(s)
	local words = {}

	for substr in s:gmatch("%a+") do
		words[#words + 1] = substr:sub(1, 1):upper() .. substr:sub(2)
	end

	if #words == 0 then
		return ""
	end

	return table.concat(words, " ") .. " "
end

local function stringify_position(pos)
	return pos.x .. "_" .. pos.y .. "_" .. pos.z
end

function helpers.build_name_from_tmp(name, entry_type, i, pos)
	local base = name .. "_" .. i .. "_" .. entry_type .. "_" .. stringify_position(pos)

	if name:match("^multidecor:") then
		return base
	end

	return "multidecor:" .. base
end

function table.copy_to(t1, t2)
	for i = 1, #t1 do
		t2[#t2 + 1] = t1[i]
	end
end
