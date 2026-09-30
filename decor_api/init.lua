multidecor = {}

multidecor.S = core.get_translator("decor_api")

local modpath = core.get_modpath("decor_api")

package.path = modpath .. "/?.lua;" .. package.path

-- Helpers
multidecor.BBox = require("decor_api.helpers.box")
multidecor.common = require("decor_api.helpers.common")
multidecor.dir_ops = require("decor_api.helpers.dir_ops")
multidecor.Timer = require("decor_api.helpers.timer")

-- Deprecated legacy alias kept until the OO migration of the remaining files is finished
-- (connecting.lua, placement.lua, banister.lua, curtains.lua, hanging.lua, door.lua still use it)
multidecor.helpers = {
	get_dir = multidecor.dir_ops.get_dir,
	get_dir_from_param2 = multidecor.dir_ops.get_dir_from_param2,
	from_dir_get_param2 = multidecor.dir_ops.from_dir_get_param2,
	rotate_to_dir = multidecor.dir_ops.rotate_to_dir,
	rotate_to_node_dir = multidecor.dir_ops.rotate_to_node_dir,
	rot = multidecor.dir_ops.rotate_y,
	rotate_y = multidecor.dir_ops.rotate_y,
	get_rot_y = multidecor.dir_ops.get_rot_y,
	ndef = multidecor.common.ndef,
	clamp = multidecor.common.clamp,
	swap = multidecor.common.swap,
	upper_first_letters = multidecor.common.upper_first_letters,
	build_name_from_tmp = multidecor.common.build_name_from_tmp,
	rotate_bbox = function(box, dir)
		return multidecor.BBox.from_box(box):rotate(dir):get_coords()
	end,
}

-- Common
local animation_t = require("decor_api.common.animation")
multidecor.AnimatedEntity, multidecor.CyclicEntity = animation_t[1], animation_t[2]
local furniture_t = require("decor_api.common.furniture_entity")
multidecor.FurnitureEntity, multidecor.FurnitureDescriptor, multidecor.FurnitureManager = furniture_t[1], furniture_t[2], furniture_t[3]
dofile(modpath .. "/common/connecting.lua")
dofile(modpath .. "/common/placement.lua")
dofile(modpath .. "/common/register.lua")
local shelves_t = require("decor_api.common.shelves")
multidecor.Shelf, multidecor.shelves_api = shelves_t[1], shelves_t[2]
-- Legacy alias: register.lua, door.lua and the modern mod scripts still use it
multidecor.shelves = shelves_t[2]
local sitting_t = require("decor_api.common.sitting")
multidecor.SittingEntity, multidecor.sitting = sitting_t[1], sitting_t[2]
dofile(modpath .. "/common/tools_sounds.lua")

-- Furniture
dofile(modpath .. "/furniture/banister.lua")
dofile(modpath .. "/furniture/clock.lua")
dofile(modpath .. "/furniture/curtains.lua")
local door_t = require("decor_api.furniture.door")
multidecor.DoorEntity, multidecor.Door, multidecor.doors = door_t[1], door_t[2], door_t[3]
dofile(modpath .. "/furniture/bed.lua")
dofile(modpath .. "/furniture/hanging.lua")
dofile(modpath .. "/furniture/hedge.lua")
dofile(modpath .. "/furniture/lighting.lua")
dofile(modpath .. "/furniture/seat.lua")
dofile(modpath .. "/furniture/table.lua")
dofile(modpath .. "/furniture/tap.lua")
