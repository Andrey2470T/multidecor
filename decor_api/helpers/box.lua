-- Bounding box class
------------------------------------------------------

local common = require("decor_api.helpers.common")
local dir_ops = require("decor_api.helpers.dir_ops")

local BBox = {
	min_edge = vector.new(),
	max_edge = vector.new()
}

BBox.__index = BBox

function BBox.from_default()
	return setmetatable({}, BBox)
end

function BBox.from_box(box)
	local self = setmetatable({}, BBox)
	self.min_edge = vector.new(box[1], box[2], box[3])
	self.max_edge = vector.new(box[4], box[5], box[6])

	return self
end

function BBox.from_edges(_min_edge, _max_edge)
	local self = setmetatable({}, BBox)
	self.min_edge = _min_edge
	self.max_edge = _max_edge

	return self
end

function BBox:width()
	return self.max_edge.x - self.min_edge.x
end

function BBox:height()
	return self.max_edge.y - self.min_edge.y
end

function BBox:depth()
	return self.max_edge.z - self.min_edge.z
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

-- Rotates 'bbox' bounding box (collision or selection) corresponding to 'dir'
function BBox:rotate(dir)
	self.min_edge = dir_ops.rotate_to_dir(self.min_edge, dir)
	self.max_edge = dir_ops.rotate_to_dir(self.max_edge, dir)
end

return BBox