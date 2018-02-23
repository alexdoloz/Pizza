local stringx = require('stringx')
local array2d = require('array2d')
local List = require('List')

--- Instance methods
local PizzaMT = {}
PizzaMT.__index = PizzaMT

function PizzaMT:__tostring()
  return string.format("L = %d, H = %d\n%s", self.minIngredients, self.maxSize, utils.matrixToString(self.matrix))
end

function PizzaMT:findKernels(callback)
  local min = math.min
  local minKernelSize = 2 * self.minIngredients
  for rowCount = 1, minKernelSize do
    if minKernelSize % rowCount ~= 0 then goto continue end
    local colCount = minKernelSize // rowCount
    print("CONF", rowCount, colCount)
    for y = 1, self.height - rowCount + 1 do
      for x = 1, self.width - colCount + 1 do
        local slice = PizzaSlice.new(self, y, x, min(y + rowCount - 1, self.height), min(x + colCount - 1, self.width))
        if slice:isValid() then
          callback(slice)
        end
      end
    end
    -- local tCount, mCount = PizzaSlice.new(self, 1, 1, min(rowCount, self.height), min(colCount, self.width)):ingredientsCount()
    -- print("TM", tCount, mCount)
    -- local direction = 1
    ::continue::
  end
end

--- Pizza constructor
local Pizza = {}

function Pizza.loadFromFile(filename) 
  local file = io.open(filename, 'r')
  local contents = file:read('a')
  local lines = stringx.split(contents, '\n')
  local first = lines[1]
  local rows, cols, L, H = table.unpack(List(stringx.split(first, ' ')):map(tonumber))
  local pizzaMatrix = List(lines):slice(2, rows + 1):map(utils.stringToArray)

  local pizza = {
    width = cols,
    height = rows,
    maxSize = H,
    minIngredients = L,
    matrix = pizzaMatrix
  }
  setmetatable(pizza, PizzaMT)
  return pizza
end

return Pizza