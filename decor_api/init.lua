multidecor = {}

-- Module loader
--------------------------------------------------------------------------------
-- Every file of this modpack is loaded with require("<mod>.<subfolder>.<file>")
-- (package-style names: dots are directory separators). The engine's mod
-- security (on by default) disables require() completely and strips
-- package.loaded, so a restricted require is emulated on top of dofile():
-- a module name resolves to <modpath of its mod>/<subfolders>.lua and the
-- returned value is cached in package.loaded like the real require does
-- (a nil return becomes true). Mod security allows reading the files of every
-- installed mod, so the dependent mods use the same global require for
-- decor_api modules (e.g. modern/kitchen.lua). Names that are not a module of
-- an installed mod fall back to the previous require (the engine's
-- "require() is disabled" error under mod security, the real require
-- otherwise).
package = package or {}
package.loaded = package.loaded or {}

local previous_require = require

local function secure_require(name)
	if type(name) ~= "string" or not name:match("^[%w_]+%.[%w_.]+$") then
		-- Not a "<mod>.<path>" module name: not ours to resolve
		return previous_require(name)
	end

	if package.loaded[name] == nil then
		local modname, rel = name:match("^([%w_]+)%.(.+)$")
		local modpath = core.get_modpath(modname)

		if not modpath then
			return previous_require(name)
		end

		-- Pre-register the module (like Lua's require) so circular
		-- dependencies cannot recurse infinitely
		package.loaded[name] = true
		local module = dofile(modpath .. "/" .. rel:gsub("%.", "/") .. ".lua")
		package.loaded[name] = module ~= nil and module or true
	end

	return package.loaded[name]
end

require = secure_require

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
multidecor.AnimatedEntity, multidecor.CyclicEntity, multidecor.EntityTimer =
	animation_t[1], animation_t[2], animation_t[3]
local furniture_t = require("decor_api.common.furniture_entity")
multidecor.FurnitureEntity, multidecor.FurnitureDescriptor, multidecor.FurnitureManager = furniture_t[1], furniture_t[2], furniture_t[3]
multidecor.connecting = require("decor_api.common.connecting")
multidecor.placement = require("decor_api.common.placement")
multidecor.register = require("decor_api.common.register")
multidecor.Formspec = require("decor_api.common.formspec")
multidecor.ShelfFormspec = require("decor_api.common.shelves_formspec")
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
