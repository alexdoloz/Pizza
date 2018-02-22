local stringx = require('stringx')
local array2d = require('array2d')
local List = require('List')
local utils = require('utils')

--- Instance methods
local PizzaMT = {}
PizzaMT.__index = PizzaMT

function PizzaMT:__tostring()
  return string.format("L = %d, H = %d\n%s", self.minIngredients, self.maxSize, utils.matrixToString(self.matrix))
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
    maxSize = H,
    minIngredients = L,
    matrix = pizzaMatrix
  }
  setmetatable(pizza, PizzaMT)
  return pizza
end

return Pizza