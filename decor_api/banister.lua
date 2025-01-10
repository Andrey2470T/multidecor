multidecor.banister = {}

function multidecor.banister.check_for_foot_node(pos)
	local foot_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

	local stair = minetest.get_item_group(foot_node.name, "stair")
	local spiral = minetest.get_item_group(foot_node.name, "spiral")

	return stair == 1, spiral == 1
end

function multidecor.banister.check_for_free_space(pos, invert_second_cond)
	local node_def = hlpfuncs.ndef(pos)
	local down_node_def = hlpfuncs.ndef({x=pos.x, y=pos.y-1, z=pos.z})

	local second_cond = down_node_def.drawtype == "airlike" or
		not down_node_def.walkable

	if invert_second_cond then
		second_cond = not second_cond
	end
	return node_def.drawtype == "airlike" and second_cond
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
				local fwd_dir = hlpfuncs.rot(dir_to_pos, -math.pi/2)
				local bwd_dir = hlpfuncs.rot(dir_to_pos, math.pi/2)
				local res2 = multidecor.banister.check_for_free_space(bpos + fwd_dir, true)
				local res3 = multidecor.banister.check_for_free_space(bpos + bwd_dir, true)

				local param2
				local cname = name

				if res2 then
					param2 = minetest.dir_to_facedir(hlpfuncs.rot(fwd_dir, math.pi/2))
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
		local dir = hlpfuncs.get_dir({x=pos.x, y=pos.y-1, z=pos.z})*-1
		local dir_to_param2 = minetest.dir_to_facedir(dir)

		local left_pos = pos + hlpfuncs.rot(dir, math.pi/2)
		local right_pos = pos + hlpfuncs.rot(dir, -math.pi/2)

		if multidecor.banister.check_for_free_space(left_pos) then
			minetest.set_node(left_pos, {name=name.."_left", param2=dir_to_param2})
			itemstack:take_item()
		end

		if multidecor.banister.check_for_free_space(right_pos) then
			minetest.set_node(right_pos, {name=name.."_right", param2=dir_to_param2})
			itemstack:take_item()
		end
	elseif shape == "spiral" then
		local dir = hlpfuncs.get_dir({x=pos.x, y=pos.y-1, z=pos.z})*-1
		local dir_to_param2 = minetest.dir_to_facedir(dir)
		minetest.set_node(pos, {name=name, param2=dir_to_param2})
		itemstack:take_item()
	end
end

function multidecor.banister.after_place_node(pos, placer, itemstack)
	local add_properties = hlpfuncs.ndef(pos).add_properties

	multidecor.banister.place_banister(pos, add_properties.common_name, itemstack)
end

function multidecor.register.register_banister(name, base_def, add_def, craft_def)
	local def = table.copy(base_def)

	def.type = "banister"
	def.paramtype2 = "facedir"

	-- additional properties
	if not add_def or not add_def.banister_shapes then
		return
	end

	def.add_properties = add_def
	def.callbacks = def.callbacks or {}
	def.callbacks.after_place_node = def.callbacks.after_place_node or multidecor.banister.after_place_node

	multidecor.register.register_furniture_unit(name, def, craft_def)

	local banister_shapes = def.add_properties.banister_shapes

	local bshape_def = table.copy(def)
	bshape_def.groups = bshape_def.groups or {}
	bshape_def.groups.not_in_creative_inventory = 1
	bshape_def.drop = "multidecor:" .. name

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
