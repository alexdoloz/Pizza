local stringx = require('stringx')
local array2d = require('array2d')
local List = require('List')

--- Instance methods
local PizzaMT = {}
PizzaMT.__index = PizzaMT

function PizzaMT:__tostring()
  return string.format("L = %d, H = %d\n%s", self.minIngredients, self.maxSize, utils.matrixToString(self.matrix))
end

function PizzaMT:ingredientsCountForSlice(slice)
  if slice == PizzaSlice.EMPTY then return 0, 0 end
  local t, m = 0, 0
  local matrix = self.matrix
  for row = slice.r1, slice.r2 do
  for col = slice.c1, slice.c2 do
    if matrix[row][col] == "T" then
      t = t + 1
    else 
      m = m + 1
    end
  end
  end
  return t, m
end
  

function PizzaMT:isEnoughIngredientsForSlice(slice)
  local t, m = self:ingredientsCountForSlice(slice)
  return t >= self.minIngredients and m >= self.minIngredients
end

function PizzaMT:isSliceValid(slice)
  return self:isEnoughIngredientsForSlice(slice) and slice:size() <= self.maxSize 
end

function PizzaMT:enumerateKernels(callback)
  local min = math.min
  local maxKernelSize = 2 * self.minIngredients
  for rowCount = 1, maxKernelSize do
    local colCount = maxKernelSize // rowCount
    if rowCount * colCount < maxKernelSize then
      goto continue
    end
    local count = 0
    
    for y = 1, self.height - rowCount + 1 do
      for x = 1, self.width - colCount + 1 do
        local slice = PizzaSlice.new(x, y, min(x + colCount - 1, self.width), min(y + rowCount - 1, self.height))
        if self:isSliceValid(slice) then
          count = count + 1
          callback(slice)
        end
      end
    end
    print("Kernels", colCount, rowCount, count)
    ::continue::
  end
end

function PizzaMT:enumerateSliceDimensionsForKernel(kernel, callback)
  local kWidth, kHeight = kernel:dimensions()
  local minSize = 2 * self.minIngredients
  for height = kHeight, self.maxSize do
    for width = math.max(kWidth, math.ceil(minSize / height)), self.maxSize // height do
      callback(width, height)
    end
  end
end

function PizzaMT:enumerateContainerSlicesForKernel(kernel, callback)
  local kWidth, kHeight = kernel:dimensions()
  local min, max = math.min, math.max
  self:enumerateSliceDimensionsForKernel(kernel, function(width, height)
    for row = max(1, kernel.r2 - height + 1), min(self.height - height, kernel.r1) do
      for col = max(1, kernel.c2 - width + 1), min(self.width - width, kernel.c1) do
        local slice = PizzaSlice.new(col, row, col + width - 1, row + height - 1)
        callback(slice)
      end
    end
  end)
end

-- function PizzaMT:allSlices()

function PizzaMT:enumeratePartitions(callback)
  local kernels = List {}
  self:enumerateKernels(function(k) kernels[#kernels + 1] = k end)
  local partition = List {}
  local kernelIndex = 1
  -- local backtracking = false
  -- local slices = {}
  local currentSlicesList = List {}
  local currentSliceIndicesList = List {}
  local availableKernelsList = List { kernels }
  -- local canAddNextKernel
  -- local currentSlices
  -- local currentSliceIndex
  -- local canUpdateSlice
  -- local canBacktrack
  -- local availableKernels
  -- local nextKernel

  ::begin:: do

    if kernelIndex > 10 then return end -- temp

    print("Begin: ", kernelIndex)
    print("Partition is", partition)
    local canAddNextKernel = #availableKernelsList[kernelIndex] >= 2
    if canAddNextKernel then goto next_kernel end
    callback(partition)
    local currentSlices = currentSlicesList[#currentSlicesList]
    local currentSliceIndex = currentSliceIndicesList[#currentSliceIndicesList]
    local canUpdateSlice = currentSliceIndex < #currentSlices
    if canUpdateSlice then goto next_slice end
    local canBacktrack = kernelIndex > 1
    if canBacktrack then goto previous_kernel end
    return
  end

  ::next_kernel:: do
    print("Next kernel")
    local availableKernels = availableKernelsList[kernelIndex]
    local nextKernel = availableKernels[1]
    print("Kernel", nextKernel)
    local slices = {}
    self:enumerateContainerSlicesForKernel(nextKernel, function(s) 
      if not s:intersectsSlices(partition) then
        slices[#slices + 1] = s 
      end
    end)
    slices[#slices + 1] = PizzaSlice.EMPTY
    print("# of slices: ", #slices)
    currentSlicesList[kernelIndex] = slices
    currentSliceIndicesList[kernelIndex] = 1
    partition[kernelIndex] = slices[1]
    kernelIndex = kernelIndex + 1
    print("Available old", availableKernels)
    availableKernelsList[kernelIndex] = availableKernels:filter(function(k) 
      return (not k:intersectsSlices(partition)) and (k ~= nextKernel)
    end)
    print("Available", availableKernelsList[kernelIndex])
    goto begin
  end

  ::next_slice:: do
    print("Next slice")
    local ci = #currentSliceIndicesList
    if currentSliceIndicesList[ci] < #currentSlicesList[ci] then 
      currentSliceIndicesList[ci] = currentSliceIndicesList[ci] + 1
      partition[ci] = currentSlicesList[currentSliceIndicesList[ci]]
    end
    print("Slice index: ", currentSliceIndicesList[ci])
    goto begin
  end

  ::previous_kernel:: do
    print("Previous kernel")
    kernelIndex = kernelIndex - 1
    goto next_slice 
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