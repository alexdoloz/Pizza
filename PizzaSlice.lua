--[[
  {
    r1: number,
    c1: number,
    r2: number,
    c2: number
    _pizza: Pizza
  }
--]]

--- Instance methods

local PizzaSliceMT = {}

-- Returns width, height
function PizzaSliceMT:dimensions()
  if self == PizzaSlice.EMPTY then 
    return 0, 0
  end
  return self.c2 - self.c1 + 1, self.r2 - self.r1 + 1
end

function PizzaSliceMT:size()
  if self == PizzaSlice.EMPTY then 
    return 0
  end
  return (self.c2 - self.c1 + 1) * (self.r2 - self.r1 + 1)
end

function PizzaSliceMT:containsCell(row, col)
  if self == PizzaSlice.EMPTY then 
    return false
  end
  return self.r1 <= row and row <= self.r2 and self.c1 <= col and col <= self.c2
end

-- экономим на вызове функции
function PizzaSliceMT:intersectsSlices(slices)
  if self == PizzaSlice.EMPTY then return false end
  local r11, r12, c11, c12 = self.r1, self.r2, self.c1, self.c2
  for i = 1, #slices do
    local slice = slices[i]
    if slice == PizzaSlice.EMPTY then goto continue end
    local r21, r22, c21, c22 = slice.r1, slice.r2, slice.c1, slice.c2
    if not (r11 > r22 or r12 < r21 or c11 > c22 or c12 < c21) then
      return true
    end
    ::continue::
  end
  return false
end

function PizzaSliceMT:__tostring()
  if self == PizzaSlice.EMPTY then 
    return "EMPTY"
  end
  local width, height = self:dimensions()
  return string.format("%d %d – %d %d (%d x %d)", self.c1, self.r1, self.c2, self.r2, width, height)
end

PizzaSliceMT.__index = PizzaSliceMT

--- PizzaSlice constructor

local cache = {}
local indexMultiplier = 2000 -- т.к. максимальная размерность задачи – 1000

local PizzaSlice = {}
PizzaSlice.EMPTY = {}
setmetatable(PizzaSlice.EMPTY, PizzaSliceMT)

function PizzaSlice.new(c1, r1, c2, r2)
  assert(r1 <= r2 and c1 <= c2)
  local cacheIndex = r1 + indexMultiplier * c1 + indexMultiplier^2 * r2 + indexMultiplier^3 * c2
  local pizzaSlice = cache[cacheIndex]
  if pizzaSlice then return pizzaSlice end
  pizzaSlice = {
    r1 = r1,
    r2 = r2,
    c1 = c1,
    c2 = c2
  }
  setmetatable(pizzaSlice, PizzaSliceMT)
  cache[cacheIndex] = pizzaSlice
  return pizzaSlice
end

return PizzaSlice