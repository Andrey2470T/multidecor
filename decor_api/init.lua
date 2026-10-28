multidecor = {}

local modpath = core.get_modpath("decor_api")

package.path = modpath .. "/?.lua;" .. package.path

-- Helpers
multidecor.BBox = require("decor_api.helpers.box")
multidecor.common = require("decor_api.helpers.common")
multidecor.dir_ops = require("decor_api.helpers.dir_ops")
multidecor.Timer = require("decor_api.helpers.timer")
multidecor.colors = multidecor.common.colors

-- Deprecated legacy alias kept until the OO migration of the modern mod scripts is finished
-- (only modern/*.lua still use it, decor_api itself is require-based)
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
multidecor.connecting = require("decor_api.common.connecting")
multidecor.placement = require("decor_api.common.placement")
multidecor.register = require("decor_api.common.register")
local shelves_t = require("decor_api.common.shelves")
multidecor.Shelf, multidecor.shelves = shelves_t[1], shelves_t[2]
local sitting_t = require("decor_api.common.sitting")
multidecor.SittingEntity, multidecor.sitting = sitting_t[1], sitting_t[2]
multidecor.tools_sounds = require("decor_api.common.tools_sounds")

-- Furniture
multidecor.banister = require("decor_api.furniture.banister")
local clock_t = require("decor_api.furniture.clock")
multidecor.ClockEntity, multidecor.clock = clock_t[1], clock_t[2]
multidecor.curtains = require("decor_api.furniture.curtains")
-- Note: door.lua attaches "register_door" through the "multidecor.register" global,
-- so it must load only after the register module is assigned above
local door_t = require("decor_api.furniture.door")
multidecor.DoorEntity, multidecor.Door, multidecor.doors = door_t[1], door_t[2], door_t[3]
multidecor.bed = require("decor_api.furniture.bed")
multidecor.hanging = require("decor_api.furniture.hanging")
multidecor.hedge = require("decor_api.furniture.hedge")
multidecor.lighting = require("decor_api.furniture.lighting")
-- seat.lua and table.lua only extend "multidecor.register" with register_seat/register_table
require("decor_api.furniture.seat")
require("decor_api.furniture.table")
multidecor.tap = require("decor_api.furniture.tap")
