-- Formspec is the generic formspec builder:
-- its element methods append one formspec element each and return
-- self, so a whole form reads as a chained element sequence instead of string
-- concatenation. Not bound to any particular API — shelf forms and any
-- future formspecs are built on top of it.
--------------------------------------------------------------------------------

local common = require("decor_api.helpers.common")

-- Formspec
------------------------------------------------------

local Formspec = common.Extendable:extend()

function Formspec.new(version)
	local self = setmetatable({}, Formspec)
	self.parts = {("formspec_version[%d]"):format(version or 4)}
	return self
end

-- Appends a raw preformatted element
function Formspec:raw(el)
	self.parts[#self.parts + 1] = el
	return self
end

function Formspec:size(w, h)
	return self:raw(("size[%f,%f]"):format(w, h))
end

-- 'location' is a list location: "current_player" or "detached:<inv name>"
function Formspec:list(location, listname, x, y, w, h)
	return self:raw(("list[%s;%s;%f,%f;%f,%f;]"):format(location, listname, x, y, w, h))
end

-- The texture may be a modifier string; an empty one leaves an empty slot image
function Formspec:image(x, y, w, h, texture)
	return self:raw(("image[%f,%f;%f,%f;%s]"):format(x, y, w, h, texture))
end

function Formspec:image_button(x, y, w, h, texture, name)
	return self:raw(("image_button[%f,%f;%f,%f;%s;%s;]"):format(x, y, w, h, texture, name))
end

function Formspec:button(x, y, w, h, name, label)
	return self:raw(("button[%f,%f;%f,%f;%s;%s]"):format(x, y, w, h, name, label))
end

function Formspec:tooltip(name, text)
	return self:raw(("tooltip[%s;%s]"):format(name, text))
end

function Formspec:label(x, y, text)
	return self:raw(("label[%f,%f;%s]"):format(x, y, text))
end

function Formspec:field(x, y, w, h, name, label, default)
	return self:raw(("field[%f,%f;%f,%f;%s;%s;%s]"):format(x, y, w, h, name, label, default or ""))
end

function Formspec:textarea(x, y, w, h, name, label, default)
	return self:raw(("textarea[%f,%f;%f,%f;%s;%s;%s]"):format(x, y, w, h, name, label, default or ""))
end

function Formspec:box(x, y, w, h, color)
	return self:raw(("box[%f,%f;%f,%f;%s]"):format(x, y, w, h, color))
end

-- 'props' is a {name = value} table of the style properties
function Formspec:style_type(selector, props)
	local parts = {}
	for name, value in pairs(props) do
		parts[#parts + 1] = name .. "=" .. value
	end

	return self:raw(("style_type[%s;%s]"):format(selector, table.concat(parts, ";")))
end

-- 'opts' is a {name = value} table of the scrollbar options
function Formspec:scrollbaroptions(opts)
	local parts = {}
	for name, value in pairs(opts) do
		parts[#parts + 1] = name .. "=" .. value
	end

	return self:raw("scrollbaroptions[" .. table.concat(parts, ";") .. "]")
end

function Formspec:scrollbar(x, y, w, h, orientation, name)
	return self:raw(("scrollbar[%f,%f;%f,%f;%s;%s;]"):format(x, y, w, h, orientation, name))
end

function Formspec:scroll_container(x, y, w, h, scrollbar_name, orientation)
	return self:raw(("scroll_container[%f,%f;%f,%f;%s;%s]"):format(x, y, w, h, scrollbar_name, orientation))
end

function Formspec:scroll_container_end()
	return self:raw("scroll_container_end[]")
end

function Formspec:to_string()
	return table.concat(self.parts)
end

return Formspec
