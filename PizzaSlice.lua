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

-- Returns size in format width, height
function PizzaSliceMT:size()
  return self.c2 - self.c1 + 1, self.r2 - self.r1 + 1
end

-- Returns ingredient count (T, M)
function PizzaSliceMT:ingredientsCount()
  local t, m = 0, 0
  local matrix = self._pizza.matrix
  for row = self.r1, self.r2 do
  for col = self.c1, self.c2 do
    if matrix[row][col] == "T" then
      t = t + 1
    else 
      m = m + 1
    end
  end
  end
  return t, m
end

function PizzaSliceMT:isEnoughIngredients()
  local minIngredients = self._pizza.minIngredients
  local t, m = self:ingredientsCount()
  return t >= minIngredients and m >= minIngredients
end

function PizzaSliceMT:isSizeValid()
  local maxSize = self._pizza.maxSize
  local width, height = self:size()
  return width * height <= maxSize
end

function PizzaSliceMT:isValid()
  return self:isEnoughIngredients() and self:isSizeValid()
end

PizzaSliceMT.__index = PizzaSliceMT

--- PizzaSlice constructor

local PizzaSlice = {}

function PizzaSlice.new(pizza, r1, c1, r2, c2)
  local min, max = math.min, math.max
  local pizzaSlice = {
    r1 = min(r1, r2),
    r2 = max(r1, r2),
    c1 = min(c1, c2),
    c2 = max(c1, c2),
    _pizza = pizza
  }
  setmetatable(pizzaSlice, PizzaSliceMT)
  return pizzaSlice
end

return PizzaSlice