local common = {}

-- Returns a node def of the node at 'pos'
function common.ndef(pos)
	return core.registered_nodes[core.get_node(pos).name]
end

-- Swaps two values if a > b
function common.swap(a, b, criteria)
	if criteria == true or criteria == nil then
		return b, a
	else
		return a, b
	end
end

-- Limits the 'v' value at the range [s, e]. If 'v' < 's', returns 's', 'v' > 'e', returns 'e'
function common.clamp(s, e, v)
	local start_v, end_v = common.swap(s, e, s > e)

	return v < start_v and start_v or v > end_v and end_v or v
end

-- Makes the first letters of each word uppercase in 's' string
function common.upper_first_letters(s)
	local new_s = ""

	for substr in s:gmatch("%a+") do
		new_s = new_s .. substr:sub(1, 1):upper() .. substr:sub(2) .. " "
	end

	return new_s
end

-- Builds a inv/list/fs name in the template 'multidecor:<name>_<i>_<type>_<strpos>'
function common.build_name_from_tmp(name, type, i, pos)
	local resname = ("%s_%d_%s_%d_%d_%d"):format(
		name, i, type, pos.x, pos.y, pos.z)

	if not name:match("multidecor:") then
		resname = "multidecor:" .. resname
	end

	return resname
end

-- Basic colors names
common.colors = {}
common.colors.white = "white"
common.colors.red = "red"
common.colors.blue = "blue"
common.colors.yellow = "yellow"
common.colors.green = "green"
common.colors.cyan = "cyan"
common.colors.magenta = "magenta"
common.colors.grey = "grey"

-- Basic direction vectors
vector.up = vector.new(0, 1, 0)
vector.down = vector.new(0, -1, 0)
vector.left = vector.new(-1, 0, 0)
vector.right = vector.new(1, 0, 0)
vector.forward = vector.new(0, 0, 1)
vector.back = vector.new(0, 0, -1)

-- Finds the full table length including non-integer keys
function table.len(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

-- Shallow copies all elements from 't1' array inserting them in 't2'
function table.copy_arr_to(t1, t2)
	for _, val in ipairs(t1) do
		table.insert(t2, val)
	end
end

-- Shallow copies all key-value pairs from 't1' table to 't2'
function table.copy_to(t1, t2)
	for key, val in pairs(t1) do
		rawset(t2, key, val)
	end
end

return common