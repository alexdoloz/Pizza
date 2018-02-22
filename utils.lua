local module = {}

function module.stringToArray(s)  
  local chars = {}
  for i = 1, #s do
    chars[#chars + 1] = string.sub(s, i, i)
  end
  return chars
end

function module.matrixToString(matrix, separator)
  separator = separator or " "
  local result = ""
  for _, row in ipairs(matrix) do
    result = result .. table.concat(row, separator) .. "\n"
  end
  return result
end

function module.split(pString, pPattern)
  local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
     if s ~= 1 or cap ~= "" then
    table.insert(Table,cap)
     end
     last_end = e+1
     s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
     cap = pString:sub(last_end)
     table.insert(Table, cap)
  end
  return Table
end


return module