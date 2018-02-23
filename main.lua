require 'globals'

pizza = Pizza.loadFromFile('data/medium.in')
sl = PizzaSlice.new(pizza, 1, 1, 3, 2)

count = 0
pizza:findKernels(function(kernel) 
  --print(kernel.r1, kernel.c1, kernel.r2, kernel.c2)
  count = count + 1
end)

print("--- ", count)