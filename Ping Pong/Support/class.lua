
local setmetatable, getmetatable = setmetatable, getmetatable
local type, assert, pairs = type, assert, pairs
local tostring, string_format = tostring, string.format
module(...)

local function __NULL__() end
function new(constructor)
	-- check name and constructor
	local name = '<unnamed class>'
	if type(constructor) == "table" then
		if constructor.name then name = constructor.name end
		constructor = constructor[1]
	end
	assert(not constructor or type(constructor) == "function",
		string_format('%s: constructor has to be nil or a function', name))

	-- build class
	local c = {}
	c.__index = c
	c.__tostring = function() return string_format("<instance of %s>", name) end
	c.construct = constructor or __NULL__
	c.Construct = constructor or __NULL__
	c.inherit = inherit
	c.Inherit = inherit

	local meta = {
		__call = function(self, ...)
			local obj = {}
			self.construct(obj, ...)
			return setmetatable(obj, self)
		end,
		__tostring = function() return tostring(name) end
	}

	return setmetatable(c, meta)
end

function inherit(class, interface, ...)
	if not interface then return end

	-- __index and construct are not overwritten as for them class[name] is defined
	for name, func in pairs(interface) do
		if not class[name] and type(func) == "function" then
			class[name] = func
		end
	end

	inherit(class, ...)
end

-- class() as shortcut to class.new()
do
	local m = {}
	m.__call = function(_, ...) return new(...) end
	setmetatable(_M, m)
end
