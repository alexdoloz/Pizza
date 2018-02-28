require 'globals'

pizza = Pizza.loadFromFile('data/example.in')
function partitionCoverage(partition)
  local area = 0
  for i = 1, #partition do
    area = area + partition[i]:size()
  end
  return area
end

pizza:enumeratePartitions(function(p)
  pretty.dump(p)
  print("AREA: ", partitionCoverage(p))
  print('--------')
end)