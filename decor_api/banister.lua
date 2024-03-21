multidecor.banister = {}

function multidecor.banister.check_for_foot_node(pos)
	local foot_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

	local stair = minetest.get_item_group(foot_node.name, "stair")
	local spiral = minetest.get_item_group(foot_node.name, "spiral")

	return stair == 1, spiral == 1
end

local function ndef(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name]
end

function multidecor.banister.check_for_free_space(pos, invert_second_cond)
	local node_def = ndef(pos)
	local down_node_def = ndef({x=pos.x, y=pos.y-1, z=pos.z})

	local second_cond = down_node_def.drawtype == "airlike" or
		not down_node_def.walkable

	if invert_second_cond then
		second_cond = not second_cond
	end
	return node_def.drawtype == "airlike" and second_cond
end

local function rotate_vert(dir, sign)
	return vector.rotate_around_axis(dir, vector.new(0, 1, 0), sign*math.pi/2)
end

function multidecor.banister.place_banister(pos, common_name, itemstack)
	local is_stair, is_spiral = multidecor.banister.check_for_foot_node(pos)

	local shape = ""

	if is_stair then
		shape = "raised"
	end

	if is_spiral then
		shape = "spiral"
	end

	local name = "multidecor:" .. common_name .. (shape ~= "" and "_" .. shape or "")

	minetest.remove_node(pos)

	if shape == "" then
		local sides_fdirs_map = {
			["forward"] = {x=1, y=0, z=0},
			["backward"] = {x=-1, y=0, z=0},
			["left"] = {x=0, y=0, z=1},
			["right"] = {x=0, y=0, z=-1}
		}

		local function check_and_set_banister(pos, dir_to_pos, side)
			local bpos = vector.add(pos, dir_to_pos)

			local res1 = multidecor.banister.check_for_free_space(bpos)

			if res1 then
				local fwd_dir = rotate_vert(dir_to_pos, -1)
				local bwd_dir = rotate_vert(dir_to_pos, 1)
				local res2 = multidecor.banister.check_for_free_space(bpos + fwd_dir, true)
				local res3 = multidecor.banister.check_for_free_space(bpos + bwd_dir, true)

				local param2
				local cname = name

				if res2 then
					param2 = minetest.dir_to_facedir(rotate_vert(fwd_dir, 1))
					cname = cname .. "_corner"
				elseif res3 then
					param2 = minetest.dir_to_facedir(fwd_dir)
					cname = cname .. "_corner"
				else
					param2 = minetest.dir_to_facedir(sides_fdirs_map[side])
				end

				minetest.set_node(bpos, {name=cname, param2=param2})
				itemstack:take_item()
			end
		end

		check_and_set_banister(pos, {x=-1, y=0, z=0}, "left")
		check_and_set_banister(pos, {x=1, y=0, z=0}, "right")
		check_and_set_banister(pos, {x=0, y=0, z=1}, "forward")
		check_and_set_banister(pos, {x=0, y=0, z=-1}, "backward")
	elseif shape == "raised" then
		local dir = multidecor.helpers.get_dir({x=pos.x, y=pos.y-1, z=pos.z})*-1
		local dir_to_param2 = minetest.dir_to_facedir(dir)

		local left_pos = pos + rotate_vert(dir, 1)
		local right_pos = pos + rotate_vert(dir, -1)

		if multidecor.banister.check_for_free_space(left_pos) then
			minetest.set_node(left_pos, {name=name.."_left", param2=dir_to_param2})
			itemstack:take_item()
		end

		if multidecor.banister.check_for_free_space(right_pos) then
			minetest.set_node(right_pos, {name=name.."_right", param2=dir_to_param2})
			itemstack:take_item()
		end
		--[[local left_node_def = ndef(left_pos)
		local right_node_def = ndef(right_pos)

		local down_left_node_def = ndef({x=left_pos.x, y=left_pos.y-1, z=left_pos.z})
		local down_right_node_def = ndef({x=right_pos.x, y=right_pos.y-1, z=right_pos.z})

		if left_node_def.drawtype == "airlike" and (down_left_node_def.drawtype == "airlike" or not down_left_node_def.walkable) then
			minetest.set_node(left_pos, {name=name.."_left", param2=dir_to_param2})
			itemstack:take_item()
		end

		if right_node_def.drawtype == "airlike" and (down_right_node_def.drawtype == "airlike" or not down_right_node_def.walkable) then
			minetest.set_node(right_pos, {name=name.."_right", param2=dir_to_param2})
			itemstack:take_item()
		end]]
	elseif shape == "spiral" then
		local dir = multidecor.helpers.get_dir({x=pos.x, y=pos.y-1, z=pos.z})*-1
		local dir_to_param2 = minetest.dir_to_facedir(dir)
		minetest.set_node(pos, {name=name, param2=dir_to_param2})
		itemstack:take_item()
	end

	return itemstack
end

function multidecor.banister.default_after_place_node(pos, placer, itemstack)
	local add_properties = ndef(pos).add_properties

	return multidecor.banister.place_banister(pos, add_properties.common_name, itemstack)
end

function multidecor.register.register_banister(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "banister"
	def.paramtype2 = "facedir"

	-- additional properties
	if add_def then
		if add_def.recipe then
			craft_def = add_def
		else
			def.add_properties = add_def
		end
	end

	def.callbacks = def.callbacks or {}

	def.callbacks.after_place_node = def.callbacks.after_place_node or multidecor.banister.default_after_place_node

	multidecor.register.register_furniture_unit(name, def, craft_def)

	if def.add_properties and def.add_properties.banister_shapes then
		local banister_shapes = def.add_properties.banister_shapes

		local bshape_def = table.copy(def)
		bshape_def.groups = bshape_def.groups or {}
		bshape_def.groups.not_in_creative_inventory = 1

		bshape_def.callbacks.after_place_node = nil

		local function register_banister_shape(shape)
			local shape_def = table.copy(bshape_def)
			shape_def.mesh = banister_shapes[shape].mesh
			shape_def.bounding_boxes = banister_shapes[shape].bboxes
			multidecor.register.register_furniture_unit(name .. "_" .. shape, shape_def)
		end

		register_banister_shape("raised_left")
		register_banister_shape("raised_right")
		register_banister_shape("spiral")
		register_banister_shape("corner")
	end
end
