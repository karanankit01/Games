
local floor = math.floor
local min, max = math.min, math.max
module(..., package.seeall)
local Class = require(_PACKAGE .. 'class')
local vector = require(_PACKAGE .. 'vector')
_M.class = nil
_M.vector = nil

-- special cell accesor metamethods, so vectors are converted
-- to a string before using as keys
local cell_meta = {}
function cell_meta.__newindex(tbl, key, val)
	return rawset(tbl, key.x..","..key.y, val)
end
function cell_meta.__index(tbl, key)
	local key = key.x..","..key.y
	local ret = rawget(tbl, key)
	if not ret then
		ret = setmetatable({}, {__mode = "kv"})
		rawset(tbl, key, ret)
	end
	return ret
end

Spatialhash = Class{name = 'Spatialhash', function(self, cell_size)
	self.cell_size = cell_size or 100
	self.cells = setmetatable({}, cell_meta)
end}

function Spatialhash:cellCoords(v)
	return {x=floor(v.x / self.cell_size), y=floor(v.y / self.cell_size)}
end

function Spatialhash:cell(v)
	return self.cells[ self:cellCoords(v) ]
end

function Spatialhash:insert(obj, ul, lr)
	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			rawset(self.cells[ {x=i,y=k} ], obj, obj)
		end
	end
end

function Spatialhash:remove(obj, ul, lr)
	-- no bbox given. => must check all cells
	if not ul or not lr then
		for _,cell in pairs(self.cells) do
			rawset(cell, obj, nil)
		end
		return
	end

	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	-- else: remove only from bbox
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			rawset(self.cells[{x=i,y=k}], obj, nil)
		end
	end
end

-- update an objects position
function Spatialhash:update(obj, ul_old, lr_old, ul_new, lr_new)
	local ul_old, lr_old = self:cellCoords(ul_old), self:cellCoords(lr_old)
	local ul_new, lr_new = self:cellCoords(ul_new), self:cellCoords(lr_new)

	local xmin, xmax = min(ul_old.x, ul_new.x), max(lr_old.x, lr_new.x)
	local ymin, ymax = min(ul_old.y, ul_new.y), max(lr_old.y, lr_new.y)

	if xmin == xmax and ymin == ymax then return end

	for i = xmin,xmax do
		for k = ymin,ymax do
			local region_old = i >= ul_old.x and i <= lr_old.x and k >= ul_old.y and k <= lr_old.y
			local region_new = i >= ul_new.x and i <= lr_new.x and k >= ul_new.y and k <= lr_new.y
			if region_new and not region_old then
				rawset(self.cells[{x=i,y=k}], obj, obj)
			elseif not region_new and region_old then
				rawset(self.cells[{x=i,y=k}], obj, nil)
			end
		end
	end
end

function Spatialhash:getNeighbors(obj, ul, lr)
	local ul = self:cellCoords(ul)
	local lr = self:cellCoords(lr)
	local set = {}
	for i = ul.x,lr.x do
		for k = ul.y,lr.y do
			local cell = self.cells[{x=i,y=k}] or {}
			for other,_ in pairs(cell) do
				rawset(set, other, other)
			end
		end
	end
	rawset(set, obj, nil)
	return set
end

-- module() as shortcut to module.Spatialhash()
do
	local m = getmetatable(_M)
	m.__call = function(_, ...) return Spatialhash(...) end
end
