multidecor = {}

multidecor.S = core.get_translator("decor_api")

local modpath = core.get_modpath("decor_api")

package.path = modpath .. "/?.lua;" .. package.path

-- Helpers
multidecor.BBox = require("decor_api.helpers.box")
multidecor.common = require("decor_api.helpers.common")
multidecor.dir_ops = require("decor_api.helpers.dir_ops")
multidecor.Timer = require("decor_api.helpers.timer")

-- Common
multidecor.AnimatedEntity, multidecor.CyclicEntity = require("decor_api.common.animation")
multidecor.FurnitureEntity, multidecor.FurnitureDescriptor, multidecor.FurnitureManager = require("decor_api.common.furniture_entity")
dofile(modpath .. "/common/connecting.lua")
dofile(modpath .. "/common/placement.lua")
dofile(modpath .. "/common/register.lua")
dofile(modpath .. "/common/shelves.lua")
dofile(modpath .. "/common/sitting.lua")
dofile(modpath .. "/common/tools_sounds.lua")

-- Furniture
dofile(modpath .. "/furniture/banister.lua")
dofile(modpath .. "/furniture/clock.lua")
dofile(modpath .. "/furniture/curtains.lua")
dofile(modpath .. "/furniture/door.lua")
dofile(modpath .. "/furniture/bed.lua")
dofile(modpath .. "/furniture/hanging.lua")
dofile(modpath .. "/furniture/hedge.lua")
dofile(modpath .. "/furniture/lighting.lua")
dofile(modpath .. "/furniture/seat.lua")
dofile(modpath .. "/furniture/table.lua")
dofile(modpath .. "/furniture/tap.lua")
