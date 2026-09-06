-- Static bounding box class
------------------------------------------------------

local common = require("decor_api.helpers.common")
local dir_ops = require("decor_api.helpers.dir_ops")

local BBox = {}
BBox.__index = BBox

local function new(x1, y1, z1, x2, y2, z2)
	local self = setmetatable({
		min_edge = vector.new(x1, y1, z1),
		max_edge = vector.new(x2, y2, z2),
		hdir     = vector.new(vector.forward)
	}, BBox)

	self:repair()
	self.dims = self.max_edge - self.min_edge

	return self
end

function BBox.from_default()
	return new(0, 0, 0, 0, 0, 0)
end

function BBox.from_box(box)
	return new(table.unpack(box))
end

function BBox.from_edges(min_edge, max_edge)
	return new(min_edge.x, min_edge.y, min_edge.z, max_edge.x, max_edge.y, max_edge.z)
end

function BBox:width()
	return self.dims.x
end

function BBox:height()
	return self.dims.y
end

function BBox:depth()
	return self.dims.z
end

function BBox:get_coords()
	return {
		self.min_edge.x, self.min_edge.y, self.min_edge.z,
		self.max_edge.x, self.max_edge.y, self.max_edge.z
	}
end

function BBox:repair()
	local e1 = self.min_edge
	local e2 = self.max_edge

	e1.x, e2.x = common.swap(e1.x, e2.x, e1.x > e2.x)
	e1.y, e2.y = common.swap(e1.y, e2.y, e1.y > e2.y)
	e1.z, e2.z = common.swap(e1.z, e2.z, e1.z > e2.z)
end

-- Rotates 'bbox' bounding box vertically (collision or selection) corresponding to 'dir'
function BBox:rotate(dir)
	local orig_min_edge = dir_ops.rotate_to_dir(self.min_edge, -self.hdir)
	local orig_max_edge = dir_ops.rotate_to_dir(self.max_edge, -self.hdir)
	self.min_edge = dir_ops.rotate_to_dir(orig_min_edge, dir)
	self.max_edge = dir_ops.rotate_to_dir(orig_max_edge, dir)

	self.hdir = vector.new(dir)

	self:repair()
end

return BBox