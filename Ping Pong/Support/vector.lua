
local setmetatable, getmetatable = setmetatable, getmetatable
local type, tonumber = type, tonumber
local sqrt, cos, sin = math.sqrt, math.cos, math.sin
module(...)

local vector = {}
vector.__index = vector

function new(x,y)
	local v = {x = x or 0, y = y or 0}
	return setmetatable(v, vector)
end

function isvector(v)
	return getmetatable(v) == vector
end

function vector:clone()
	return new(self.x, self.y)
end

function vector:unpack()
	return self.x, self.y
end

function vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function vector.__unm(a)
	return new(-a.x, -a.y)
end

function vector.__add(a,b)
	return new(a.x+b.x, a.y+b.y)
end

function vector.__sub(a,b)
	return new(a.x-b.x, a.y-b.y)
end

function vector.__mul(a,b)
	if type(a) == "number" then
		return new(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return new(b*a.x, b*a.y)
	else
		return a.x*b.x + a.y*b.y
	end
end

function vector.__div(a,b)
	return new(a.x / b, a.y / b)
end

function vector.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function vector.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function vector.permul(a,b)
	return new(a.x*b.x, a.y*b.y)
end

function vector:len2()
	return self * self
end

function vector:len()
	return sqrt(self*self)
end

function vector.dist(a, b)
	return (b-a):len()
end

function vector:normalize_inplace()
	local l = self:len()
	self.x, self.y = self.x / l, self.y / l
	return self
end

function vector:normalized()
	return self / self:len()
end

function vector:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function vector:rotated(phi)
	return self:clone():rotate_inplace(phi)
end

function vector:perpendicular()
	return new(-self.y, self.x)
end

function vector:projectOn(v)
	return (self * v) * v / v:len2()
end

function vector:cross(other)
	return self.x * other.y - self.y * other.x
end

-- vector() as shortcut to vector.new()
do
	local m = {}
	m.__call = function(_, ...) return new(...) end
	setmetatable(_M, m)
end
